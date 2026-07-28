local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local QiServiceClient = require(ReplicatedStorage.Shared.Services.QiService.QiServiceClient)
local Text = require(ReplicatedStorage.UI.components.Text)

local e = React.createElement

type QiProps = {}

local BASE_SIZE = UDim2.fromScale(0.75, 1)

local popInInfo = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local popOutInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function QiGranted(props: QiProps)
	local scaleRef = React.useRef(nil)

	local show, setShow = React.useState(false)
	local amount, setAmount = React.useState(BigNum.fromNumber(0))
	local amountText, setAmountText = React.useState("NIL")

	React.useEffect(function()
		local signal = QiServiceClient:QiGranted()
		if not signal then
			return
		end

		local hideThread: thread? = nil

		local conn = signal:Connect(function(newAmount)
			-- Add Amount and Update the Text
			setAmount(function(prevAmount)
				local totalAmount = BigNum.add(prevAmount, newAmount)

				setAmountText("+" .. BigNum.toSuffix(totalAmount))

				return totalAmount
			end)

			setShow(true)

			-- Animation
			if scaleRef.current then
				local uiScale = scaleRef.current :: TextLabel

				local popInTween = TweenService:Create(uiScale, popInInfo, { Scale = 1.2 })
				local popOutTween = TweenService:Create(uiScale, popOutInfo, { Scale = 1 })

				popInTween:Play()
				popInTween.Completed:Once(function()
					popOutTween:Play()
				end)
			end

			-- Cancel Hide
			if hideThread then
				task.cancel(hideThread)
			end

			-- Hide text within 2 sec of no data
			hideThread = task.delay(2, function()
				setShow(false)
				setAmount(BigNum.fromNumber(0))
				setAmountText("NIL")
			end)
		end)

		return function()
			conn:Disconnect()
			if hideThread then
				task.cancel(hideThread)
			end
		end
	end, {})

	return e(Text, {
		scaleRef = scaleRef,
		size = BASE_SIZE,
		pos = UDim2.fromScale(0.5, 1.5),
		text = amountText,
		visible = show,
		anchorPoint = Vector2.new(0.5, 0.5),
	})
end

return QiGranted
