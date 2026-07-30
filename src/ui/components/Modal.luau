local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local useAnimatedButton = require(ReplicatedStorage.UI.hooks.useAnimatedButton)
local e = React.createElement

type ModalProps = {
	text: string,
	onClose: () -> (),
	children: any?,
}

local function Modal(props: ModalProps)
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

		CloseButton = e("ImageButton", buttonProps, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),

			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			UIScale = e("UIScale", {
				ref = buttonAnim.ref,
			}),
		}),

		ImageLabel = e("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://138496797110912",
			Active = false,
		}),

		Content = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 11,
		}, { Child = props.children }),
	})
end

return Modal
