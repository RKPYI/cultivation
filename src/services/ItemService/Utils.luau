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
		image = "rbxassetid://80557352288392",
		realmReq = 1,
		qiMultiplier = 1.1,
	},
	book2 = {
		name = "Qi Condensation Book",
		image = "rbxassetid://80557352288392",
		realmReq = 15,
		qiMultiplier = 1.5,
	},
	book3 = {
		name = "Golden Core Book",
		image = "rbxassetid://80557352288392",
		realmReq = 35,
		qiMultiplier = 1.75,
	},
	book4 = {
		name = "Soul Formation Book",
		image = "rbxassetid://80557352288392",
		realmReq = 55,
		qiMultiplier = 2,
	},
	book5 = {
		name = "Body Integration Book",
		image = "rbxassetid://80557352288392",
		realmReq = 75,
		qiMultiplier = 3,
	},
} :: { [string]: ItemInfo }

return Item
