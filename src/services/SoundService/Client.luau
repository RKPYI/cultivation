local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Data = require(ReplicatedStorage.Shared.Data).client

-- Source: https://create.roblox.com/store/asset/80633624136557/Whispering-Meadows
local AmbientMusic = SoundService:WaitForChild("Whispering Meadows") :: Sound

export type SoundServiceClient = typeof(setmetatable({ __index = {} })) & {
	init: (self: SoundServiceClient) -> (),

	-- ... Add More Functions Here
	MusicSettingListener: (self: SoundServiceClient) -> (),
	PlayBacksound: (self: SoundServiceClient) -> (),
}

local SoundServiceClient = {}

function SoundServiceClient.init(self: SoundServiceClient)
	self:PlayBacksound()
	self:MusicSettingListener()
end

function SoundServiceClient.MusicSettingListener(self: SoundServiceClient)
	Data.settings.music.Changed(function()
		self:PlayBacksound()
	end)
end

function SoundServiceClient.PlayBacksound(self: SoundServiceClient)
	if Data.settings.music() then
		AmbientMusic:Resume()
	else
		AmbientMusic:Pause()
	end
end

return SoundServiceClient
