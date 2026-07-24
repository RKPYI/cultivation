local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RootUI = require(ReplicatedStorage.UI.RootUI)
local e = React.createElement

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = e(RootUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
