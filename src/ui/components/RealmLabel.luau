local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type RealmLabelProps = {
	realmName: string,
	lvlStart: number,
}

local function RealmLabel(props: RealmLabelProps)
	local lvlEnd = props.lvlStart + 9 -- Ex: Lvl 1-10
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 100),
		LayoutOrder = props.lvlStart,
	}, {
		Level = e(Text, {
			size = UDim2.fromScale(0.2, 1),
			text = props.lvlStart .. " - " .. lvlEnd,
			textSize = 50,
		}),

		RealmName = e(Text, {
			pos = UDim2.fromScale(0.3, 0),
			size = UDim2.fromScale(0.7, 1),
			text = props.realmName,
		}),
	})
end

return RealmLabel
