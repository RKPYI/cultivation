local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client
local Player = Players.LocalPlayer

export type RealmServiceClient = typeof(setmetatable({ __index = {} })) & {
	init: (self: RealmServiceClient) -> (),
	OnPlayerAdded: (self: RealmServiceClient, player: Player) -> (),
	OnPlayerRemoving: (self: RealmServiceClient, player: Player) -> (),

	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local RealmServiceClient = {}

function RealmServiceClient.init(self)
	self.networker = Networker.new("RealmService", RealmServiceClient)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function RealmServiceClient.OnPlayerAdded(self, player: Player) end

function RealmServiceClient.OnPlayerRemoving(self, player: Player) end

return RealmServiceClient
