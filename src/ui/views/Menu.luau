local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local MenuButton = require(ReplicatedStorage.UI.components.MenuButton)
local e = React.createElement

type menuProps = {
	onOpenMenu: (tabName: string) -> (),
}

local function Menu(props: menuProps)
	return e("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0.54),
		Size = UDim2.fromScale(0.12, 0.4),
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.05, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = true,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
		Settings = e(MenuButton, {
			text = "Settings",
			iconImage = "rbxassetid://102114906009290",
			layoutOrder = 0,
			onClick = function()
				props.onOpenMenu("Settings")
			end,
		}),
		Shop = e(MenuButton, {
			text = "Shop",
			iconImage = "rbxassetid://104887644590053",
			layoutOrder = 1,
			onClick = function()
				props.onOpenMenu("Shop")
			end,
		}),
		Inventory = e(MenuButton, {
			text = "Inventory",
			iconImage = "rbxassetid://98519268429528",
			layoutOrder = 2,
			onClick = function()
				props.onOpenMenu("Inventory")
			end,
		}),
	})
end

return Menu
