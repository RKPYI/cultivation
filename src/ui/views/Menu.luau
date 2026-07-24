local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

type MenuProps = {
	Text: string,
	Color: Color3,
	Position: UDim2,
}

local e = React.createElement
local function Menu(props: MenuProps)
	return e("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = props.Color,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),

		UIStroke = e("UIStroke", {
			Thickness = 4,
		}),

		Text = e("TextLabel", {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = props.Text,
		}),
	})
end

return Menu
