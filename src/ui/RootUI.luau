local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Breakthrough = require(ReplicatedStorage.UI.views.Breakthrough)
local Counter = require(ReplicatedStorage.UI.views.Counter)

local e = React.createElement

local function RootUI()
	return e(React.Fragment, nil, {
		qiCounter = e(Counter, {
			currency = "qi",
			image = "rbxassetid://81588162443025",
		}),
		BreakthroughHUD = e(Breakthrough),
	})
end

return RootUI
