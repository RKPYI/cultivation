local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local NPCServiceUtils = require(ReplicatedStorage.Shared.Services.NPCService.NPCServiceUtils)
local SoundServiceUtils = require(ReplicatedStorage.Shared.Services.SoundService.SoundServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type OptionProps = {
	currentNode: NPCServiceUtils.DialogueNode,
	callback: () -> (),
	onAction: () -> (),
	onClose: () -> (),
}

local function DialogueOptions(props: OptionProps)
	local currentNode = props.currentNode

	local function ButtonColor(opt): Color3
		if not opt.action then
			return Color3.fromRGB(191, 191, 191)
		end

		if opt.action == "AcceptQuest" then
			return Color3.fromRGB(44, 188, 0)
		end

		if opt.action == "CompleteQuest" then
			return Color3.fromRGB(255, 255, 0)
		end

		return Color3.fromRGB(191, 191, 191)
	end

	local function handleOptionClick(option: NPCServiceUtils.OptionProps)
		SoundServiceUtils.playClick()

		if option.action then
			if option.action == "AcceptQuest" then
				SoundServiceUtils.playAcceptQuest()
			end
			if option.action == "CompleteQuest" then
				SoundServiceUtils.playCompleteQuest()
			end

			props.onAction(option.action, option.actionParam)
		end

		if option.nextId then
			props.callback(option.nextId)
		else
			props.onClose()
		end
	end

	React.useEffect(function()
		local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			local keyPressed = nil
			if input.KeyCode.Value >= Enum.KeyCode.One.Value and input.KeyCode.Value <= Enum.KeyCode.Nine.Value then
				keyPressed = input.KeyCode.Value - Enum.KeyCode.One.Value + 1
			elseif
				input.KeyCode.Value >= Enum.KeyCode.KeypadOne.Value
				and input.KeyCode.Value <= Enum.KeyCode.KeypadNine.Value
			then
				keyPressed = input.KeyCode.Value - Enum.KeyCode.KeypadOne.Value + 1
			end

			if not keyPressed then
				return
			end

			for _, opt in currentNode.options do
				if opt.order == keyPressed then
					handleOptionClick(opt)
					break
				end
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, { props.currentNode })

	return e(
		"Frame",
		{
			Size = UDim2.fromScale(0.9, 0.2),
			Position = UDim2.fromScale(0.05, 0.65),
			BackgroundTransparency = 1,
		},
		(function()
			local optionCount = #currentNode.options
			local totalGapScale = 0.05 * (optionCount - 1)
			local buttonScaleX = if optionCount > 0 then (1 - totalGapScale) / optionCount else 1
			buttonScaleX = math.clamp(buttonScaleX, 0, 0.45)

			local children = {
				UIListLayout = e("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
				}),
			}
			for idx, opt in currentNode.options do
				children["Opt_" .. idx] = e("TextButton", {
					Text = "",
					Size = UDim2.fromScale(buttonScaleX, 1),
					BackgroundColor3 = ButtonColor(opt),
					LayoutOrder = opt.order,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamBlack,
					TextScaled = true,
					[React.Event.MouseEnter] = function()
						SoundServiceUtils.playHover()
					end,
					[React.Event.Activated] = function()
						handleOptionClick(opt)
					end,
				}, {
					Order = e(Text, {
						size = UDim2.fromScale(0.1, 1),
						text = "[" .. opt.order .. "]",
					}),

					Text = e(Text, {
						pos = UDim2.fromScale(0.15, 0),
						size = UDim2.fromScale(0.85, 1),
						text = opt.label,
					}),

					UIPadding = e("UIPadding", {
						PaddingBottom = UDim.new(0.1, 0),
						PaddingTop = UDim.new(0.1, 0),
						PaddingLeft = UDim.new(0.1, 0),
						PaddingRight = UDim.new(0.1, 0),
					}),

					UICorner = e("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),

					UIStroke = e("UIStroke", {
						Thickness = 2,
					}),
				})
			end
			return children
		end)()
	)
end

return DialogueOptions
