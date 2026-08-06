local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Enemy = {}

export type EnemyConfig = {
	id: string,
	name: string,
	realm: number,
	maxHealth: number,
	respawnTime: number,

	drops: {
		spiritualStone: BigNum.BN,
	}?,
}

Enemy.Data = {
	["slime"] = {
		id = "slime",
		name = "Slime",
		realm = 3,
		maxHealth = 3,
		respawnTime = 10,

		drops = {
			spiritualStone = BigNum.fromNumber(10),
		},
	},
	["rat"] = {
		id = "rat",
		name = "Rat",
		realm = 5,
		maxHealth = 10,
		respawnTime = 10,
	},
} :: { [string]: EnemyConfig }

function Enemy.GiveDrops(enemyId)
	local EnemyData = Enemy.Data[enemyId]
	local EnemyDrop = EnemyData.drops or { spiritualStone = BigNum.fromNumber(0) }

	-- If a drop is not guaranteed, the function to give the drop/not can be put here and return the variable
	-- for now its just simple return

	return EnemyDrop
end

return Enemy
