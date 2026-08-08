local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker).client

local networker = nil
local ItemServiceClient = {}

function ItemServiceClient.init(self)
	networker = Networker.new("ItemService", ItemServiceClient)
end

function ItemServiceClient.ToggleEquipItem(self, item: string)
	networker:fire("toggleEquipItem", item)
end

function ItemServiceClient.turnOffNotification(self)
	print("ITEMSERVICECLIENT: TURNING OFF NOTIFICATION")
	networker:fire("turnOffNotification")
end

function ItemServiceClient.NPCShopBuyItem(self, itemId: string)
	networker:fire("buyItem", itemId)
end

return ItemServiceClient
