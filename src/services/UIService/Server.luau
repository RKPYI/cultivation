local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)

type State = {}

export type UIServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: UIServiceServer) -> (),
	start: (self: UIServiceServer) -> (),

	-- Networker
	networker: any,
}

local UIServiceServer = {} :: UIServiceServer

-- Setup
function UIServiceServer.init(self: UIServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"UIService",
		self,
		{
			-- Add public network
		} :: any
	)
end

function UIServiceServer.start(self: UIServiceServer) end

return UIServiceServer
