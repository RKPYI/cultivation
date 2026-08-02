--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {
	playerRealmData: { [Player]: {
		realmName: string,
		qiReq: BigNum.BN,
	} },
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

-- Setup
function RealmServiceServer.init(self: RealmServiceServer)
	self.playerRealmData = {}

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
	task.spawn(function()
		while not Data[player] and player:IsDescendantOf(Players) do
			task.wait(0.1)
		end

		if not player:IsDescendantOf(Players) then
			return
		end

		self:SetRealmState(player)
		self:UpdateWalkspeed(player)
	end)
end

function RealmServiceServer.OnPlayerRemoving(self: RealmServiceServer, player: Player)
	self.playerRealmData[player] = nil
end

function RealmServiceServer.start(self: RealmServiceServer) end

function RealmServiceServer.Breakthrough(self, player)
	if not Data[player] then
		return
	end

	local playerQi = Data[player].qi()
	local playerRealm = Data[player].realm()
	local qiReq = RealmServiceUtils.CalculateBreakthroughReq(playerRealm)

	if BigNum.gte(playerQi, qiReq) then
		local newPlayerQi = BigNum.sub(playerQi, qiReq)
		Data[player].qi(newPlayerQi)
		Data[player].realm(playerRealm + 1)
		self:SetRealmState(player)
	end
end

function RealmServiceServer.SetRealmState(self, player)
	local playerRealm = Data[player].realm()
	local realmName = RealmServiceUtils.RealmName(playerRealm)
	local qiReq = RealmServiceUtils.CalculateBreakthroughReq(playerRealm)

	self.playerRealmData[player] = { realmName = realmName, qiReq = qiReq }
end

function RealmServiceServer.GetRealmData(self, player)
	local data = self.playerRealmData[player] :: { realmName: string, qiReq: BigNum.BN }
	return data
end

-- SHOULD BE MOVED TO UserInputService or whatever more related to the humanoid
local function recalculateSpeed(player: Player, realm: number)
	local newWalkspeed = 16 + (realm / 2)
	local newSprintspeed = newWalkspeed * 1.5

	Data[player].walkspeed(newWalkspeed)
	Data[player].sprintspeed(newSprintspeed)

	if player.Character then
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			return
		end

		humanoid.WalkSpeed = newWalkspeed

		local baseJumpHeight = 7.2
		if realm > 100 then
			baseJumpHeight = baseJumpHeight * ((realm - 100) + 1)
		end
		humanoid.JumpHeight = baseJumpHeight + (realm / 10)
	end
end

function RealmServiceServer.UpdateWalkspeed(self, player)
	if not Data[player] then
		return
	end

	-- Initializing
	local currentRealm = Data[player].realm()
	recalculateSpeed(player, currentRealm)

	-- Listening to new realm
	Data[player].realm.Changed(function(newRealm)
		recalculateSpeed(player, newRealm)
	end)

	print("Walkspeed Upated: " .. Data[player].walkspeed())
end

return RealmServiceServer
