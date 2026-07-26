local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Roman = require(ReplicatedStorage.Shared.Roman)
local Realm = {}

Realm.Name = {
	"Qi Refining",
	"Qi Condensation",
	"Foundation Establishment",
	"Golden Core",
	"Nascent Soul",
	"Soul Formation",
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

function Realm.CalculateBreakthroughReq(realm: number): BigNum.BN
	local baseQi = 10 * (realm ^ 2)

	local realmTier = math.floor((realm - 1) / 10)

	local tierFactor = 12 ^ realmTier

	local isMajorBottleneck = (realm % 10 == 0)
	local bottleneckMult = isMajorBottleneck and 3 or 1.0

	local totalReq = BigNum.mul(baseQi, tierFactor)
	totalReq = BigNum.mul(totalReq, bottleneckMult)

	return totalReq
end

function Realm.GetQiBonus(realm: number): BigNum.BN
	local baseQiPerSec = 1.5 * (realm ^ 1.8)

	local realmTier = math.floor((realm - 1) / 10)
	local tierFactor = 9 ^ realmTier

	local qiPerSecond = baseQiPerSec * tierFactor

	local isMajorBottleneck = (realm % 10 == 0)
	if isMajorBottleneck then
		qiPerSecond *= 1.25
	end

	return BigNum.fromNumber(math.floor(qiPerSecond))
end

return Realm
