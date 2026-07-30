local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Shared.Data).client

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

-- Connect again incase player died/respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid") :: Humanoid
end)

local DEFAULT_SPEED = 16
local SPRINT_SPEED = 24

local UserInputServiceClient = {}

function UserInputServiceClient.init(self)
	self:Sprint()
end

function UserInputServiceClient.Sprint(self)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		-- Ignore if player typing in chat, etc.
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.LeftShift then
			Humanoid.WalkSpeed = Data.sprintspeed() or SPRINT_SPEED
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			Humanoid.WalkSpeed = Data.walkspeed() or DEFAULT_SPEED
		end
	end)
end

return UserInputServiceClient
