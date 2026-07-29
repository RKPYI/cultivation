local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type buttonProps = {
	text: string,
	iconImage: string?,
	layoutOrder: number?,

	onClick: (() -> ())?,
}

local clickSfx = SoundService:WaitForChild("uiClick") :: Sound
local hoverSfx = SoundService:WaitForChild("uiClickHover") :: Sound

-- Helper so multiple sound can be played at once
local function PlaySound(sound: Sound)
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

-- local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local popInInfo = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local popOutInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function MenuButton(props: buttonProps)
	local scaleRef = React.useRef(nil)

	local iconImage = props.iconImage or "rbxassetid://102114906009290"
	local layoutOrder = props.layoutOrder or 0

	local function animateScale(targetScale: number, tweenInfo: TweenInfo)
		local ScaleInstance = scaleRef.current
		if ScaleInstance then
			local tween = TweenService:Create(ScaleInstance, tweenInfo, { Scale = targetScale })
			tween:Play()
		end
	end

	local OnMouseEnter = React.useCallback(function()
		animateScale(1.1, popInInfo)
		PlaySound(hoverSfx)
	end, {})

	local OnMouseLeave = React.useCallback(function()
		animateScale(1, popInInfo)
	end, {})

	local OnMouseDown = React.useCallback(function()
		animateScale(0.95, popOutInfo)
	end, {})

	local OnActivated = React.useCallback(function()
		animateScale(1.1, popOutInfo)

		if props.onClick then
			props.onClick()
		end

		PlaySound(clickSfx)
	end, { props.onClick })

	return e("ImageButton", {
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(0.35, 0.35),
		Image = "rbxassetid://89760829760036",
		[React.Event.MouseEnter] = OnMouseEnter,
		[React.Event.MouseLeave] = OnMouseLeave,
		[React.Event.MouseButton1Down] = OnMouseDown,
		[React.Event.Activated] = OnActivated,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.1, 0),
		}),
		UIScale = e("UIScale", {
			ref = scaleRef,
		}),
		IconImage = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = iconImage,
			Size = UDim2.fromScale(1, 1),
		}),
		Label = e(Text, {
			text = props.text,
			pos = UDim2.fromScale(-0.25, 0.8),
			size = UDim2.fromScale(1.5, 0.4),
		}),
	})
end

return MenuButton
