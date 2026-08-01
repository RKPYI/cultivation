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

function Zone.CalculateDist(zone: Part, callback: (boolean) -> ())
	zone.Touched:Connect(function(hit)
		if game.Players:GetPlayerFromCharacter(hit.Parent) then
			callback(true)
		end
	end)

	zone.TouchEnded:Connect(function(hit)
		if game.Players:GetPlayerFromCharacter(hit.Parent) then
			callback(false)
		end
	end)
end

return Zone
