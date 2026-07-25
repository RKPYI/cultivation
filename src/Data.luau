local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local BigNum = require(ReplicatedStorage.Shared.BigNum)

local template = {
	qi = BigNum.fromNumber(0),
	realm = 1,
	settings = {
		music = true,
		sfx = true,
	},
}

return DataServiceTyped({
	template = template,
})
