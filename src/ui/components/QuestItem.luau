local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local React = require(ReplicatedStorage.Packages.React)
local QuestServiceUtils = require(ReplicatedStorage.Shared.Services.QuestService.QuestServiceUtils)
local TutorialBeamManager = require(ReplicatedStorage.Shared.TutorialBeamManager)
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

local function getInstanceFromPath(pathString: string): Instance?
    local current: Instance = Workspace
    for _, segment in string.split(pathString, "/") do
        current = current:FindFirstChild(segment)
        if not current then
            return nil
        end
    end
    return current
end

local function QuestItem(props: QuestItemProps)
	local quest = QuestServiceUtils.Data[props.questId]
	if not quest then
		return nil
	end

	local isCompleted = props.progress.isCompleted

	React.useEffect(function()
        if isCompleted and quest.npcPath then
            local npcInstance = getInstanceFromPath(quest.npcPath)
            if npcInstance then
                TutorialBeamManager.setTarget(npcInstance)
            end
        end
    end, { isCompleted, quest.npcPath })

    -- Manual click handler to guide the player to the NPC at any time
    local function trackNPC()
        if quest.npcPath then
            local npcInstance = getInstanceFromPath(quest.npcPath)
            if npcInstance then
                TutorialBeamManager.setTarget(npcInstance)
            end
        end
    end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.2),
	}, {
		PointerButton = e("ImageButton", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(-0.15, 0),
			Size = UDim2.fromScale(1, 0.3),
			Image = "rbxassetid://75395055043947",
			ScaleType = Enum.ScaleType.Fit,
			[React.Event.Activated] = trackNPC,
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
