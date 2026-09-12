export type TutorialStepConfig = {
	stepIndex: number,
	title: string,
	description: string,
	highlightArea: string?,
	allowSkip: boolean?,
	nextText: string?,
}

local TutorialServiceUtils = {}

TutorialServiceUtils.Data = {
	[1] = {
		stepIndex = 1,
		title = "Welcome, Cultivator!",
		description = "Welcome to the world. Let's begin by exploring your surroundings.",
		highlightArea = nil,
		allowSkip = true,
		nextText = "Begin >",
	},
	[2] = {
		stepIndex = 2,
		title = "Locate the Cultivation Spot",
		description = "Head over to the glowing Stone to start gathering Qi.",
		highlightArea = "QiArea/Area1",
		allowSkip = true,
		nextText = "Next >",
	},
	[3] = {
		stepIndex = 3,
		title = "Start Cultivating",
		description = "Press (C) to start cultivating. You can only start cultivating in a cultivation area and meets the requirement of the area.",
		highlightArea = "QiArea/Area1",
		allowSkip = true,
		nextText = "Next >",
	},
	[4] = {
		stepIndex = 4,
		title = "Visit the Merchant",
		description = "Find the Shopkeeper beside the waterfall to view available items that help with cultivating.",
		highlightArea = "NPC/Shopkeeper",
		allowSkip = true,
		nextText = "Next >",
	},
	[5] = {
		stepIndex = 5,
		title = "Get a Quest",
		description = "Now its time to start your first quest! talk to the Mysterious Man and start your first quest.",
		highlightArea = "NPC/???",
		allowSkip = true,
		nextText = "Finish",
	},
} :: { [number]: TutorialStepConfig }

TutorialServiceUtils.MAX_STEPS = #TutorialServiceUtils.Data

return TutorialServiceUtils
