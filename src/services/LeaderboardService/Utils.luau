local LeaderboardServiceUtils = {}

function LeaderboardServiceUtils.formatTime(seconds: number): string
	if seconds <= 0 then
		return "Refreshing..."
	end

	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

return LeaderboardServiceUtils
