local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Data = require(ReplicatedStorage.Shared.Data).client
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local QiGranted = require(ReplicatedStorage.UI.components.QiGranted)
local Text = require(ReplicatedStorage.UI.components.Text)

local e = React.createElement

type CounterProps = {
	currency: string,
	image: string?,
	persecCounter: boolean,
}

local function Capitalize(letter: string)
	return letter:sub(1, 1):upper() .. letter:sub(2)
end

local function CounterItem(props: CounterProps)
	local initialValue: BigNum.BN = BigNum.fromNumber(0)
	if Data[props.currency] then
		initialValue = Data[props.currency]()
	end

	local InitialValueString = BigNum.toSuffix(initialValue)

	local amount: string, setAmount = React.useState(InitialValueString)

	React.useEffect(function()
		if Data[props.currency]() then
			setAmount(BigNum.toSuffix(Data[props.currency]()))
		end

		local conn = Data[props.currency].Changed(function(newAmount)
			local newAmountFormatted = BigNum.toSuffix(newAmount)
			setAmount(newAmountFormatted)
		end)

		return conn
	end, {})

	if props.image then
		return e("Frame", {
			Size = UDim2.new(1, 0, 0.1, 20),
			BackgroundTransparency = 1,
		}, {
			Texture = e("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Image = props.image,
				ScaleType = Enum.ScaleType.Fit,
			}, {
				PosFrame = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(0.65, 0.6),
					Position = UDim2.fromScale(0.35, 0.25),
				}, {
					Label = e(Text, {
						text = amount,
						textXAlignment = Enum.TextXAlignment.Left,
					}),

					PerSecLabel = props.persecCounter and e(QiGranted),
				}),
			}),
		})
	else
		return e("Frame", {
			Size = UDim2.new(1, 0, 0.1, 20),
		}, {
			Label = e("TextLabel", {
				TextScaled = true,
				Size = UDim2.fromScale(1, 1),
				Font = Enum.Font.BuilderSansExtraBold,
				Text = amount .. " " .. Capitalize(props.currency),
			}),
		})
	end
end

return CounterItem
