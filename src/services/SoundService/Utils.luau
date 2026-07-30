local SoundService = game:GetService("SoundService")
local Sound = {}

local clickSfx = SoundService:WaitForChild("uiClick") :: Sound
local hoverSfx = SoundService:WaitForChild("uiClickHover") :: Sound

function Sound.play(sound: Sound?)
	if not sound then
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

return Sound
