local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ItemServiceClient = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceClient)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).client
local ItemButton = require(ReplicatedStorage.UI.components.ItemButton)
local ItemDetailPanel = require(ReplicatedStorage.UI.components.ItemDetailPanel)
local e = React.createElement

local function Inventory()
	local items, setItems = React.useState({})
	local selectedItem, setSelectedItem = React.useState(nil :: string?)
	local equippedItem, setEquippedItem = React.useState(Data.inventory.itemEquipped() or "")
	local playerRealm, setPlayerRealm = React.useState(Data.realm() or 1)

	React.useEffect(function()
		local initialItems = Data.inventory.item() or {}
		setItems(initialItems)

		local itemsConn = Data.inventory.item.Changed(function(newItem: { string })
			setItems(newItem)
		end)

		local equippedConn = Data.inventory.itemEquipped.Changed(function(newEquipped)
			setEquippedItem(newEquipped or "")
		end)

		local realmConn = Data.realm.Changed(function(newRealm)
			setPlayerRealm(newRealm)
		end)

		return function()
			itemsConn()
			equippedConn()
			realmConn()
		end
	end, {})

	local inventoryListChildren = React.useMemo(function()
		local children = {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.02, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				Wraps = true,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
			}),
		}

		for i, itemName in items do
			local itemData = ItemServiceUtils.Data[itemName]

			if itemData then
				local isItemEquipped = (itemName == equippedItem)
				local realmMet = playerRealm >= itemData.realmReq

				local layoutOrder = if isItemEquipped then 1 else (1 + i)

				children["Item_" .. itemName .. "_" .. i] = e(ItemButton, {
					key = itemName .. "_" .. i,
					name = itemData.name,
					icon = itemData.image,
					isSelected = (selectedItem == itemName),
					isEquipped = isItemEquipped,
					meetsRealmReq = realmMet,
					layoutOrder = layoutOrder,
					onClick = function()
						-- If same item clicked twice, it gets closed
						if selectedItem == itemName then
							setSelectedItem(nil)
						else
							setSelectedItem(itemName)
						end
					end,
				})
			end
		end

		return children
	end, { items, selectedItem, equippedItem, playerRealm })

	local activeItemData = selectedItem and ItemServiceUtils.Data[selectedItem]
	local isEquipped = (selectedItem ~= nil and selectedItem == equippedItem)

	local function toggleEquip()
		ItemServiceClient:ToggleEquipItem(selectedItem)
	end

	return e(React.Fragment, nil, {
		MainInventory = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.47),
			Size = UDim2.fromScale(0.95, 0.75),
		}, {
			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0.05, 0),
				PaddingTop = UDim.new(0.05, 0),
			}),

			InventoryList = e("ScrollingFrame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollBarThickness = 5,
			}, inventoryListChildren),
		}),

		ItemDisplay = e(ItemDetailPanel, {
			activeItemData = activeItemData,
			selectedItem = selectedItem,
			isEquipped = isEquipped,
			playerRealm = playerRealm,
			toggleEquip = toggleEquip,
		}),
	})
end

return Inventory
