local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local QuestServiceUtils = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type ProgressType = {
	currentAmount: number,
	targetAmount: number,
	isCompleted: boolean,
}

type QuestItemProps = {
	questId: string,
	progress: ProgressType,
}

local function QuestItem(props: QuestItemProps)
	local quest = QuestServiceUtils.Data[props.questId]
	if not quest then
		return nil
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.2),
	}, {
		PointerImage = e("ImageLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(-0.15, 0),
			Size = UDim2.fromScale(1, 0.3),
			Image = "rbxassetid://75395055043947",
			ScaleType = Enum.ScaleType.Fit,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				DominantAxis = Enum.DominantAxis.Height,
			}),
		}),

		QuestTitle = e(Text, {
			size = UDim2.fromScale(0.75, 0.3),
			text = quest.title,
			textColor3 = Color3.fromRGB(255, 255, 0),
			textXAlignment = Enum.TextXAlignment.Left,
		}),

		QuestDescription = e(Text, {
			pos = UDim2.fromScale(0, 0.4),
			size = UDim2.fromScale(1, 0.6),
			text = quest.description,
			textColor3 = Color3.fromRGB(211, 211, 211),
			textXAlignment = Enum.TextXAlignment.Left,
		}),

		QuestAmountLabel = e(Text, {
			pos = UDim2.fromScale(0.75, 0),
			size = UDim2.fromScale(0.2, 0.3),
			text = props.progress.currentAmount .. "/" .. props.progress.targetAmount,
			textColor3 = if props.progress.isCompleted
				then Color3.fromRGB(0, 255, 100)
				else Color3.fromRGB(255, 255, 255),
		}),
	})
end

return QuestItem
