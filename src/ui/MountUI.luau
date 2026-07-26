local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RootUI = require(ReplicatedStorage.UI.RootUI)
local CharacterOverhead = require(ReplicatedStorage.UI.views.CharacterOverhead)

return function()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local container = Instance.new("ScreenGui")

	container.Name = "React"
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.ClipToDeviceSafeArea = false
	container.Parent = playerGui
	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(RootUI)
	root:render(app)

	local head = player.Character:WaitForChild("Head", 10)
	local overheadFolder = Instance.new("Folder")
	overheadFolder.Name = "o_Folder"
	overheadFolder.Parent = head
	local o_root = ReactRoblox.createRoot(overheadFolder)
	local o_app = React.createElement(CharacterOverhead, {
		player = player,
		adornee = head,
	})
	o_root:render(o_app)
end

-- PLS HELP
