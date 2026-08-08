--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)

type State = {}

export type NPCServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: NPCServiceServer) -> (),
	start: (self: NPCServiceServer) -> (),
	OnPlayerAdded: (self: NPCServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: NPCServiceServer, player: Player) -> (),

	-- Networker
	networker: any,
}

local NPCServiceServer = {} :: NPCServiceServer

-- Setup
function NPCServiceServer.init(self: NPCServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"NPCService",
		self,
		{
			-- Add public network
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function NPCServiceServer.OnPlayerAdded(self: NPCServiceServer, player: Player) end

function NPCServiceServer.OnPlayerRemoving(self: NPCServiceServer, player: Player) end

function NPCServiceServer.start(self: NPCServiceServer) end

return NPCServiceServer
