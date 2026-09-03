--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local TutorialServiceUtils = require(ReplicatedStorage.Shared.Services.TutorialService.TutorialServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {}

export type TutorialServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: TutorialServiceServer) -> (),
	start: (self: TutorialServiceServer) -> (),
	OnPlayerAdded: (self: TutorialServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: TutorialServiceServer, player: Player) -> (),

	NextStep: (self: TutorialServiceServer, player: Player) -> (),
	SkipTutorial: (self: TutorialServiceServer, player: Player) -> (),

	-- Networker
	networker: any,
}

local TutorialServiceServer = {} :: TutorialServiceServer

-- Setup
function TutorialServiceServer.init(self: TutorialServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"TutorialService",
		self,
		{
			self.NextStep,
			self.SkipTutorial,
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

function TutorialServiceServer.OnPlayerAdded(self: TutorialServiceServer, player: Player)
	task.spawn(function()
		while not Data[player] and player:IsDescendantOf(Players) do
			task.wait(0.1)
		end

		if not player:IsDescendantOf(Players) then
			return
		end

		-- Function that need player data
	end)
end

function TutorialServiceServer.OnPlayerRemoving(self: TutorialServiceServer, player: Player) end

function TutorialServiceServer.start(self: TutorialServiceServer) end

function TutorialServiceServer.NextStep(self, player)
	local data = Data[player]
	if not data then
		return
	end

	local currentStep = Data[player].tutorialStep() or 1

	if currentStep <= TutorialServiceUtils.MAX_STEPS then
		Data[player].tutorialStep(function(prev: number)
			return prev + 1
		end)
	end
end

function TutorialServiceServer.SkipTutorial(self, player)
	local data = Data[player]
	if not data then
		return
	end

	Data[player].tutorialStep(function()
		return TutorialServiceUtils.MAX_STEPS + 1
	end)
end

return TutorialServiceServer
