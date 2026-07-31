local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local SettingServiceClient = require(ReplicatedStorage.Shared.Services.SettingService.SettingServiceClient)
local SoundServiceUtils = require(ReplicatedStorage.Shared.Services.SoundService.SoundServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).client
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type SettingItemProps = {
	name: string,
}

local function SettingItem(props)
	local settingName = props.name:lower()
	local setting = Data.settings[settingName]
	if setting == nil then
		return e(Text, { text = "SETTING NOT FOUND: " .. props.name })
	end

	local initialColor = if setting then Color3.fromRGB(0, 255, 0) else Color3.fromRGB(255, 0, 0)
	local initialButton = if setting then "ON" else "OFF"

	local bgColor, setBgColor = React.useState(initialColor)
	local textBtn, setTextBtn = React.useState(initialButton)

	local function toggleSetting()
		SettingServiceClient:toggleSetting(settingName)
		SoundServiceUtils.playClick()
	end

	local function updateState(bool: boolean)
		if bool then
			setBgColor(Color3.fromRGB(0, 255, 0))
			setTextBtn("ON")
		else
			setBgColor(Color3.fromRGB(255, 0, 0))
			setTextBtn("OFF")
		end
	end

	React.useEffect(function()
		updateState(setting())

		local conn = setting.Changed(function(bool)
			updateState(bool)
		end)

		return conn
	end, {})

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.45, 0.12),
	}, {
		SettingName = e(Text, {
			text = props.name,
			size = UDim2.fromScale(0.6, 1),
			thickness = 3,
			textXAlignment = Enum.TextXAlignment.Left,
		}),

		Toggle = e("TextButton", {
			BackgroundColor3 = bgColor,
			Position = UDim2.fromScale(0.8, 0),
			Size = UDim2.fromScale(0.2, 1),
			Font = Enum.Font.GothamBlack,
			Text = textBtn,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			[React.Event.MouseEnter] = function()
				SoundServiceUtils.playHover()
			end,
			[React.Event.Activated] = toggleSetting,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.3, 0),
			}),

			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0.1, 0),
				PaddingRight = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.1, 0),
				PaddingTop = UDim.new(0.1, 0),
			}),

			UIStrokeText = e("UIStroke", {
				Thickness = 3,
			}),

			UIStroke = e("UIStroke", {
				Thickness = 3,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		}),
	})
end

return SettingItem
