local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ItemServiceClient = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceClient)
local NPCServiceClient = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceClient)
local MountUI = require(ReplicatedStorage.UI.MountUI)
local QiServiceClient = require(ReplicatedStorage.Shared.Services.QiService.QiServiceClient)
local QuestServiceClient = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceClient)
local RealmServiceClient = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceClient)
local SettingServiceClient = require(ReplicatedStorage.Shared.Services.SettingService.SettingServiceClient)
local SoundServiceClient = require(ReplicatedStorage.Shared.Services.SoundService.SoundServiceClient)
local UserInputServiceClient = require(ReplicatedStorage.Shared.Services.UserInputService.UserInputServiceClient)
local ZoneServiceClient = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceClient)

local Data = require(ReplicatedStorage.Shared.Data).client

QiServiceClient:init()
RealmServiceClient:init()
ZoneServiceClient:init()
ItemServiceClient:init()
SettingServiceClient:init()
SoundServiceClient:init()
UserInputServiceClient:init()
NPCServiceClient:init()
QuestServiceClient:init()

MountUI()

RealmServiceClient:start(Player)
