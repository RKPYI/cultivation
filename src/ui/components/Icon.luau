local React = require("../../Packages/React")
local e = React.createElement

export type IconProps = {
    img: string,
}

local function Icon(props: IconProps)
    return e("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Image = props.img,
    }, {
        UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
    })
end

return Icon