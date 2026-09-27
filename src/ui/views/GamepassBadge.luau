local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local GamepassServiceUtils = require(ReplicatedStorage.Shared.Services.GamepassService.GamepassServiceUtils)
local Icon = require(ReplicatedStorage.UI.components.Icon)
local e = React.createElement

local function GamepassBadge()
    local localPlayer = Players.LocalPlayer
    local ownedPasses, setOwnedPasses = React.useState({} :: { [string]: boolean })

    React.useEffect(function()
        local isMounted = true

        task.spawn(function()
            local owned = GamepassServiceUtils.loadPlayerPassesAsync(localPlayer)
            if isMounted then
                setOwnedPasses(owned or {})
            end
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
            isMounted = false
            conn:Disconnect()
        end
    end, {})

    local children = {
        UIListLayout = e("UIListLayout", {
            Padding = UDim.new(0, 5),
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        }),
    }

    local layoutOrder = 0
    for passKey, isOwned in ownedPasses do
        if isOwned then
            local passData = GamepassServiceUtils.Data[passKey]
            if passData then
                layoutOrder += 1
                children["Badge_" .. passKey] = e(Icon, {
                    key = passKey,
                    img = passData.iconId,
                    layoutOrder = layoutOrder,
                })
            end
        end
    end

    return e("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.49, 0, 0.95, -15),
        Size = UDim2.new(0.5, 0, 0.05, 10),
    }, children)
end

return GamepassBadge