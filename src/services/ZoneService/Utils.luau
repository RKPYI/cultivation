local Zone = {}

export type ZoneInfo = {
	realmReq: number,
	qiMultiplier: number,
}

Zone.Data = {
	Area1 = {
		realmReq = 1,
		qiMultiplier = 1,
	},
	Area2 = {
		realmReq = 21,
		qiMultiplier = 2,
	},
	Area3 = {
		realmReq = 41,
		qiMultiplier = 4,
	},
	Area4 = {
		realmReq = 61,
		qiMultiplier = 8,
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
