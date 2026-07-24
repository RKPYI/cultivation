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

function QiServiceClient.init(self)
	networker = Networker.new("QiService", QiServiceClient)

	self:AreaEntered()
end

function QiServiceClient.AreaEntered(self)
	RunService.RenderStepped:Connect(function()
		for _, area in QiAreaFolder:GetChildren() do
			if not area:IsA("Part") then
				continue
			end

			local Distance = Player:DistanceFromCharacter(area.Position)
			local Range = area.Size.Y

			if Distance < Range then
				self.GiveQi()
			end
		end
	end)
end

function QiServiceClient.GiveQi()
	networker:fire("GiveQi")
	-- ADD FLOATING +1 QI in screen
end

return QiServiceClient
