local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local NPCServiceUtils = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceUtils)
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

	local function handleOptionClick(option: NPCServiceUtils.OptionProps)
		if option.action then
			props.onAction(option.action, option.actionParam)
		end

		if option.nextId then
			setCurrentNodeId(option.nextId)
		else
			props.onClose()
		end
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

		OptionsList = e(
			"Frame",
			{
				Size = UDim2.fromScale(0.96, 0.25),
				Position = UDim2.fromScale(0.02, 0.65),
				BackgroundTransparency = 1,
			},
			(function()
				local optionCount = #currentNode.options
				local totalGapScale = 0.05 * (optionCount - 1)
				local buttonScaleX = if optionCount > 0 then (1 - totalGapScale) / optionCount else 1

				local children = {
					UIListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
					}),
				}
				for idx, opt in currentNode.options do
					children["Opt_" .. idx] = e("TextButton", {
						Text = opt.label,
						Size = UDim2.fromScale(buttonScaleX, 1),
						BackgroundColor3 = Color3.fromRGB(170, 170, 0),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.GothamBlack,
						TextScaled = true,
						[React.Event.Activated] = function()
							handleOptionClick(opt)
						end,
					}, {
						UICorner = e("UICorner", {
							CornerRadius = UDim.new(0.05, 0),
						}),

						UIStroke = e("UIStroke", {
							Thickness = 2,
						}),
					})
				end
				return children
			end)()
		),
	})
end

return Dialogue
