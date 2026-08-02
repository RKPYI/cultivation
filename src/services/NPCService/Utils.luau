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
	initialNode: string,
	dialogues: { [string]: DialogueNode },
}

local NPCServiceUtils = {}

NPCServiceUtils.Data = {
	["OldMan"] = {
		name = "Mysterious Old Man",
		title = "???",
		initialNode = "greeting",
		dialogues = {
			["greeting"] = {
				text = "You're too weak to take any mission from me. Get stronger first.",
				options = {
					{
						label = "Ok. (Quest: Cultivate to Qi Condensation I)",
						action = "AcceptQuest",
						actionParam = "Cultivate_01",
						nextId = "quest_accepted",
					},
					{
						label = "...",
						nextId = nil,
					},
				},
			},

			["quest_accepted"] = {
				text = "... Return once you get stronger, I'll reward you something.",
				options = {
					{ label = "I will return soon.", nextId = nil },
				},
			},
		},
	} :: NPCConfig,
}

return NPCServiceUtils
