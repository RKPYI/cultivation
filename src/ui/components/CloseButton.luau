local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useAnimatedButton = require(ReplicatedStorage.UI.hooks.useAnimatedButton)
local e = React.createElement

type CloseButtonProps = {
	onClose: () -> (),
}

local function CloseButton(props: CloseButtonProps)
	local buttonAnim = useAnimatedButton({
		hoverScale = 1.1,
		pressScale = 0.8,
		onClick = props.onClose,
	})

	local buttonProps = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.15, 0.15),
		Image = "rbxassetid://80557352288392",
		ZIndex = 11,
	}
	for key, value in buttonAnim.events do
		buttonProps[key] = value
	end

	return e("ImageButton", buttonProps, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),

		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),

		UIScale = e("UIScale", {
			ref = buttonAnim.ref,
		}),
	})
end

return CloseButton
