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

export type QuestChain = {
	id: string,
	startText: string,
	progressText: string,
	claimText: string,
	nextId: string?,
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

local function createQuestChainNPC(name: string, title: string, questChain: { QuestChain }): NPCConfig
	local dialogues = {}

	for i, quest in questChain do
		local startNode = "q" .. i .. "_start"
		local progressNode = "q" .. i .. "_in_progress"
		local claimNode = "q" .. i .. "_claim"
		local nextStartNode = if i < #questChain then "q" .. (i + 1) .. "_start" else nil

		dialogues[startNode] = {
			text = quest.startText,
			options = {
				{ order = 1, label = "Accept", action = "AcceptQuest", actionParam = quest.id },
				{ order = 2, label = "Maybe later...", nextId = nil },
			},
		}
		dialogues[progressNode] = {
			text = quest.progressText,
			options = { { order = 1, label = "I'm on it.", nextId = nil } },
		}
		dialogues[claimNode] = {
			text = quest.claimText,
			options = {
				{
					order = 1,
					label = "Claim Reward",
					action = "CompleteQuest",
					actionParam = quest.id,
					nextId = nextStartNode,
				},
			},
		}
	end

	dialogues["no_more_quests"] = {
		text = "You have proven your worth. I have nothing left to teach you.",
		options = { { order = 1, label = "Thank you.", nextId = nil } },
	}

	return {
		name = name,
		title = title,
		initialNode = function(quests)
			for i, quest in questChain do
				if not quests.completed[quest.id] then
					if quests.active[quest.id] then
						return quests.active[quest.id].isCompleted and ("q" .. i .. "_claim")
							or ("q" .. i .. "_in_progress")
					else
						return "q" .. i .. "_start"
					end
				end
			end
			return "no_more_quests"
		end,
		dialogues = dialogues,
	}
end

NPCServiceUtils.Data = {
	["???"] = createQuestChainNPC("Mysterious Being", "???", {
		{
			id = "Cultivate_01", -- quest ID
			startText = "You're too weak to take any mission from me. Reach Qi Condensation I first.",
			progressText = "Why are you back? You haven't reached Qi Condensation I yet!",
			claimText = "Not bad. You've reached Qi Condensation I. Here is your reward.",
		},
		{
			id = "Kill_01",
			startText = "Now try to beat 10 slimes.",
			progressText = "Why are you back? You haven't killed 10 Slimes yet!",
			claimText = "Not bad. Here is your reward before doing the next quest, you'll need it.",
		},
		{
			id = "Cultivate_02",
			startText = "Now, Cultivate to Foundation Establishment I to Unlock the Waterfall Area.",
			progressText = "Why are you back? GO CULTIVATE AGAIN!",
			claimText = "Not bad. Here is your reward.",
		},
		{
			id = "Kill_02",
			startText = "Now try to beat 10 goblins.",
			progressText = "Why are you back? You haven't killed 10 Goblins yet!",
			claimText = "Not bad. Here is your reward.",
		},
	}),

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
