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
    lastUpdated: number,
    nextUpdate: number,
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
local PREFIX = "v1_release_" -- v1_testing_, v1_mock_, v1_release_
-- local PREFIX = "v1_mock_" -- v1_testing_, v1_mock_, v1_release_

local dataStores: { [string]: OrderedDataStore } = {
    -- qi = DataStoreService:GetOrderedDataStore(PREFIX .. "QiLeaderboard"),
    -- spiritStone = DataStoreService:GetOrderedDataStore(PREFIX .. "SpiritStoneLeaderboard"),
    realm = DataStoreService:GetOrderedDataStore(PREFIX .. "RealmLeaderboard"),
}

-- Username cache to prevent GetNameFromUserIdAsync yielding lag
local usernameCache: { [number]: string } = {}

local function getUsername(userId: number): string
    if usernameCache[userId] then
        return usernameCache[userId]
    end

    local player = Players:GetPlayerByUserId(userId)
    if player then
        usernameCache[userId] = player.Name
        return player.Name
    end

    local success, name = pcall(function()
        return Players:GetNameFromUserIdAsync(userId)
    end)

    if success and name then
        usernameCache[userId] = name
        return name
    end

    return "Player_" .. userId
end

local LeaderboardServiceServer = {} :: LeaderboardServiceServer

-- Setup
function LeaderboardServiceServer.init(self: LeaderboardServiceServer)
    self.cache = { realm = {} }
    self.lastUpdated = os.time()
    self.nextUpdate = os.time() + UPDATE_INTERVAL

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

    return {
        data = self.cache,
        nextUpdate = self.nextUpdate,
    }
end

function LeaderboardServiceServer.updatePlayers(self: LeaderboardServiceServer)
	local threadCount = 0
	local players = Players:GetPlayers()

    for _, player in players do
        if not Data[player] then
            continue
        end

        -- -- QI
        -- local qiValue = Data[player].qi()
        -- local qiNumValue = BigNum.lbencode(qiValue)
        -- if qiNumValue > 0 then
        -- 	pcall(function()
        -- 		dataStores.qi:SetAsync(tostring(player.UserId), qiNumValue)
        -- 	end)
        -- end

        -- -- SPIRITUAL STONES
        -- local spiritStoneValue = Data[player].spiritualStones()
        -- local spiritStoneNumVale = BigNum.lbencode(spiritStoneValue)
        -- if spiritStoneNumVale > 0 then
        -- 	pcall(function()
        -- 		dataStores.spiritStone:SetAsync(tostring(player.UserId), spiritStoneNumVale)
        -- 	end)
        -- end

        -- REALM
        local realmValue = Data[player].realm()
        if realmValue > 0 then
			threadCount += 1
            task.spawn(function()
                pcall(function()
                    dataStores.realm:SetAsync(tostring(player.UserId), realmValue)
                end)
				threadCount -= 1
            end)
        end
    end

	while threadCount > 0 do
		task.wait(0.1)
	end

	task.wait(1)
end

function LeaderboardServiceServer.update(self: LeaderboardServiceServer)
    self:updatePlayers()

    self.lastUpdated = os.time()
    self.nextUpdate = self.lastUpdated + UPDATE_INTERVAL

    for key, store in dataStores do
        task.spawn(function()
            local success, pages = pcall(function()
                return store:GetSortedAsync(false, 50)
            end)

            if not success or not pages then
                return
            end

            local entries = pages:GetCurrentPage()
            local leaderboardData = {}

            for rank, item in entries do
                local userId = tonumber(item.key)
                if not userId then
                    continue
                end

                local username = getUsername(userId)

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
            self.networker:fireAll("leaderboardUpdated", key, leaderboardData, self.nextUpdate)
        end)
    end
end

return LeaderboardServiceServer