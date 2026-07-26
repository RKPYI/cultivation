local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Data = require(ReplicatedStorage.Shared.Data).client
local BigNum = require(ReplicatedStorage.Shared.BigNum)

local e = React.createElement

type CounterProps = {
	currency: string,
	image: string?,
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

		return function()
			conn:Disconnect()
		end
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
					Label = e("TextLabel", {
						BackgroundTransparency = 1,
						TextScaled = true,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Size = UDim2.fromScale(1, 1),
						Font = Enum.Font.GothamBlack,
						Text = amount,
						-- Weight = Enum.FontWeight.Black,
						TextXAlignment = Enum.TextXAlignment.Left,
					}, {
						UIStroke = e("UIStroke", {
							Thickness = 2,
						}),
					}),
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
