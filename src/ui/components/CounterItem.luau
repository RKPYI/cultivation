local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Data = require(ReplicatedStorage.Shared.Data).client
local BigNum = require(ReplicatedStorage.Shared.BigNum)

local e = React.createElement

type CounterProps = {
	currency: string,
}

local function Capitalize(letter: string)
	return letter:sub(1, 1):upper() .. letter:sub(2)
end

local function CounterItem(props: CounterProps)
	local initialValue: BigNum.BN = BigNum.fromNumber(0)
	if Data[props.currency] then
		print("Initialized Already Getting it.")
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

return CounterItem
