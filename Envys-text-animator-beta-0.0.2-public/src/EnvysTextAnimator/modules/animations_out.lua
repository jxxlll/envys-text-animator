local Easing = require("EnvysTextAnimator.modules.easing")

local AnimOut = {}

AnimOut.order = {
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

function AnimOut.defaults()
	return {
		blur = false,
		fade = false,
		slideUp = false,
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

function AnimOut.anySlideEnabled(animations)
	return animations.slideUp or animations.slideDown or animations.slideLeft or animations.slideRight or animations.slideUpLeft or animations.slideUpRight or animations.slideDownLeft or animations.slideDownRight
end

function AnimOut.selectedLabel(animations)
	local labels = {}

	for _, item in ipairs(AnimOut.order) do
		if animations[item.key] then
			table.insert(labels, item.label)
		end
	end

	if #labels == 0 then
		return "None"
	end

	return table.concat(labels, ", ")
end

function AnimOut.slidePoints(animations)
	if animations.slideDown then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = 0, RY = 0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.468, LX = 0, LY = -0.0106666666666667 }"
	end

	if animations.slideLeft then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = -0.0106666666666667, RY = 0 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.532, Y = -0.5, LX = 0.0106666666666667, LY = 0 }"
	end

	if animations.slideRight then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = 0.0106666666666667, RY = 0 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.468, Y = -0.5, LX = -0.0106666666666667, LY = 0 }"
	end

	if animations.slideUpLeft then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = -0.0106666666666667, RY = -0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.532, Y = -0.532, LX = 0.0106666666666667, LY = 0.0106666666666667 }"
	end

	if animations.slideUpRight then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = 0.0106666666666667, RY = -0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.468, Y = -0.532, LX = -0.0106666666666667, LY = 0.0106666666666667 }"
	end

	if animations.slideDownLeft then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = -0.0106666666666667, RY = 0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.532, Y = -0.468, LX = 0.0106666666666667, LY = -0.0106666666666667 }"
	end

	if animations.slideDownRight then
		return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = 0.0106666666666667, RY = 0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.468, Y = -0.468, LX = -0.0106666666666667, LY = -0.0106666666666667 }"
	end

	return "{ Linear = true, LockY = true, X = -0.5, Y = -0.5, RX = 0, RY = -0.0106666666666667 },\n\t\t\t\t\t\t\t\t\t{ Linear = true, LockY = true, X = -0.5, Y = -0.532, LX = 0, LY = 0.0106666666666667 }"
end

function AnimOut.followerInputs(animations, follower)
	local inputs = {}

	if AnimOut.anySlideEnabled(animations) then
		table.insert(inputs, [[
						]] .. follower.offset .. [[ = Input {
							SourceOp = "OutPath1",
							Source = "Position",
						},]])
	end

	if animations.rotate then
		table.insert(inputs, [[
						TransformRotation = Input { Value = 1, },
						]] .. follower.angle .. [[ = Input {
							SourceOp = "OutAngleCurve",
							Source = "Value",
						},]])
	end

	if animations.scale then
		table.insert(inputs, [[
						TransformSize = Input { Value = 1, },
						]] .. follower.sizeX .. [[ = Input {
							SourceOp = "OutScaleCurve",
							Source = "Value",
						},]])
		table.insert(inputs, [[
						]] .. follower.sizeY .. [[ = Input {
							SourceOp = "OutScaleCurveY",
							Source = "Value",
							Expression = "]] .. follower.sizeX .. [[",
						},]])
	end

	if animations.fade then
		table.insert(inputs, [[
						Opacity1 = Input {
							SourceOp = "OutOpacityCurve",
							Source = "Value",
						},]])
	end

	return table.concat(inputs, "\n")
end

