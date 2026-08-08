local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local NPCServiceClient = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceClient)
local NPCServiceUtils = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceUtils)
local QuestServiceClient = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceClient)
local Modal = require(ReplicatedStorage.UI.components.Modal)
local Breakthrough = require(ReplicatedStorage.UI.views.Breakthrough)
local Counter = require(ReplicatedStorage.UI.views.Counter)
local Dialogue = require(ReplicatedStorage.UI.views.Dialogue)
local Inventory = require(ReplicatedStorage.UI.views.Inventory)
local Menu = require(ReplicatedStorage.UI.views.Menu)
local NPCShop = require(ReplicatedStorage.UI.views.NPCShop)
local Quest = require(ReplicatedStorage.UI.views.Quest)
local Settings = require(ReplicatedStorage.UI.views.Settings)

local e = React.createElement

local function RootUI()
	local activeModal, setActiveModal = React.useState(nil)
	local activeShop, setActiveShop = React.useState(nil)

	local handleOpen = React.useCallback(function(menuName: string)
		setActiveModal(function(prevMenuName)
			setActiveShop(nil)
			-- If same button clicked twice, it closes the modal
			if menuName == prevMenuName then
				return nil
			else
				return menuName
			end
		end)
	end, {})

	local handleClose = React.useCallback(function()
		setActiveModal(nil)
		setActiveShop(nil)
	end, {})

	local function renderModalContent()
		if activeModal == "Settings" then
			return e(Settings)
		end

		if activeModal == "Inventory" then
			return e(Inventory)
		end

		if activeModal == "NPCShop" then
			return e(NPCShop, {
				shopId = activeShop,
			})
		end

		return nil
	end

	local activeNPC, setActiveNPC = React.useState(nil :: string?)

	React.useEffect(function()
		local conn = NPCServiceClient.OnNPCTriggered:Connect(function(npcId: string?)
			setActiveNPC(npcId)
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return e(React.Fragment, nil, {
		currencyCounter = e(Counter, {
			qi = "qi",
			qiImage = "rbxassetid://81588162443025",
			spiritStone = "spiritualStones",
			spiritImage = "rbxassetid://100281307393248",
		}),
		BreakthroughHUD = e(Breakthrough),
		Menu = e(Menu, {
			onOpenMenu = handleOpen,
		}),

		Modal = activeModal ~= nil and e(Modal, {
			text = activeShop and NPCServiceUtils.Shops[activeShop].shopName or activeModal,
			onClose = handleClose,
			children = renderModalContent(),
			background = activeShop and NPCServiceUtils.Shops[activeShop].background or "rbxassetid://138496797110912",
		}),

		Quest = e(Quest),

		DialogueModal = activeNPC ~= nil and e(Dialogue, {
			npcId = activeNPC,
			onClose = function()
				setActiveNPC(nil)
				NPCServiceClient:CloseNPC()
			end,
			onAction = function(action: string, param: string?)
				if action == "AcceptQuest" and param then
					QuestServiceClient:AcceptQuest(param)
				end
				if action == "CompleteQuest" and param then
					QuestServiceClient:CompleteQuest(param)
				end
				if action == "OpenShop" and param then
					setActiveNPC(nil)
					NPCServiceClient:CloseNPC()

					setActiveShop(param)
					setActiveModal("NPCShop")
				end
			end,
		}),
	})
end

return RootUI

-- Credits:
-- https://www.flaticon.com/free-icon/gems_3621938?related_id=3621888&origin=search
-- https://www.flaticon.com/free-icon/fire_1453025?term=fire&page=1&position=13&origin=search&related_id=1453025
