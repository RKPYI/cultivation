--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local GamepassServiceUtils = require(ReplicatedStorage.Shared.Services.GamepassService.GamepassServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {
	playerRealmData: { [Player]: {
		realmName: string,
		qiReq: BigNum.BN,
	} },
	ownedGamepasses: { [Player]: { [string]: boolean } },
}

export type RealmServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: RealmServiceServer) -> (),
	start: (self: RealmServiceServer) -> (),
	OnPlayerAdded: (self: RealmServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: RealmServiceServer, player: Player) -> (),

	Breakthrough: (self: RealmServiceServer, player: Player) -> (),
	SetRealmState: (self: RealmServiceServer, player: Player) -> (),
	GetRealmData: (self: RealmServiceServer, player: Player) -> { realmName: string, qiReq: BigNum.BN },
	UpdateWalkspeed: (self: RealmServiceServer, player: Player) -> (),
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local RealmServiceServer = {} :: RealmServiceServer

-- SHOULD BE MOVED TO UserInputService or whatever more related to the humanoid
local function recalculateSpeed(player: Player, realm: number)
	local newWalkspeed = 16 + (realm / 2)
	local newSprintspeed = newWalkspeed * 1.5
	local baseJumpheight = 7.2
	if realm > 100 then
		baseJumpheight *= (realm - 100) + 1
	end
	local newJumpheight = baseJumpheight + (realm / 10)

	Data[player].walkspeed(newWalkspeed)
	Data[player].sprintspeed(newSprintspeed)
	Data[player].jumpheight(newJumpheight)

	if player.Character then
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			return
		end

		humanoid.WalkSpeed = newWalkspeed
		humanoid.JumpHeight = newJumpheight
	end
end

-- Setup
function RealmServiceServer.init(self: RealmServiceServer)
	self.playerRealmData = {}
	self.ownedGamepasses = {}

	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"RealmService",
		self,
		{
			-- Add public network
			self.Breakthrough,
			self.GetRealmData,
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function RealmServiceServer.OnPlayerAdded(self: RealmServiceServer, player: Player)
	self.ownedGamepasses[player] = {}

	task.spawn(function()
		while not Data[player] and player:IsDescendantOf(Players) do
			task.wait(0.1)
		end

		if not player:IsDescendantOf(Players) then
			return
		end

		-- Load gamepass state
		local owned = GamepassServiceUtils.loadPlayerPassesAsync(player)
		if self.ownedGamepasses[player] then
			self.ownedGamepasses[player] = owned
		end

		-- Listening to new realm
		Data[player].realm.Changed(function(newRealm)
			recalculateSpeed(player, newRealm)
		end)

		-- AUTO BREAKTHROUGH: Triggers whenever Qi changes
		Data[player].qi.Changed(function()
			if self.ownedGamepasses[player] and self.ownedGamepasses[player]["AutoBreakthrough"] then
				task.spawn(function()
					self:Breakthrough(player)
				end)
			end
		end)

		self:SetRealmState(player)
		self:UpdateWalkspeed(player)

		player.CharacterAdded:Connect(function(char)
			local currentRealm = Data[player].realm()
			recalculateSpeed(player, currentRealm)
		end)
	end)
end

function RealmServiceServer.OnPlayerRemoving(self: RealmServiceServer, player: Player)
	self.playerRealmData[player] = nil
	self.ownedGamepasses[player] = nil
end

function RealmServiceServer.start(self: RealmServiceServer)
	-- Listen for dynamic gamepass purchases in-game
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, wasPurchased: boolean)
			if wasPurchased then
				local passKey = GamepassServiceUtils.getKeyFromId(passId)
				if passKey and self.ownedGamepasses[player] then
					self.ownedGamepasses[player][passKey] = true
					
					-- Immediately trigger breakthrough upon purchase if eligible
					if passKey == "AutoBreakthrough" then
						self:Breakthrough(player)
					end
				end
			end
		end
	)

	ZoneServiceServer.onMovementLockedChanged:Connect(function(player: Player, locked: boolean)
		if not player.Character then
			return
		end
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			return
		end

		if locked then
			humanoid.WalkSpeed = 0
			humanoid.JumpHeight = 0
		else
			self:UpdateWalkspeed(player)
		end
	end)
end

function RealmServiceServer.Breakthrough(self: RealmServiceServer, player: Player)
	if not Data[player] then
		return
	end

	local playerQi = Data[player].qi()
	local playerRealm = Data[player].realm()
	local qiReq = RealmServiceUtils.CalculateBreakthroughReq(playerRealm)

	if not BigNum.gte(playerQi, qiReq) then
		return
	end

	local realmsGained = 0
	while BigNum.gte(playerQi, qiReq) do
		playerQi = BigNum.sub(playerQi, qiReq)
		playerRealm += 1
		realmsGained += 1
		qiReq = RealmServiceUtils.CalculateBreakthroughReq(playerRealm)
	end

	-- Update Data once after all math is finished
	if realmsGained > 0 then
		Data[player].realm(playerRealm)
		Data[player].qi(playerQi)
		self:SetRealmState(player)
	end
end

function RealmServiceServer.SetRealmState(self: RealmServiceServer, player: Player)
	local playerRealm = Data[player].realm()
	local realmName = RealmServiceUtils.RealmName(playerRealm)
	local qiReq = RealmServiceUtils.CalculateBreakthroughReq(playerRealm)

	self.playerRealmData[player] = { realmName = realmName, qiReq = qiReq }
end

function RealmServiceServer.GetRealmData(self: RealmServiceServer, player: Player)
	local data = self.playerRealmData[player] :: { realmName: string, qiReq: BigNum.BN }
	return data
end

function RealmServiceServer.UpdateWalkspeed(self: RealmServiceServer, player: Player)
	if not Data[player] then
		return
	end

	-- Initializing
	local currentRealm = Data[player].realm()
	recalculateSpeed(player, currentRealm)

	print("Walkspeed Upated: " .. Data[player].walkspeed())
end

return RealmServiceServer
