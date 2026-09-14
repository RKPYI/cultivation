--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Data = require(ReplicatedStorage.Shared.Data).server
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local QiAreaFolder = workspace:WaitForChild("QiArea")

type State = {
	isTouching: { [Player]: { [string]: boolean } },
	isCultivating: { [Player]: boolean },
	onZoneStateChanged: any, -- Signal
	onCultivationStateChanged: any, -- Signal
	onMovementLockedChanged: any, -- Signal
}

export type ZoneServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: ZoneServiceServer) -> (),
	start: (self: ZoneServiceServer) -> (),
	OnPlayerAdded: (self: ZoneServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: ZoneServiceServer, player: Player) -> (),

	setupAreaListener: (self: ZoneServiceServer) -> (),
	getCurrentZone: (self: ZoneServiceServer, player: Player) -> string?,
	toggleCultivation: (self: ZoneServiceServer, player: Player, start: boolean) -> (),
	-- Networker
	networker: any,
}

local ZoneServiceServer = {} :: ZoneServiceServer

-- Setup
function ZoneServiceServer.init(self: ZoneServiceServer)
	self.isTouching = {}
	self.isCultivating = {}
	self.onZoneStateChanged = Signal.new()
	self.onCultivationStateChanged = Signal.new()
	self.onMovementLockedChanged = Signal.new()

	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"ZoneService",
		self,
		{
			self.toggleCultivation,
			self.getCurrentZone,
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
	self.isCultivating[player] = false
end

function ZoneServiceServer.OnPlayerRemoving(self: ZoneServiceServer, player: Player)
	self.isTouching[player] = nil
	self.isCultivating[player] = nil
end

function ZoneServiceServer.start(self: ZoneServiceServer)
	self:setupAreaListener()
end

function ZoneServiceServer.getCurrentZone(self: ZoneServiceServer, player: Player): string?
	local playerTouches = self.isTouching[player]
	if not playerTouches then
		return nil
	end

	for zoneName, isInside in playerTouches do
		if isInside then
			return zoneName
		end
	end
	return nil
end

function ZoneServiceServer.toggleCultivation(self: ZoneServiceServer, player: Player, start: boolean): boolean
	if not player or not player.Character then
		return false
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	if start then
		if self.isCultivating[player] then
			return false
		end

		local currentZone = self:getCurrentZone(player)
		if not currentZone then
			return false
		end

		local zoneData = ZoneServiceUtils.Data[currentZone]
		local playerRealm = Data[player] and Data[player].realm() or 0
		if not zoneData or playerRealm < zoneData.realmReq then
			return false
		end

		self.isCultivating[player] = true
		-- humanoid.WalkSpeed = 0
		-- humanoid.JumpPower = 0
		self.onMovementLockedChanged:Fire(player, true)

		self.networker:set(player, "IsCultivating", true)
		self.onCultivationStateChanged:Fire(player, true)
		return true
	else
		if not self.isCultivating[player] then
			return false
		end

		self.isCultivating[player] = false

		-- RealmServiceServer:UpdateWalkspeed(player)
		self.onMovementLockedChanged:Fire(player, false)

		self.networker:set(player, "IsCultivating", false)
		self.onCultivationStateChanged:Fire(player, false)
		return true
	end
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
			self.networker:set(player, "InZone", isInside and area.Name or nil)

			if not isInside and self.isCultivating[player] then
				self:toggleCultivation(player, false)
			end
		end)
	end
end

return ZoneServiceServer
