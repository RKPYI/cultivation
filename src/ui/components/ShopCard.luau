local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local ItemServiceClient = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceClient)
local Data = require(ReplicatedStorage.Shared.Data).client
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local SoundServiceUtils = require(ReplicatedStorage.Shared.Services.SoundService.SoundServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type ShopCardProps = {
	itemId: string,
	layoutOrder: number,
}

local function ShopCard(props: ShopCardProps)
	local info = ItemServiceUtils.Data[props.itemId]
	local haveItem, setHaveItem = React.useState(table.find(Data.inventory.item(), props.itemId) ~= nil)
	local canAfford, setCanAfford = React.useState(BigNum.gte(Data.spiritualStones(), info.price or 0))
	local meetsRealm, setMeetsRealm = React.useState(Data.realm() >= info.realmReq)
	local canBuy = canAfford and meetsRealm and not haveItem

	local statBoosts = {}
	if info.qiMultiplier then
		table.insert(statBoosts, "Qi: x" .. info.qiMultiplier)
	end
	if info.dmgMultiplier then
		table.insert(statBoosts, "Dmg: x" .. info.dmgMultiplier)
	end

	local function onBuy(itemId)
		ItemServiceClient:NPCShopBuyItem(itemId)
	end

	local function buyText()
		if haveItem then
			return "OWNED"
		elseif canBuy then
			return "BUY"
		elseif meetsRealm then
			return "TOO EXPENSIVE"
		else
			return "LOCKED"
		end
	end

	React.useEffect(function()
		local spiritStoneConn = Data.spiritualStones.Changed(function(newStoneAmount)
			setCanAfford(BigNum.gte(newStoneAmount, info.price or 0))
		end)
		local realmConn = Data.realm.Changed(function(newRealm)
			setMeetsRealm(newRealm >= info.realmReq)
		end)
		local itemConn = Data.inventory.item.Changed(function(newItems)
			setHaveItem(table.find(newItems, props.itemId) ~= nil)
		end)

		return function()
			spiritStoneConn()
			realmConn()
			itemConn()
		end
	end, {})

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.19, 1),
		LayoutOrder = props.layoutOrder,
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		topFrame = e("Frame", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(0, 170, 0),
			Size = UDim2.fromScale(1, 0.4),
			Transparency = 0.5,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.1, 0),
			}),
			UIStroke = e("UIStroke", {
				Thickness = 2,
			}),

			ItemImage = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.65),
				Size = UDim2.fromScale(0.5, 1),
				Image = info.image, -- SHOULD BE DYNAMIC TO THE ITEM IMAGE DATA
				ScaleType = Enum.ScaleType.Fit,
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
			}),

			ItemName = e(Text, {
				anchorPoint = Vector2.new(0.5, 0.5),
				pos = UDim2.fromScale(0.5, 0.15),
				size = UDim2.fromScale(0.9, 0.25),
				text = info.name, -- SHOULD BE DYNAMIC TO THE ITEM NAME DATA
			}),
		}),

		bottomFrame = e("Frame", {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(0, 85, 0),
			Size = UDim2.fromScale(1, 0.58),
			Transparency = 0.5,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.1, 0),
			}),
			UIStroke = e("UIStroke", {
				Thickness = 2,
			}),
			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0.05, 0),
				PaddingTop = UDim.new(0.05, 0),
				PaddingLeft = UDim.new(0.02, 0),
				PaddingRight = UDim.new(0.02, 0),
			}),
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.04, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			CostFrame = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.9, 0.15),
				LayoutOrder = 1,
			}, {
				CurrencyImage = e("ImageLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.8, 0),
					Size = UDim2.fromScale(1, 1),
					Image = "rbxassetid://115065742501490", -- WILL BE STATIC FOR NOW
					ScaleType = Enum.ScaleType.Fit,
				}, {
					UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				}),

				PriceLabel = e(Text, {
					anchorPoint = Vector2.new(0.5, 0.5),
					pos = UDim2.fromScale(0.5, 0.5),
					text = "Cost: " .. BigNum.toSuffix(info.price), -- SHOULD BE DYNAMIC TO THE ITEM PRICE DATA
					textXAlignment = Enum.TextXAlignment.Left,
				}),
			}),

			RealmReq = e(Text, {
				anchorPoint = Vector2.new(0.5, 0.5),
				size = UDim2.fromScale(0.9, 0.2),
				textColor3 = if meetsRealm then Color3.fromRGB(130, 200, 255) else Color3.fromRGB(255, 107, 109),
				text = "Req: " .. RealmServiceUtils.RealmName(info.realmReq), -- SHOULD  BE DYNAMIC TO THE ITEM REALM REQ
				layoutOrder = 2,
			}),

			Data = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.9, 0.35),
				LayoutOrder = 3,
			}, {
				UIListLayout = e("UIListLayout"),

				-- MAX 2 STAT BOOST (FOR NOW)
				boost1 = statBoosts[1] and e(Text, {
					anchorPoint = Vector2.new(0.5, 0.5),
					size = UDim2.fromScale(1, 0.4),
					textColor3 = Color3.fromRGB(85, 255, 127),
					text = statBoosts[1], -- SHOULD BE DYNAMIC TO THE ITEM BOOSTED STAT
				}),
				boost2 = statBoosts[2] and e(Text, {
					anchorPoint = Vector2.new(0.5, 0.5),
					size = UDim2.fromScale(1, 0.4),
					textColor3 = Color3.fromRGB(255, 161, 85),
					text = statBoosts[2], -- SHOULD BE DYNAMIC TO THE ITEM BOOSTED STAT
				}),
			}),

			BuyButton = e("TextButton", {
				BackgroundColor3 = canBuy and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(150, 150, 150), -- DYNAMIC ON WHETHER THE PLAYER CAN BUY OR NOT
				Size = UDim2.fromScale(0.7, 0.15),
				LayoutOrder = 4,
				Font = Enum.Font.GothamBlack,
				Text = buyText(),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				[React.Event.MouseEnter] = function()
					SoundServiceUtils.playHover()
				end,
				[React.Event.Activated] = function()
					SoundServiceUtils.playClick()
					if canBuy then
						onBuy(props.itemId)
						SoundServiceUtils.playCompleteQuest()
					end
				end,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0.25, 0),
				}),
				UIPadding = e("UIPadding", {
					PaddingBottom = UDim.new(0.1, 0),
					PaddingTop = UDim.new(0.1, 0),
					PaddingLeft = UDim.new(0.1, 0),
					PaddingRight = UDim.new(0.1, 0),
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

return ShopCard
