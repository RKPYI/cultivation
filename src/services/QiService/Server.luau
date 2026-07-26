--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
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
	GiveQi: (self: QiServiceServer, player: Player) -> (),
	GetTotalQiGiven: (player: Player) -> BigNum.BN,
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
function QiServiceServer.GiveQi(self: QiServiceServer, player: Player)
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
	local QiAmount = QiServiceServer.GetTotalQiGiven(player)

	Data[player].qi(function(qi: BigNum.BN)
		return BigNum.add(qi, QiAmount)
	end)

	local qi = Data[player].qi() :: BigNum.BN
end

function QiServiceServer.GetTotalQiGiven(player: Player): BigNum.BN
	local BaseQi = BigNum.fromNumber(1)

	local qiRealm = RealmServiceUtils.GetQiBonus(Data[player].realm())

	local TotalQiGiven = BigNum.mul(BaseQi, qiRealm)

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
