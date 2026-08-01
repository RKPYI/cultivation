local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Roman = require(ReplicatedStorage.Shared.Roman)
local Realm = {}

Realm.Name = {
	-- Reference: Top Tier Providence + Some Tweaks
	"Qi Refining",
	"Qi Condensation",
	"Foundation Establishment",
	"Golden Core",
	"Nascent Soul",
	"Soul Formation",
	"Void Amalgamation",
	"Body Integration",
	"Tribulation Transcendence",
	"Mahayana",

	-- Upper World (Should have Crazy QI Increase/Need different type of qi like immortal qi and maybe could rebirth at this point for whatever reason)
	"Loose Immortal",
	"Earth Immortal",
	"Heaven Immortal",
	"True Immortal",
	"Mystic Immortal",
	"Golden Immortal",
	"Immortal Emperor",

	-- Upper World "Boss" (Should have crazy qi increase & Transitioning to Dao)
	"Deity",
	"Zenith Heaven",
	"Quasi-Sage",

	-- Chaotic Space (Qi Should'nt matter at this stage of the game, The Dao should be the main focus here)
	"Heavenly Dao Sage",
	"Freedom Primordial Chaos",
	"Great Dao Primordial Chaos",
	"Great Dao Supreme",
	"Dao Creator",
}

function Realm.RealmName(realm: number): string
	local bigRealm = math.floor((realm - 1) / 10) + 1
	local smallRealm = (realm - 1) % 10 + 1

	local baseName = Realm.Name[bigRealm]
	if not baseName then
		return "ABOVE THE SYSTEM"
	end

	local RealmName = baseName .. " " .. Roman(smallRealm)

	return RealmName
end

local function getBigRealm(realm: number)
	return math.floor((realm - 1) / 10) -- Qi Refining (realm 1-10) = 0
end

function Realm.CalculateBreakthroughReq(realm: number): BigNum.BN
	local baseQi = 2 ^ realm * 100
	local bigRealm = getBigRealm(realm)

	local bigRealmQi = BigNum.pow10(BigNum.fromNumber(bigRealm)) -- Multiply by 10 every major realm
	local totalReq = BigNum.mul(BigNum.fromNumber(baseQi), bigRealmQi)
	totalReq = BigNum.mul(totalReq, BigNum.pow(BigNum.fromNumber(2), bigRealm))

	if realm > 100 then
		local immortalOffset = realm - 100

		local immortalFactor = BigNum.pow(BigNum.fromNumber(2), immortalOffset)

		totalReq = BigNum.mul(totalReq, immortalFactor)
	end

	return totalReq
end

function Realm.GetQiBonus(realm: number): BigNum.BN
	local baseQi = 1.8 ^ realm * 15
	local bigRealm = getBigRealm(realm)

	local bigRealmQi = BigNum.pow(BigNum.fromNumber(9), BigNum.fromNumber(bigRealm))
	local totalQi = BigNum.mul(BigNum.fromNumber(baseQi), bigRealmQi)

	return totalQi
end

return Realm
