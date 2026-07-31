local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local BigNum = require(ReplicatedStorage.Shared.BigNum)

local template = {
	qi = BigNum.fromNumber(0),
	realm = 1,
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
		itemEquipped = "",
	},
}

return DataServiceTyped({
	template = template,
})
