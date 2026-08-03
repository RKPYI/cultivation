export type OptionProps = {
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
						label = "Accept. (Quest: Cultivate to Qi Condensation I)",
						action = "AcceptQuest",
						actionParam = "Cultivate_01",
						nextId = nil,
					},
					{
						label = "...",
						nextId = nil,
					},
				},
			},
			["q1_in_progress"] = {
				text = "Why are you back? you haven't reached Qi Condensation I yet!",
				options = {
					{
						label = "I'm working on it.",
						nextId = nil,
					},
				},
			},
			["q1_claim"] = {
				text = "Not bad. You've reached Qi Condensation I. Here is your reward.",
				options = {
					{
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
						label = "Thank you, elder.",
						nextId = nil,
					},
				},
			},
		},
	} :: NPCConfig,
}

return NPCServiceUtils
