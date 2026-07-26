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
	if Data[player] then
		self:SetRealmState(player)
	end
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

return RealmServiceServer
