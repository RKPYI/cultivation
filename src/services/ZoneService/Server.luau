--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Data = require(ReplicatedStorage.Shared.Data)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local QiAreaFolder = workspace:WaitForChild("QiArea")

type State = {
	isTouching: { [Player]: { [string]: boolean } },
	onZoneStateChanged: any, -- Signal
}

export type ZoneServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: ZoneServiceServer) -> (),
	start: (self: ZoneServiceServer) -> (),
	OnPlayerAdded: (self: ZoneServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: ZoneServiceServer, player: Player) -> (),

	setupAreaListener: (self: ZoneServiceServer) -> (),
	-- Networker
	networker: any,
}

local ZoneServiceServer = {} :: ZoneServiceServer

-- Setup
function ZoneServiceServer.init(self: ZoneServiceServer)
	self.isTouching = {}
	self.onZoneStateChanged = Signal.new()

	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"ZoneService",
		self,
		{
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

function ZoneServiceServer.OnPlayerAdded(self: ZoneServiceServer, player: Player)
	self.isTouching[player] = {}
end

function ZoneServiceServer.OnPlayerRemoving(self: ZoneServiceServer, player: Player)
	self.isTouching[player] = nil
end

function ZoneServiceServer.start(self: ZoneServiceServer)
	self:setupAreaListener()
end

function ZoneServiceServer.setupAreaListener(self)
	for _, area in QiAreaFolder:GetChildren() do
		local zone = area:IsA("Model") and area:WaitForChild("Zone") :: Part
		if not zone then
			continue
		end
		local billBoardGui = zone:FindFirstChild("BillboardGui") :: BillboardGui
		if not billBoardGui then
			continue
		end
		local RealmReqText = billBoardGui:FindFirstChild("RealmReq") :: TextLabel
		if not RealmReqText then
			continue
		end

		local realmReq = ZoneServiceUtils.Data[area.Name].realmReq

		ZoneServiceUtils.CalculateDist(zone, function(player: Player, isInside: boolean)
			if not self.isTouching[player] then
				return
			end

			local wasTouching = self.isTouching[player][area.Name] or false
			if wasTouching == isInside then
				return
			end

			self.isTouching[player][area.Name] = isInside
			self.onZoneStateChanged:Fire(player, area.Name, isInside)
		end)
	end
end

return ZoneServiceServer
