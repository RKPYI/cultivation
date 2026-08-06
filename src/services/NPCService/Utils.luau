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
						label = "Of course!!",
						action = "OpenShop",
						actionParam = "JimShop",
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
