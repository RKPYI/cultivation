local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client

local NPCServiceClient = {}
NPCServiceClient.OnNPCTriggered = Signal.new()

function NPCServiceClient.init(self) end

function NPCServiceClient.OpenNPC(self, npcId: string)
	print("OpenNPC Fired with Id: " .. npcId)
	NPCServiceClient.OnNPCTriggered:Fire(npcId)
end

function NPCServiceClient.CloseNPC(self)
	NPCServiceClient.OnNPCTriggered:Fire(nil)
end

return NPCServiceClient
