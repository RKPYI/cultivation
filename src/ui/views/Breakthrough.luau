local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

-- type BreakthroughProps = {
-- 	text: string,
-- 	thickness: number?,
-- }

local function Breakthrough()
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
			Size = UDim2.fromScale(0.5, 1), -- xScale CHANGE TO DYNAMIC --> Percentage of qi / qiNeededtoBreakthrough
		}, {
			UICorner = e("UICorner"),
		}),
		Percent = e(Text, {
			text = "50%", -- Percentage AMOUNT --> {Percent}%
			size = UDim2.fromScale(0.1, 1),
			pos = UDim2.new(1, 5, 0, 0),
		}),
		qiText = e(Text, {
			text = "1 / 10", -- playerQi / qiNeededtoBreakthrough --> useSuffix
			pos = UDim2.new(0, 0, 0.5, 20),
		}),
		BreakthroughButton = e("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 0),
			Position = UDim2.new(0.4, 0, 2, 20),
			Size = UDim2.fromScale(0.2, 2),
			Visible = false, -- Visible if percentage AMOUNT = 100%
			Font = Enum.Font.GothamBlack,
			TextScaled = true,
			Text = "BREAKTHROUGH",
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
				PaddingTop = UDim.new(0.01, 0),
				PaddingLeft = UDim.new(0.01, 0),
				PaddingBottom = UDim.new(0.01, 0),
				PaddingRight = UDim.new(0.01, 0),
			}),
		}),
	})
end

return Breakthrough
