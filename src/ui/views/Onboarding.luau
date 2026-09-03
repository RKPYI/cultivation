local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Data = require(ReplicatedStorage.Shared.Data).client
local TutorialServiceClient = require(ReplicatedStorage.Shared.Services.TutorialService.TutorialServiceClient)
local TutorialServiceUtils = require(ReplicatedStorage.Shared.Services.TutorialService.TutorialServiceUtils)
local Text = require(ReplicatedStorage.UI.components.Text)
local e = React.createElement

type OnboardingProps = {}

local goldColor = Color3.fromRGB(255, 190, 60)

local function Onboarding(props: OnboardingProps)
	local step, setStep = React.useState(Data.tutorialStep() or 1)
	local stepConfig = TutorialServiceUtils.Data[step]

	React.useEffect(function()
		local conn = Data.tutorialStep.Changed(function(newStep)
			setStep(newStep)
		end)

		return function()
			conn()
		end
	end, {})

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(18, 20, 26),
		BackgroundTransparency = 0.15,
		Position = UDim2.fromScale(0.5, 0.15),
		Size = UDim2.new(0.33, 0, 0.1, 20),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.15, 0),
		}),
		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
		}),
		UIStroke = e("UIStroke", {
			Color = goldColor,
			Thickness = 2,
		}),

		HeaderRow = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.3),
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.05, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			StepBadge = e(Text, {
				size = UDim2.fromScale(0.2, 1),
				bgColor3 = goldColor,
				bgTransparency = 0,
				text = step .. "/" .. TutorialServiceUtils.MAX_STEPS or "NO DATA MAX STEPS", -- DYNAMIC
				children = e(React.Fragment, {}, {
					UICorner = e("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
					UIStroke = e("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2 }),
				}),
			}),
			TitleText = e(Text, {
				size = UDim2.fromScale(0.75, 1),
				text = stepConfig.title or "NO DATA TITLE", -- DYNAMIC
				textXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
		InstructionRow = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.4),
			Size = UDim2.fromScale(1, 0.6),
		}, {
			InstructionText = e(Text, {
				size = UDim2.fromScale(0.8, 1),
				text = stepConfig.description or "NO DATA DESCRIPTION", -- DYNAMIC
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			NextButton = e("TextButton", {
				BackgroundColor3 = goldColor,
				Position = UDim2.fromScale(0.82, 0.4),
				Size = UDim2.fromScale(0.18, 0.6),
				Text = "",
				[React.Event.Activated] = function()
					TutorialServiceClient:NextStep()
				end,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				UIPadding = e("UIPadding", {
					PaddingBottom = UDim.new(0.1, 0),
					PaddingTop = UDim.new(0.1, 0),
					PaddingLeft = UDim.new(0.1, 0),
					PaddingRight = UDim.new(0.1, 0),
				}),
				UIStroke = e("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = 2,
				}),
				Text = e(Text, {
					text = stepConfig.nextText or "NEXT >", -- DYNAMICs
				}),
			}),
		}),
	})
end

return Onboarding
