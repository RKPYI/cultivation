local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local NPCServiceUtils = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceUtils)
local ShopCard = require(ReplicatedStorage.UI.components.ShopCard)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type NPCShopProps = {
	shopId: string,
}

local function NPCShop(props: NPCShopProps)
	local shopId = props.shopId
	local shopItems = NPCServiceUtils.Shops[shopId].items

	local children = {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.01, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}
	for i, item in shopItems do
		children[item] = e(ShopCard, {
			key = item,
			itemId = item,
			layoutOrder = i,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.96, 0.75),
	}, children)
end

return NPCShop
