local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Zone = {}

export type ZoneInfo = {
	realmReq: number,
	qiMultiplier: number,
}

Zone.Data = {
	Area1 = {
		realmReq = 1,
		qiMultiplier = 2 ^ 0,
	},
	Area2 = {
		realmReq = 21,
		qiMultiplier = 2 ^ 1,
	},
	Area3 = {
		realmReq = 41,
		qiMultiplier = 2 ^ 2,
	},
	Area4 = {
		realmReq = 61,
		qiMultiplier = 2 ^ 3,
	},
	Area5 = {
		realmReq = 81,
		qiMultiplier = 2 ^ 4,
	},
	Area6 = {
		realmReq = 101,
		qiMultiplier = 4 ^ 4,
	},
	Area7 = {
		realmReq = 111,
		qiMultiplier = 4 ^ 5,
	},
	Area8 = {
		realmReq = 121,
		qiMultiplier = 4 ^ 6,
	},
} :: { [string]: ZoneInfo }

function Zone.CalculateDist(zone: Part, callback: (player: Player, isInside: boolean) -> ())
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include

	local playersInZone: { [Player]: boolean } = {}

	task.spawn(function()
		while zone and zone.Parent do
			local rootParts = {}
			for _, player in Players:GetPlayers() do
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					table.insert(rootParts, player.Character.HumanoidRootPart)
				end
			end
			overlapParams.FilterDescendantsInstances = rootParts

			local partsInZone = workspace:GetPartsInPart(zone, overlapParams)
			local currentPlayers: { [Player]: boolean } = {}

			for _, part in partsInZone do
				local character = part.Parent
				if character then
					local player = Players:GetPlayerFromCharacter(character)
					if player then
						currentPlayers[player] = true
					end
				end
			end

			-- Fire enter callbacks
			for player in currentPlayers do
				if not playersInZone[player] then
					playersInZone[player] = true
					callback(player, true)
				end
			end

			-- Fire leave callbacks
			for player in playersInZone do
				if not currentPlayers[player] then
					playersInZone[player] = nil
					callback(player, false)
				end
			end

			task.wait(0.2)
		end
	end)
end

return Zone
