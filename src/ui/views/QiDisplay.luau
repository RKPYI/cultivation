local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local QiServiceClient = require(ReplicatedStorage.Shared.Services.QiService.QiServiceClient)
local AnimatedImage = require(ReplicatedStorage.UI.components.AnimatedImage)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type QiDisplayProps = {
	isInZone: boolean,
}

local function QiDisplay(props: QiDisplayProps)
	local qiText, setQiText = React.useState("x1")

	React.useEffect(function()
		local signal = QiServiceClient:QiGranted()
		if not signal then
			return
		end

		local conn = signal:Connect(function(qiAmount: BigNum.BN)
			if qiAmount then
				local formattedText = "x" .. BigNum.toSuffix(qiAmount)
				setQiText(formattedText)
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Size = UDim2.fromScale(0.05, 0.5),
		Position = UDim2.fromScale(0.9, 0.05),
		Visible = props.isInZone,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		UIStroke = e("UIStroke", {
			Thickness = 5,
			Transparency = 0.75,
		}),
		Animation = props.isInZone and e(AnimatedImage, {
			Image = "rbxassetid://130535446222552",
			FrameWidth = 1024 / 11,
			FrameHeight = 1024 / 11,
			Columns = 11,
			TotalFrames = 121,
			FPS = 30,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
		Text = e(Text, {
			anchorPoint = Vector2.new(0.5, 0.5),
			pos = UDim2.fromScale(0.5, 0.8),
			size = UDim2.fromScale(1, 0.25),
			text = qiText,
			zIndex = 2,
		}),
	})
end

return QiDisplay
