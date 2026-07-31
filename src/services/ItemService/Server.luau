--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

type State = {}

export type ItemServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: ItemServiceServer) -> (),
	start: (self: ItemServiceServer) -> (),
	OnPlayerAdded: (self: ItemServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: ItemServiceServer, player: Player) -> (),

	toggleEquipItem: (self: ItemServiceServer, player: Player, item: string) -> (),
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local ItemServiceServer = {} :: ItemServiceServer

-- Setup
function ItemServiceServer.init(self: ItemServiceServer)
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"ItemService",
		self,
		{
			self.toggleEquipItem,
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

function ItemServiceServer.OnPlayerAdded(self: ItemServiceServer, player: Player)
	task.spawn(function()
		while not Data[player] and player:IsDescendantOf(Players) do
			task.wait(0.1)
		end

		if not player:IsDescendantOf(Players) then
			return
		end
	end)
end

function ItemServiceServer.OnPlayerRemoving(self: ItemServiceServer, player: Player) end

function ItemServiceServer.start(self: ItemServiceServer) end

function ItemServiceServer.toggleEquipItem(self: ItemServiceServer, player: Player, item: string)
	if not Data[player] then
		return
	end

	-- Check if Player actually have the item
	local inventoryItems = Data[player].inventory.item() or {}
	if not table.find(inventoryItems, item) then
		return
	end

	-- Check if item data exist
	local itemData = ItemServiceUtils.Data[item]
	if not itemData then
		return
	end

	-- Check if realm requirement is satisfied
	local playerRealm = Data[player].realm()
	if playerRealm < itemData.realmReq then
		return
	end

	-- Unequip if item is already equipped
	local playerCurrentItem = Data[player].inventory.itemEquipped()
	if playerCurrentItem == item then
		Data[player].inventory.itemEquipped("") -- Unequip
	else
		Data[player].inventory.itemEquipped(item) -- Equip
	end
end

return ItemServiceServer
