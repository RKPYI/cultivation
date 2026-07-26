local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local MountUI = require(ReplicatedStorage.UI.MountUI)
local QiServiceClient = require(ReplicatedStorage.Shared.Services.QiService.QiServiceClient)
local RealmServiceClient = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceClient)

local Data = require(ReplicatedStorage.Shared.Data).client

QiServiceClient:init()
RealmServiceClient:init()

MountUI()

RealmServiceClient:start(Player)
