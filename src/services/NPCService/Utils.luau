local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
export type OptionProps = {
	order: number,
	label: string,
	nextId: string?,
	action: string?,
	actionParam: string?,
}

export type DialogueNode = {
	text: string,
	options: { OptionProps },
}

export type NPCConfig = {
	name: string,
	title: string,
	initialNode: string | (quests: any) -> string,
	dialogues: { [string]: DialogueNode },
}

export type QuestMarkState = "Available" | "Claimable" | "InProgress" | "None"

export type Shop = {
	shopName: string,
	background: string,
	items: { string },
}

local NPCServiceUtils = {}

function NPCServiceUtils.getNPCQuestState(npcConfig: NPCConfig, questData): QuestMarkState
	if not questData or type(npcConfig.initialNode) ~= "function" then
		return "None"
	end

	local node = npcConfig.initialNode(questData)

	if node:find("_start") then
		return "Available"
	elseif node:find("_claim") then
		return "Claimable"
	elseif node:find("_in_progress") then
		return "InProgress"
	end

	return "None"
end

function NPCServiceUtils.getNPCQuestMarkVisibility(npcConfig: NPCConfig, questData)
	local state = NPCServiceUtils.getNPCQuestState(npcConfig, questData)

	return {
		showExclamation = (state == "Available"),
		showQuestion = (state == "Claimable" or state == "InProgress"),
		questionColor = if state == "Claimable" then Color3.fromRGB(255, 215, 0) else Color3.fromRGB(130, 130, 130),
		exclamationColor = Color3.fromRGB(255, 255, 255),
	}
end

function NPCServiceUtils.getShopItems(shopId: string)
	local shopConfig = NPCServiceUtils.Shops[shopId]
	if not shopConfig then
		return {}
	end

	local resolvedItems = {}
	for _, itemId in shopConfig.items do
		local info = ItemServiceUtils.Data[itemId]
		if info then
			table.insert(resolvedItems, {
				id = itemId,
				info = info,
			})
		end
	end

	return resolvedItems
end

NPCServiceUtils.Shops = {
	JimShop = {
		shopName = "Jim's Scroll Shop",
		background = "rbxassetid://98309507803049",
		items = { "scroll1", "scroll2", "scroll3", "scroll4", "scroll5" },
	},
} :: { [string]: Shop }

