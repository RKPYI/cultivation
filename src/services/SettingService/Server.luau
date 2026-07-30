--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {}

export type SettingServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: SettingServiceServer) -> (),
	start: (self: SettingServiceServer) -> (),
	OnPlayerAdded: (self: SettingServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: SettingServiceServer, player: Player) -> (),

	toggleSetting: (self: SettingServiceServer, player: Player, settingName: string) -> (),
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local SettingServiceServer = {} :: SettingServiceServer

-- Setup
function SettingServiceServer.init(self: SettingServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"SettingService",
		self,
		{
			-- Add public network
			self.toggleSetting,
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function SettingServiceServer.OnPlayerAdded(self: SettingServiceServer, player: Player) end

function SettingServiceServer.OnPlayerRemoving(self: SettingServiceServer, player: Player) end

function SettingServiceServer.start(self: SettingServiceServer) end

function SettingServiceServer.toggleSetting(self: SettingServiceServer, player: Player, settingName: string)
	if not Data[player] then
		return
	end

	local settingSetter = Data[player].settings[settingName]
	if settingSetter == nil then
		return
	end

	settingSetter(function(sett)
		return not sett
	end)
end

return SettingServiceServer
