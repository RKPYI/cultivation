local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type TextProps = {
	text: string,
	textXAlignment: Enum.TextXAlignment?,
	thickness: number?,
	size: UDim2?,
	pos: UDim2?,
	textColor3: Color3?,
	layoutOrder: number?,
	visible: boolean?,
	anchorPoint: Vector2?,

	ref: React.Ref<TextLabel>?,
	scaleRef: React.Ref<TextLabel>?,
}

local function Text(props: TextProps)
	local textXAlignment = props.textXAlignment or Enum.TextXAlignment.Center
	local thickness = props.thickness or 2
	local size = props.size or UDim2.fromScale(1, 1)
	local pos = props.pos or UDim2.fromOffset(0, 0)
	local textColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255)
	local layoutOrder = props.layoutOrder or 0
	local visible = if props.visible ~= nil then props.visible else true
	local anchorPoint = props.anchorPoint or Vector2.new(0, 0)
	return e("TextLabel", {
		ref = props.ref,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		TextScaled = true,
		TextXAlignment = textXAlignment,
		TextColor3 = textColor3,
		Size = size,
		Position = pos,
		Font = Enum.Font.GothamBlack,
		Text = props.text,
		LayoutOrder = layoutOrder,
		Visible = visible,
	}, {
		UIStroke = e("UIStroke", {
			Thickness = thickness,
		}),
		UIScale = e("UIScale", {
			ref = props.scaleRef,
		}),
	})
end

return Text