function AnimOut.tools(animations, startFrame, endFrame)
	local tools = {}
	startFrame = startFrame or 90
	endFrame = endFrame or 100

	if AnimOut.anySlideEnabled(animations) then
		table.insert(tools, [[
				OutPath1 = PolyPath {
					DrawMode = "InsertAndModify",
					Inputs = {
						Displacement = Input {
							SourceOp = "OutPathDisplacement",
							Source = "Value",
						},
						PolyLine = Input {
							Value = Polyline {
								Points = {
									]] .. AnimOut.slidePoints(animations) .. [[
								}
							},
						}
					},
				},
				OutPathDisplacement = BezierSpline {
					SplineColor = { Red = 255, Green = 0, Blue = 255 },
					NameSet = true,
					KeyFrames = {
						[]] .. startFrame .. [[] = { 0, RH = { ]] .. (startFrame + 3.7) .. [[, 0 }, Flags = { LockedY = true } },
						[]] .. endFrame .. [[] = { 1, LH = { ]] .. (endFrame - 11) .. [[, 1 }, Flags = { LockedY = true } }
					}
				},]])
	end

	if animations.rotate then
		table.insert(tools, [[
				OutAngleCurve = BezierSpline {
					SplineColor = { Red = 28, Green = 216, Blue = 243 },
					NameSet = true,
					KeyFrames = {
						[]] .. startFrame .. [[] = { 0, RH = { ]] .. (startFrame + 2.5) .. [[, 0 } },
						[]] .. endFrame .. [[] = { -33, LH = { ]] .. (endFrame - 0.14) .. [[, -32.4 }, Flags = { Linear = true } }
					}
				},]])
	end

	if animations.scale then
		table.insert(tools, [[
				OutScaleCurve = BezierSpline {
					SplineColor = { Red = 255, Green = 128, Blue = 0 },
					NameSet = true,
					KeyFrames = {
						[]] .. startFrame .. [[] = { 1, RH = { ]] .. (startFrame + 1.6) .. [[, 0.995999999999999 } },
						[]] .. endFrame .. [[] = { 0, LH = { ]] .. (endFrame - 0.08) .. [[, 0.015 }, Flags = { Linear = true } }
					}
				},
				OutScaleCurveY = BezierSpline {
					SplineColor = { Red = 255, Green = 128, Blue = 0 },
					NameSet = true,
					KeyFrames = {
						[]] .. startFrame .. [[] = { 1, Flags = { Linear = true } }
					}
				},]])
	end

	if animations.fade then
		table.insert(tools, [[
				OutOpacityCurve = BezierSpline {
					SplineColor = { Red = 179, Green = 28, Blue = 244 },
					NameSet = true,
					KeyFrames = {
						[]] .. startFrame .. [[] = { 1, RH = { ]] .. (startFrame + 3.9) .. [[, 0.995999999999999 } },
						[]] .. endFrame .. [[] = { 0, LH = { ]] .. endFrame .. [[, 0.002 }, Flags = { Linear = true } }
					}
				},]])
	end

	if animations.blur then
		table.insert(tools, [[
				OutBlurSizeCurve = BezierSpline {
					SplineColor = { Red = 18, Green = 240, Blue = 11 },
					NameSet = true,
					KeyFrames = {
						[]] .. startFrame .. [[] = { 0, RH = { ]] .. (startFrame + 1.94) .. [[, 0.04 } },
						[]] .. endFrame .. [[] = { 8, LH = { ]] .. (endFrame - 0.38) .. [[, 7.6 }, Flags = { Linear = true } }
					}
				},]])
	end

	return table.concat(tools, "\n")
end

function AnimOut.blurTool(animations, inputSource)
	if not animations.blur then
		return ""
	end

	return ""
end

function AnimOut.outputSource(animations, fallbackSource)
	return fallbackSource or "TextMain"
end

function AnimOut.hasAny(animations)
	animations = animations or {}

	for _, item in ipairs(AnimOut.order) do
		if animations[item.key] then
			return true
		end
	end

	return false
end

local function frameNumber(value)
	if math.floor(value) == value then
		return tostring(value)
	end

	return string.format("%.2f", value)
end

local function scaleFrame(timing, value)
	return value * ((timing and timing.scale) or 1)
end

local function scaledFrameText(timing, value)
	return frameNumber(scaleFrame(timing, value))
end

local function authoredFrame(timing, value)
	if not timing then
		return value
	end

	if value <= 10 then
		return timing.inStartFrame + (value * timing.animationScale)
	end

	if value >= 90 then
		return timing.outStartFrame + ((value - 90) * timing.animationScale)
	end

	return scaleFrame(timing, value)
end

local function authoredFrameText(timing, value)
	return frameNumber(authoredFrame(timing, value))
end

local function keyFrameLine(frame, value, handleType)
	local frameText = frameNumber(frame)

	if handleType == "hold" then
		return "\t\t\t\t\t\t[" .. frameText .. "] = { " .. value .. ", Flags = { Linear = true } }"
	end

	return "\t\t\t\t\t\t[" .. frameText .. "] = { " .. value .. " }"
end

local function addKey(lines, frame, value, handleType)
	table.insert(lines, keyFrameLine(frame, value, handleType))
end

local function joinKeyFrames(lines)
	return table.concat(lines, ",\n")
end

local function point(x, y)
	return "{ Linear = true, LockY = true, X = " .. x .. ", Y = " .. y .. " }"
