--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {}

export type OverheadServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: OverheadServiceServer) -> (),
	start: (self: OverheadServiceServer) -> (),
	OnPlayerAdded: (self: OverheadServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: OverheadServiceServer, player: Player) -> (),

	OnCharacterAdded: (self: OverheadServiceServer, player: Player, character: Model) -> (),
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local OverheadServiceServer = {} :: OverheadServiceServer
local overheadTemplate = ServerStorage:WaitForChild("OverheadGui") :: BillboardGui

-- Setup
function OverheadServiceServer.init(self: OverheadServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"OverheadService",
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

function OverheadServiceServer.OnPlayerAdded(self: OverheadServiceServer, player: Player)
	if player.Character then
		self:OnCharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		self:OnCharacterAdded(player, character)
	end)
end

function OverheadServiceServer.OnPlayerRemoving(self: OverheadServiceServer, player: Player) end

function OverheadServiceServer.start(self: OverheadServiceServer) end

function OverheadServiceServer.OnCharacterAdded(self: OverheadServiceServer, player: Player, character: Model)
	local head = character:WaitForChild("Head", 10) :: BasePart?
	if not head then
		return
	end

	local overhead = overheadTemplate:Clone()
	overhead.Adornee = head

	local PlayerUName = overhead:FindFirstChild("PlayerUName") :: TextLabel?
	if PlayerUName then
		PlayerUName.Text = "@" .. player.Name
	end

	overhead.Parent = head

	task.spawn(function()
		while not Data[player] and player:IsDescendantOf(Players) do
			task.wait(0.1)
		end

		if not player:IsDescendantOf(Players) then
			return
		end
		-- Function that need player data
		local RealmLabel = overhead:FindFirstChild("Realm") :: TextLabel?
		if not RealmLabel then
			return
		end

		local function updateRealmDisplay(realm: number)
			RealmLabel.Text = RealmServiceUtils.RealmName(realm)
		end

		-- Initial Display
		updateRealmDisplay(Data[player].realm())

		-- Update Display on Breakthrough
		Data[player].realm.Changed(function(newRealm)
			if head:IsDescendantOf(game) then
				updateRealmDisplay(newRealm)
			end
		end)
	end)
end
return OverheadServiceServer
