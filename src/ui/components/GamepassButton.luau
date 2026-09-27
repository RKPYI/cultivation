local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type GamepassButtonProps = {
	key: string?,
	name: string,
	icon: string,
	isSelected: boolean,
	price: number,
	isOwned: boolean,
	layoutOrder: number,
	onClick: () -> (),
}

local function GamepassButton(props: GamepassButtonProps)
	return e("TextButton", {
		Size = UDim2.fromScale(0.2, 1),
		BackgroundColor3 = props.isSelected and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(30, 30, 38),
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = props.layoutOrder,
		AutoButtonColor = true,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),

		Icon = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.25),
			Size = UDim2.fromScale(0.5, 0.5),
			Image = props.icon,
			BackgroundTransparency = 1,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		}),

		Title = e(Text, {
			size = UDim2.fromScale(0.9, 0.2),
			pos = UDim2.fromScale(0.5, 0.6),
			anchorPoint = Vector2.new(0.5, 0.5),
			text = props.name,
		}),

		BuyButton = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = props.isOwned and Color3.fromRGB(55,100,55) or Color3.fromRGB(0, 255, 0),
			Position = UDim2.fromScale(0.5, 0.85),
			Size = UDim2.fromScale(0.66, 0.2),
			Text = "",
			[React.Event.Activated] = props.onClick,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.2, 0)
			}),
			UIPadding = e("UIPadding", {
				PaddingTop = UDim.new(0.1, 0),
				PaddingBottom = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.1, 0),
				PaddingRight = UDim.new(0.1, 0),
			}),
			UIStroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 2,
				Color = Color3.fromRGB(13, 62, 0),
			}),
			Price = e(Text, {
				text =  props.isOwned and "OWNED" or  "\u{E002}".. tostring(props.price or "LOADING")
			}),
		}),

		OwnedBadge = props.isOwned and e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(80, 200, 120),
			Position = UDim2.fromScale(0.7, 0),
			Size = UDim2.fromScale(0.2, 0.2),
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
