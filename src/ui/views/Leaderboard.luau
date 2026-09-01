local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local LeaderboardServiceClient = require(ReplicatedStorage.Shared.Services.LeaderboardService.LeaderboardServiceClient)
local CountdownTimer = require(ReplicatedStorage.UI.components.CountdownTimer)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type LeaderboardProps = {
	Visible: boolean,
}

type LeaderboardEntry = {
	rank: number,
	userId: number,
	username: string,
	value: number | string,
}

local function Leaderboard(props: LeaderboardProps)
	local leaderboard, setLeaderboards = React.useState({ qi = {}, spiritStone = {}, realm = {} })
	local nextUpdate, setNextUpdate = React.useState(os.time() + 120) -- NOT DYNAMIC but its ok its just placeholder

	React.useEffect(function()
		task.spawn(function()
			local response = LeaderboardServiceClient:getLeaderboards()
			if response then
				if response.data then
					setLeaderboards(response.data)
				end
				if response.nextUpdate then
					setNextUpdate(response.nextUpdate)
				end
			end
		end)

		local conn = LeaderboardServiceClient.OnUpdated:Connect(
			function(key: string, updatedData: any, newNextUpdated: number?)
				setLeaderboards(function(prev)
					local updated = table.clone(prev)
					updated[key] = updatedData
					return updated
				end)

				if newNextUpdated then
					setNextUpdate(newNextUpdated)
				end
			end
		)

		return function()
			conn:Disconnect()
		end
	end, {})

	local entryChildren = {
		UIListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),
	}

	local realmList = leaderboard.realm or {}
	for idx, entry: LeaderboardEntry in realmList do
		entryChildren["Entry_" .. tostring(entry.userId or idx)] = e("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = idx,
			BackgroundColor3 = idx % 2 == 0 and Color3.fromRGB(30, 30, 25) or Color3.fromRGB(40, 40, 48),
			BackgroundTransparency = 0.2,
		}, {
			UICorner = e("UICorner", { CornerRadius = UDim.new(0, 6) }),

			RankText = e(Text, {
				size = UDim2.fromScale(0.15, 1),
				text = tostring(entry.rank or idx),
				textColor3 = idx <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200),
			}),

			NameText = e(Text, {
				pos = UDim2.fromScale(0.17, 0),
				size = UDim2.fromScale(0.55, 1),
				text = "@" .. entry.username or "JOE",
				textXAlignment = Enum.TextXAlignment.Left,
			}),

			ValueText = e(Text, {
				pos = UDim2.fromScale(0.73, 0),
				size = UDim2.fromScale(0.25, 1),
				text = entry.value,
				textColor3 = Color3.fromRGB(255, 255, 0),
				textXAlignment = Enum.TextXAlignment.Right,
			}),
		})
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Timer = e(CountdownTimer, {
			targetTime = nextUpdate,
		}),
		ListContainer = e("ScrollingFrame", {
			Size = UDim2.new(1, -16, 0.95, -55),
			Position = UDim2.fromOffset(8, 48),
			BackgroundTransparency = 1,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.fromScale(0, 0),
			ScrollBarThickness = 5,
		}, entryChildren),
	})
end

return Leaderboard
