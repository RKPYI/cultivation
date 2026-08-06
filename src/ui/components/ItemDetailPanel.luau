local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type DisplayPanelProps = {
	activeItemData: ItemServiceUtils.ItemInfo?,
	selectedItem: string?,
	isEquipped: boolean,
	playerRealm: number,
	toggleEquip: () -> (),
}

local function ItemDisplayPanel(props: DisplayPanelProps)
	local activeItemData = props.activeItemData
	local selectedItem = props.selectedItem
	local isEquipped = props.isEquipped
	local playerRealm = props.playerRealm
	local toggleEquip = props.toggleEquip

	if not selectedItem or not activeItemData then
		return nil
	end

	local meetsRealmReq = playerRealm >= activeItemData.realmReq
	local statusColor = if isEquipped
		then Color3.fromRGB(0, 255, 0)
		elseif meetsRealmReq then Color3.fromRGB(0, 0, 255)
		else Color3.fromRGB(255, 0, 0)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 203, 129),
		Position = UDim2.fromScale(1.16, 0.5),
		Size = UDim2.fromScale(0.3, 0.85),
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
			BackgroundColor3 = statusColor,
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
				text = "Req: " .. (activeItemData and RealmServiceUtils.RealmName(activeItemData.realmReq) or "None"),
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
	})
end

return ItemDisplayPanel
