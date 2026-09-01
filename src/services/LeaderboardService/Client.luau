local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local Networker = require(ReplicatedStorage.Packages.Networker).client

local networker = nil
local LeaderboardServiceClient = {}
LeaderboardServiceClient.OnUpdated = Signal.new()

function LeaderboardServiceClient.init(self)
	networker = Networker.new("LeaderboardService", self)
end

function LeaderboardServiceClient.getLeaderboards(self)
	return networker:fetch("getLeaderboards")
end

function LeaderboardServiceClient.leaderboardUpdated(self, key: string, data: any, nextUpdate: number)
	self.OnUpdated:Fire(key, data, nextUpdate)
end

return LeaderboardServiceClient