end

local function inSlidePoint(animations)
	if animations.slideDown then
		return point("-0.5", "-0.468")
	end

	if animations.slideLeft then
		return point("-0.532", "-0.5")
	end

	if animations.slideRight then
		return point("-0.468", "-0.5")
	end

	if animations.slideUpLeft then
		return point("-0.532", "-0.532")
	end

	if animations.slideUpRight then
		return point("-0.468", "-0.532")
	end

	if animations.slideDownLeft then
		return point("-0.532", "-0.468")
	end

	if animations.slideDownRight then
		return point("-0.468", "-0.468")
	end

	return point("-0.5", "-0.532")
end

local function outSlidePoint(animations)
	if animations.slideUp then
		return point("-0.5", "-0.468")
	end

	if animations.slideLeft then
		return point("-0.532", "-0.5")
	end

	if animations.slideRight then
		return point("-0.468", "-0.5")
	end

	if animations.slideUpLeft then
		return point("-0.532", "-0.532")
	end

	if animations.slideUpRight then
		return point("-0.468", "-0.532")
	end

	if animations.slideDownLeft then
		return point("-0.532", "-0.468")
	end

	if animations.slideDownRight then
		return point("-0.468", "-0.468")
	end

	return point("-0.5", "-0.532")
end

local function slidePolyline(animationsIn, animationsOut, forceIn, forceOut)
	local hasIn = forceIn or AnimOut.anySlideEnabled(animationsIn)
	local hasOut = forceOut or AnimOut.anySlideEnabled(animationsOut)
	local normal = point("-0.5", "-0.5")

	if hasIn and hasOut then
		return inSlidePoint(animationsIn) .. ",\n\t\t\t\t\t\t\t\t\t" .. normal .. ",\n\t\t\t\t\t\t\t\t\t" .. outSlidePoint(animationsOut)
	end

	if hasOut then
		return normal .. ",\n\t\t\t\t\t\t\t\t\t" .. outSlidePoint(animationsOut)
	end

	return inSlidePoint(animationsIn) .. ",\n\t\t\t\t\t\t\t\t\t" .. normal
end

local function progressFrames(hasIn, hasOut, startFrame, endFrame, inStartValue, normalValue, outValue, easingIn, easingOut, timing)
	local lines = {}
	local inStartFrame = timing and timing.inStartFrame or 0
	local inEndFrame = timing and timing.inEndFrame or 10

	if hasIn and hasOut then
		table.insert(lines, Easing.transition(inStartFrame, inEndFrame, inStartValue, normalValue, easingIn, false))
		table.insert(lines, Easing.transition(startFrame, endFrame, normalValue, outValue, easingOut, true))
	elseif hasOut then
		addKey(lines, inStartFrame, normalValue, "hold")
		addKey(lines, startFrame, normalValue, "hold")
		table.insert(lines, Easing.transition(startFrame, endFrame, normalValue, outValue, easingOut, true))
	else
		table.insert(lines, Easing.transition(inStartFrame, inEndFrame, inStartValue, normalValue, easingIn, false))
	end

	return joinKeyFrames(lines)
end

local function usesWordMaskedBlur(animationsIn, animationsOut, follower)
	return follower and follower.label == "Word" and ((animationsIn and (animationsIn.blur or animationsIn.fade)) or (animationsOut and (animationsOut.blur or animationsOut.fade)))
end

function AnimOut.combinedFollowerInputs(animationsIn, animationsOut, follower, forceWordMaskedBlur)
	animationsIn = animationsIn or {}
	animationsOut = animationsOut or {}
	local maskedBlur = forceWordMaskedBlur or usesWordMaskedBlur(animationsIn, animationsOut, follower)

	local inputs = {}

	if AnimOut.anySlideEnabled(animationsIn) or AnimOut.anySlideEnabled(animationsOut) or maskedBlur then
		table.insert(inputs, [[
						]] .. follower.offset .. [[ = Input {
							SourceOp = "Path1",
							Source = "Position",
						},]])
	end

	if animationsIn.rotate or animationsOut.rotate then
		table.insert(inputs, [[
						TransformRotation = Input { Value = 1, },
						]] .. follower.angle .. [[ = Input {
							SourceOp = "AngleCurve",
							Source = "Value",
						},]])
	end

	if animationsIn.scale or animationsOut.scale then
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

	if (animationsIn.fade or animationsOut.fade) and not maskedBlur then
		table.insert(inputs, [[
						Opacity1 = Input {
							SourceOp = "OpacityCurve",
							Source = "Value",
						},]])
	end

	if (animationsIn.blur or animationsOut.blur) and not maskedBlur then
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

	if maskedBlur then
		table.insert(inputs, [[
						SelectElement = Input { Value = 4, },
						Enabled1 = Input { Value = 0, },
						Enabled5 = Input { Value = 1, },
						Opacity5 = Input {
							SourceOp = "Follower1Opacity5",
							Source = "Value",
						},
						ElementShape5 = Input { Value = 2, },]])
	end

	return table.concat(inputs, "\n")
