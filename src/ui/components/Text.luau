local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type TextProps = {
	text: string,
	thickness: number?,
	size: UDim2?,
	pos: UDim2?,
	textColor3: Color3?,
	layoutOrder: number?,
}

local function Text(props: TextProps)
	local thickness = props.thickness or 2
	local size = props.size or UDim2.fromScale(1, 1)
	local pos = props.pos or UDim2.fromOffset(0, 0)
	local textColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255)
	local layoutOrder = props.layoutOrder or 0
	return e("TextLabel", {
		BackgroundTransparency = 1,
		TextScaled = true,
		TextColor3 = textColor3,
		Size = size,
		Position = pos,
		Font = Enum.Font.GothamBlack,
		Text = props.text,
		LayoutOrder = layoutOrder,
	}, {
		UIStroke = e("UIStroke", {
			Thickness = thickness,
		}),
	})
end

return Text
