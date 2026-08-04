local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local BigNum = require(ReplicatedStorage.Shared.BigNum)

local template = {
	qi = BigNum.fromNumber(0),
	spiritualStones = BigNum.fromNumber(0),
	realm = 1,
	spiritualRoot = "Common",
	rebirth = 0,

	walkspeed = 16,
	sprintspeed = 24,
	settings = {
		music = true,
		sfx = true,
	},

	inventory = {
		item = {
			"book1",
			"book2",
			"book3",
			"book4",
			"book5",
		},
		newItem = false,
		itemEquipped = "",
		weapons = {
			"wooden_sword",
		},
		herbs = {} :: { [string]: number },
	},

	quests = {
		active = {} :: {
			[string]: {
				currentAmount: number,
				targetAmount: number,
				isCompleted: boolean,
			},
		},
		completed = {} :: { [string]: boolean },
	},
}

return DataServiceTyped({
	template = template,
	-- resetData = true,
	useMock = true,
})
