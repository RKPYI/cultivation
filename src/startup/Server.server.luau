local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QiServiceServer = require(ServerScriptService.Services.QiService.QiServiceServer)
local RealmServiceServer = require(ServerScriptService.Services.RealmService.RealmServiceServer)
local UIServiceServer = require(ServerScriptService.Services.UIService.UIServiceServer)
local Data = require(ReplicatedStorage.Shared.Data).server

QiServiceServer:init()
RealmServiceServer:init()
UIServiceServer:init()
