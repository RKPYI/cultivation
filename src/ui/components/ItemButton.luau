local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type ItemButtonProps = {
	icon: string,
	name: string,
	isSelected: boolean,
	isEquipped: boolean,
	meetsRealmReq: boolean,
	layoutOrder: number,

	onClick: () -> (),
}

local function ItemButton(props: ItemButtonProps)
	local icon = props.icon or "rbxassetid://80557352288392"
	return e("Frame", {
		BackgroundColor3 = if props.isEquipped
			then Color3.fromRGB(0, 255, 0)
			elseif props.meetsRealmReq then Color3.fromRGB(0, 0, 255)
			else Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 0.5,
		Size = UDim2.fromScale(0.08, 1),
		LayoutOrder = props.layoutOrder,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0.05, 0),
			PaddingTop = UDim.new(0.05, 0),
			PaddingRight = UDim.new(0.05, 0),
			PaddingLeft = UDim.new(0.05, 0),
		}),
		UIStroke = e("UIStroke", {
			Thickness = 3,
			Color = if props.isSelected and props.isEquipped
				then Color3.fromRGB(0, 255, 255)
				elseif props.isSelected then Color3.fromRGB(0, 0, 255)
				elseif props.isEquipped then Color3.fromRGB(0, 255, 0)
				else Color3.fromRGB(0, 0, 0),
		}),

		IconButton = e("ImageButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = icon,
			ScaleType = Enum.ScaleType.Fit,
			[React.Event.Activated] = props.onClick,
		}, {
			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0.1, 0),
				PaddingTop = UDim.new(0.1, 0),
				PaddingRight = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.1, 0),
			}),
		}),
	})
end

return ItemButton
