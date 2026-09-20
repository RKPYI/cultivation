local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local GamepassServiceUtils = require(ReplicatedStorage.Shared.Services.GamepassService.GamepassServiceUtils)
local GamepassButton = require(ReplicatedStorage.UI.components.GamepassButton)
local GamepassDetail = require(ReplicatedStorage.UI.components.GamepassDetail)
local e = React.createElement

local function GamepassShop(props)
	local localPlayer = Players.LocalPlayer
	local ownedPasses, setOwnedPasses = React.useState({} :: { [string]: boolean })
	local selectedPass, setSelectedPass = React.useState(nil :: string?)

	React.useEffect(function()
		task.spawn(function()
			local owned = GamepassServiceUtils.loadPlayerPassesAsync(localPlayer)
			setOwnedPasses(owned)
		end)

		local conn = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
			if player == localPlayer and wasPurchased then
				local passKey = GamepassServiceUtils.getKeyFromId(passId)
				if passKey then
					setOwnedPasses(function(prev)
						local updated = table.clone(prev)
						updated[passKey] = true
						return updated
					end)
				end
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	local shopListChildren = React.useMemo(function()
		local children = {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.02, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				Wraps = true,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			-- UIPadding = e("UIPadding", {
			--     PaddingBottom = UDim.new(0, 5),
			--     PaddingTop = UDim.new(0, 5),
			--     PaddingRight = UDim.new(0, 5),
			--     PaddingLeft = UDim.new(0, 5),
			-- }),
		}

		local layoutOrder = 0
		for passKey, passData in GamepassServiceUtils.Data do
			layoutOrder += 1
			local isOwned = ownedPasses[passKey] or false

			children["Pass_" .. passKey] = e(GamepassButton, {
				key = passKey,
				name = passData.name,
				icon = passData.iconId,
				isSelected = (selectedPass == passKey),
				isOwned = isOwned,
				layoutOrder = layoutOrder,
				onClick = function()
					if selectedPass == passKey then
						setSelectedPass(nil)
					else
						setSelectedPass(passKey)
					end
				end,
			})
		end

		return children
	end, { ownedPasses, selectedPass })

	local activePassData = selectedPass and GamepassServiceUtils.Data[selectedPass]
	local isOwned = selectedPass ~= nil and (ownedPasses[selectedPass] == true)

	local function promptPurchase()
		if activePassData then
			MarketplaceService:PromptGamePassPurchase(localPlayer, activePassData.id)
		end
	end

	return e(React.Fragment, nil, {
		MainShop = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.05, 0.47),
			Size = UDim2.fromScale(0.58, 0.75),
		}, {
			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0.05, 0),
				PaddingTop = UDim.new(0.05, 0),
			}),

			ShopList = e("ScrollingFrame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollBarThickness = 5,
			}, shopListChildren),
		}),

		PassDisplay = e(GamepassDetail, {
			activePassData = activePassData,
			selectedPass = selectedPass,
			isOwned = isOwned,
			onPurchase = promptPurchase,
		}),
	})
end

return GamepassShop
