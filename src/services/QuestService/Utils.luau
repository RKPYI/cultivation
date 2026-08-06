local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
export type QuestType = "ReachRealm" | "TotalKillEnemy" | "KillEnemy" | "GatherHerb"

export type QuestConfig = {
	id: string,
	title: string,
	description: string,
	questType: QuestType,
	targetValue: number | string, -- ID / Realm Level
	targetAmount: number, -- How much mob/herb/realm level to finish the quests
	rewards: {
		spiritualStones: BigNum.BN,
		qiBonus: number?, -- NOT IMPLEMENTED YET

		item: string?,
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
			spiritualStones = BigNum.fromNumber(200),
			item = "book1",
		},
	},

	["Kill_01"] = {
		id = "Kill_01",
		title = "First Enemy",
		description = "Kill Total 10 Slimes to finish the quest.",
		questType = "TotalKillEnemy",
		targetValue = "slime",
		targetAmount = 10,
		rewards = {
			spiritualStones = BigNum.fromNumber(500),
			item = "book2",
		},
	},
	-- Add more quest for hunting, herb collection
} :: { [string]: QuestConfig }

return QuestServiceUtils
