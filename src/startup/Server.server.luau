local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemServiceServer = require(ServerScriptService.Services.ItemService.ItemServiceServer)
local OverheadServiceServer = require(ServerScriptService.Services.OverheadService.OverheadServiceServer)
local QiServiceServer = require(ServerScriptService.Services.QiService.QiServiceServer)
local RealmServiceServer = require(ServerScriptService.Services.RealmService.RealmServiceServer)
local SettingServiceServer = require(ServerScriptService.Services.SettingService.SettingServiceServer)
local UIServiceServer = require(ServerScriptService.Services.UIService.UIServiceServer)
local Data = require(ReplicatedStorage.Shared.Data).server

QiServiceServer:init()
RealmServiceServer:init()
ItemServiceServer:init()
OverheadServiceServer:init()
UIServiceServer:init()
SettingServiceServer:init()
