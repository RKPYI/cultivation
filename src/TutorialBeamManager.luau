local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local TutorialBeamManager = {}

local activeBeam: Beam? = nil
local att0: Attachment? = nil
local att1: Attachment? = nil

function TutorialBeamManager.clear()
	if activeBeam then
		activeBeam:Destroy()
		activeBeam = nil
	end
	if att0 then
		att0:Destroy()
		att0 = nil
	end
	if att1 then
		att1:Destroy()
		att1 = nil
	end
end

function TutorialBeamManager.setTarget(target: Instance?)
	TutorialBeamManager.clear()

	if not target then
		return
	end

	local targetPart: BasePart? = nil
	if target:IsA("BasePart") then
		targetPart = target
	elseif target:IsA("Model") then
		targetPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
	end

	if not targetPart then
		warn("[TutorialBeamManager] Target has no BasePart to attach Beam to:", target:GetFullName())
		return
	end

	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	if not rootPart then
		return
	end

	att0 = Instance.new("Attachment")
	att0.Name = "TutorialBeamAtt0"
	att0.Position = Vector3.new(0, 0, 0) -- Positioned at feet (0, -2.5, 0)
	att0.Parent = rootPart

	att1 = Instance.new("Attachment")
	att1.Name = "TutorialBeamAtt1"
	att1.Position = Vector3.new(0, 0, 0)
	att1.Parent = targetPart

	local beam = Instance.new("Beam")
	beam.Name = "TutorialGuideBeam"
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.FaceCamera = true
	beam.Width0 = 1.5
	beam.Width1 = 1.5

	beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
	beam.Texture = "rbxassetid://102114906009290"
	beam.TextureSpeed = 2
	beam.TextureLength = 3
	beam.TextureMode = Enum.TextureMode.Wrap
	beam.LightEmission = 0.8
	beam.LightInfluence = 0

	beam.Parent = rootPart
	activeBeam = beam
end

return TutorialBeamManager
