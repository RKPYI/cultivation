local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)

type CharProps = {
	adornee: BasePart?,
}

local e = React.createElement

local function CharacterOverhead(props: CharProps)
	return e("BillboardGui", {
		AlwaysOnTop = true,
		MaxDistance = 150,
		ResetOnSpawn = false,
		Adornee = props.adornee,

		-- quesstionable
		Size = UDim2.fromScale(7, 2),
		StudsOffset = Vector3.new(0, 2, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.1, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Realm = e(Text, {
			text = "Qi Refining I", -- HAVE TO MAKE IT DYNAMIC
			size = UDim2.fromScale(1, 0.6),
			textColor3 = Color3.fromRGB(255, 255, 0),
		}),

		PlayerUName = e(Text, {
			text = "@johndoe", -- HAVE TO MAKE IT DYNAMIC
			size = UDim2.fromScale(1, 0.3),
			layoutOrder = 1,
		}),
	})
end

return CharacterOverhead
