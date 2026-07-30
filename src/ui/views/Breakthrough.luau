local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local RealmServiceClient = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceClient)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).client

local Player = Players.LocalPlayer
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

-- type BreakthroughProps = {
-- 	text: string,
-- 	thickness: number?,
-- }

local function Breakthrough()
	local progressBarRef = React.useRef(nil)

	local initialQiReq = BigNum.fromNumber(10)
	local initialQiAmount = BigNum.fromNumber(100)

	local qiReq, setQiReq = React.useState(initialQiReq)
	local qiAmount, setQiAmount = React.useState(initialQiAmount)
	local qiText = BigNum.toSuffix(qiAmount) .. " / " .. BigNum.toSuffix(qiReq)
	local rawPercentage = BigNum.div(qiAmount, qiReq)
	local percentage = math.clamp(BigNum.toNumber(rawPercentage), 0, 1)
	local breakthrough = percentage == 1

	-- Update Qi and QiReq
	React.useEffect(function()
		if not Data then
			return
		end

		setQiAmount(Data.qi())
		setQiReq(RealmServiceUtils.CalculateBreakthroughReq(Data.realm()))

		local qiConn = Data.qi.Changed(function(newQi)
			setQiAmount(newQi)
		end)

		local realmConn = Data.realm.Changed(function(newRealm)
			setQiReq(RealmServiceUtils.CalculateBreakthroughReq(newRealm))
		end)

		return function()
			qiConn()
			realmConn()
		end
	end, {})

	-- Smooth progress bar animation
	React.useEffect(function()
		local frame = progressBarRef.current
		if not frame then
			return
		end

		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local targetSize = UDim2.fromScale(percentage, 1)
		local tween = TweenService:Create(frame, tweenInfo, { Size = targetSize })

		tween:Play()

		return function()
			tween:Cancel()
		end
	end, { percentage })

	return e("Frame", {
		Position = UDim2.new(0.25, 0, 0, 10),
		Size = UDim2.new(0.5, 0, 0.025, 10),
	}, {
		UICorner = e("UICorner"),
		UIStroke = e("UIStroke", {
			Thickness = 2,
		}),
		currentProgress = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 0),
			ref = progressBarRef,
		}, {
			UICorner = e("UICorner"),
		}),
		Percent = e(Text, {
			text = string.format("%.2f%%", percentage * 100), -- Show max 2 decimal
			size = UDim2.fromScale(0.1, 1),
			pos = UDim2.new(1, 5, 0, 0),
		}),
		qiText = e(Text, {
			text = qiText,
			pos = UDim2.fromScale(0, 1.1),
		}),
		BreakthroughButton = e("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 0),
			Position = UDim2.new(0.4, 0, 2, 20),
			Size = UDim2.fromScale(0.2, 2),
			Visible = breakthrough,
			Font = Enum.Font.GothamBlack,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Text = "Breakthrough",

			[React.Event.Activated] = function()
				RealmServiceClient.networker:fire("Breakthrough")
			end,
		}, {
			UICorner = e("UICorner"),
			UIStroke = e("UIStroke", {
				Thickness = 2,
			}),
			UIStrokeOutside = e("UIStroke", {
				Thickness = 2,
				ApplyStrokeMode = "Border",
			}),
			UIPadding = e("UIPadding", {
				PaddingTop = UDim.new(0.01, 1),
				PaddingLeft = UDim.new(0.01, 1),
				PaddingBottom = UDim.new(0.01, 1),
				PaddingRight = UDim.new(0.01, 1),
			}),
		}),
	})
end

return Breakthrough
