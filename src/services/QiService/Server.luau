--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {
	Qi: { [Player]: number },
	GiveQiCooldown: { [Player]: number },
}

export type QiServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: QiServiceServer) -> (),
	start: (self: QiServiceServer) -> (),
	OnPlayerAdded: (self: QiServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: QiServiceServer, player: Player) -> (),

	-- Qi Functions
	GiveQi: (self: QiServiceServer, player: Player, zoneName: string) -> (),
	GetTotalQiGiven: (self: QiServiceServer, player: Player, zoneName: string?) -> BigNum.BN,
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local QiServiceServer = {} :: QiServiceServer
local COOLDOWN_DURATION = 1

-- Setup
function QiServiceServer.init(self: QiServiceServer)
	self.Qi = {}
	self.GiveQiCooldown = {}

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
end

function QiServiceServer.OnPlayerRemoving(self: QiServiceServer, player: Player)
	self.Qi[player] = nil
	self.GiveQiCooldown[player] = nil
end

function QiServiceServer.start(self: QiServiceServer) end

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
