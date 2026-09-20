local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type GamepassButtonProps = {
	key: string?,
	name: string,
	icon: string,
	isSelected: boolean,
	isOwned: boolean,
	layoutOrder: number,
	onClick: () -> (),
}

local function GamepassButton(props: GamepassButtonProps)
	return e("TextButton", {
		Size = UDim2.fromScale(0.28, 0.35),
		BackgroundColor3 = props.isSelected and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(30, 30, 38),
		BackgroundTransparency = 0.2,
		Text = "",
		LayoutOrder = props.layoutOrder,
		AutoButtonColor = true,
		[React.Event.Activated] = props.onClick,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
		UIStroke = e("UIStroke", {
			Thickness = props.isSelected and 3 or 2,
			Color = props.isSelected and Color3.fromRGB(255, 215, 0)
				or (props.isOwned and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(70, 70, 80)),
		}),

		Icon = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.4),
			Size = UDim2.fromScale(0.7, 0.7),
			Image = props.icon,
			BackgroundTransparency = 1,
		}),

		Title = e(Text, {
			size = UDim2.fromScale(0.9, 0.2),
			pos = UDim2.fromScale(0.5, 0.85),
			anchorPoint = Vector2.new(0.5, 0.5),
			text = props.name,
		}),

		OwnedBadge = props.isOwned and e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(80, 200, 120),
			Position = UDim2.new(1, -4, 0, 4),
			Size = UDim2.fromOffset(20, 20),
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			Check = e(Text, {
				size = UDim2.fromScale(1, 1),
				text = "✓",
			}),
		}),
	})
end

return GamepassButton
