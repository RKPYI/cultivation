local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local Data = require(ReplicatedStorage.Shared.Data).client
local ZoneServiceClient = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceClient)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

local ACTION_CULTIVATE = "ToggleCultivationAction"

local function MobileControls(props)
	local isTouchDevice = React.useMemo(function()
		return UserInputService.TouchEnabled -- and not UserInputService.KeyboardEnabled
	end, {})

	local isCultivating, setIsCultivating = React.useState(false)
	local currentZone, setCurrentZone = React.useState(nil :: string?)
	local playerRealm, setPlayerRealm = React.useState(Data.realm() or 0)

	React.useEffect(function()
		local cultSignal = ZoneServiceClient:onCultivationStateChanged()
		local zoneSignal = ZoneServiceClient:OnZoneChanged()

		local connCult = cultSignal:Connect(setIsCultivating)
		local connZone = zoneSignal:Connect(setCurrentZone)
		local connRealm = Data.realm.Changed(setPlayerRealm)

		return function()
			connCult:Disconnect()
			connZone:Disconnect()
			connRealm()
		end
	end, {})

	local canCultivate = React.useMemo(function()
		if not currentZone then
			return false
		end

		local zoneData = ZoneServiceUtils.Data[currentZone]
		return zoneData and playerRealm >= zoneData.realmReq
	end, { currentZone, playerRealm })

	local toggleCultivation = React.useCallback(function()
		if canCultivate or isCultivating then
			ZoneServiceClient:toggleCultivation(not isCultivating)
		end
	end, { canCultivate, isCultivating })

	React.useEffect(function()
		ContextActionService:BindAction(
			ACTION_CULTIVATE,
			function(actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
				if inputState == Enum.UserInputState.Begin then
					toggleCultivation()
				end
			end,
			false, -- false to disable to default button
			Enum.KeyCode.C
		)

		return function()
			ContextActionService:UnbindAction(ACTION_CULTIVATE)
		end
	end, { toggleCultivation })

	local buttonColor = if isCultivating
		then Color3.fromRGB(80, 200, 120)
		elseif canCultivate then Color3.fromRGB(80, 176, 200)
		else Color3.fromRGB(50, 50, 50)

	return e(React.Fragment, _, {
		Shortcut = canCultivate and e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.01, 0.95),
			Size = UDim2.fromScale(0.1, 0.03),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 6,
			}),
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			Description = e(Text, {
				pos = UDim2.fromScale(0.4, 0),
				size = UDim2.fromScale(0.5, 1),
				text = "Cultivate",
			}),

			ShortcutContainer = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 107, 109),
				BackgroundTransparency = 0.25,
				Size = UDim2.fromScale(0.3, 1),
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				UIStroke = e("UIStroke", {
					Thickness = 2,
					Transparency = 0.25,
				}),

				Title = e(Text, {
					anchorPoint = Vector2.new(0.5, 0.5),
					pos = UDim2.fromScale(0.5, 0.5),
					size = UDim2.fromScale(0.8, 0.8),
					text = "C",
				}),
			}),
		}),

		Button = e("ImageButton", {
			BackgroundColor3 = buttonColor,
			BackgroundTransparency = 0.2,
			Position = UDim2.fromScale(0.8, 0.8),
			Size = UDim2.fromScale(0.05, 0.1),
			Visible = isTouchDevice,
			[React.Event.Activated] = toggleCultivation,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			UIStroke = e("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			}),
		}),
	})
end

return MobileControls