NPCServiceUtils.Data = {
	["???"] = {
		name = "Mysterious Being",
		title = "???",
		initialNode = function(quests)
			if not quests.completed["Cultivate_01"] then
				if quests.active["Cultivate_01"] then
					return quests.active["Cultivate_01"].isCompleted and "q1_claim" or "q1_in_progress"
				else
					return "q1_start"
				end
			end

			if not quests.completed["Kill_01"] then
				if quests.active["Kill_01"] then
					return quests.active["Kill_01"].isCompleted and "q2_claim" or "q2_in_progress"
				else
					return "q2_start"
				end
			end

			if not quests.completed["Cultivate_02"] then
				if quests.active["Cultivate_02"] then
					return quests.active["Cultivate_02"].isCompleted and "q3_claim" or "q3_in_progress"
				else
					return "q3_start"
				end
			end

			return "no_more_quests"
		end,

		dialogues = {
			["q1_start"] = {
				text = "You're too weak to take any mission from me. Reach Qi Condensation I first.",
				options = {
					{
						order = 1,
						label = "Accept.",
						action = "AcceptQuest",
						actionParam = "Cultivate_01",
						nextId = nil,
					},
					{
						order = 2,
						label = "Maybe later...",
						nextId = nil,
					},
				},
			},
			["q1_in_progress"] = {
				text = "Why are you back? you haven't reached Qi Condensation I yet!",
				options = {
					{
						order = 1,
						label = "I'm on it.",
						nextId = nil,
					},
				},
			},
			["q1_claim"] = {
				text = "Not bad. You've reached Qi Condensation I. Here is your reward.",
				options = {
					{
						order = 1,
						label = "Claim Reward",
						action = "CompleteQuest",
						actionParam = "Cultivate_01",
						nextId = "q2_start", -- "q2_start"
					},
				},
			},

			["q2_start"] = {
				text = "Now try to beat 10 slimes.",
				options = {
					{
						order = 1,
						label = "Okay.",
						action = "AcceptQuest",
						actionParam = "Kill_01",
						nextId = nil,
					},
					{
						order = 2,
						label = "Maybe later.",
						nextId = nil,
					},
				},
			},
			["q2_in_progress"] = {
				text = "Why are you back? you haven't kill 10 Slimes yet!",
				options = {
					{
						order = 1,
						label = "I'm on it.",
						nextId = nil,
					},
				},
			},
			["q2_claim"] = {
				text = "Not bad. Here is your reward before doing the next quest, you'll need it.",
				options = {
					{
						order = 1,
						label = "Claim Reward",
						action = "CompleteQuest",
						actionParam = "Kill_01",
						nextId = "q3_start",
					},
				},
			},

			["q3_start"] = {
				text = "Now, Cultivate to Foundation Establishment I to Unlock the Waterfall Cultivation Area (2x Boost).",
				options = {
					{
						order = 1,
						label = "Okay.",
						action = "AcceptQuest",
						actionParam = "Cultivate_02",
						nextId = nil,
					},
					{
						order = 2,
						label = "Maybe later.",
						nextId = nil,
					},
				},
			},
			["q3_in_progress"] = {
				text = "Why are you back? GO CULTIVATE AGAIN!",
				options = {
					{
						order = 1,
						label = "I'm on it.",
						nextId = nil,
					},
				},
			},
			["q3_claim"] = {
				text = "Not bad. Here is your reward.",
				options = {
					{
						order = 1,
						label = "Claim Reward",
						action = "CompleteQuest",
						actionParam = "Cultivate_02",
						nextId = nil,
					},
				},
			},

			["no_more_quests"] = {
				text = "You have proven your worth. I have nothing left to teach you.",
				options = {
					{
						order = 1,
						label = "Thank you, Elder.",
						nextId = nil,
					},
				},
			},
		},
	} :: NPCConfig,

	["GoblinSlayer"] = {
		name = "The Goblin Hater",
		title = "Goblin Slayer",
		initialNode = function(quests)
			if quests.active["Kill_Goblin_Repeatable"] then
				return quests.active["Kill_Goblin_Repeatable"].isCompleted and "goblin_claim" or "goblin_in_progress"
			end

			-- Always available because its repeatable
			return "goblin_start"
		end,

		dialogues = {
			["goblin_start"] = {
				text = "The goblins are attacking our supply routes again! Eliminate 10 Goblins and I will make it worth your while.",
				options = {
					{
						order = 1,
						label = "Accept Hunt (Kill 10 Goblins)",
						action = "AcceptQuest",
						actionParam = "Kill_Goblin_Repeatable",
						nextId = nil,
					},
					{
						order = 2,
						label = "I am not ready.",
						nextId = nil,
					},
				},
			},
			["goblin_in_progress"] = {
				text = "What are you doing here? There are still goblins lurking outside!",
				options = {
					{
						order = 1,
						label = "On my way!",
						nextId = nil,
					},
				},
			},
			["goblin_claim"] = {
				text = "Outstanding work! You've thinned their ranks. Take your reward, and report back if you want to hunt more.",
				options = {
					{
						order = 1,
						label = "Claim Reward",
						action = "CompleteRepeatableQuest", --CompleteRepeatableQuest
						actionParam = "Kill_Goblin_Repeatable",
						nextId = nil,
					},
				},
			},
		},
	} :: NPCConfig,

	["Shopkeeper"] = {
		name = "Jim",
		title = "Shopkeeper",
		initialNode = "greeting",

		dialogues = {
			["greeting"] = {
				text = "New guy? Im selling a quality item here, take a look!",
				options = {
					{
						order = 1,
						label = "Open Shop.",
						action = "OpenShop",
						actionParam = "JimShop",
						nextId = nil,
					},
					{
						order = 2,
						label = "Nah",
						nextId = nil,
					},
				},
			},
		},
	},

	["RanDK"] = {
		name = "RanDK",
		title = "Creator",
		initialNode = "greeting",

		dialogues = {
			["greeting"] = {
				text = "Yo! Welcome to the Game, Hope you enjoys it ;D.",
				options = {
					{
						order = 1,
						label = "Of course!!",
						nextId = nil,
					},
					{
						order = 2,
						label = "Hell nah",
						nextId = nil,
					},
				},
			},
		},
	},
}

return NPCServiceUtils
