local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Item = {}

export type ItemInfo = {
	name: string,
	image: string,
	realmReq: number,
	qiMultiplier: number,
	dmgMultiplier: number,
	price: BigNum.BN?,
}

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
		qiMultiplier = 2.5,
	},
	book5 = {
		name = "Body Integration Book",
		image = "rbxassetid://134161933386968",
		realmReq = 75,
		qiMultiplier = 5,
	},

	scroll1 = {
		name = "Common Scroll",
		image = "rbxassetid://116520877504123",
		realmReq = 20,
		qiMultiplier = 1.5,
		dmgMultiplier = 1.1,
		price = 500,
	},
	scroll2 = {
		name = "Uncommon Scroll",
		image = "rbxassetid://83016027871475",
		realmReq = 30,
		qiMultiplier = 1.6,
		dmgMultiplier = 1.2,
		price = 1000,
	},
	scroll3 = {
		name = "Rare Scroll",
		image = "rbxassetid://133891318823760",
		realmReq = 40,
		qiMultiplier = 1.8,
		dmgMultiplier = 1.5,
		price = 2000,
	},
	scroll4 = {
		name = "Epic Scroll",
		image = "rbxassetid://133010596383800",
		realmReq = 50,
		qiMultiplier = 2,
		dmgMultiplier = 2,
		price = 5000,
	},
	scroll5 = {
		name = "Legendary Scroll",
		image = "rbxassetid://71382641711697",
		realmReq = 60,
		qiMultiplier = 3,
		dmgMultiplier = 2.5,
		price = 10000,
	},
} :: { [string]: ItemInfo }

return Item
