local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local NPCServiceClient = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceClient)
local QuestServiceClient = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceClient)
local Modal = require(ReplicatedStorage.UI.components.Modal)
local Breakthrough = require(ReplicatedStorage.UI.views.Breakthrough)
local Counter = require(ReplicatedStorage.UI.views.Counter)
local Dialogue = require(ReplicatedStorage.UI.views.Dialogue)
local Inventory = require(ReplicatedStorage.UI.views.Inventory)
local Menu = require(ReplicatedStorage.UI.views.Menu)
local Quest = require(ReplicatedStorage.UI.views.Quest)
local Settings = require(ReplicatedStorage.UI.views.Settings)

local e = React.createElement

local function RootUI()
	local activeModal, setActiveModal = React.useState(nil)

	local handleOpen = React.useCallback(function(menuName: string)
		setActiveModal(function(prevMenuName)
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
	end, {})

	local function renderModalContent()
		if activeModal == "Settings" then
			return e(Settings)
		end

		if activeModal == "Inventory" then
			return e(Inventory)
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
			spiritImage = "rbxassetid://97406683523245",
		}),
		BreakthroughHUD = e(Breakthrough),
		Menu = e(Menu, {
			onOpenMenu = handleOpen,
		}),

		Modal = activeModal ~= nil and e(Modal, {
			text = activeModal,
			onClose = handleClose,
			children = renderModalContent(),
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
			end,
		}),
	})
end

return RootUI

-- 127597807958112
