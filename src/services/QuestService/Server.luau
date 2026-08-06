--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local QuestServiceUtils = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type QuestProgress = {
	questId: string,
	currentAmount: number,
	targetAmount: number,
	isCompleted: boolean,
}

type State = {
	playerQuests: { [Player]: { [string]: QuestProgress } },
}

export type QuestServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: QuestServiceServer) -> (),
	start: (self: QuestServiceServer) -> (),
	OnPlayerAdded: (self: QuestServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: QuestServiceServer, player: Player) -> (),

	AcceptQuest: (self: QuestServiceServer, player: Player, questId: string) -> (),
	CompleteQuest: (self: QuestServiceServer, player: Player, questId: string) -> (),
	RealmListener: (self: QuestServiceServer, player: Player) -> (),
	EnemyListener: (self: QuestServiceServer, player: Player) -> (),

	-- Networker
	networker: any,
}

local QuestServiceServer = {} :: QuestServiceServer

-- Setup
function QuestServiceServer.init(self: QuestServiceServer)
	self.playerQuests = {}

	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"QuestService",
		self,
		{
			self.AcceptQuest,
			self.CompleteQuest,
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
	self.playerQuests[player] = {}
	task.spawn(function()
		while not Data[player] and player:IsDescendantOf(Players) do
			task.wait(0.1)
		end

		if not player:IsDescendantOf(Players) then
			return
		end

		-- Function that need player data
		self:RealmListener(player)
		self:EnemyListener(player)
	end)
end

function QuestServiceServer.OnPlayerRemoving(self: QuestServiceServer, player: Player)
	self.playerQuests[player] = nil
end

function QuestServiceServer.start(self: QuestServiceServer) end

function QuestServiceServer.AcceptQuest(self: QuestServiceServer, player: Player, questId: string)
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

	Data[player].quests.active(function(currentQuests)
		local updated = table.clone(currentQuests)

		local currentRealm = Data[player].realm() or 1
		local startingAmount = 0

		if questConfig.questType == "ReachRealm" then
			startingAmount = currentRealm
		end

		if questConfig.questType == "TotalKillEnemy" then
			local totalKill = Data[player].totalEnemyKilled[questConfig.targetValue]()
			startingAmount = totalKill
		end

		updated[questId] = {
			questId = questId,
			currentAmount = startingAmount,
			targetAmount = questConfig.targetAmount,
			isCompleted = startingAmount >= questConfig.targetAmount,
		}

		return updated
	end)
end

function QuestServiceServer.CompleteQuest(self: QuestServiceServer, player: Player, questId: string)
	local playerData = Data[player]
	if not playerData then
		return
	end

	local questConfig = QuestServiceUtils.Data[questId]
	if not questConfig then
		return
	end

	if Data[player].quests.active[questId]() and not Data[player].quests.active[questId]().isCompleted then
		return
	end

	Data[player].quests.completed(function(currentCompletedQuests)
		local updated = table.clone(currentCompletedQuests)

		updated[questId] = true

		return updated
	end)

	Data[player].quests.active(function(currentQuests)
		local updated = table.clone(currentQuests)

		updated[questId] = nil

		return updated
	end)

	local questBonusSpiritualStone = questConfig.rewards.spiritualStones
	Data[player].spiritualStones(function(spiritualStones)
		local updated = BigNum.add(spiritualStones, questBonusSpiritualStone)
		return updated
	end)

	local item = questConfig.rewards.item
	if item then
		Data[player].inventory.item(function(currentItems)
			local updated = table.clone(currentItems)
			table.insert(updated, item)
			return updated
		end)

		Data[player].inventory.newItem(function()
			return true
		end)
	end
end

function QuestServiceServer.RealmListener(self: QuestServiceServer, player: Player)
	local PlayerData = Data[player]
	if not PlayerData then
		warn("[QuestServiceServer] RealmListener returned early because there is no PlayerData")
		return
	end

	Data[player].realm.Changed(function(newRealm)
		Data[player].quests.active(function(currentQuests)
			local updated = table.clone(currentQuests)

			for questId, progress in updated do
				local config = QuestServiceUtils.Data[questId]
				if config and config.questType == "ReachRealm" and not progress.isCompleted then
					local targetRealm = config.targetValue :: number
					progress.currentAmount = newRealm
					if progress.currentAmount >= targetRealm then
						progress.isCompleted = true
					end
				end
			end

			return updated
		end)
	end)
end

function QuestServiceServer.EnemyListener(self: QuestServiceServer, player: Player)
	local PlayerData = Data[player]
	if not PlayerData then
		warn("[QuestServiceServer] EnemyListener returned early because there is no PlayerData")
		return
	end

	Data[player].totalEnemyKilled.Changed(function(newEnemyList)
		Data[player].quests.active(function(currentQuests)
			local updated = table.clone(currentQuests)

			for questId, progress in updated do
				local config = QuestServiceUtils.Data[questId]
				if config and config.questType == "TotalKillEnemy" and not progress.isCompleted then
					local targetEnemy = config.targetValue :: number
					local killedCount = newEnemyList[targetEnemy] or 0

					local progressCopy = table.clone(progress)

					progressCopy.currentAmount = math.min(killedCount, config.targetAmount)
					if progressCopy.currentAmount >= config.targetAmount then
						progressCopy.isCompleted = true
					end

					updated[questId] = progressCopy
				end
			end

			return updated
		end)
	end)
end

return QuestServiceServer
