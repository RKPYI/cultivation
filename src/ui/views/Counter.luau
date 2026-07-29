local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local CounterItem = require(ReplicatedStorage.UI.components.CounterItem)

export type CounterProps = {
	currency: string,
	image: string?,
}

local e = React.createElement

local function Counter(props: CounterProps)
	return e("Frame", {
		Size = UDim2.fromScale(0.12, 0.5),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),

		CounterComponent = e(CounterItem, {
			currency = props.currency,
			image = props.image,
			persecCounter = true,
		}),
	})
end

return Counter
