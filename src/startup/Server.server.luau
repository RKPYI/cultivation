local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QiServiceServer = require(ServerScriptService.Services.QiService.QiServiceServer)
local Data = require(ReplicatedStorage.Shared.Data).server

QiServiceServer:init()
