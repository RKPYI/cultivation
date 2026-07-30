local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client

local networker = nil
local SettingServiceClient = {}
SettingServiceClient.OnQiGranted = Signal.new()

function SettingServiceClient.init(self)
	networker = Networker.new("SettingService", SettingServiceClient)
end

function SettingServiceClient.toggleSetting(self, settingName: string)
	networker:fire("toggleSetting", settingName)
end

return SettingServiceClient
