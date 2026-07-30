local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local SoundServiceUtils = require(ReplicatedStorage.Shared.Services.SoundService.SoundServiceUtils)
local popInInfo = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local popOutInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

type ButtonConfig = {
	hoverScale: number?,
	pressScale: number?,
	onClick: (() -> ())?,
}

local function useAnimatedButton(config: ButtonConfig)
	local hoverScale = config.hoverScale or 1.1
	local pressScale = config.pressScale or 0.95
	local onClick = config.onClick

	local scaleRef = React.useRef(nil)

	local function animateScale(targetScale: number, tweenInfo: TweenInfo)
		local ScaleInstance = scaleRef.current
		if ScaleInstance then
			local tween = TweenService:Create(ScaleInstance, tweenInfo, { Scale = targetScale })
			tween:Play()
		end
	end

	local OnMouseEnter = React.useCallback(function()
		animateScale(1.1, popInInfo)
		SoundServiceUtils.playHover()
	end, {})

	local OnMouseLeave = React.useCallback(function()
		animateScale(1, popInInfo)
	end, {})

	local OnMouseDown = React.useCallback(function()
		animateScale(pressScale, popOutInfo)
	end, {})

	local OnActivated = React.useCallback(function()
		animateScale(hoverScale, popOutInfo)

		if config.onClick then
			config.onClick()
		end

		SoundServiceUtils.playClick()
	end, { config.onClick }) -- hoverScale

	return {
		ref = scaleRef,
		events = {
			[React.Event.MouseEnter] = OnMouseEnter,
			[React.Event.MouseLeave] = OnMouseLeave,
			[React.Event.MouseButton1Down] = OnMouseDown,
			[React.Event.Activated] = OnActivated,
		},
	}
end

return useAnimatedButton
