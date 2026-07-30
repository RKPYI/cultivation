local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local MountUI = require(ReplicatedStorage.UI.MountUI)
local QiServiceClient = require(ReplicatedStorage.Shared.Services.QiService.QiServiceClient)
local RealmServiceClient = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceClient)
local SettingServiceClient = require(ReplicatedStorage.Shared.Services.SettingService.SettingServiceClient)
local SoundServiceClient = require(ReplicatedStorage.Shared.Services.SoundService.SoundServiceClient)
local UserInputServiceClient = require(ReplicatedStorage.Shared.Services.UserInputService.UserInputServiceClient)
local ZoneServiceClient = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceClient)

local Data = require(ReplicatedStorage.Shared.Data).client

QiServiceClient:init()
RealmServiceClient:init()
ZoneServiceClient:init()
SettingServiceClient:init()
SoundServiceClient:init()
UserInputServiceClient:init()

MountUI()

RealmServiceClient:start(Player)
