local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local GamepassServiceUtils = require(ReplicatedStorage.Shared.Services.GamepassService.GamepassServiceUtils)
local GamepassButton = require(ReplicatedStorage.UI.components.GamepassButton)
local e = React.createElement

local function GamepassShop(props)
    local localPlayer = Players.LocalPlayer
    local ownedPasses, setOwnedPasses = React.useState({} :: { [string]: boolean })
    local passPrices, setPassPrices = React.useState({} :: { [string]: number })

    React.useEffect(function()
        local isMounted = true

        -- Load initial ownership status
        task.spawn(function()
            local owned = GamepassServiceUtils.loadPlayerPassesAsync(localPlayer)
            if isMounted then
                setOwnedPasses(owned or {})
            end
        end)

        -- Load prices asynchronously using GamepassServiceUtils
        task.spawn(function()
            local loadedPrices: { [string]: number } = {}
            for passKey, config in GamepassServiceUtils.Data do
                local price = GamepassServiceUtils.getPassPriceAsync(config.id)
                if price then
                    loadedPrices[passKey] = price
                end
            end
            if isMounted then
                setPassPrices(loadedPrices)
            end
        end)

        -- Listen for completed purchases
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
            isMounted = false
            conn:Disconnect()
        end
    end, {})

    local shopListChildren = React.useMemo(function()
        local children = {
            UIListLayout = e("UIListLayout", {
                Padding = UDim.new(0.05, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                Wraps = true,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        }

        local layoutOrder = 0
        for passKey, passData in GamepassServiceUtils.Data do
            layoutOrder += 1

            children["Pass_" .. passKey] = e(GamepassButton, {
                key = passKey,
                name = passData.name,
                icon = passData.iconId,
                price = passPrices[passKey],
                isOwned = ownedPasses[passKey] == true,
                layoutOrder = layoutOrder,
                onClick = function()
                    if passData.id then
                        MarketplaceService:PromptGamePassPurchase(localPlayer, passData.id)
                    end
                end,
            })
        end

        return children
    end, {ownedPasses, passPrices})

    return e("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.05, 0.47),
        Size = UDim2.fromScale(0.9, 0.75),
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
    })
end

return GamepassShop