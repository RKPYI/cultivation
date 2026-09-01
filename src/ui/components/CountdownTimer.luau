local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local LeaderboardServiceUtils = require(ReplicatedStorage.Shared.Services.LeaderboardService.LeaderboardServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type CountdownProps = {
	targetTime: number,
}

local function CountdownTimer(props: CountdownProps)
	local timeLeft, setTImeLeft = React.useState(function()
		return math.max(0, props.targetTime - os.time())
	end)

	React.useEffect(function()
		setTImeLeft(math.max(0, props.targetTime - os.time()))

		local running = true
		task.spawn(function()
			while running do
				task.wait(1)
				local remaining = math.max(0, props.targetTime - os.time())
				setTImeLeft(remaining)
			end
		end)

		return function()
			running = false
		end
	end, { props.targetTime })

	return e(Text, {
		size = UDim2.fromScale(1, 0.05),
		pos = UDim2.fromScale(0, 0.94),
		text = "Refreshes in: " .. LeaderboardServiceUtils.formatTime(timeLeft),
	})
end

return CountdownTimer
