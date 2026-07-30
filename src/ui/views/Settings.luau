local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local SettingItem = require(ReplicatedStorage.UI.components.SettingItem)
local e = React.createElement

local function Settings(props)
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.8),
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 2,
		}),

		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.1, 0),
			Wraps = true,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0.05, 0),
			PaddingTop = UDim.new(0.05, 0),
		}),

		Music = e(SettingItem, {
			name = "Music",
		}),

		Sfx = e(SettingItem, {
			name = "Sfx",
		}),
	})
end

return Settings
