local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client

local NPCServiceClient = {}
NPCServiceClient.OnNPCTriggered = Signal.new()

function NPCServiceClient.init(self) end

function NPCServiceClient.OpenNPC(self, npcId: string)
	ProximityPromptService.Enabled = false
	NPCServiceClient.OnNPCTriggered:Fire(npcId)
end

function NPCServiceClient.CloseNPC(self)
	ProximityPromptService.Enabled = true
	NPCServiceClient.OnNPCTriggered:Fire(nil)
end

function NPCServiceClient.OpenShop(self, shopId: string) end

return NPCServiceClient
