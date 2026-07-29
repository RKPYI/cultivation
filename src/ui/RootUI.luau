local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Modal = require(ReplicatedStorage.UI.components.Modal)
local Breakthrough = require(ReplicatedStorage.UI.views.Breakthrough)
local Counter = require(ReplicatedStorage.UI.views.Counter)
local Menu = require(ReplicatedStorage.UI.views.Menu)

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

	return e(React.Fragment, nil, {
		qiCounter = e(Counter, {
			currency = "qi",
			image = "rbxassetid://81588162443025",
		}),
		BreakthroughHUD = e(Breakthrough),
		Menu = e(Menu, {
			onOpenMenu = handleOpen,
		}),

		Modal = activeModal ~= nil and e(Modal, {
			text = activeModal,
			onClose = handleClose,
		}),
	})
end

return RootUI

-- 1:1 Image = rbxassetid://89760829760036
-- Shop Icon = rbxassetid://17368217589
-- rbxassetid://102114906009290
