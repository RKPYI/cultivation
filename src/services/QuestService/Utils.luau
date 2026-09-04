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

	["Cultivate_02"] = {
		id = "Cultivate_02",
		title = "Journey Begins (3)",
		description = "Reach Foundation Establishment I to prove your worth.",
		questType = "ReachRealm",
		targetValue = 21,
		targetAmount = 21, -- Always same value for both target value and amount for ReachRealm questType
		rewards = {
			spiritualStones = BigNum.fromNumber(1000),
			item = "book3",
		},
	},

	["Kill_01"] = {
		id = "Kill_01",
		title = "Journey Begins (2)",
		description = "Kill Total 10 Slimes to finish the quest.",
		questType = "TotalKillEnemy",
		targetValue = "slime",
		targetAmount = 10,
		rewards = {
			spiritualStones = BigNum.fromNumber(500),
			item = "book2",
		},
	},

	["Kill_02"] = {
		id = "Kill_02",
		title = "Journey Begins (4)",
		description = "Kill Total 10 Goblins to finish the quest.",
		questType = "TotalKillEnemy",
		targetValue = "goblin",
		targetAmount = 10,
		rewards = {
			spiritualStones = BigNum.fromNumber(1500),
		},
	},

	["Kill_Goblin_Repeatable"] = {
		id = "Kill_Goblin_Repeatable",
		title = "Goblin Outbreak",
		description = "Defeat 10 Goblins terrorizing the forest.",
		questType = "KillEnemy",
		targetValue = "goblin",
		targetAmount = 10,
		rewards = {
			spiritualStones = BigNum.fromNumber(1000),
			-- item = "goblin_ear",
		},
	},
	-- Add more quest for hunting, herb collection
} :: { [string]: QuestConfig }

return QuestServiceUtils
