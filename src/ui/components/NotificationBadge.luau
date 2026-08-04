local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type NotificationProps = {
	visible: boolean,
}

local function NotificationBadge(props: NotificationProps)
	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.35, 1),
		Text = "",
		Visible = props.visible,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		UIStroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 2,
		}),
	})
end

return NotificationBadge
