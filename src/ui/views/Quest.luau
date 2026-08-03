local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local QuestItem = require(ReplicatedStorage.UI.components.QuestItem)
local Data = require(ReplicatedStorage.Shared.Data).client
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

local function Quest(props)
	local activeQuests, setActiveQuests = React.useState(Data.quests.active() or {})
	local isEmpty = next(activeQuests) == nil

	React.useEffect(function()
		setActiveQuests(Data.quests.active() or {})

		local conn = Data.quests.active.Changed(function(currentQuests)
			setActiveQuests(currentQuests or {})
		end)

		return function()
			conn()
		end
	end, {})

	local QuestListChildren = {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for questId, progressData in activeQuests do
		QuestListChildren["Quest_" .. questId] = e(QuestItem, {
			questId = questId,
			progress = progressData,
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.85, 0.3),
		Size = UDim2.fromScale(0.15, 0.5),
	}, {
		Title = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.1),
			Visible = not isEmpty,
		}, {
			Image = e("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Image = "rbxassetid://89978446111798",
				ScaleType = Enum.ScaleType.Fit,
			}),
			Text = e(Text, {
				text = "Quests",
			}),
		}),

		QuestList = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.12),
			Size = UDim2.fromScale(1, 0.88),
		}, QuestListChildren),
	})
end

return Quest
