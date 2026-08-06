--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {
	Qi: { [Player]: number },
	GiveQiCooldown: { [Player]: number },

	activeLoops: { [Player]: { [string]: boolean } },
}

export type QiServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: QiServiceServer) -> (),
	start: (self: QiServiceServer) -> (),
	OnPlayerAdded: (self: QiServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: QiServiceServer, player: Player) -> (),

	-- Qi Functions
	StartQiLoop: (self: QiServiceServer, player: Player, zoneName: string) -> (),
	StopQiLoop: (self: QiServiceServer, player: Player, zoneName: string) -> (),
	GiveQi: (self: QiServiceServer, player: Player, zoneName: string) -> (),
	GetTotalQiGiven: (self: QiServiceServer, player: Player, zoneName: string?) -> BigNum.BN,
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local QiServiceServer = {} :: QiServiceServer
local COOLDOWN_DURATION = 0.5

-- Setup
function QiServiceServer.init(self: QiServiceServer)
	self.Qi = {}
	self.GiveQiCooldown = {}
	self.activeLoops = {}

	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"QiService",
		self,
		{
			self.GiveQi,
			self.GetTotalQiGiven,
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function QiServiceServer.OnPlayerAdded(self: QiServiceServer, player: Player)
	self.Qi[player] = 0
	self.GiveQiCooldown[player] = 0
	self.activeLoops[player] = {}
end

function QiServiceServer.OnPlayerRemoving(self: QiServiceServer, player: Player)
	self.Qi[player] = nil
	self.GiveQiCooldown[player] = nil
	self.activeLoops[player] = nil
end

function QiServiceServer.start(self: QiServiceServer)
	ZoneServiceServer.onZoneStateChanged:Connect(function(player: Player, zoneName: string, isInside: boolean)
		if isInside then
			self:StartQiLoop(player, zoneName)
		else
			self:StopQiLoop(player, zoneName)
		end
	end)
end

function QiServiceServer.StartQiLoop(self: QiServiceServer, player: Player, zoneName: string)
	if not self.activeLoops[player] then
		return
	end
	if self.activeLoops[player][zoneName] then
		return
	end

	local zoneConfig = ZoneServiceUtils.Data[zoneName]
	if not zoneConfig then
		return
	end

	self.activeLoops[player][zoneName] = true

	task.spawn(function()
		while self.activeLoops[player] and self.activeLoops[player][zoneName] do
			local playerRealm = Data[player].realm() or 0
			if playerRealm >= zoneConfig.realmReq then
				self:GiveQi(player, zoneName)
			end

			task.wait(COOLDOWN_DURATION)
		end
	end)
end

function QiServiceServer.StopQiLoop(self: QiServiceServer, player: Player, zoneName: string)
	if self.activeLoops[player] then
		self.activeLoops[player][zoneName] = nil
	end
end

-- Qi Functions
function QiServiceServer.GiveQi(self: QiServiceServer, player: Player, zoneName: string)
	if not Data[player] then
		return
	end

	-- Cooldown
	local currentTime, inCooldown = CheckGiveQiCooldown(self.GiveQiCooldown[player])
	if inCooldown then
		return
	end

	self.GiveQiCooldown[player] = currentTime

	-- Giving Qi
	local QiAmount = QiServiceServer:GetTotalQiGiven(player, zoneName)

	Data[player].qi(function(qi: BigNum.BN)
		return BigNum.add(qi, QiAmount)
	end)

	self.networker:set(player, "QiGranted", QiAmount)
end

function QiServiceServer.GetTotalQiGiven(self: QiServiceServer, player: Player, zoneName: string?): BigNum.BN
	local BaseQi = BigNum.fromNumber(1)

	local qiRealm = RealmServiceUtils.GetQiBonus(Data[player].realm())

	local qiZone = 1
	if zoneName and ZoneServiceUtils.Data[zoneName] then
		-- CHECK IF PLAYER ACTUALLY HAS ENOUGH REALM
		local realmReq = ZoneServiceUtils.Data[zoneName].realmReq
		if Data[player].realm() >= realmReq then
			qiZone = ZoneServiceUtils.Data[zoneName].qiMultiplier or 1
		end
	end

	local itemMul = 1
	if Data[player].inventory.itemEquipped() ~= "" then
		local item = Data[player].inventory.itemEquipped()
		local itemData = ItemServiceUtils.Data[item]

		-- Check if item data exist
		if itemData then
			-- Add if player realm is higher than the requirement
			if Data[player].realm() >= itemData.realmReq then
				itemMul = itemData.qiMultiplier
			end
		end
	end

	local TotalQiGiven = BigNum.mul(BaseQi, qiRealm)
	TotalQiGiven = BigNum.mul(TotalQiGiven, qiZone)
	TotalQiGiven = BigNum.mul(TotalQiGiven, itemMul)

	-- #TESTMODE
	if Data.Service.options.useMock then
		print(Data)
		TotalQiGiven = BigNum.mul(TotalQiGiven, BigNum.fromNumber(1e6))
	end

	return TotalQiGiven
end

-- Local functions that can only be used here

--[=[
	@return (currentTime: number, inCooldown: boolean)
]=]
function CheckGiveQiCooldown(lastTime: number): (number, boolean)
	local currentTime = os.clock()

	if currentTime - lastTime < COOLDOWN_DURATION then
		return currentTime, true
	end

	return currentTime, false
end

return QiServiceServer
