local Weapon = {}

export type WeaponConfig = {
	name: string,
	atk: number,
	atkSpd: number,
	realmReq: number,
}

Weapon.Data = {
	["wooden_sword"] = {
		name = "Wooden Sword",
		atk = 1,
		atkSpd = 1,
		realmReq = 1,
		-- image = ""
		-- model = ""
	},
} :: { [string]: WeaponConfig }

return Weapon
