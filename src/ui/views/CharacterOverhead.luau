local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).client
local Text = require(ReplicatedStorage.UI.components.Text)

type CharProps = {
	player: Player,
	adornee: BasePart?,
}

-- local networker =	Networker.
local e = React.createElement

local function CharacterOverhead(props: CharProps)
	local player = props.player

	-- Initiate Variable
	local initialRealm = 1
	local initialRealmName = "Loading..."

	-- Input Variable with existing Data
	if Data and Data.realm then
		initialRealm = Data.realm()
	end
	initialRealmName = RealmServiceUtils.RealmName(initialRealm)

	-- Initiate State
	local realmLevel, setRealmLevel = React.useState(initialRealm)
	local realmName, setRealmName = React.useState(initialRealmName)

	React.useEffect(function()
		if not Data or not Data.realm then
			return
		end

		local conn = Data.realm.Changed(function(newRealm)
			setRealmLevel(newRealm)

			local newRealmName = RealmServiceUtils.RealmName(newRealm)
			setRealmName(newRealmName)
		end)

		return conn
	end, {})

	return e("BillboardGui", {
		AlwaysOnTop = true,
		MaxDistance = 150,
		ResetOnSpawn = false,
		Adornee = props.adornee,

		-- quesstionable
		Size = UDim2.fromScale(10, 2),
		StudsOffset = Vector3.new(0, 2, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.1, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Realm = e(Text, {
			text = realmName, -- HAVE TO MAKE IT DYNAMIC
			size = UDim2.fromScale(1, 0.6),
			textColor3 = Color3.fromRGB(255, 255, 0),
		}),

		PlayerUName = e(Text, {
			text = "@" .. (player and player.Name or "HACKER"), -- HAVE TO MAKE IT DYNAMIC
			size = UDim2.fromScale(1, 0.3),
			layoutOrder = 1,
		}),
	})
end

return CharacterOverhead
