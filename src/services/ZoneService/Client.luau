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
	self:AreaEntered()
end

function ZoneServiceClient.setupAreaUI(self)
	for _, area in QiAreaFolder:GetChildren() do
		local zone = area:IsA("Model") and area:WaitForChild("Zone")
		if not zone then
			continue
		end

		local billboardGui = zone.BillboardGui
		if not billboardGui then
			continue
		end

		-- Data
		local data = ZoneServiceUtils.Data
		local req = RealmServiceUtils.RealmName(data[area.Name].realmReq)
		local qi = data[area.Name].qiMultiplier

		-- The UI
		local reqUI = billboardGui.RealmReq :: TextLabel
		local qiUI = billboardGui.QiMul :: TextLabel

		reqUI.Text = "Req: " .. req
		qiUI.Text = "Qi: " .. qi .. "x [TEST]"

		-- Particle
		local particleEmitter = zone.ParticleEmitter :: ParticleEmitter
		particleEmitter.Size = NumberSequence.new(qi * 0.2)
		particleEmitter.Rate = 10 + data[area.Name].realmReq
	end
end

function ZoneServiceClient.setupAreaListener()
	for _, area in QiAreaFolder:GetChildren() do
		local zone = area:IsA("Model") and area:WaitForChild("Zone")
		if not zone then
			continue
		end

		ZoneServiceUtils.CalculateDist(zone, function(isInside)
			isTouching[zone.Parent.Name] = isInside
		end)
	end
end

function ZoneServiceClient.AreaEntered(self)
	RunService.RenderStepped:Connect(function()
		for _, area in QiAreaFolder:GetChildren() do
			local zone = area:IsA("Model") and area:WaitForChild("Zone")
			if not zone and not ZoneServiceUtils.Data[zone.Name] then
				continue
			end

			local realmReq = ZoneServiceUtils.Data[zone.Parent.Name].realmReq

			if isTouching[zone.Parent.Name] and Data.realm() >= realmReq then
				self:GiveQi(area.Name)
				break
			end
		end
	end)
end

function ZoneServiceClient.GiveQi(self, zoneName: string)
	networker:fire("GiveQi", zoneName)
	-- ADD FLOATING +1 QI in screen
end

return ZoneServiceClient
