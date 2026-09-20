local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local GamepassServiceUtils = require(ReplicatedStorage.Shared.Services.GamepassService.GamepassServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type DetailPanelProps = {
	activePassData: GamepassServiceUtils.GamepassConfig?,
	selectedPass: string?,
	isOwned: boolean,
	onPurchase: () -> (),
}

local function GamepassDetailPanel(props: DetailPanelProps)
	if not props.activePassData or not props.selectedPass then
		return e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.95, 0.47),
			Size = UDim2.fromScale(0.32, 0.75),
			BackgroundTransparency = 1,
		}, {
			EmptyText = e("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Text = "Select a Gamepass to view details",
				TextColor3 = Color3.fromRGB(150, 150, 160),
				TextWrapped = true,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
		})
	end

	local config = props.activePassData

	return e("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(25, 25, 32),
		BackgroundTransparency = 0.1,
		Position = UDim2.fromScale(0.95, 0.47),
		Size = UDim2.fromScale(0.32, 0.75),
	}, {
		UICorner = e("UICorner", { CornerRadius = UDim.new(0, 10) }),
		UIStroke = e("UIStroke", { Color = Color3.fromRGB(70, 70, 85), Thickness = 1.5 }),
		UIPadding = e("UIPadding", {
			PaddingTop = UDim.new(0.1, 0),
			PaddingBottom = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
		}),

		PreviewIcon = e("ImageLabel", {
			Size = UDim2.fromOffset(90, 90),
			Position = UDim2.fromScale(0.5, 0.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = config.iconId,
			BackgroundTransparency = 1,
		}),

		PassTitle = e(Text, {
			pos = UDim2.fromScale(0.5, 0.4),
			size = UDim2.new(1, 0, 0, 25),
			anchorPoint = Vector2.new(0.5, 0.5),
			text = config.name,
		}),

		PassDescription = e(Text, {
			size = UDim2.new(1, 0, 0, 60),
			pos = UDim2.fromScale(0.5, 0.58),
			anchorPoint = Vector2.new(0.5, 0.5),
			text = config.description,
			textColor3 = Color3.fromRGB(190, 190, 200),
		}),

		ActionButton = e("TextButton", {
			Size = UDim2.new(1, 0, 0, 42),
			Position = UDim2.fromScale(0.5, 0.92),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = props.isOwned and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(0, 140, 240),
			Text = props.isOwned and "OWNED" or "BUY",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			AutoButtonColor = not props.isOwned,
			[React.Event.Activated] = function()
				if not props.isOwned then
					props.onPurchase()
				end
			end,
		}, {
			UICorner = e("UICorner", { CornerRadius = UDim.new(0, 8) }),
		}),
	})
end

return GamepassDetailPanel
