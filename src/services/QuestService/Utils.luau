export type QuestType = "ReachRealm" | "KillMob" | "GatherHerb"

export type QuestConfig = {
	id: string,
	title: string,
	description: string,
	questType: QuestType,
	targetValue: number | string, -- ID / Realm Level
	targetAmount: number, -- How much mob/herb/realm level to finish the quests
	rewards: {
		spiritualStones: number,
		qiBonus: number?,
		-- Add more here idk what else though
	},
}

export type Quests = {}

local QuestServiceUtils = {}

QuestServiceUtils.Data = {
	["Cultivate_01"] = {
		id = "Cultivate_01",
		title = "Journey Begins",
		description = "Reach Qi Condensation I to prove your worth.",
		questType = "ReachRealm",
		targetValue = 11,
		targetAmount = 11, -- Always same value for both target value and amount for ReachRealm questType
		rewards = {
			spiritualStones = 200,
		},
	},

	-- Add more quest for hunting, herb collection
} :: { [string]: QuestConfig }

return QuestServiceUtils
