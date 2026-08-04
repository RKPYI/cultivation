local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local NotificationBadge = require(ReplicatedStorage.UI.components.NotificationBadge)
local Text = require(ReplicatedStorage.UI.components.Text)
local useAnimatedButton = require(ReplicatedStorage.UI.hooks.useAnimatedButton)
local e = React.createElement

type buttonProps = {
	text: string,
	iconImage: string?,
	layoutOrder: number?,
	notificationBadge: boolean?,

	onClick: (() -> ())?,
}

local function MenuButton(props: buttonProps)
	-- local scaleRef = React.useRef(nil)
	local iconImage = props.iconImage or "rbxassetid://102114906009290"
	local layoutOrder = props.layoutOrder or 0

	local buttonAnim = useAnimatedButton({
		hoverScale = 1.1,
		pressScale = 0.95,
		onClick = props.onClick,
	})

	local buttonProps = {
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(0.35, 0.35),
		Image = "rbxassetid://89760829760036",
	}
	for key, value in buttonAnim.events do
		buttonProps[key] = value
	end

	return e("ImageButton", buttonProps, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.1, 0),
		}),
		UIScale = e("UIScale", {
			ref = buttonAnim.ref,
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

		Notification = e(NotificationBadge, {
			visible = props.notificationBadge or false,
		}),
	})
end

return MenuButton
