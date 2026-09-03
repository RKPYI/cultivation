local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Signal = require(ReplicatedStorage.Packages.Signal)
local TutorialServiceUtils = require(ReplicatedStorage.Shared.Services.TutorialService.TutorialServiceUtils)
local TutorialBeamManager = require(ReplicatedStorage.Shared.TutorialBeamManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local Data = require(ReplicatedStorage.Shared.Data).client

local networker = nil
local activeHighlight: Highlight? = nil

local TutorialServiceClient = {}

function TutorialServiceClient.init(self)
	networker = Networker.new("TutorialService", TutorialServiceClient)

	Data.tutorialStep.Changed(function(newStepIndex: number)
		self:UpdateHighlight(newStepIndex)
	end)

	task.spawn(function()
		local initialStep = Data.tutorialStep() or 1
		self:UpdateHighlight(initialStep)
	end)
end

function TutorialServiceClient.GetInstanceFromPath(self, pathString: string): Instance?
	local current: Instance = Workspace
	for _, segment in string.split(pathString, "/") do
		current = current:FindFirstChild(segment)
		if not current then
			return nil
		end
	end

	return current
end

function TutorialServiceClient.UpdateHighlight(self, stepIndex: number)
	if activeHighlight then
		activeHighlight.Enabled = false
		activeHighlight = nil
	end
	TutorialBeamManager.clear()

	local stepConfig = TutorialServiceUtils.Data[stepIndex]
	if not stepConfig or not stepConfig.highlightArea then
		return
	end

	local target: Instance? = self:GetInstanceFromPath(stepConfig.highlightArea)
	if target then
		local highlight = target:FindFirstChildOfClass("Highlight")
		if highlight then
			highlight.Enabled = true
			activeHighlight = highlight
		end

		TutorialBeamManager.setTarget(target)
	end
end

function TutorialServiceClient.NextStep(self)
	networker:fire("NextStep")
end

function TutorialServiceClient.SkipTutorial(self)
	networker:fire("SkipTutorial")
end

return TutorialServiceClient
