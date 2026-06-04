local Easing = require("EnvysTextAnimator.modules.easing")

local AnimIn = {}

local function frameNumber(value)
	if math.floor(value) == value then
		return tostring(value)
	end

	return string.format("%.2f", value)
end

local function scaleFrame(timing, value)
	return value * ((timing and timing.animationScale) or 1)
end

local function scaledFrameText(timing, value)
	return frameNumber(scaleFrame(timing, value))
end

AnimIn.order = {
	{ key = "blur", label = "Blur" },
	{ key = "fade", label = "Fade" },
	{ key = "slideUp", label = "Slide Up" },
	{ key = "slideDown", label = "Slide Down" },
	{ key = "slideLeft", label = "Slide Left" },
	{ key = "slideRight", label = "Slide Right" },
	{ key = "slideUpLeft", label = "Slide Up Left" },
	{ key = "slideUpRight", label = "Slide Up Right" },
	{ key = "slideDownLeft", label = "Slide Down Left" },
	{ key = "slideDownRight", label = "Slide Down Right" },
	{ key = "rotate", label = "Rotate" },
	{ key = "scale", label = "Scale" },
}

function AnimIn.defaults()
	return {
		blur = true,
		fade = true,
		slideUp = true,
		slideDown = false,
		slideLeft = false,
		slideRight = false,
		slideUpLeft = false,
		slideUpRight = false,
		slideDownLeft = false,
		slideDownRight = false,
		rotate = false,
		scale = false,
	}
end

function AnimIn.anySlideEnabled(animations)
	return animations.slideUp or animations.slideDown or animations.slideLeft or animations.slideRight or animations.slideUpLeft or animations.slideUpRight or animations.slideDownLeft or animations.slideDownRight
end

function AnimIn.selectedLabel(animations)
	local labels = {}

	for _, item in ipairs(AnimIn.order) do
		if animations[item.key] then
			table.insert(labels, item.label)
		end
	end

	if #labels == 0 then
		return "None"
	end

	return table.concat(labels, ", ")
end

function AnimIn.slidePoints(animations)
	if animations.slideDown then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.468, RX = 0, RY = -0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = 0, LY = 0.0106666666666667 }"
	end

	if animations.slideLeft then
		return "{ Linear = true, LockY = true, X = -0.532, Y = -0.5, RX = 0.0106666666666667, RY = 0 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = -0.0106666666666667, LY = 0 }"
	end

	if animations.slideRight then
		return "{ Linear = true, LockY = true, X = -0.468, Y = -0.5, RX = -0.0106666666666667, RY = 0 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = 0.0106666666666667, LY = 0 }"
	end

	if animations.slideUpLeft then
		return "{ Linear = true, LockY = true, X = -0.532, Y = -0.532, RX = 0.0106666666666667, RY = 0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = -0.0106666666666667, LY = -0.0106666666666667 }"
	end

	if animations.slideUpRight then
		return "{ Linear = true, LockY = true, X = -0.468, Y = -0.532, RX = -0.0106666666666667, RY = 0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = 0.0106666666666667, LY = -0.0106666666666667 }"
	end

	if animations.slideDownLeft then
		return "{ Linear = true, LockY = true, X = -0.532, Y = -0.468, RX = 0.0106666666666667, RY = -0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = -0.0106666666666667, LY = 0.0106666666666667 }"
	end

	if animations.slideDownRight then
		return "{ Linear = true, LockY = true, X = -0.468, Y = -0.468, RX = -0.0106666666666667, RY = -0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = 0.0106666666666667, LY = 0.0106666666666667 }"
	end

	return "{ Linear = true, LockY = true, X = -0.5, Y = -0.532, RX = 0, RY = 0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.5, LX = 0, LY = -0.0106666666666667 }"
end

local function wordDelayInput(follower)
	if not (follower and follower.wordByWord) then
		return ""
	end

	return [[
						DelayByCharacterPosition = Input {
							Value = 30,
							Expression = ":\nlocal d=TextMain.DelayWBW\nlocal s=tostring(self.Text.Value or \"\")\nlocal p=math.floor(time+1)\n\nlocal w=0\nlocal inw=false\nlocal i=0\n\nfor c in s:gmatch(\"[%z\\1-\\127\\194-\\244][\\128-\\191]*\") do\n\ti=i+1\n\tif c:match(\"%s\") then\n\t\tinw=false\n\telseif not inw then\n\t\tw=w+1\n\t\tinw=true\n\tend\n\tif i>=p then break end\nend\n\nreturn (w-1)*d",
						},]]
end

function AnimIn.followerInputs(animations, follower)
	local inputs = {}

	local delayInput = wordDelayInput(follower)
	if delayInput ~= "" then
		table.insert(inputs, delayInput)
	end

	if AnimIn.anySlideEnabled(animations) then
		table.insert(inputs, [[
						]] .. follower.offset .. [[ = Input {
							SourceOp = "Path1",
							Source = "Position",
						},]])
	end

	if animations.rotate then
		table.insert(inputs, [[
						TransformRotation = Input { Value = 1, },
						]] .. follower.angle .. [[ = Input {
							SourceOp = "AngleCurve",
							Source = "Value",
						},]])
	end

	if animations.scale then
		table.insert(inputs, [[
						TransformSize = Input { Value = 1, },
						]] .. follower.sizeX .. [[ = Input {
							SourceOp = "ScaleCurve",
							Source = "Value",
						},]])
		table.insert(inputs, [[
						]] .. follower.sizeY .. [[ = Input {
							SourceOp = "ScaleCurveY",
							Source = "Value",
							Expression = "]] .. follower.sizeX .. [[",
						},]])
	end

	if animations.fade then
		table.insert(inputs, [[
						Opacity1 = Input {
							SourceOp = "OpacityCurve",
							Source = "Value",
						},]])
	end

	if animations.blur then
		table.insert(inputs, [[
						SoftnessX1 = Input {
							SourceOp = "BlurSoftnessXCurve",
							Source = "Value",
						},
						SoftnessY1 = Input {
							SourceOp = "BlurSoftnessYCurve",
							Source = "Value",
						},
						SoftnessOnFillColorToo1 = Input { Value = 1, },]])
	end

	return table.concat(inputs, "\n")
