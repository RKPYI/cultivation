local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type ModalProps = {
	text: string,
	onClose: () -> (),
	children: any?,
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

local popInInfo = TweenInfo.new(0.10, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local popOutInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Modal(props: ModalProps)
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
		PlaySound(hoverSfx)
	end, {})

	local OnMouseLeave = React.useCallback(function()
		animateScale(1, popInInfo)
	end, {})

	local OnMouseDown = React.useCallback(function()
		animateScale(0.8, popOutInfo)
	end, {})

	local OnActivated = React.useCallback(function()
		animateScale(1.1, popOutInfo)

		if props.onClose then
			props.onClose()
		end

		PlaySound(clickSfx)
	end, { props.onClose })

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.6),
		ZIndex = 10,
	}, {
		Text = e(Text, {
			anchorPoint = Vector2.new(0.5, 0.5),
			pos = UDim2.fromScale(0.5, 0),
			size = UDim2.fromScale(0.3, 0.15),
			zIndex = 11,
			thickness = 4,
			text = props.text,
		}),

		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 2,
		}),

		CloseButton = e("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.15, 0.15),
			Image = "rbxassetid://80557352288392",
			ZIndex = 11,
			[React.Event.MouseEnter] = OnMouseEnter,
			[React.Event.MouseLeave] = OnMouseLeave,
			[React.Event.MouseButton1Down] = OnMouseDown,
			[React.Event.Activated] = OnActivated,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),

			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			UIScale = e("UIScale", {
				ref = scaleRef,
			}),
		}),

		ImageLabel = e("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://138496797110912",
		}),

		Content = props.children,
	})
end

return Modal
