local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type AnimatedImageProps = {
	Image: string,
	FrameWidth: number,
	FrameHeight: number,
	Columns: number,
	TotalFrames: number,
	FPS: number?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	LayoutOrder: number?,
}

local function AnimatedImage(props: AnimatedImageProps)
	local currentFrame, setCurrentFrame = React.useState(0)
	local fps = props.FPS or 30

	React.useEffect(function()
		local accumulatedTime = 0
		local frameDuration = 1 / fps

		local conn = RunService.Heartbeat:Connect(function(dt)
			accumulatedTime += dt

			if accumulatedTime >= frameDuration then
				local framesToAdvance = math.floor(accumulatedTime / frameDuration)
				accumulatedTime %= frameDuration

				setCurrentFrame(function(prev)
					return (prev + framesToAdvance) % props.TotalFrames
				end)
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, { props.TotalFrames, fps })

	local column = currentFrame % props.Columns
	local row = math.floor(currentFrame / props.Columns)

	return e("ImageLabel", {
		Image = props.Image,
		ScaleType = Enum.ScaleType.Fit,
		ImageRectSize = Vector2.new(props.FrameWidth, props.FrameHeight),
		ImageRectOffset = Vector2.new(column * props.FrameWidth, row * props.FrameHeight),
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
	})
end

return AnimatedImage
