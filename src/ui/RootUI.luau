local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local FloatingQiText = require(ReplicatedStorage.UI.components.FloatingQiText)
local Counter = require(ReplicatedStorage.UI.views.Counter)
local FloatingTextContainer = require(ReplicatedStorage.UI.views.FloatingTextContainer)
-- local Menu = require(ReplicatedStorage.UI.views.Menu)
local e = React.createElement

local function RootUI()
	return e(React.Fragment, nil, {
		qiCounter = e(Counter, {
			currency = "qi",
		}),
		-- FloatingQiContainer = e(FloatingQiText, {
		-- 	Text = "+1 Qi",
		-- 	startPos = Vector2.new(0, 0),
		-- }),
	})
end

return RootUI
