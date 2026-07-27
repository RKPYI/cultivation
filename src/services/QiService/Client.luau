local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client
local QiAreaFolder = workspace:WaitForChild("QiArea")
local Player = Players.LocalPlayer

local networker = nil
local QiServiceClient = {}
local isTouching = {}

function QiServiceClient.init(self)
	networker = Networker.new("QiService", QiServiceClient)

	self:setupAreaListener()
	self:AreaEntered()
end

local function CalculateDist(area: Part)
	area.Touched:Connect(function(hit)
		if game.Players:GetPlayerFromCharacter(hit.Parent) then
			isTouching[area.Name] = true
		end
	end)
	area.TouchEnded:Connect(function(hit)
		if game.Players:GetPlayerFromCharacter(hit.Parent) then
			isTouching[area.Name] = nil
		end
	end)
end

function QiServiceClient.setupAreaListener()
	for _, area in QiAreaFolder:GetChildren() do
		local zone = area:IsA("Model") and area:WaitForChild("Zone")
		if not zone then
			continue
		end

		CalculateDist(zone)
	end
end

function QiServiceClient.AreaEntered(self)
	RunService.RenderStepped:Connect(function()
		for _, area in QiAreaFolder:GetChildren() do
			local zone = area:IsA("Model") and area:WaitForChild("Zone")
			if not zone then
				continue
			end

			if isTouching[zone.Name] then
				self.GiveQi()
				break
			end
		end
	end)
end

function QiServiceClient.GiveQi()
	networker:fire("GiveQi")
	-- ADD FLOATING +1 QI in screen
end

return QiServiceClient
