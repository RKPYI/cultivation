local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {}

export type RealmServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: RealmServiceServer) -> (),
	start: (self: RealmServiceServer) -> (),
	OnPlayerAdded: (self: RealmServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: RealmServiceServer, player: Player) -> (),

	Breakthrough: (self: RealmServiceServer, player: Player) -> (),
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local RealmServiceServer = {} :: RealmServiceServer

-- Setup
function RealmServiceServer.init(self: RealmServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"RealmService",
		self,
		{
			-- Add public network
			self.Breakthrough,
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function RealmServiceServer.OnPlayerAdded(self: RealmServiceServer, player: Player) end

function RealmServiceServer.OnPlayerRemoving(self: RealmServiceServer, player: Player) end

function RealmServiceServer.start(self: RealmServiceServer) end

local function CalculateBreakthrough(realm: number): BigNum.BN
	local baseQi = 10 * (realm ^ 2)

	local realmTier = math.floor((realm - 1) / 10)

	local tierFactor = 12 ^ realmTier

	local isMajorBottleneck = (realm % 10 == 0)
	local bottleneckMult = isMajorBottleneck and 3 or 1.0

	local totalReq = BigNum.mul(baseQi, tierFactor)
	totalReq = BigNum.mul(totalReq, bottleneckMult)

	return totalReq
end

function RealmServiceServer.Breakthrough(self, player)
	if not Data[player] then
		return
	end

	local playerQi = Data[player].qi()
	local playerRealm = Data[player].realm()
	local qiReq = CalculateBreakthrough(playerRealm)

	if BigNum.lt(qiReq, playerQi) then
		local newPlayerQi = BigNum.sub(playerQi, qiReq)
		Data[player].qi(newPlayerQi)
		Data[player].realm(playerRealm + 1)
		print("BREAKTHROUGH SUCCESS!!")
	end
end

return RealmServiceServer
