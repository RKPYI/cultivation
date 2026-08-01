local Item = {}

export type ItemInfo = {
	name: string,
	image: string,
	realmReq: number,
	qiMultiplier: number,
}

-- DEFAULT IMAGE: "rbxassetid://80557352288392"
Item.Data = {
	book1 = {
		name = "Basic Manual Book",
		image = "rbxassetid://135221951303922",
		realmReq = 1,
		qiMultiplier = 1.1,
	},
	book2 = {
		name = "Qi Condensation Book",
		image = "rbxassetid://125395344678989",
		realmReq = 15,
		qiMultiplier = 1.5,
	},
	book3 = {
		name = "Golden Core Book",
		image = "rbxassetid://119645128928800",
		realmReq = 35,
		qiMultiplier = 1.75,
	},
	book4 = {
		name = "Soul Formation Book",
		image = "rbxassetid://117849238997175",
		realmReq = 55,
		qiMultiplier = 2,
	},
	book5 = {
		name = "Body Integration Book",
		image = "rbxassetid://134161933386968",
		realmReq = 75,
		qiMultiplier = 3,
	},
} :: { [string]: ItemInfo }

return Item
