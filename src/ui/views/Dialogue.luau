local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local NPCServiceUtils = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceUtils)
local DialogueOptions = require(ReplicatedStorage.UI.components.DialogueOptions)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type DialogueProps = {
	npcId: string,
	onClose: () -> (),
	onAction: (action: string, params: string?) -> (),
}

local function Dialogue(props: DialogueProps)
	local npcData = NPCServiceUtils.Data[props.npcId] :: NPCServiceUtils.NPCConfig
	local currentNodeId, setCurrentNodeId = React.useState(npcData.initialNode or "")

	if not npcData then
		return nil
	end

	local currentNode = npcData.dialogues[currentNodeId]
	if not currentNode then
		return nil
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(20, 20, 35),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.25),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		NPCName = e(Text, {
			text = npcData.name .. " (" .. npcData.title .. ")",
			size = UDim2.fromScale(0.96, 0.15),
			pos = UDim2.fromScale(0.02, 0.05),
			textColor3 = Color3.fromRGB(255, 215, 0),
			textXAlignment = Enum.TextXAlignment.Left,
		}),

		NPCText = e(Text, {
			text = currentNode.text,
			size = UDim2.fromScale(0.96, 0.3),
			pos = UDim2.fromScale(0.02, 0.25),
		}),

		OptionsList = e(DialogueOptions, {
			currentNode = currentNode,
			callback = function(nextId)
				setCurrentNodeId(nextId)
			end,
			onAction = props.onAction,
			onClose = props.onClose,
		}),
	})
end

return Dialogue
