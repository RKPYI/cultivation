local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type ShortcutProps = {
	Icon: string,
	Description: string,
	Color: Color3,
}

local function Shortcut(props: ShortcutProps)
	return e("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.01, 0.95),
		Size = UDim2.fromScale(0.1, 0.03),
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 6,
		}),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),

		Description = e(Text, {
			pos = UDim2.fromScale(0.4, 0),
			size = UDim2.fromScale(0.5, 1),
			text = props.Description,
		}),

		ShortcutContainer = e("Frame", {
			BackgroundColor3 = props.Color,
			BackgroundTransparency = 0.25,
			Size = UDim2.fromScale(0.3, 1),
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			UIStroke = e("UIStroke", {
				Thickness = 2,
				Transparency = 0.25,
			}),

			Title = e(Text, {
				anchorPoint = Vector2.new(0.5, 0.5),
				pos = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.8, 0.8),
				text = props.Icon,
			}),
		}),
	})
end

return Shortcut
