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

local NPCServiceUtils = {}

NPCServiceUtils.Data = {
	["OldMan"] = {
		name = "Mysterious Old Man",
		title = "???",
		-- initialNode = "greeting",
		initialNode = function(quests)
			-- local quests = playerData.quests

			if not quests.completed["Cultivate_01"] then
				if quests.active["Cultivate_01"] then
					return quests.active["Cultivate_01"].isCompleted and "q1_claim" or "q1_in_progress"
				else
					return "q1_start"
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
						nextId = nil, -- "q2_start"
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
