local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ItemServiceClient = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceClient)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).client
local ItemButton = require(ReplicatedStorage.UI.components.ItemButton)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

local function Inventory(props)
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
	end, { selectedItem })

	local inventoryListChildren = {
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

			inventoryListChildren["Item_" .. itemName .. "_" .. i] = e(ItemButton, {
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

	local activeItemData = selectedItem and ItemServiceUtils.Data[selectedItem]
	local isEquipped = (selectedItem ~= nil and selectedItem == equippedItem)
	local meetsRealmReq = false

	if activeItemData then
		meetsRealmReq = playerRealm >= activeItemData.realmReq
	end

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

		-- (All Data should be sent by the ItemButton)
		ItemDisplay = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 203, 129),
			Position = UDim2.fromScale(1.16, 0.5),
			Size = UDim2.fromScale(0.3, 0.85),
			Visible = (selectedItem ~= nil and activeItemData ~= nil),
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.1, 0),
			}),

			UIStroke = e("UIStroke", {
				Thickness = 3,
			}),

			-- Display Icon
			ItemIcon = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = if isEquipped
					then Color3.fromRGB(0, 255, 0)
					elseif meetsRealmReq then Color3.fromRGB(0, 0, 255)
					else Color3.fromRGB(255, 0, 0),
				BackgroundTransparency = 0.5,
				Position = UDim2.fromScale(0.5, 0.25),
				Size = UDim2.fromScale(0.5, 0.5),
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
				}),

				IconImg = e("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = activeItemData and activeItemData.image, -- Get Image from ItemButton
					ScaleType = Enum.ScaleType.Fit,
				}),
			}),

			-- Item Data
			ItemData = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 0.3),
			}, {
				UIListLayout = e("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				UIPadding = e("UIPadding", {
					PaddingLeft = UDim.new(0.1, 0),
					PaddingRight = UDim.new(0.1, 0),
				}),

				ItemName = e(Text, {
					text = activeItemData and activeItemData.name or selectedItem or "",
					size = UDim2.fromScale(1, 0.3),
					layoutOrder = 0,
				}),

				ReqRealm = e(Text, {
					text = "Req: "
						.. (activeItemData and RealmServiceUtils.RealmName(activeItemData.realmReq) or "None"),
					textColor3 = if meetsRealmReq then Color3.fromRGB(130, 200, 255) else Color3.fromRGB(255, 107, 109),
					size = UDim2.fromScale(1, 0.3),
					layoutOrder = 1,
				}),

				QiMult = e(Text, {
					text = "Qi Multiplier: " .. (activeItemData and activeItemData.qiMultiplier or "1") .. "x",
					textColor3 = Color3.fromRGB(85, 255, 127),
					size = UDim2.fromScale(1, 0.3),
					layoutOrder = 2,
				}),
			}),

			-- Buttons to Equip/Unequip & Delete
			Button = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0.8),
				Size = UDim2.fromScale(1, 0.1),
			}, {
				UIPadding = e("UIPadding", {
					PaddingLeft = UDim.new(0.1, 0),
					PaddingRight = UDim.new(0.1, 0),
				}),

				ToggleEquip = e("TextButton", {
					BackgroundColor3 = if isEquipped then Color3.fromRGB(255, 107, 109) else Color3.fromRGB(0, 255, 0),
					Size = UDim2.fromScale(0.45, 1),
					Font = Enum.Font.GothamBlack,
					Text = if isEquipped then "Unequip" else "Equip",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					[React.Event.Activated] = toggleEquip,
				}, {
					UICorner = e("UICorner", {
						CornerRadius = UDim.new(0.25, 0),
					}),
					UIPadding = e("UIPadding", {
						PaddingBottom = UDim.new(0.1, 0),
						PaddingTop = UDim.new(0.1, 0),
						PaddingRight = UDim.new(0.1, 0),
						PaddingLeft = UDim.new(0.1, 0),
					}),
					UIStroke = e("UIStroke", {
						Thickness = 2,
					}),
					UIStrokeOuter = e("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
					}),
				}),

				-- Add functionality to actually delete the item
				-- Low Priority: Add Confirm Modal before actually deleting it
				DeleteBtn = e("TextButton", {
					BackgroundColor3 = Color3.fromRGB(255, 0, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0.45, 1),
					Font = Enum.Font.GothamBlack,
					Text = "Delete [WIP]",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
				}, {
					UICorner = e("UICorner", {
						CornerRadius = UDim.new(0.25, 0),
					}),
					UIPadding = e("UIPadding", {
						PaddingBottom = UDim.new(0.1, 0),
						PaddingTop = UDim.new(0.1, 0),
						PaddingRight = UDim.new(0.1, 0),
						PaddingLeft = UDim.new(0.1, 0),
					}),
					UIStroke = e("UIStroke", {
						Thickness = 2,
					}),
					UIStrokeOuter = e("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
					}),
				}),
			}),
		}),
	})
end

return Inventory
