local MarketplaceService = game:GetService("MarketplaceService")
export type GamepassType = "Multiplier" | "Utility"

export type GamepassConfig = {
	id: number,
	name: string,
	description: string,
	iconId: string,
	type: GamepassType,
	multiplier: number?,
}

local GamepassServiceUtils = {}

GamepassServiceUtils.Data = {
	DoubleQi = {
		id = 1981917384, -- Gamepass ID
		name = "2x Qi Multiplier",
		description = "Multiply all qi by 2x",
		iconId = "rbxthumb://type=GamePass&id=1981917384&w=150&h=150",
		type = "Multiplier",
		multiplier = 2,
	},
} :: { [string]: GamepassConfig }

local priceCache: { [number]: number } = {}

function GamepassServiceUtils.getPassPriceAsync(passId: number): number?
	if priceCache[passId] then
		return priceCache[passId]
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(passId, Enum.InfoType.GamePass)
	end)

	if success and result and result.PriceInRobux then
		priceCache[passId] = result.PriceInRobux
		return result.PriceInRobux
	end

	return nil
end

local PassIdToKeyMap: { [number]: string } = {}
for key, config in GamepassServiceUtils.Data do
	PassIdToKeyMap[config.id] = key
end

function GamepassServiceUtils.getKeyFromId(passId: number): string?
	return PassIdToKeyMap[passId]
end

function GamepassServiceUtils.loadPlayerPassesAsync(player: Player): { [string]: boolean }
	local owned: { [string]: boolean } = {}

	for key, config in GamepassServiceUtils.Data do
		local success, ownsPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, config.id)
		end)

		if success and ownsPass then
			owned[key] = true
		end
	end

	return owned
end

function GamepassServiceUtils.getCombinedMultiplier(ownedPasses: { [string]: boolean }, passType: GamepassType): number
	local totalMul = 1
	for key, owned in ownedPasses do
		if owned then
			local config = GamepassServiceUtils.Data[key]
			if config and config.type == passType and config.multiplier then
				totalMul *= config.multiplier
			end
		end
	end
	return totalMul
end

return GamepassServiceUtils
