local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client
local QiAreaFolder = workspace:WaitForChild("QiArea")
local Player = Players.LocalPlayer

local networker = nil
local QiServiceClient = {}
QiServiceClient.OnQiGranted = Signal.new()

function QiServiceClient.init(self)
	networker = Networker.new("QiService", QiServiceClient)
end

function QiServiceClient.GiveQi()
	networker:fire("GiveQi")
	-- ADD FLOATING +1 QI in screen
end

function QiServiceClient.QiGranted(self)
	return networker:getServerChangedSignal("QiGranted")
end

return QiServiceClient
