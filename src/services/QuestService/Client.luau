local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client

local networker = nil
local QuestServiceClient = {}

function QuestServiceClient.init(self)
	networker = Networker.new("QuestService", QuestServiceClient)
end

function QuestServiceClient.AcceptQuest(self, questId: string)
	print("AcceptQuest Client Fired with questId: " .. questId)
	networker:fire("AcceptQuest", questId)
end

return QuestServiceClient
