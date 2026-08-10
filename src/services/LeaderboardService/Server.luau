--!strict
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {
	cache: { [string]: {} },
}

export type LeaderboardServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: LeaderboardServiceServer) -> (),

	getLeaderboards: (self: LeaderboardServiceServer) -> { [string]: {} },

	updatePlayers: (self: LeaderboardServiceServer) -> (),
	update: (self: LeaderboardServiceServer) -> (),

	-- Networker
	networker: any,
}

local UPDATE_INTERVAL = 120
local PREFIX = "v1_"

local dataStores: { [string]: OrderedDataStore } = {
	qi = DataStoreService:GetOrderedDataStore(PREFIX .. "QiLeaderboard"),
	spiritStone = DataStoreService:GetOrderedDataStore(PREFIX .. "SpiritStoneLeaderboard"),
	realm = DataStoreService:GetOrderedDataStore(PREFIX .. "RealmLeaderboard"),
}

local LeaderboardServiceServer = {} :: LeaderboardServiceServer

-- Setup
function LeaderboardServiceServer.init(self: LeaderboardServiceServer)
	self.cache = { qi = {} }

	self.networker = Networker.server.new(
		"LeaderboardService",
		self,
		{
			self.getLeaderboards,
		} :: any
	)

	task.spawn(function()
		task.wait(5)
		while true do
			self:update()
			task.wait(UPDATE_INTERVAL)
		end
	end)
end

function LeaderboardServiceServer.getLeaderboards(self)
	print("GETLEADERBOARDS")

	return self.cache
end

function LeaderboardServiceServer.updatePlayers()
	for _, player in Players:GetPlayers() do
		if not Data[player] then
			continue
		end

		-- QI
		local qiValue = Data[player].qi()
		local qiNumValue = BigNum.lbencode(qiValue)
		if qiNumValue > 0 then
			pcall(function()
				dataStores.qi:SetAsync(tostring(player.UserId), qiNumValue)
			end)
		end

		-- SPIRITUAL STONES
		local spiritStoneValue = Data[player].spiritualStones()
		local spiritStoneNumVale = BigNum.lbencode(spiritStoneValue)
		if spiritStoneNumVale > 0 then
			pcall(function()
				dataStores.spiritStone:SetAsync(tostring(player.UserId), spiritStoneNumVale)
			end)
		end

		-- REALM
		local realmValue = Data[player].realm()
		if realmValue > 0 then
			pcall(function()
				dataStores.realm:SetAsync(tostring(player.UserId), realmValue)
			end)
		end
	end
end

function LeaderboardServiceServer.update(self)
	self:updatePlayers()

	for key, store in dataStores do
		local success, pages = pcall(function()
			return store:GetSortedAsync(false, 50)
		end)

		if not success or not pages then
			continue
		end

		local entries = pages:GetCurrentPage()
		local leaderboardData = {}

		for rank, item in entries do
			local userId = tonumber(item.key)
			if not userId then
				continue
			end

			local username = "Player_" .. userId
			pcall(function()
				username = Players:GetNameFromUserIdAsync(userId)
			end)

			local displayValue = "NIL"
			if key == "realm" then
				displayValue = RealmServiceUtils.RealmName(item.value)
			else
				local decode = BigNum.lbdecode(item.value)
				displayValue = BigNum.toSuffix(decode)
			end

			table.insert(leaderboardData, {
				rank = rank,
				userId = userId,
				username = username,
				value = displayValue,
			})
		end

		self.cache[key] = leaderboardData
		self.networker:fireAll("leaderboardUpdated", key, leaderboardData)
	end
end

return LeaderboardServiceServer
