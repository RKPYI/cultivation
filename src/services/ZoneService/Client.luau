local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client
local QiAreaFolder = workspace:WaitForChild("QiArea")
local Player = Players.LocalPlayer

local networker = nil
local ZoneServiceClient = {}
local isTouching = {}

function ZoneServiceClient.init(self)
	networker = Networker.new("QiService", ZoneServiceClient)

	self:setupAreaUI()
	self:setupAreaListener()
end

local function calculateParticle(qi)
	local maxParticleSize = 6.4
	local minParticleSize = 0.2
	if qi <= 64 then
		local progress = math.clamp(qi / 64, 0, 1)
		local size = minParticleSize + progress * (maxParticleSize - minParticleSize)
		return 0, size
	end

	local tier = 1
	local prevLimit = 64
	local currentLimit = 64 ^ 2 -- 4096

	while qi > currentLimit do
		tier = tier + 1
		prevLimit = currentLimit
		currentLimit = 64 ^ (2 ^ tier)
	end

	local range = currentLimit - prevLimit
	local progress = (qi - prevLimit) / range
	local size = minParticleSize + progress * (maxParticleSize - minParticleSize)

	return tier, size
end

function ZoneServiceClient.setupAreaUI(self)
	for _, area in QiAreaFolder:GetChildren() do
		local zone = area:IsA("Model") and area:WaitForChild("Zone")
		if not zone then
			continue
		end

		local billboardGui = zone.BillboardGui :: BillboardGui
		if not billboardGui then
			continue
		end

		billboardGui.AlwaysOnTop = true

		-- Data
		local playerRealm = Data.realm()
		local data = ZoneServiceUtils.Data
		local req = RealmServiceUtils.RealmName(data[area.Name].realmReq)
		local qi = BigNum.fromNumber(data[area.Name].qiMultiplier)

		-- The UI
		local reqUI = billboardGui.RealmReq :: TextLabel
		local qiUI = billboardGui.QiMul :: TextLabel

		if playerRealm >= data[area.Name].realmReq then
			reqUI.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			reqUI.TextColor3 = Color3.fromRGB(255, 107, 109)
		end

		reqUI.Text = "Req: " .. req
		qiUI.Text = "Qi: " .. BigNum.toSuffix(qi) .. "x"

		-- Particle
		local particleEmitter = zone.ParticleEmitter :: ParticleEmitter

		local currentTier, particleSize = calculateParticle(BigNum.toNumber(qi))

		particleEmitter.Size = NumberSequence.new(particleSize)
		particleEmitter.Rate = 10 + data[area.Name].realmReq

		-- Higher Particle
		if currentTier == 0 then -- x1 --> x64
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		elseif currentTier == 1 then -- x65 --> x4k
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 150, 255))
		elseif currentTier == 2 then -- x4k --> x16m
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(138, 43, 226))
		elseif currentTier >= 3 then -- x16m --> x281t --> beyond
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
		end
	end
end

function ZoneServiceClient.setupAreaListener(self)
	for _, area in QiAreaFolder:GetChildren() do
		local zone = area:IsA("Model") and area:WaitForChild("Zone")
		if not zone then
			continue
		end

		local realmReq = ZoneServiceUtils.Data[zone.Parent.Name].realmReq

		Data.realm.Changed(function(newRealm)
			if newRealm >= realmReq then
				zone.BillboardGui.RealmReq.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				zone.BillboardGui.RealmReq.TextColor3 = Color3.fromRGB(255, 107, 109)
			end
		end, {})
	end
end

function ZoneServiceClient.GiveQi(self, zoneName: string)
	networker:fire("GiveQi", zoneName)
	-- ADD FLOATING +1 QI in screen
end

return ZoneServiceClient
