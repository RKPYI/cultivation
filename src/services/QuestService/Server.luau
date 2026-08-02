--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local QuestServiceUtils = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

-- type QuestProgress = {
-- 	questId: string,
-- 	currentAmount: number,
-- 	targetAmount: number,
-- 	isCompleted: boolean,
-- }

type State = {
	-- 	playerQuests: { [Player]: { [string]: QuestProgress } },
}

export type QuestServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: QuestServiceServer) -> (),
	start: (self: QuestServiceServer) -> (),
	OnPlayerAdded: (self: QuestServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: QuestServiceServer, player: Player) -> (),

	AcceptQuest: (self: QuestServiceServer, player: Player, questId: string) -> (),

	-- Networker
	networker: any,
}

local QuestServiceServer = {} :: QuestServiceServer

-- Setup
function QuestServiceServer.init(self: QuestServiceServer)
	-- self.playerQuests = {}

	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"QuestService",
		self,
		{
			self.AcceptQuest,
			-- Add public network
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function QuestServiceServer.OnPlayerAdded(self: QuestServiceServer, player: Player)
	-- self.playerQuests[player] = {}
end

function QuestServiceServer.OnPlayerRemoving(self: QuestServiceServer, player: Player)
	-- self.playerQuests[player] = nil
end

function QuestServiceServer.start(self: QuestServiceServer) end

function QuestServiceServer.AcceptQuest(self: QuestServiceServer, player: Player, questId: string)
	print("AcceptQuest Server Fired")
	local playerData = Data[player]
	if not playerData then
		return
	end

	local questConfig = QuestServiceUtils.Data[questId]
	if not questConfig then
		return
	end

	local activeQuests = Data[player].quests.active() or {}
	local completedQuests = Data[player].quests.completed() or {}
	if activeQuests[questId] or completedQuests[questId] then
		return
	end

	print("QUEST ACCEPTED!")
	print("Quest ID: " .. questId)

	Data[player].quests.active(function(currentQuests)
		local updated = table.clone(currentQuests)

		local currentRealm = Data[player].realm() or 1
		local startingAmount = 0

		if questConfig.questType == "ReachRealm" then
			startingAmount = currentRealm
		end

		updated[questId] = {
			questId = questId,
			currentAmount = startingAmount,
			targetAmount = questConfig.targetAmount,
			isCompleted = startingAmount >= questConfig.targetAmount,
		}

		print(updated)
		return updated
	end)
end

return QuestServiceServer
