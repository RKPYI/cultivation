local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Counter = require(ReplicatedStorage.UI.views.Counter)

local e = React.createElement

local function RootUI()
	return e(React.Fragment, nil, {
		qiCounter = e(Counter, {
			currency = "qi",
		}),
	})
end

return RootUI