end

function AnimOut.combinedTools(animationsIn, animationsOut, startFrame, endFrame, easingIn, easingOut, follower, timing)
	animationsIn = animationsIn or {}
	animationsOut = animationsOut or {}
	startFrame = startFrame or (timing and timing.outStartFrame) or 90
	endFrame = endFrame or (timing and timing.outEndFrame) or 100
	easingIn = easingIn or Easing.defaultKey
	easingOut = easingOut or Easing.defaultKey
	local maskedBlur = usesWordMaskedBlur(animationsIn, animationsOut, follower)
	local inStartFrame = timing and timing.inStartFrame or 0
	local inEndFrame = timing and timing.inEndFrame or 10

	local tools = {}

	if AnimOut.anySlideEnabled(animationsIn) or AnimOut.anySlideEnabled(animationsOut) or maskedBlur then
		local hasIn = AnimOut.anySlideEnabled(animationsIn) or (maskedBlur and (animationsIn.blur or animationsIn.fade))
		local hasOut = AnimOut.anySlideEnabled(animationsOut) or (maskedBlur and (animationsOut.blur or animationsOut.fade))
		local inValue = "0"
		local normalValue = hasIn and hasOut and "0.5" or "1"
		local outValue = hasIn and hasOut and "1" or "1"

		if hasOut and not hasIn then
			normalValue = "0"
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
									]] .. slidePolyline(animationsIn, animationsOut, maskedBlur and (animationsIn.blur or animationsIn.fade), maskedBlur and (animationsOut.blur or animationsOut.fade)) .. [[
								}
							},
						}
					},
				},
				PathDisplacement = BezierSpline {
					SplineColor = { Red = 255, Green = 0, Blue = 255 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(hasIn, hasOut, startFrame, endFrame, inValue, normalValue, outValue, easingIn, easingOut, timing) .. [[
					}
				},]])
	end

	if animationsIn.rotate or animationsOut.rotate then
		table.insert(tools, [[
				AngleCurve = BezierSpline {
					SplineColor = { Red = 28, Green = 216, Blue = 243 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(animationsIn.rotate, animationsOut.rotate, startFrame, endFrame, "-33", "0", "-33", easingIn, easingOut, timing) .. [[
					}
				},]])
	end

	if animationsIn.scale or animationsOut.scale then
		table.insert(tools, [[
				ScaleCurve = BezierSpline {
					SplineColor = { Red = 255, Green = 128, Blue = 0 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(animationsIn.scale, animationsOut.scale, startFrame, endFrame, "0", "1", "0", easingIn, easingOut, timing) .. [[
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

	if (animationsIn.fade or animationsOut.fade) and not maskedBlur then
		table.insert(tools, [[
				OpacityCurve = BezierSpline {
					SplineColor = { Red = 179, Green = 28, Blue = 244 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(animationsIn.fade, animationsOut.fade, startFrame, endFrame, "0", "1", "0", easingIn, easingOut, timing) .. [[
					}
				},]])
	end

	if (animationsIn.blur or animationsOut.blur) and not maskedBlur then
		table.insert(tools, [[
				BlurSoftnessXCurve = BezierSpline {
					SplineColor = { Red = 231, Green = 243, Blue = 234 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(animationsIn.blur, animationsOut.blur, startFrame, endFrame, "5", "0", "5", easingIn, easingOut, timing) .. [[
					}
				},
				BlurSoftnessYCurve = BezierSpline {
					SplineColor = { Red = 231, Green = 190, Blue = 243 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(animationsIn.blur, animationsOut.blur, startFrame, endFrame, "5", "0", "5", easingIn, easingOut, timing) .. [[
					}
				},]])
	end

	if maskedBlur then
		local opacity5Frames = [[
						[]] .. inStartFrame .. [[] = { 0, RH = { 0, 0 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. authoredFrameText(timing, 2.04155844155844) .. [[, 1 } }]]

		if animationsOut.blur or animationsOut.fade then
			opacity5Frames = [[
						[]] .. inStartFrame .. [[] = { 0, RH = { 0, 0 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. authoredFrameText(timing, 2.04155844155844) .. [[, 1 }, RH = { ]] .. authoredFrameText(timing, 36.6666666666667) .. [[, 1 } },
						[]] .. startFrame .. [[] = { 1, LH = { ]] .. authoredFrameText(timing, 73.3333333333333) .. [[, 1 }, RH = { ]] .. authoredFrameText(timing, 96.6666666666667) .. [[, 0.666666666666667 } },
						[]] .. endFrame .. [[] = { 0, LH = { ]] .. authoredFrameText(timing, 96.6666666666667) .. [[, 0.333333333333333 }, Flags = { Linear = true } }]]
		elseif not animationsIn.blur and not animationsIn.fade then
			opacity5Frames = [[
						[]] .. inStartFrame .. [[] = { 1, Flags = { Linear = true } },
						[]] .. startFrame .. [[] = { 1, RH = { ]] .. authoredFrameText(timing, 96.6666666666667) .. [[, 1 } },
						[]] .. endFrame .. [[] = { 0, LH = { ]] .. authoredFrameText(timing, 96.6666666666667) .. [[, 0 }, Flags = { Linear = true } }]]
		end

		table.insert(tools, [[
				Follower1Opacity5 = BezierSpline {
					SplineColor = { Red = 179, Green = 28, Blue = 244 },
					CtrlWZoom = false,
					NameSet = true,
					KeyFrames = {
]] .. opacity5Frames .. [[
					}
				},]])
	end

	return table.concat(tools, "\n")
end

function AnimOut.combinedBlurTool(animationsIn, animationsOut, follower, timing)
	animationsIn = animationsIn or {}
	animationsOut = animationsOut or {}
	local maskedBlur = usesWordMaskedBlur(animationsIn, animationsOut, follower)
	local outStartFrame = timing and timing.outStartFrame or 90
	local outEndFrame = timing and timing.outEndFrame or 100

	if not animationsIn.blur and not animationsOut.blur and not maskedBlur then
		return ""
	end

	if maskedBlur then
		local blurNode = ""

		if animationsIn.blur or animationsOut.blur then
			blurNode = [[
				Blur1 = Blur {
					Inputs = {
						EffectMask = Input {
							SourceOp = "BlurMaskText",
							Source = "Output",
						},
						ApplyMaskInverted = Input { Value = 1, },
						MaskLow = Input {
							SourceOp = "Blur1Low",
							Source = "Value",
						},
						MaskHigh = Input {
							SourceOp = "Blur1High",
							Source = "Value",
						},
						Filter = Input { Value = FuID { "Fast Gaussian" }, },
						XBlurSize = Input { Value = 6.5, },
						Input = Input {
							SourceOp = "TextMain",
							Source = "Output",
						}
					},
					ViewInfo = OperatorInfo { Pos = { 330, 115.5 } },
				},
				Blur1Low = BezierSpline {
					SplineColor = { Red = 231, Green = 243, Blue = 234 },
					NameSet = true,
					KeyFrames = {
]] .. progressFrames(animationsIn.blur, animationsOut.blur, outStartFrame, outEndFrame, "1", "0", "1", "setting", "setting", timing) .. [[
					}
				},
				Blur1High = BezierSpline {
					SplineColor = { Red = 231, Green = 190, Blue = 243 },
					CtrlWZoom = false,
					NameSet = true,
					KeyFrames = {
						[0] = { 1, RH = { ]] .. scaledFrameText(timing, 39.6666666666667) .. [[, 1 }, Flags = { Linear = true } },
						[]] .. outEndFrame .. [[] = { 1, LH = { ]] .. scaledFrameText(timing, 66.6666666666667) .. [[, 1 }, Flags = { Linear = true } }
					}
				},]]
		end

		return [[
				BlurMaskText = TextPlus {
					CtrlWZoom = false,
					SourceOp = "TextMain",
					Inputs = {
						Enabled1 = Input { Value = 0, },
						Enabled5 = Input { Value = 1, },
						ExtendHorizontal5 = Input { Value = -0.151, },
						Softness5 = Input { Value = 1, },
					},
					ViewInfo = OperatorInfo { Pos = { 330, 42.5 } },
				},]] .. blurNode
	end

	return ""
end

function AnimOut.combinedOutputSource(animationsIn, animationsOut, follower)
	animationsIn = animationsIn or {}
	animationsOut = animationsOut or {}

	if (animationsIn.blur or animationsOut.blur) and follower and follower.label == "Word" then
		return "Blur1"
	end

	return "TextMain"
end

return AnimOut