end

local function customKeyframes(startFrame, endFrame, startValue, endValue, easingKey)
	return Easing.transition(startFrame, endFrame, startValue, endValue, easingKey, false)
end

function AnimIn.tools(animations, easingKey, follower, timing)
	local tools = {}
	local useDefaultHandles = easingKey == nil or easingKey == "setting"
	local inStartFrame = timing and timing.inStartFrame or 0
	local inEndFrame = timing and timing.inEndFrame or 10

	if AnimIn.anySlideEnabled(animations) then
		local pathKeyframes = [[
						[]] .. inStartFrame .. [[] = { 0, RH = { ]] .. scaledFrameText(timing, 0.226666666666667) .. [[, 0.0248989898989897 }, Flags = { LockedY = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. scaledFrameText(timing, 2.04) .. [[, 1 }, Flags = { LockedY = true } }]]

		if not useDefaultHandles then
			pathKeyframes = customKeyframes(inStartFrame, inEndFrame, "0", "1", easingKey)
		end

		table.insert(tools, [[
				Path1 = PolyPath {
					DrawMode = "InsertAndModify",
					Inputs = {
						Displacement = Input {
							SourceOp = "PathDisplacement",
							Source = "Value",
						},
						PolyLine = Input {
							Value = Polyline {
								Points = {
									]] .. AnimIn.slidePoints(animations) .. [[
								}
							},
						}
					},
				},
				PathDisplacement = BezierSpline {
					SplineColor = { Red = 255, Green = 0, Blue = 255 },
					NameSet = true,
					KeyFrames = {
]] .. pathKeyframes .. [[
					}
				},]])
	end

	if animations.rotate then
		local angleKeyframes = [[
						[]] .. inStartFrame .. [[] = { -33, RH = { ]] .. scaledFrameText(timing, 0.14) .. [[, -32.4 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 0, LH = { ]] .. scaledFrameText(timing, 1.94) .. [[, 0 } }]]

		if not useDefaultHandles then
			angleKeyframes = customKeyframes(inStartFrame, inEndFrame, "-33", "0", easingKey)
		end

		table.insert(tools, [[
				AngleCurve = BezierSpline {
					SplineColor = { Red = 28, Green = 216, Blue = 243 },
					NameSet = true,
					KeyFrames = {
]] .. angleKeyframes .. [[
					}
				},]])
	end

	if animations.scale then
		local scaleKeyframes = [[
						[]] .. inStartFrame .. [[] = { 0, RH = { ]] .. scaledFrameText(timing, 0.08) .. [[, 0.015 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. scaledFrameText(timing, 1.6) .. [[, 0.995999999999999 } }]]

		if not useDefaultHandles then
			scaleKeyframes = customKeyframes(inStartFrame, inEndFrame, "0", "1", easingKey)
		end

		table.insert(tools, [[
				ScaleCurve = BezierSpline {
					SplineColor = { Red = 255, Green = 128, Blue = 0 },
					NameSet = true,
					KeyFrames = {
]] .. scaleKeyframes .. [[
					}
				},
				ScaleCurveY = BezierSpline {
					SplineColor = { Red = 255, Green = 128, Blue = 0 },
					NameSet = true,
					KeyFrames = {
						[0] = { 0, Flags = { Linear = true } }
					}
				},]])
	end

	if animations.fade then
		local opacityKeyframes = [[
						[]] .. inStartFrame .. [[] = { 0, RH = { 0, 0.00133333333333333 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. scaledFrameText(timing, 2.06) .. [[, 1 } }]]

		if not useDefaultHandles then
			opacityKeyframes = customKeyframes(inStartFrame, inEndFrame, "0", "1", easingKey)
		end

		table.insert(tools, [[
				OpacityCurve = BezierSpline {
					SplineColor = { Red = 179, Green = 28, Blue = 244 },
					NameSet = true,
					KeyFrames = {
]] .. opacityKeyframes .. [[
					}
				},]])
	end

	if animations.blur then
		local blurKeyframes = [[
						[]] .. inStartFrame .. [[] = { 5, RH = { ]] .. scaledFrameText(timing, 0.74) .. [[, 4.48 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 0, LH = { ]] .. scaledFrameText(timing, 2.2) .. [[, 0 } }]]

		if not useDefaultHandles then
			blurKeyframes = customKeyframes(inStartFrame, inEndFrame, "5", "0", easingKey)
		end

		table.insert(tools, [[
				BlurSoftnessXCurve = BezierSpline {
					SplineColor = { Red = 231, Green = 243, Blue = 234 },
					NameSet = true,
					KeyFrames = {
]] .. blurKeyframes .. [[
					}
				},
				BlurSoftnessYCurve = BezierSpline {
					SplineColor = { Red = 231, Green = 190, Blue = 243 },
					NameSet = true,
					KeyFrames = {
]] .. blurKeyframes .. [[
					}
				},]])
	end

	return table.concat(tools, "\n")
end

function AnimIn.blurTool(animations, follower, timing)
	return ""
end

function AnimIn.outputSource(animations, follower)
	return "TextMain"
end

return AnimIn
