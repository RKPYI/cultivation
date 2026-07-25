local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local CharacterOverhead = require(ReplicatedStorage.UI.views.CharacterOverhead)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {}

export type UIServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: UIServiceServer) -> (),
	start: (self: UIServiceServer) -> (),
	OnPlayerAdded: (self: UIServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: UIServiceServer, player: Player) -> (),

	-- ... Add More Functions Here
	MountCharacterOverhead: (self: UIServiceServer, player: Player, character: Model) -> (),

	-- Networker
	networker: any,
}

local UIServiceServer = {} :: UIServiceServer
local activeRoots = {}

local function cleanupOverhead(character: Model)
	if activeRoots[character] then
		activeRoots[character]:unmount()
		activeRoots[character] = nil
	end
end

-- Setup
function UIServiceServer.init(self: UIServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"UIService",
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

function UIServiceServer.OnPlayerAdded(self: UIServiceServer, player: Player)
	player.CharacterAdded:Connect(function(char)
		self.MountCharacterOverhead(self, player, char)
	end)

	player.CharacterRemoving:Connect(cleanupOverhead)
end

function UIServiceServer.OnPlayerRemoving(self: UIServiceServer, player: Player)
	player.CharacterRemoving:Connect(cleanupOverhead)
end

function UIServiceServer.start(self: UIServiceServer) end

function UIServiceServer.MountCharacterOverhead(self: UIServiceServer, player: Player, character: Model)
	local head = character:WaitForChild("Head", 10)
	if not head then
		return
	end

	local guiContainer = Instance.new("Folder")
	guiContainer.Name = "OverheadUI"
	guiContainer.Parent = head

	-- create React Root inside player head
	local root = ReactRoblox.createRoot(guiContainer)
	activeRoots[character] = root

	-- local playerRealm = RealmServiceUtils.RealmName(1) -- NOT IMPLEMENTED YET
	local e = React.createElement
	local element = e(CharacterOverhead, {
		adornee = head,
	})

	root:render(element, { adornee = head })
end

return UIServiceServer
