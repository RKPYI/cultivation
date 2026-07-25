local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BigNum = require(ReplicatedStorage.Shared.BigNum)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client
local Player = Players.LocalPlayer

local networker = nil
local RealmServiceClient = {}
local isTouching = {}

function RealmServiceClient.init(self)
	networker = Networker.new("RealmService", RealmServiceClient)
end

return RealmServiceClient
