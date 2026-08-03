local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundService = game:GetService("SoundService")

local Data = require(ReplicatedStorage.Shared.Data).client
local Sound = {}

local clickSfx = SoundService:WaitForChild("uiClick") :: Sound
local hoverSfx = SoundService:WaitForChild("uiClickHover") :: Sound
local BreakthroughSfx = SoundService:WaitForChild("breakthroughsfx") :: Sound
local acceptQuestSfx = SoundService:WaitForChild("Twinkling SFX noise") :: Sound
local completeQuestSfx = SoundService:WaitForChild("CollectAdjusted") :: Sound

function Sound.play(sound: Sound?)
	if not sound then
		return
	end

	if not Data.settings.sfx() then
		return
	end

	local soundClone = sound:Clone()
	soundClone.Parent = SoundService
	soundClone:Play()
	soundClone.Ended:Once(function()
		soundClone:Destroy()
	end)
end

function Sound.playClick()
	Sound.play(clickSfx)
end

function Sound.playHover()
	Sound.play(hoverSfx)
end

function Sound.playBreakthrough()
	Sound.play(BreakthroughSfx)
end

function Sound.playAcceptQuest()
	Sound.play(acceptQuestSfx)
end

function Sound.playCompleteQuest()
	Sound.play(completeQuestSfx)
end

return Sound
