-- Envy's Text Animator - compiled public launcher
-- Version: beta 0.0.4
-- Generated from src/EnvysTextAnimator.

package.preload["EnvysTextAnimator.modules.config"] = function(...)
local Config = {}

Config.titleName = "Envys Text Animator Generated"
Config.appName = "Envy's Text Animator"
Config.version = "beta 0.0.4"
Config.defaultText = "Your Text Here"
Config.defaultFont = "Open Sans"
Config.defaultFontStyle = "Regular"
Config.defaultDurationSeconds = 5
Config.defaultTimelineFps = 24
Config.defaultAnimationSeconds = 10 / Config.defaultTimelineFps
Config.minAnimationSeconds = 0.1
Config.maxAnimationSeconds = 1.5
Config.sourceDurationSeconds = 5
Config.animationEndFrame = 100
Config.stretchStartFrame = 35
Config.stretchEndFrame = 80

local function scaledFrame(value, scale)
	return math.floor((value * scale) + 0.5)
end

local function clamp(value, minValue, maxValue)
	return math.max(minValue, math.min(maxValue, value))
end

function Config.timelineFrameRate(project, timeline)
	return tonumber(timeline and timeline:GetSetting("timelineFrameRate"))
		or tonumber(project and project:GetSetting("timelineFrameRate"))
		or Config.defaultTimelineFps
end

function Config.clampAnimationSeconds(value)
	local seconds = tonumber(value) or Config.defaultAnimationSeconds

	return clamp(seconds, Config.minAnimationSeconds, Config.maxAnimationSeconds)
end

function Config.durationFrames(frameRate, durationSeconds, animationSeconds)
	local fps = tonumber(frameRate) or Config.defaultTimelineFps

	return math.floor((fps * Config.sourceDurationSeconds) + 0.5)
end

function Config.globalOutFrame(frameRate, durationSeconds, animationSeconds)
	return Config.durationFrames(frameRate, durationSeconds, animationSeconds) - 1
end

function Config.animationTiming(frameRate, animationSeconds)
	local fps = tonumber(frameRate) or Config.defaultTimelineFps
	local scale = fps / Config.defaultTimelineFps
	local animationFrameCount = math.max(1, math.floor((fps * Config.clampAnimationSeconds(animationSeconds)) + 0.5))
	local sourceEndFrame = Config.durationFrames(fps) - 1
	local animationEndFrame = scaledFrame(Config.animationEndFrame, scale)
	local outEndFrame = animationEndFrame
	local outStartFrame = math.max(animationFrameCount, outEndFrame - animationFrameCount)

	return {
		scale = scale,
		animationScale = animationFrameCount / 10,
		animationFrameCount = animationFrameCount,
		inStartFrame = 0,
		inEndFrame = animationFrameCount,
		stretchStartFrame = scaledFrame(Config.stretchStartFrame, scale),
		stretchEndFrame = scaledFrame(Config.stretchEndFrame, scale),
		outStartFrame = outStartFrame,
		outEndFrame = outEndFrame,
		tailPaddingFrames = sourceEndFrame - outEndFrame,
		animationEndFrame = animationEndFrame,
		sourceEndFrame = sourceEndFrame,
		renderSafetyFrames = 0,
		renderEndFrame = sourceEndFrame,
	}
end

function Config.titleDir()
	return os.getenv("APPDATA") .. "\\Blackmagic Design\\DaVinci Resolve\\Support\\Fusion\\Templates\\Edit\\Titles"
end

function Config.titlePath()
	return Config.titleDir() .. "\\" .. Config.titleName .. ".setting"
end

function Config.tempCompPath()
	return os.getenv("TEMP") .. "\\Envys_Text_Animator_from_UI.comp"
end

return Config

end

package.preload["EnvysTextAnimator.modules.utils"] = function(...)
local Utils = {}

function Utils.writeAll(path, value)
	local file = io.open(path, "wb")
	if not file then
		return false
	end

	file:write(value)
	file:close()
	return true
end

function Utils.escapeLuaString(value)
	value = tostring(value or "")
	value = value:gsub("\\", "\\\\")
	value = value:gsub("\r\n", "\\n")
	value = value:gsub("\n", "\\n")
	value = value:gsub('"', '\\"')
	return value
end

function Utils.ensureDir(path)
	os.execute('mkdir "' .. path .. '" >nul 2>nul')
end

return Utils

end

package.preload["EnvysTextAnimator.modules.followers"] = function(...)
local Followers = {}

Followers.labels = {
	char = "Character",
	word = "Word",
	line = "Line",
}

Followers.byKey = {
	char = { label = "Character", offset = "CharacterOffset", angle = "CharacterAngleZ", sizeX = "CharacterSizeX", sizeY = "CharacterSizeY", order = 7, delay = 0.6 },
	word = { label = "Word", offset = "CharacterOffset", angle = "CharacterAngleZ", sizeX = "CharacterSizeX", sizeY = "CharacterSizeY", order = 6, delay = 0, wordDelay = 6, wordByWord = true },
	line = { label = "Line", offset = "LineOffset", angle = "LineAngleZ", sizeX = "LineSizeX", sizeY = "LineSizeY", order = 7, delay = 0 },
}

function Followers.get(key)
	return Followers.byKey[key] or Followers.byKey.char
end

function Followers.label(key)
	return Followers.labels[key] or Followers.labels.char
end

return Followers

end

package.preload["EnvysTextAnimator.modules.easing"] = function(...)
local Easing = {}

Easing.order = {
	{ key = "setting", label = "Default" },
	{ key = "smooth", label = "Smooth" },
	{ key = "linear", label = "Linear" },
	{ key = "quad", label = "Quad" },
	{ key = "cubic", label = "Cubic" },
	{ key = "elastic", label = "Elastic" },
}

Easing.defaultKey = "setting"

Easing.presets = {
	setting = {
		label = "Default",
		inHandle = 0.34,
		outHandle = 0.74,
	},
	smooth = {
		label = "Smooth",
		inHandle = 0.333333333333333,
		outHandle = 0.339441762960804,
	},
	linear = {
		label = "Linear",
		inHandle = 0.333333333333333,
		outHandle = 0.333333333333333,
		linear = true,
	},
	quad = {
		label = "Quad",
		inHandle = 0.24,
		outHandle = 0.38,
	},
	cubic = {
		label = "Cubic",
		inHandle = 0.34,
		outHandle = 0.74,
	},
	elastic = {
		label = "Elastic",
		inHandle = 0.12,
		midFrame = 0.6,
		midLeft = 0.36,
		midRight = 0.12,
		endHandle = 0.14,
		preOvershoot = 0.18,
		outStartHandle = 0.14,
		outMidFrame = 0.4,
		outMidLeft = 0.12,
		outMidRight = 0.36,
		outHandle = 0.12,
		outEndOvershoot = 0.18,
		overshoot = 0.14,
	},
}

function Easing.get(key)
	return Easing.presets[key] or Easing.presets[Easing.defaultKey]
end

function Easing.label(key)
	return Easing.get(key).label
end

function Easing.frame(value)
	if math.floor(value) == value then
		return tostring(value)
	end

	return string.format("%.2f", value)
end

function Easing.value(value)
	if type(value) == "number" then
		return tostring(value)
	end

	return value
end

function Easing.key(frame, value, flags)
	local text = "[" .. Easing.frame(frame) .. "] = { " .. Easing.value(value)

	if flags and flags ~= "" then
		text = text .. ", Flags = { " .. flags .. " }"
	end

	return text .. " }"
end

function Easing.segment(startFrame, endFrame, startValue, endValue, key)
	local preset = Easing.get(key)
	local duration = endFrame - startFrame
	local flags = preset.linear and "Linear = true" or nil
	local startText = Easing.key(startFrame, startValue, flags)
	local endText = Easing.key(endFrame, endValue, flags)

	if preset.linear then
		return startText .. ",\n" .. endText
	end

	local rightFrame = startFrame + (duration * preset.inHandle)
	local leftFrame = endFrame - (duration * preset.outHandle)

	startText = "[" .. Easing.frame(startFrame) .. "] = { " .. Easing.value(startValue) .. ", RH = { " .. Easing.frame(rightFrame) .. ", " .. Easing.value(startValue) .. " } }"
	endText = "[" .. Easing.frame(endFrame) .. "] = { " .. Easing.value(endValue) .. ", LH = { " .. Easing.frame(leftFrame) .. ", " .. Easing.value(endValue) .. " } }"

	return startText .. ",\n" .. endText
end

function Easing.hold(frame, value)
	return Easing.key(frame, value, "Linear = true")
end

function Easing.reversed(key)
	local preset = Easing.get(key)

	return {
		label = preset.label .. " Reverse",
		inHandle = preset.outHandle,
		outHandle = preset.inHandle,
		linear = preset.linear,
		overshoot = preset.overshoot,
	}
end

function Easing.keyWithHandles(frame, value, rightFrame, rightValue, leftFrame, leftValue, flags)
	local text = "[" .. Easing.frame(frame) .. "] = { " .. Easing.value(value)

	if rightFrame and rightValue then
		text = text .. ", RH = { " .. Easing.frame(rightFrame) .. ", " .. Easing.value(rightValue) .. " }"
	end

	if leftFrame and leftValue then
		text = text .. ", LH = { " .. Easing.frame(leftFrame) .. ", " .. Easing.value(leftValue) .. " }"
	end

	if flags and flags ~= "" then
		text = text .. ", Flags = { " .. flags .. " }"
	end

	return text .. " }"
end

local function numericValue(value, fallback)
	local number = tonumber(value)
	if number ~= nil then
		return number
	end

	return fallback
end

local function elasticTransition(startFrame, endFrame, startValue, endValue, preset, reverse)
	local startNumber = numericValue(startValue, 0)
	local endNumber = numericValue(endValue, 1)
	local duration = endFrame - startFrame
	local midFrame
	local midValue
	local startText
	local midText
	local endText

	if reverse then
		midFrame = startFrame + (duration * preset.outMidFrame)
		midValue = startNumber + ((startNumber - endNumber) * preset.overshoot)
		startText = Easing.keyWithHandles(startFrame, startValue, startFrame + (duration * preset.outStartHandle), startValue)
		midText = Easing.keyWithHandles(midFrame, midValue, midFrame + (duration * preset.outMidRight), midValue, midFrame - (duration * preset.outMidLeft), midValue)
		endText = Easing.keyWithHandles(endFrame, endValue, nil, nil, endFrame - (duration * preset.outHandle), endNumber - ((startNumber - endNumber) * preset.outEndOvershoot))
	else
		midFrame = startFrame + (duration * preset.midFrame)
		midValue = endNumber + ((endNumber - startNumber) * preset.overshoot)
		startText = Easing.keyWithHandles(startFrame, startValue, startFrame + (duration * preset.inHandle), startNumber - ((endNumber - startNumber) * preset.overshoot))
		midText = Easing.keyWithHandles(midFrame, midValue, midFrame + (duration * preset.midRight), midValue, midFrame - (duration * preset.midLeft), midValue)
		endText = Easing.keyWithHandles(endFrame, endValue, nil, nil, endFrame - (duration * preset.endHandle), endValue)
	end

	return startText .. ",\n" .. midText .. ",\n" .. endText
end

function Easing.transition(startFrame, endFrame, startValue, endValue, key, reverse)
	local preset = Easing.get(key)
	local duration = endFrame - startFrame

	if preset.linear then
		local rightFrame = startFrame + (duration * preset.inHandle)
		local leftFrame = endFrame - (duration * preset.outHandle)
		local startNumber = numericValue(startValue, 0)
		local endNumber = numericValue(endValue, 1)
		local delta = endNumber - startNumber
		local startText = Easing.keyWithHandles(startFrame, startValue, rightFrame, startNumber + (delta / 3))
		local endText = Easing.keyWithHandles(endFrame, endValue, nil, nil, leftFrame, startNumber + ((delta * 2) / 3), "Linear = true")

		return startText .. ",\n" .. endText
	end

	if key == "elastic" then
		return elasticTransition(startFrame, endFrame, startValue, endValue, preset, reverse)
	end

	local inHandle = preset.inHandle
	local outHandle = preset.outHandle

	if reverse then
		inHandle = preset.outHandle
		outHandle = preset.inHandle
	end

	local rightFrame = startFrame + (duration * inHandle)
	local leftFrame = endFrame - (duration * outHandle)
	local startText = Easing.keyWithHandles(startFrame, startValue, rightFrame, startValue)
	local endText = Easing.keyWithHandles(endFrame, endValue, nil, nil, leftFrame, endValue)

	return startText .. ",\n" .. endText
end

return Easing

end

package.preload["EnvysTextAnimator.modules.animations_in"] = function(...)
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

local function usesWordMaskedBlur(animations, follower)
	return false
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

function AnimIn.followerInputs(animations, follower, forceWordMaskedBlur)
	local inputs = {}
	local maskedBlur = forceWordMaskedBlur or usesWordMaskedBlur(animations, follower)

	local delayInput = wordDelayInput(follower)
	if delayInput ~= "" then
		table.insert(inputs, delayInput)
	end

	if AnimIn.anySlideEnabled(animations) or maskedBlur then
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

	if animations.fade and not maskedBlur then
		table.insert(inputs, [[
						Opacity1 = Input {
							SourceOp = "OpacityCurve",
							Source = "Value",
						},]])
	end

	if animations.blur and not maskedBlur then
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

local function customKeyframes(startFrame, endFrame, startValue, endValue, easingKey)
	return Easing.transition(startFrame, endFrame, startValue, endValue, easingKey, false)
end

function AnimIn.tools(animations, easingKey, follower, timing)
	local tools = {}
	local useDefaultHandles = easingKey == nil or easingKey == "setting"
	local maskedBlur = usesWordMaskedBlur(animations, follower)
	local inStartFrame = timing and timing.inStartFrame or 0
	local inEndFrame = timing and timing.inEndFrame or 10

	if AnimIn.anySlideEnabled(animations) or maskedBlur then
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

	if animations.fade and not maskedBlur then
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

	if animations.blur and not maskedBlur then
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

	if maskedBlur then
		table.insert(tools, [[
				Follower1Opacity5 = BezierSpline {
					SplineColor = { Red = 179, Green = 28, Blue = 244 },
					CtrlWZoom = false,
					NameSet = true,
					KeyFrames = {
						[]] .. inStartFrame .. [[] = { 0, RH = { 0, 0 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. scaledFrameText(timing, 2.04155844155844) .. [[, 1 } }
					}
				},]])
	end

	return table.concat(tools, "\n")
end

function AnimIn.blurTool(animations, follower, timing)
	local maskedBlur = usesWordMaskedBlur(animations, follower)
	local inStartFrame = timing and timing.inStartFrame or 0
	local inEndFrame = timing and timing.inEndFrame or 10

	if not animations.blur and not maskedBlur then
		return ""
	end

	if maskedBlur then
		local blurNode = ""

		if animations.blur then
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
						[]] .. inStartFrame .. [[] = { 1, RH = { ]] .. scaledFrameText(timing, 3.4) .. [[, 1 } },
						[]] .. inEndFrame .. [[] = { 0, LH = { ]] .. scaledFrameText(timing, 2.6) .. [[, 0 } }
					}
				},
				Blur1High = BezierSpline {
					SplineColor = { Red = 231, Green = 190, Blue = 243 },
					CtrlWZoom = false,
					NameSet = true,
					KeyFrames = {
						[]] .. inStartFrame .. [[] = { 1, RH = { ]] .. scaledFrameText(timing, 3.33333333333333) .. [[, 1 }, Flags = { Linear = true } },
						[]] .. inEndFrame .. [[] = { 1, LH = { ]] .. scaledFrameText(timing, 6.66666666666667) .. [[, 1 }, Flags = { Linear = true } }
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

function AnimIn.outputSource(animations, follower)
	return "TextMain"
end

return AnimIn

end

package.preload["EnvysTextAnimator.modules.animations_out"] = function(...)
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
	return false
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

function AnimOut.combinedFollowerInputs(animationsIn, animationsOut, follower, forceWordMaskedBlur)
	animationsIn = animationsIn or {}
	animationsOut = animationsOut or {}
	local maskedBlur = forceWordMaskedBlur or usesWordMaskedBlur(animationsIn, animationsOut, follower)

	local inputs = {}

	local delayInput = wordDelayInput(follower)
	if delayInput ~= "" then
		table.insert(inputs, delayInput)
	end

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

	return "TextMain"
end

return AnimOut

end

package.preload["EnvysTextAnimator.modules.generator"] = function(...)
local Config = require("EnvysTextAnimator.modules.config")
local Utils = require("EnvysTextAnimator.modules.utils")
local Followers = require("EnvysTextAnimator.modules.followers")
local AnimIn = require("EnvysTextAnimator.modules.animations_in")
local AnimOut = require("EnvysTextAnimator.modules.animations_out")

local Generator = {}

function Generator.buildComp(textValue, state, asTitle)
	state = state or {}
	local escapedText = Utils.escapeLuaString(textValue)
	local escapedFont = Utils.escapeLuaString(state.fontFamily or Config.defaultFont)
	local escapedStyle = Utils.escapeLuaString(state.fontStyle or Config.defaultFontStyle or "Regular")
	local follower = Followers.get(state.followerMode)
	local animations = state.animations or {}
	local animationsOut = state.animationsOut or {}
	local easingIn = state.easingIn or "setting"
	local easingOut = state.easingOut or "setting"
	local animationSeconds = Config.clampAnimationSeconds(state.animationLengthSeconds)
	local globalOut = Config.globalOutFrame(state.timelineFps, state.durationSeconds, animationSeconds)
	local timing = Config.animationTiming(state.timelineFps, animationSeconds)
	local hasAnimationOut = AnimOut.hasAny(animationsOut)
	local usesWordMaskedBlur = false
	local wordDelayValue = follower.wordDelay or 6
	local followerDelayInputSourceOp = follower.wordByWord and "TextMain" or "Follower1"
	local followerDelayInputSource = follower.wordByWord and "DelayWBW" or "Delay"
	local followerDelayDefault = follower.wordByWord and wordDelayValue or follower.delay
	local followerOrder = follower.order or 7
	local followerDelayInput = ""
	local wordDelayTextInput = ""
	local textMainUserControls = ""
	if not follower.wordByWord then
		followerDelayInput = [[
						Delay = Input { Value = ]] .. follower.delay .. [[, },]]
	end
	if follower.wordByWord then
		wordDelayTextInput = [[
						DelayWBW = Input { Value = ]] .. wordDelayValue .. [[, },]]
		textMainUserControls = [[,
					UserControls = ordered() {
						DelayWBW = {
							LINKS_Name = "Follower Delay",
							LINKID_DataType = "Number",
							INPID_InputControl = "ScrewControl",
							INP_Default = ]] .. wordDelayValue .. [[,
							INP_Integer = false,
							INP_MinScale = 0,
							INP_MaxScale = 30,
							INP_MinAllowed = 0,
							INP_MaxAllowed = 1000,
							INP_SplineType = "Default",
							LINKID_AddBeforeID = "StyledText",
							ICS_ControlPage = "Controls",
							INP_External = false
						}
					}]]
	end
	local followerInputs = AnimIn.followerInputs(animations, follower, usesWordMaskedBlur)
	local animationTools = AnimIn.tools(animations, easingIn, follower, timing)
	local blurTool = AnimIn.blurTool(animations, follower, timing)
	local outSource = AnimIn.outputSource(animations, follower)

	if hasAnimationOut then
		followerInputs = AnimOut.combinedFollowerInputs(animations, animationsOut, follower, usesWordMaskedBlur)
		animationTools = AnimOut.combinedTools(animations, animationsOut, nil, nil, easingIn, easingOut, follower, timing)
		blurTool = AnimOut.combinedBlurTool(animations, animationsOut, follower, timing)
		outSource = AnimOut.combinedOutputSource(animations, animationsOut, follower)
	end

	local mediaOutBlock = ""
	if not asTitle then
		mediaOutBlock = [[,
		MediaOut1 = MediaOut {
			Inputs = {
				Index = Input { Value = "0", },
				Input = Input {
					SourceOp = "KeyframeStretcher1",
					Source = "Result",
				}
			},
			ViewInfo = OperatorInfo { Pos = { 520, 115.5 } },
		}]]
	end

	return [[{
	Tools = ordered() {
		EnvysTextAnimator = GroupOperator {
			CtrlWZoom = false,
			NameSet = true,
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Templates:\\Edit\\Titles\\"
					}
				}
			},
			Inputs = ordered() {
				Input1 = InstanceInput { SourceOp = "Follower1", Source = "Text", Page = "Controls", Name = "Styled Text" },
				Input2 = InstanceInput { SourceOp = "TextMain", Source = "Font", Page = "Controls", Name = "Font", ControlGroup = 1 },
				Input3 = InstanceInput { SourceOp = "TextMain", Source = "Style", Page = "Controls", Name = "Style", ControlGroup = 1 },
				Input4 = InstanceInput { SourceOp = "TextMain", Source = "Red1Clone", Page = "Controls", Name = "Color", ControlGroup = 2, Default = 1 },
				Input5 = InstanceInput { SourceOp = "TextMain", Source = "Green1Clone", Page = "Controls", ControlGroup = 2, Default = 1 },
				Input6 = InstanceInput { SourceOp = "TextMain", Source = "Blue1Clone", Page = "Controls", ControlGroup = 2, Default = 1 },
				Input7 = InstanceInput { SourceOp = "TextMain", Source = "Alpha1Clone", Page = "Controls", ControlGroup = 2, Default = 1 },
				Input8 = InstanceInput { SourceOp = "TextMain", Source = "Size", Page = "Controls", Name = "Size", Default = 0.09 },
				Input9 = InstanceInput { SourceOp = "TextMain", Source = "Center", Page = "Controls", Name = "Position" },
				Input10 = InstanceInput { SourceOp = "TextMain", Source = "CharacterSpacingClone", Page = "Controls", Name = "Character Spacing", Default = 0.95 },
				Input11 = InstanceInput { SourceOp = "TextMain", Source = "LineSpacingClone", Page = "Controls", Name = "Line Spacing", Default = 1 },
				Input12 = InstanceInput { SourceOp = "TextMain", Source = "VerticalJustificationTop", Page = "Controls", Name = "V Anchor Top", ControlGroup = 3 },
				Input13 = InstanceInput { SourceOp = "TextMain", Source = "VerticalJustificationCenter", Page = "Controls", Name = "V Anchor Center", ControlGroup = 3 },
				Input14 = InstanceInput { SourceOp = "TextMain", Source = "VerticalJustificationBottom", Page = "Controls", Name = "V Anchor Bottom", ControlGroup = 3 },
				Input15 = InstanceInput { SourceOp = "TextMain", Source = "VerticalTopCenterBottom", Page = "Controls", Name = "Vertical Anchor", Default = 0 },
				Input16 = InstanceInput { SourceOp = "TextMain", Source = "HorizontalJustificationLeft", Page = "Controls", Name = "H Anchor Left", ControlGroup = 4 },
				Input17 = InstanceInput { SourceOp = "TextMain", Source = "HorizontalJustificationCenter", Page = "Controls", Name = "H Anchor Center", ControlGroup = 4 },
				Input18 = InstanceInput { SourceOp = "TextMain", Source = "HorizontalJustificationRight", Page = "Controls", Name = "H Anchor Right", ControlGroup = 4 },
				Input19 = InstanceInput { SourceOp = "TextMain", Source = "HorizontalLeftCenterRight", Page = "Controls", Name = "Horizontal Anchor", Default = 0 },
				Input20 = InstanceInput { SourceOp = "]] .. followerDelayInputSourceOp .. [[", Source = "]] .. followerDelayInputSource .. [[", Page = "Controls", Name = "Follower Delay", Default = ]] .. followerDelayDefault .. [[ }
			},
			Outputs = {
				MainOutput1 = InstanceOutput {
					SourceOp = "KeyframeStretcher1",
					Source = "Result",
				}
			},
			ViewInfo = GroupInfo { Pos = { 0, 0 } },
			Tools = ordered() {
				TextMain = TextPlus {
					CtrlWZoom = false,
					NameSet = true,
					Inputs = {
						GlobalOut = Input { Value = ]] .. globalOut .. [[, },
						Width = Input { Value = 1920, },
						Height = Input { Value = 1080, },
						UseFrameFormatSettings = Input { Value = 1, },
						LineSpacing = Input { Value = 1, },
						CharacterSpacing = Input { Value = 0.95, },]] .. wordDelayTextInput .. [[
						StyledText = Input {
							SourceOp = "Follower1",
							Source = "StyledText",
						},
						Font = Input { Value = "]] .. escapedFont .. [[", },
						Style = Input { Value = "]] .. escapedStyle .. [[", },
						Size = Input { Value = 0.09, },
						Center = Input { Value = { 0.5, 0.5 }, },
						VerticalJustificationNew = Input { Value = 3, },
						HorizontalJustificationNew = Input { Value = 3, }
					},
					ViewInfo = OperatorInfo { Pos = { 110, 115.5 } }]] .. textMainUserControls .. [[,
				},
				Follower1 = StyledTextFollower {
					CtrlWZoom = false,
					Inputs = {
						Order = Input { Value = ]] .. followerOrder .. [[, },]] .. followerDelayInput .. [[
						Text = Input {
							Value = StyledText {
								Value = "]] .. escapedText .. [["
							},
						},]] .. followerInputs .. [[
						Softness1 = Input { Value = 1, },
						Softness2 = Input { Value = 1, },
						Softness3 = Input { Value = 1, },
						Softness4 = Input { Value = 1, },
						Softness5 = Input { Value = 1, },
						Softness6 = Input { Value = 1, },
						Softness7 = Input { Value = 1, },
						Softness8 = Input { Value = 1, }
					},
				},]] .. blurTool .. animationTools .. [[
				KeyframeStretcher1 = KeyStretcher {
					CtrlWZoom = false,
					Inputs = {
						Keyframes = Input {
							SourceOp = "]] .. outSource .. [[",
							Source = "Output",
						},
						SourceEnd = Input { Value = ]] .. timing.sourceEndFrame .. [[, },
						StretchStart = Input { Value = ]] .. timing.stretchStartFrame .. [[, },
						StretchEnd = Input { Value = ]] .. timing.stretchEndFrame .. [[, }
					},
					ViewInfo = OperatorInfo { Pos = { 520, 115.5 } },
				},
			},
		}]] .. mediaOutBlock .. [[
	},
	ActiveTool = "EnvysTextAnimator"
}]]
end

return Generator

end

package.preload["EnvysTextAnimator.modules.title_insert"] = function(...)
local Config = require("EnvysTextAnimator.modules.config")
local Utils = require("EnvysTextAnimator.modules.utils")
local Generator = require("EnvysTextAnimator.modules.generator")

local TitleInsert = {}
TitleInsert.lastError = nil
TitleInsert.lastInfo = nil

local function addDiagnostic(diagnostics, message)
	table.insert(diagnostics, message)
	print(message)
end

local function tryCall(label, fn, diagnostics)
	local ok, result = pcall(fn)
	if ok then
		return result
	end

	addDiagnostic(diagnostics or {}, "Timeline diagnostic failed at " .. label .. ": " .. tostring(result))
	return nil
end

function TitleInsert.getTimeline(resolve)
	TitleInsert.lastError = nil
	TitleInsert.lastInfo = nil
	local diagnostics = {}
	local projectManager = resolve:GetProjectManager()
	local project = projectManager and projectManager:GetCurrentProject() or nil
	if not project then
		TitleInsert.lastError = "No Resolve project is currently open."
		return nil, nil, TitleInsert.lastError
	end

	local projectName = tryCall("GetName", function()
		return project:GetName()
	end, diagnostics) or "Unknown Project"
	if projectName == "Untitled Project" then
		TitleInsert.lastInfo = "Warning: Resolve reports Untitled Project. If your real project is open, restart Resolve. If it still reports Untitled Project, restart the PC."
		addDiagnostic(diagnostics, TitleInsert.lastInfo)
	end
	local timelineCount = tonumber(tryCall("GetTimelineCount", function()
		return project:GetTimelineCount()
	end, diagnostics)) or 0
	local timeline = tryCall("GetCurrentTimeline", function()
		return project:GetCurrentTimeline()
	end, diagnostics)

	addDiagnostic(diagnostics, "Timeline check: Project=" .. tostring(projectName) .. ", Count=" .. tostring(timelineCount) .. ", Current=" .. tostring(timeline ~= nil))

	if not timeline and timelineCount == 0 then
		local mediaPool = tryCall("GetMediaPool", function()
			return project:GetMediaPool()
		end, diagnostics)
		if mediaPool then
			local rootFolder = tryCall("GetRootFolder", function()
				return mediaPool:GetRootFolder()
			end, diagnostics)
			if rootFolder then
				tryCall("SetCurrentFolder(root)", function()
					return mediaPool:SetCurrentFolder(rootFolder)
				end, diagnostics)
			end

			local timelineName = "Envy Text Animator Timeline " .. os.date("%H%M%S")
			TitleInsert.lastInfo = "No active timeline found. Creating a new empty timeline."
			addDiagnostic(diagnostics, "No timelines found. Creating empty timeline: " .. timelineName)
			timeline = tryCall("CreateEmptyTimeline", function()
				return mediaPool:CreateEmptyTimeline(timelineName)
			end, diagnostics)
			addDiagnostic(diagnostics, "CreateEmptyTimeline returned: " .. tostring(timeline ~= nil))
			if timeline then
				tryCall("SetCurrentTimeline after create", function()
					return project:SetCurrentTimeline(timeline)
				end, diagnostics)
				timeline = tryCall("GetCurrentTimeline after create", function()
					return project:GetCurrentTimeline()
				end, diagnostics) or timeline
				timelineCount = tonumber(tryCall("GetTimelineCount after create", function()
					return project:GetTimelineCount()
				end, diagnostics)) or 1
				addDiagnostic(diagnostics, "Timeline after create: Count=" .. tostring(timelineCount) .. ", Current=" .. tostring(timeline ~= nil))
			end
		else
			addDiagnostic(diagnostics, "GetMediaPool returned nil; cannot create a timeline.")
		end
	end

	if not timeline then
		addDiagnostic(diagnostics, "No current timeline reported. Project: " .. tostring(projectName) .. ". Timeline count: " .. tostring(timelineCount))

		if timelineCount > 0 then
			TitleInsert.lastInfo = "No active timeline found. Trying the first available timeline."
			timeline = tryCall("GetTimelineByIndex(1)", function()
				return project:GetTimelineByIndex(1)
			end, diagnostics)
			if timeline then
				tryCall("SetCurrentTimeline", function()
					return project:SetCurrentTimeline(timeline)
				end, diagnostics)
				timeline = tryCall("GetCurrentTimeline after fallback", function()
					return project:GetCurrentTimeline()
				end, diagnostics) or timeline
			end
		end
	end

	if not timeline then
		TitleInsert.lastError = "No timeline found. Open or create a timeline and try again."
		if projectName == "Untitled Project" then
			TitleInsert.lastError = TitleInsert.lastError .. " Resolve reports Untitled Project; restart Resolve or the PC if your real project is already open."
		end
		return nil, nil, TitleInsert.lastError
	end

	local timelineName = tryCall("Timeline.GetName", function()
		return timeline:GetName()
	end, diagnostics) or "Current Timeline"
	TitleInsert.lastInfo = (TitleInsert.lastInfo and (TitleInsert.lastInfo .. "\n") or "") .. "Project: " .. tostring(projectName) .. "\nTimeline: " .. tostring(timelineName)

	return project, timeline, nil
end

function TitleInsert.setClipDuration(project, timeline, item, durationSeconds, animationLengthSeconds)
	local rate = Config.timelineFrameRate(project, timeline)
	local durationFrames = Config.durationFrames(rate, durationSeconds, animationLengthSeconds)

	pcall(function()
		item:SetProperty("Duration", durationFrames)
	end)

	-- Resolve can ignore Duration for generated Fusion Titles, so also trim the
	-- actual timeline item end to match the rendered source range.
	pcall(function()
		local startFrame = item:GetStart()
		if startFrame then
			item:SetEnd(startFrame + durationFrames)
		end
	end)

	pcall(function()
		local startFrame = item:GetStart()
		if startFrame then
			item:SetProperty("End", startFrame + durationFrames)
		end
	end)

	return durationFrames
end

local function itemKey(item)
	local okStart, startFrame = pcall(function()
		return item:GetStart()
	end)
	local okEnd, endFrame = pcall(function()
		return item:GetEnd()
	end)
	local okName, name = pcall(function()
		return item:GetName()
	end)

	if not okStart or not okEnd then
		return nil
	end

	return tostring(okName and name or "Unknown") .. "@" .. tostring(startFrame) .. "-" .. tostring(endFrame)
end

local function isTimelineItem(item)
	return itemKey(item) ~= nil
end

local function timelineItemSnapshot(timeline)
	local snapshot = {}
	local okTracks, trackCount = pcall(function()
		return timeline:GetTrackCount("video")
	end)
	trackCount = (okTracks and tonumber(trackCount)) or 0

	for trackIndex = 1, trackCount do
		local okItems, items = pcall(function()
			return timeline:GetItemsInTrack("video", trackIndex)
		end)
		if okItems and type(items) == "table" then
			for _, item in pairs(items) do
				local key = itemKey(item)
				if key then
					snapshot[key] = item
				end
			end
		end
	end

	return snapshot, trackCount
end

local function findNewTimelineItem(timeline, beforeSnapshot)
	local afterSnapshot = timelineItemSnapshot(timeline)

	for key, item in pairs(afterSnapshot) do
		if not beforeSnapshot[key] then
			return item, key
		end
	end

	return nil, nil
end

function TitleInsert.tryInsertGeneratedTitle(timeline, compText)
	TitleInsert.lastError = nil
	Utils.ensureDir(Config.titleDir())

	if not Utils.writeAll(Config.titlePath(), compText) then
		TitleInsert.lastError = "Could not write generated title: " .. Config.titlePath()
		print(TitleInsert.lastError)
		return nil
	end

	local beforeSnapshot, trackCount = timelineItemSnapshot(timeline)
	print("Insert diagnostic: video track count before insert = " .. tostring(trackCount))

	local item = timeline:InsertFusionTitleIntoTimeline(Config.titleName)
	if item and isTimelineItem(item) then
		print("Insert diagnostic: InsertFusionTitleIntoTimeline returned TimelineItem " .. tostring(itemKey(item)))
		return item
	end
	print("Insert diagnostic: InsertFusionTitleIntoTimeline returned " .. tostring(item))

	item = timeline:InsertFusionTitleIntoTimeline(Config.titleName .. ".setting")
	if item and isTimelineItem(item) then
		print("Insert diagnostic: InsertFusionTitleIntoTimeline(.setting) returned TimelineItem " .. tostring(itemKey(item)))
		return item
	end
	print("Insert diagnostic: InsertFusionTitleIntoTimeline(.setting) returned " .. tostring(item))

	local foundItem, foundKey = findNewTimelineItem(timeline, beforeSnapshot)
	if foundItem then
		print("Insert diagnostic: found new timeline item by track scan " .. tostring(foundKey))
		return foundItem
	end

	TitleInsert.lastError = "Generated title was written, but no new TimelineItem appeared on video tracks. Resolve returned " .. tostring(item) .. ". It may need a script/effects reload, or the playhead/track target is not insertable."
	print(TitleInsert.lastError)
	return nil
end

function TitleInsert.insertRawFusionComp(timeline, compText)
	if not Utils.writeAll(Config.tempCompPath(), compText) then
		print("Could not write temporary comp: " .. Config.tempCompPath())
		return nil
	end

	local item = timeline:InsertFusionCompositionIntoTimeline()
	if not item then
		print("Could not insert Fusion composition at the playhead.")
		return nil
	end

	local comp = item:ImportFusionComp(Config.tempCompPath())
	if not comp then
		print("Could not import generated comp: " .. Config.tempCompPath())
		return nil
	end

	return item
end

function TitleInsert.placeText(resolve, textValue, state)
	state = state or {}
	resolve:OpenPage("edit")
	bmd.wait(0.3)

	local project, timeline, err = TitleInsert.getTimeline(resolve)
	if err then
		print(err)
		TitleInsert.lastError = err
		return false
	end

	state.timelineFps = Config.timelineFrameRate(project, timeline)
	state.durationSeconds = tonumber(state.durationSeconds) or Config.defaultDurationSeconds
	state.animationLengthSeconds = Config.clampAnimationSeconds(state.animationLengthSeconds)

	-- Edit-page inspector controls only show when Resolve inserts this as a
	-- Fusion Title template. Raw Fusion comps expose controls on the Fusion page.
	local titleText = Generator.buildComp(textValue, state, true)
	local item = TitleInsert.tryInsertGeneratedTitle(timeline, titleText)

	if not item then
		local compText = Generator.buildComp(textValue, state, false)
		item = TitleInsert.insertRawFusionComp(timeline, compText)
	end

	if not item then
		TitleInsert.lastError = TitleInsert.lastError or "Could not insert generated text into the current timeline."
		return false
	end

	local durationFrames = TitleInsert.setClipDuration(project, timeline, item, state.durationSeconds, state.animationLengthSeconds)

	pcall(function()
		item:SetClipColor("Teal")
	end)

	print("Placed Envy's text at the current playhead. Target duration: " .. tostring(durationFrames) .. " frames.")
	return true
end

return TitleInsert

end

-- Envy's Text Animator UI - beta 0.0.4.
-- This file owns UI state only. Animation generation stays in the modules.

local function fileExists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	end

	return false
end

local function dirname(path)
	return (path:gsub("[/\\]+$", ""):match("^(.*)[/\\][^/\\]+$")) or "."
end

local function resolveScriptPath()
	local source = debug.getinfo(1, "S").source or ""
	if source:sub(1, 1) == "@" then
		return source:sub(2)
	end

	return source
end

local function hasModules(root)
	return root and fileExists(root .. "\\EnvysTextAnimator\\modules\\config.lua")
end

local function resolveScriptRoot()
	local scriptDir = dirname(resolveScriptPath())
	local candidates = {}
	local function addCandidate(path)
		if path and path ~= "" then
			table.insert(candidates, path)
		end
	end

	addCandidate(os.getenv("ENVYS_TEXT_ANIMATOR_ROOT"))
		addCandidate(scriptDir)
	addCandidate(dirname(scriptDir))

	for _, candidate in ipairs(candidates) do
		if hasModules(candidate) then
			return candidate
		end
	end

	error("Could not find EnvysTextAnimator modules. Set ENVYS_TEXT_ANIMATOR_ROOT to the folder that contains EnvysTextAnimator.")
end

local SCRIPT_ROOT = dirname(resolveScriptPath())
package.path = SCRIPT_ROOT .. "\\?.lua;" .. SCRIPT_ROOT .. "\\?\\init.lua;" .. package.path

local moduleNames = {
	"EnvysTextAnimator.modules.config",
	"EnvysTextAnimator.modules.followers",
	"EnvysTextAnimator.modules.easing",
	"EnvysTextAnimator.modules.animations_in",
	"EnvysTextAnimator.modules.animations_out",
	"EnvysTextAnimator.modules.generator",
	"EnvysTextAnimator.modules.title_insert",
	"EnvysTextAnimator.modules.utils",
}

for _, moduleName in ipairs(moduleNames) do
	package.loaded[moduleName] = nil
end

local Config = require("EnvysTextAnimator.modules.config")
local TitleInsert = require("EnvysTextAnimator.modules.title_insert")

Config.appName = Config.appName or "Envy's Text Animator"
Config.version = Config.version or "dev"

local logoCandidates = {
	SCRIPT_ROOT .. "\\assets\\Envystalogo.png",
	dirname(SCRIPT_ROOT) .. "\\assets\\Envystalogo.png",
}
local logoPath = nil
for _, candidate in ipairs(logoCandidates) do
	if fileExists(candidate) then
		logoPath = candidate
		break
	end
end

local logoHtml = [[<div align="center"><b>Envy's</b><br>Text Animator</div>]]
if logoPath then
	local logoUrl = logoPath:gsub("\\", "/")
	logoHtml = [[<div align="center"><img src="]] .. logoUrl .. [[" width="240"></div>]]
end

local resolve = Resolve()

if not resolve then
	print("Could not connect to DaVinci Resolve.")
	return
end

local fusion = resolve:Fusion()
local ui = fusion and fusion.UIManager or nil

if type(ui) == "function" then
	ui = fusion:UIManager()
end

if not ui and fu then
	ui = fu.UIManager
end

if type(ui) == "function" then
	ui = fu.UIManager()
end

if not ui or not bmd then
	print("Resolve UI Manager is not available in this scripting context.")
	return
end

local dispatcher = bmd.UIDispatcher(ui)

local followerOptions = {
	{ label = "Character", key = "char" },
	{ label = "Word", key = "word" },
	{ label = "Line", key = "line" },
}

local slideDirectionOptions = {
	{ label = "Up", key = "up" },
	{ label = "Down", key = "down" },
	{ label = "Left", key = "left" },
	{ label = "Right", key = "right" },
	{ label = "Up Left", key = "upLeft" },
	{ label = "Up Right", key = "upRight" },
	{ label = "Down Left", key = "downLeft" },
	{ label = "Down Right", key = "downRight" },
}

local easingOptions = {
	{ label = "Default", key = "default", engineKey = "setting" },
	{ label = "Ease In", key = "easeIn", engineKey = "quad" },
	{ label = "Ease Out", key = "easeOut", engineKey = "cubic" },
	{ label = "Ease In Out", key = "easeInOut", engineKey = "smooth" },
	{ label = "Back", key = "back", engineKey = "cubic" },
	{ label = "Bounce", key = "bounce", engineKey = "smooth" },
	{ label = "Elastic", key = "elastic", engineKey = "elastic" },
}

local fallbackFontOptions = {
	{ label = "Open Sans", key = "Open Sans" },
	{ label = "Arial", key = "Arial" },
	{ label = "Calibri", key = "Calibri" },
	{ label = "Segoe UI", key = "Segoe UI" },
	{ label = "Poppins", key = "Poppins" },
	{ label = "Montserrat", key = "Montserrat" },
	{ label = "Inter", key = "Inter" },
	{ label = "Roboto", key = "Roboto" },
	{ label = "Times New Roman", key = "Times New Roman" },
}

local fallbackFontStyleMap = {
	["Open Sans"] = { Regular = true },
	Arial = { Regular = true, Bold = true, Italic = true, ["Bold Italic"] = true },
	Calibri = { Regular = true, Bold = true, Italic = true, ["Bold Italic"] = true, Light = true },
	["Segoe UI"] = { Regular = true, Bold = true, Italic = true, ["Bold Italic"] = true, Semibold = true },
	Poppins = { Regular = true, Medium = true, SemiBold = true, Bold = true },
	Montserrat = { Regular = true, Medium = true, SemiBold = true, Bold = true },
	Inter = { Regular = true, Medium = true, SemiBold = true, Bold = true },
	Roboto = { Regular = true, Medium = true, Bold = true, Italic = true },
	["Times New Roman"] = { Regular = true, Bold = true, Italic = true, ["Bold Italic"] = true },
}

local fontStyleOrder = {
	"Regular",
	"Light",
	"Medium",
	"Semibold",
	"SemiBold",
	"Bold",
	"ExtraBold",
	"Black",
	"Italic",
	"Bold Italic",
	"Condensed",
	"Condensed Light",
	"Condensed Medium",
	"Condensed Bold",
	"Condensed Black",
	"Expanded",
	"Expanded Light",
	"Expanded Medium",
	"Expanded Bold",
	"Expanded Black",
	"Extraexpanded",
	"Extraexpanded Light",
	"Extraexpanded Medium",
	"Extraexpanded Bold",
	"Extraexpanded Black",
}

local baseFontStyleOptions = {
	{ label = "Regular", key = "Regular" },
	{ label = "Light", key = "Light" },
	{ label = "Medium", key = "Medium" },
	{ label = "Semibold", key = "Semibold" },
	{ label = "SemiBold", key = "SemiBold" },
	{ label = "Bold", key = "Bold" },
	{ label = "ExtraBold", key = "ExtraBold" },
	{ label = "Black", key = "Black" },
	{ label = "Italic", key = "Italic" },
	{ label = "Bold Italic", key = "Bold Italic" },
}

local function normalizeFontStyle(style)
	local cleaned = tostring(style or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local lower = cleaned:lower()
	if lower == "" or lower == "normal" then
		return "Regular"
	elseif lower == "semibold" or lower == "semi bold" or lower == "demibold" or lower == "demi bold" then
		return "SemiBold"
	elseif lower == "bolditalic" or lower == "bold italic" then
		return "Bold Italic"
	elseif lower == "extrabold" or lower == "extra bold" then
		return "ExtraBold"
	elseif lower == "regular" then
		return "Regular"
	elseif lower == "light" then
		return "Light"
	elseif lower == "medium" then
		return "Medium"
	elseif lower == "bold" then
		return "Bold"
	elseif lower == "black" then
		return "Black"
	elseif lower == "italic" then
		return "Italic"
	end

	cleaned = cleaned:gsub("Extra Expanded", "Extraexpanded")
	cleaned = cleaned:gsub("Semi Bold", "SemiBold")
	cleaned = cleaned:gsub("Semibold", "SemiBold")
	cleaned = cleaned:gsub("Extra Bold", "ExtraBold")
	cleaned = cleaned:gsub("^Normal%s+", "")
	if cleaned == "Normal" then
		return "Regular"
	end

	return cleaned
end

local function normalizeFontFamily(family)
	local cleaned = tostring(family or ""):gsub("^%s+", ""):gsub("%s+$", "")
	cleaned = cleaned:gsub("%s+PERSONAL%s+USE$", "")
	cleaned = cleaned:gsub("%s+PERSONAL$", "")
	cleaned = cleaned:gsub("(%S)FREE$", "%1 FREE")
	cleaned = cleaned:gsub("%s+", " ")

	return cleaned
end

local function buildFontStyleSuffixes()
	local widths = {
		"Extraexpanded",
		"Extra Expanded",
		"Expanded",
		"Condensed",
		"Normal",
	}
	local weights = {
		"ExtraBold",
		"Extra Bold",
		"SemiBold",
		"Semibold",
		"Semi Bold",
		"Medium",
		"Light",
		"Black",
		"Bold",
		"Regular",
	}
	local suffixes = {
		"ExtraBold Italic",
		"Extra Bold Italic",
		"Bold Italic",
		"SemiBold Italic",
		"Semibold Italic",
		"Semi Bold Italic",
		"Medium Italic",
		"Light Italic",
	}

	for _, width in ipairs(widths) do
		for _, weight in ipairs(weights) do
			table.insert(suffixes, width .. " " .. weight .. " Italic")
		end
		table.insert(suffixes, width .. " Italic")
	end

	for _, width in ipairs(widths) do
		for _, weight in ipairs(weights) do
			table.insert(suffixes, width .. " " .. weight)
		end
		table.insert(suffixes, width)
	end

	for _, suffix in ipairs(fontStyleOrder) do
		table.insert(suffixes, suffix)
	end

	return suffixes
end

local fontStyleSuffixes = buildFontStyleSuffixes()

local function detectFontFamilyAndStyle(displayName)
	local name = tostring(displayName or "")
	name = name:gsub("%s*%b()%s*$", "")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")

	local lowerName = name:lower()
	for _, suffix in ipairs(fontStyleSuffixes) do
		local lowerSuffix = suffix:lower()
		local fromIndex = #lowerName - #lowerSuffix + 1
		if fromIndex > 1 and lowerName:sub(fromIndex) == lowerSuffix and lowerName:sub(fromIndex - 1, fromIndex - 1) == " " then
			local family = name:sub(1, fromIndex - 2):gsub("%s+$", "")
			if family ~= "" then
				return family, normalizeFontStyle(suffix)
			end
		end
	end

	return name, "Regular"
end

local function addFont(fontMap, family, style)
	family = normalizeFontFamily(family)
	if not family or family == "" then
		return
	end

	fontMap[family] = fontMap[family] or {}
	fontMap[family][normalizeFontStyle(style)] = true
end

local function addRegistryFontDisplayName(fontMap, displayName)
	for namePart in tostring(displayName or ""):gmatch("[^&]+") do
		local family, style = detectFontFamilyAndStyle(namePart)
		addFont(fontMap, family, style)
	end
end

local function scanRegistryFonts(fontMap, registryPath)
	local command = 'reg query "' .. registryPath .. '"'
	local pipe = io.popen(command)
	if not pipe then
		return
	end

	for line in pipe:lines() do
		local displayName = line:match("^%s*(.-)%s+REG_%S+%s+.+$")
		if displayName and displayName ~= "" then
			addRegistryFontDisplayName(fontMap, displayName)
		end
	end

	pipe:close()
end

local function sortedFontOptions(fontMap)
	local names = {}
	for family in pairs(fontMap) do
		table.insert(names, family)
	end
	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)

	local options = {}
	for _, family in ipairs(names) do
		table.insert(options, { label = family, key = family })
	end

	return options
end

local function loadWindowsFonts()
	local fontMap = {}

	for family, styles in pairs(fallbackFontStyleMap) do
		for style in pairs(styles) do
			addFont(fontMap, family, style)
		end
	end

	if io and io.popen then
		scanRegistryFonts(fontMap, "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts")
		scanRegistryFonts(fontMap, "HKCU\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts")
	end

	return sortedFontOptions(fontMap), fontMap
end

local fontOptions, fontStyleMap = loadWindowsFonts()
local fontStyleOptions = {}

local function styleOptionsForFont(fontFamily)
	local styles = fontStyleMap[fontFamily] or {}
	local options = {}

	for _, style in ipairs(fontStyleOrder) do
		if style == "Regular" or styles[style] then
			table.insert(options, { label = style, key = style })
		end
	end

	local added = {}
	for _, item in ipairs(options) do
		added[item.key] = true
	end

	local extraStyles = {}
	for style in pairs(styles) do
		if not added[style] then
			table.insert(extraStyles, style)
		end
	end
	table.sort(extraStyles, function(a, b)
		return a:lower() < b:lower()
	end)

	for _, style in ipairs(extraStyles) do
		table.insert(options, { label = style, key = style })
	end

	if #options == 0 then
		table.insert(options, { label = "Regular", key = "Regular" })
	end

	return options
end

fontStyleOptions = styleOptionsForFont(Config.defaultFont)

local config = {
	text = Config.defaultText,
	textStyle = {
		font = Config.defaultFont,
		style = Config.defaultFontStyle,
	},
	follower = {
		mode = "char",
	},
	animationIn = {
		fade = true,
		blur = true,
		slide = true,
		scale = false,
		rotate = false,
	},
	animationOut = {
		fade = false,
		blur = false,
		slide = false,
		scale = false,
		rotate = false,
	},
	slideIn = {
		direction = "up",
	},
	slideOut = {
		direction = "down",
	},
	easing = {
		inType = "default",
		outType = "default",
	},
	animationLengthSeconds = Config.defaultAnimationSeconds,
}

local debugLines = {}
local debugLogVisible = true

local function optionKeyByLabel(options, label)
	if label == nil then
		return nil
	end

	local text = tostring(label)
	for _, item in ipairs(options) do
		if item.label == text then
			return item.key
		end
	end

	return nil
end

local function optionKey(options, index, fallback)
	local numericIndex = tonumber(index)
	local item = nil

	if numericIndex == 0 then
		item = options[1]
	elseif numericIndex and numericIndex >= 1 then
		item = options[numericIndex]
	end

	return item and item.key or fallback
end

local function comboOptionKey(combo, options, fallback)
	if combo then
		local key = optionKeyByLabel(options, combo.CurrentText)
			or optionKeyByLabel(options, combo.Text)
		if key then
			return key
		end
	end

	return optionKey(options, combo and combo.CurrentIndex, fallback)
end

local function optionLabel(options, key)
	for _, item in ipairs(options) do
		if item.key == key then
			return item.label
		end
	end

	return tostring(key)
end

local function easingEngineKey(key)
	for _, item in ipairs(easingOptions) do
		if item.key == key then
			return item.engineKey
		end
	end

	return "setting"
end

local function bool(value)
	return value == true or value == 1
end

local function selectedAnimations(animations)
	local labels = {}
	local order = {
		{ key = "fade", label = "Fade" },
		{ key = "blur", label = "Blur" },
		{ key = "slide", label = "Slide" },
		{ key = "scale", label = "Scale" },
		{ key = "rotate", label = "Rotate" },
	}

	for _, item in ipairs(order) do
		if animations[item.key] then
			table.insert(labels, item.label)
		end
	end

	if #labels == 0 then
		return "None"
	end

	return table.concat(labels, ", ")
end

local function appendLog(items, level, message)
	local line = "[" .. level .. "] " .. message
	table.insert(debugLines, line)

	if items and items.DebugLog then
		items.DebugLog.PlainText = table.concat(debugLines, "\n")
	end

	print(line)
end

local function addComboItems(combo, options, selectedKey)
	pcall(function()
		combo:Clear()
	end)
	pcall(function()
		combo:ClearItems()
	end)

	local selectedIndex = 0
	for index, item in ipairs(options) do
		pcall(function()
			combo:AddItem(item.label)
		end)

		if item.key == selectedKey then
			selectedIndex = index - 1
		end
	end

	pcall(function()
		combo.CurrentIndex = selectedIndex
	end)
end

local function hasOption(options, key)
	for _, item in ipairs(options) do
		if item.key == key then
			return true
		end
	end

	return false
end

local function refreshFontStyleOptions(items, fontFamily, preferredStyle)
	fontStyleOptions = styleOptionsForFont(fontFamily)
	local selectedStyle = preferredStyle
	if not hasOption(fontStyleOptions, selectedStyle) then
		selectedStyle = "Regular"
	end
	if not hasOption(fontStyleOptions, selectedStyle) and fontStyleOptions[1] then
		selectedStyle = fontStyleOptions[1].key
	end

	if items and items.FontStyleCombo then
		addComboItems(items.FontStyleCombo, fontStyleOptions, selectedStyle)
	end

	config.textStyle.style = selectedStyle or "Regular"
end

local function setChecked(item, value)
	pcall(function()
		item.Checked = value
	end)
end

local function getChecked(item)
	local ok, value = pcall(function()
		return item.Checked
	end)

	if ok then
		return bool(value)
	end

	return false
end

local function getText(item)
	local ok, value = pcall(function()
		return item.Text
	end)

	if ok and value ~= nil then
		return tostring(value)
	end

	ok, value = pcall(function()
		return item.PlainText
	end)

	if ok and value ~= nil then
		return tostring(value)
	end

	return ""
end

local function numberFromText(value, fallback)
	local parsed = tonumber(value)
	if parsed == nil then
		return fallback
	end

	return parsed
end

local function animationSecondsToSliderValue(seconds)
	return math.floor((Config.clampAnimationSeconds(seconds) * 1000) + 0.5)
end

local function sliderValueToAnimationSeconds(value)
	return Config.clampAnimationSeconds((tonumber(value) or animationSecondsToSliderValue(Config.defaultAnimationSeconds)) / 1000)
end

local function setAnimationLengthText(items, seconds)
	if items and items.AnimationLengthInput then
		items.AnimationLengthInput.Text = string.format("%.4f", Config.clampAnimationSeconds(seconds))
	end
end

local function setAnimationLengthSlider(items, seconds)
	if items and items.AnimationLengthSlider then
		items.AnimationLengthSlider.Value = animationSecondsToSliderValue(seconds)
	end
end

local function directionToSlideKey(direction)
	local slideKey = "slideUp"

	if direction == "down" then
		slideKey = "slideDown"
	elseif direction == "left" then
		slideKey = "slideLeft"
	elseif direction == "right" then
		slideKey = "slideRight"
	elseif direction == "upLeft" then
		slideKey = "slideUpLeft"
	elseif direction == "upRight" then
		slideKey = "slideUpRight"
	elseif direction == "downLeft" then
		slideKey = "slideDownLeft"
	elseif direction == "downRight" then
		slideKey = "slideDownRight"
	end

	return slideKey
end

-- UI config maps to the existing animation engine state here.
-- Each Slide checkbox expands to one legacy direction key for its own phase.
local function configToEngineState(uiConfig)
	local slideInKey = directionToSlideKey(uiConfig.slideIn.direction)
	local slideOutKey = directionToSlideKey(uiConfig.slideOut.direction)

	local animationIn = {
		fade = uiConfig.animationIn.fade,
		blur = uiConfig.animationIn.blur,
		scale = uiConfig.animationIn.scale,
		rotate = uiConfig.animationIn.rotate,
		slideUp = false,
		slideDown = false,
		slideLeft = false,
		slideRight = false,
		slideUpLeft = false,
		slideUpRight = false,
		slideDownLeft = false,
		slideDownRight = false,
	}

	local animationOut = {
		fade = uiConfig.animationOut.fade,
		blur = uiConfig.animationOut.blur,
		scale = uiConfig.animationOut.scale,
		rotate = uiConfig.animationOut.rotate,
		slideUp = false,
		slideDown = false,
		slideLeft = false,
		slideRight = false,
		slideUpLeft = false,
		slideUpRight = false,
		slideDownLeft = false,
		slideDownRight = false,
	}

	if uiConfig.animationIn.slide then
		animationIn[slideInKey] = true
	end

	if uiConfig.animationOut.slide then
		animationOut[slideOutKey] = true
	end

	return {
		followerMode = uiConfig.follower.mode,
		animations = animationIn,
		animationsOut = animationOut,
		easingIn = easingEngineKey(uiConfig.easing.inType),
		easingOut = easingEngineKey(uiConfig.easing.outType),
		fontFamily = uiConfig.textStyle.font,
		fontStyle = uiConfig.textStyle.style,
		animationLengthSeconds = uiConfig.animationLengthSeconds,
	}
end

local function readConfigFromUI(items)
	local text = items.TextInput.PlainText
	if text == nil or text == "" then
		text = Config.defaultText
	end

	config.text = text
	config.textStyle.font = comboOptionKey(items.FontCombo, fontOptions, Config.defaultFont)
	config.textStyle.style = comboOptionKey(items.FontStyleCombo, fontStyleOptions, Config.defaultFontStyle)
	config.follower.mode = comboOptionKey(items.FollowerCombo, followerOptions, "char")
	config.animationIn.fade = getChecked(items.AnimInFade)
	config.animationIn.blur = getChecked(items.AnimInBlur)
	config.animationIn.slide = getChecked(items.AnimInSlide)
	config.animationIn.scale = getChecked(items.AnimInScale)
	config.animationIn.rotate = getChecked(items.AnimInRotate)
	config.animationOut.fade = getChecked(items.AnimOutFade)
	config.animationOut.blur = getChecked(items.AnimOutBlur)
	config.animationOut.slide = getChecked(items.AnimOutSlide)
	config.animationOut.scale = getChecked(items.AnimOutScale)
	config.animationOut.rotate = getChecked(items.AnimOutRotate)
	config.slideIn.direction = comboOptionKey(items.SlideInDirectionCombo, slideDirectionOptions, "up")
	config.slideOut.direction = comboOptionKey(items.SlideOutDirectionCombo, slideDirectionOptions, "down")
	config.easing.inType = comboOptionKey(items.EasingInCombo, easingOptions, "default")
	config.easing.outType = comboOptionKey(items.EasingOutCombo, easingOptions, "default")
	config.animationLengthSeconds = Config.clampAnimationSeconds(numberFromText(getText(items.AnimationLengthInput), Config.defaultAnimationSeconds))
	setAnimationLengthText(items, config.animationLengthSeconds)
	setAnimationLengthSlider(items, config.animationLengthSeconds)

	return config
end

local function logCurrentConfig(items)
	appendLog(items, "INFO", "Font: " .. config.textStyle.font .. " / " .. config.textStyle.style)
	appendLog(items, "INFO", "Selected follower: " .. optionLabel(followerOptions, config.follower.mode))
	appendLog(items, "INFO", "Animation In: " .. selectedAnimations(config.animationIn))
	appendLog(items, "INFO", "Animation Out: " .. selectedAnimations(config.animationOut))
	appendLog(items, "INFO", "Slide In direction: " .. optionLabel(slideDirectionOptions, config.slideIn.direction))
	appendLog(items, "INFO", "Slide Out direction: " .. optionLabel(slideDirectionOptions, config.slideOut.direction))
	appendLog(items, "INFO", "Easing In: " .. optionLabel(easingOptions, config.easing.inType))
	appendLog(items, "INFO", "Easing Out: " .. optionLabel(easingOptions, config.easing.outType))
	appendLog(items, "INFO", "Animation Length: " .. string.format("%.4f", config.animationLengthSeconds) .. "s")
end

local function sectionLabel(text)
	return [[<span style="color:#5ae4a8;font-weight:600;letter-spacing:2px;">]] .. text .. [[</span>]]
end

local function mutedLabel(text)
	return [[<span style="color:#8a8a8a;">]] .. text .. [[</span>]]
end

local win = dispatcher:AddWindow({
	ID = "EnvysTextAnimatorWindow",
	WindowTitle = Config.appName .. " - " .. Config.version,
	Geometry = { 100, 100, 520, 760 },
	Spacing = 10,
	Margin = 14,
}, ui:VGroup{
	ID = "Root",
	Spacing = 10,

	ui:HGroup{
		ID = "BrandHeader",
		Spacing = 10,
		ui:Label{
			ID = "BrandName",
			Text = [[<span style="color:#5ae4a8;font-weight:700;">Envys</span><span style="color:#555;"> . </span><span style="color:#b8b8b8;">Text Animator</span>]],
			MinimumSize = { 360, 26 },
			Alignment = { AlignLeft = true, AlignVCenter = true },
		},
		ui:Label{
			ID = "BuildLabel",
			Text = [[<span style="color:#666;">]] .. Config.version .. [[</span>]],
			MinimumSize = { 110, 26 },
			Alignment = { AlignRight = true, AlignVCenter = true },
		},
	},

	ui:VGroup{
		ID = "TextPanel",
		Spacing = 6,
		ui:Label{ ID = "TextInputLabel", Text = sectionLabel("TEXT INPUT") },
		ui:TextEdit{
			ID = "TextInput",
			PlainText = "",
			PlaceholderText = Config.defaultText,
			MinimumSize = { 480, 92 },
		},
	},

	ui:VGroup{
		ID = "StylePanel",
		Spacing = 6,
		ui:Label{ ID = "TextStyleLabel", Text = sectionLabel("TEXT STYLE") },
		ui:HGroup{
			Spacing = 10,
			ui:ComboBox{ ID = "FontCombo", MinimumSize = { 320, 24 } },
			ui:ComboBox{ ID = "FontStyleCombo", MinimumSize = { 150, 24 } },
		},
	},

	ui:VGroup{
		ID = "FollowerPanel",
		Spacing = 6,
		ui:Label{ ID = "FollowerLabel", Text = sectionLabel("FOLLOWER") },
		ui:ComboBox{ ID = "FollowerCombo", MinimumSize = { 480, 24 } },
	},

	ui:HGroup{
		ID = "AnimationPanels",
		Spacing = 12,
		ui:VGroup{
			ID = "AnimationInPanel",
			Spacing = 7,
			ui:Label{ ID = "AnimationInLabel", Text = sectionLabel("ANIMATION IN") },
			ui:HGroup{
				Spacing = 8,
				ui:CheckBox{ ID = "AnimInSlide", Text = "Slide", MinimumSize = { 76, 20 } },
				ui:ComboBox{ ID = "SlideInDirectionCombo", MinimumSize = { 136, 22 } },
			},
			ui:HGroup{
				Spacing = 8,
				ui:CheckBox{ ID = "AnimInBlur", Text = "Blur", MinimumSize = { 104, 20 } },
				ui:CheckBox{ ID = "AnimInRotate", Text = "Rotate", MinimumSize = { 104, 20 } },
			},
			ui:HGroup{
				Spacing = 8,
				ui:CheckBox{ ID = "AnimInFade", Text = "Fade", MinimumSize = { 104, 20 } },
				ui:CheckBox{ ID = "AnimInScale", Text = "Scale", MinimumSize = { 104, 20 } },
			},
		},
		ui:VGroup{
			ID = "AnimationOutPanel",
			Spacing = 7,
			ui:Label{ ID = "AnimationOutLabel", Text = sectionLabel("ANIMATION OUT") },
			ui:HGroup{
				Spacing = 8,
				ui:CheckBox{ ID = "AnimOutSlide", Text = "Slide", MinimumSize = { 76, 20 } },
				ui:ComboBox{ ID = "SlideOutDirectionCombo", MinimumSize = { 136, 22 } },
			},
			ui:HGroup{
				Spacing = 8,
				ui:CheckBox{ ID = "AnimOutBlur", Text = "Blur", MinimumSize = { 104, 20 } },
				ui:CheckBox{ ID = "AnimOutRotate", Text = "Rotate", MinimumSize = { 104, 20 } },
			},
			ui:HGroup{
				Spacing = 8,
				ui:CheckBox{ ID = "AnimOutFade", Text = "Fade", MinimumSize = { 104, 20 } },
				ui:CheckBox{ ID = "AnimOutScale", Text = "Scale", MinimumSize = { 104, 20 } },
			},
		},
	},

	ui:VGroup{
		ID = "EasingPanel",
		Spacing = 6,
		ui:Label{ ID = "EasingLabel", Text = sectionLabel("EASING") },
		ui:HGroup{
			Spacing = 10,
			ui:VGroup{
				Spacing = 4,
				ui:Label{ ID = "EasingInLabel", Text = mutedLabel("In") },
				ui:ComboBox{ ID = "EasingInCombo", MinimumSize = { 235, 24 } },
			},
			ui:VGroup{
				Spacing = 4,
				ui:Label{ ID = "EasingOutLabel", Text = mutedLabel("Out") },
				ui:ComboBox{ ID = "EasingOutCombo", MinimumSize = { 235, 24 } },
			},
		},
	},

	ui:VGroup{
		ID = "AnimationLengthPanel",
		Spacing = 5,
		ui:Label{ ID = "AnimationLengthLabel", Text = sectionLabel("ANIMATION LENGTH") },
		ui:HGroup{
			Spacing = 10,
			ui:Slider{
				ID = "AnimationLengthSlider",
				Minimum = animationSecondsToSliderValue(Config.minAnimationSeconds),
				Maximum = animationSecondsToSliderValue(Config.maxAnimationSeconds),
				Value = animationSecondsToSliderValue(Config.defaultAnimationSeconds),
				MinimumSize = { 360, 24 },
			},
			ui:LineEdit{
				ID = "AnimationLengthInput",
				Text = string.format("%.4f", Config.defaultAnimationSeconds),
				MinimumSize = { 100, 24 },
			},
		},
	},

	ui:Button{
		ID = "CustomBezierPlaceholder",
		Text = "Custom Bezier - Coming Later",
		Enabled = false,
		MinimumSize = { 480, 26 },
	},

	ui:VGroup{
		ID = "DebugPanel",
		Spacing = 5,
		ui:HGroup{
			Spacing = 8,
			ui:Label{ ID = "DebugLogLabel", Text = sectionLabel("DEBUG LOG"), MinimumSize = { 360, 22 } },
			ui:Button{ ID = "DebugToggle", Text = "Hide", MinimumSize = { 90, 22 } },
		},
		ui:TextEdit{
			ID = "DebugLog",
			ReadOnly = true,
			PlainText = "",
			MinimumSize = { 480, 76 },
		},
	},

	ui:Label{
		ID = "TrackLockNote",
		Text = [[<span style="color:#5ae4a8;">tip:</span><span style="color:#8a8a8a;"> lock the track underneath before placing text.</span>]],
		Alignment = { AlignHCenter = true, AlignVCenter = true },
		MinimumSize = { 480, 20 },
	},

	ui:Button{
		ID = "GenerateText",
		Text = "PLACE TEXT",
		MinimumSize = { 480, 52 },
		StyleSheet = [[
			QPushButton {
				background-color: #5ae4a8;
				color: #0b1a13;
				border: 1px solid #72eebc;
				border-radius: 7px;
				font-size: 15px;
				font-weight: 800;
				letter-spacing: 1px;
			}
			QPushButton:hover {
				background-color: #72eebc;
			}
			QPushButton:pressed {
				background-color: #42c98e;
			}
		]],
	},
})

local items = win:GetItems()

addComboItems(items.FontCombo, fontOptions, config.textStyle.font)
refreshFontStyleOptions(items, config.textStyle.font, config.textStyle.style)
addComboItems(items.FollowerCombo, followerOptions, config.follower.mode)
addComboItems(items.SlideInDirectionCombo, slideDirectionOptions, config.slideIn.direction)
addComboItems(items.SlideOutDirectionCombo, slideDirectionOptions, config.slideOut.direction)
addComboItems(items.EasingInCombo, easingOptions, config.easing.inType)
addComboItems(items.EasingOutCombo, easingOptions, config.easing.outType)

setChecked(items.AnimInFade, config.animationIn.fade)
setChecked(items.AnimInBlur, config.animationIn.blur)
setChecked(items.AnimInSlide, config.animationIn.slide)
setChecked(items.AnimInScale, config.animationIn.scale)
setChecked(items.AnimInRotate, config.animationIn.rotate)
setChecked(items.AnimOutFade, config.animationOut.fade)
setChecked(items.AnimOutBlur, config.animationOut.blur)
setChecked(items.AnimOutSlide, config.animationOut.slide)
setChecked(items.AnimOutScale, config.animationOut.scale)
setChecked(items.AnimOutRotate, config.animationOut.rotate)

appendLog(items, "INFO", "UI loaded")
appendLog(items, "INFO", "Build: " .. Config.version)
appendLog(items, "INFO", "Loaded fonts: " .. tostring(#fontOptions))

function win.On.EnvysTextAnimatorWindow.Close(ev)
	dispatcher:ExitLoop()
end

function win.On.FollowerCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Selected follower: " .. optionLabel(followerOptions, config.follower.mode))
end

function win.On.FontCombo.CurrentIndexChanged(ev)
	local previousStyle = config.textStyle.style
	config.textStyle.font = comboOptionKey(items.FontCombo, fontOptions, Config.defaultFont)
	refreshFontStyleOptions(items, config.textStyle.font, previousStyle)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Font: " .. config.textStyle.font .. " / " .. config.textStyle.style)
end

function win.On.FontStyleCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Font: " .. config.textStyle.font .. " / " .. config.textStyle.style)
end

function win.On.SlideInDirectionCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Slide In direction: " .. optionLabel(slideDirectionOptions, config.slideIn.direction))
end

function win.On.SlideOutDirectionCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Slide Out direction: " .. optionLabel(slideDirectionOptions, config.slideOut.direction))
end

function win.On.EasingInCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Easing In: " .. optionLabel(easingOptions, config.easing.inType))
end

function win.On.EasingOutCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Easing Out: " .. optionLabel(easingOptions, config.easing.outType))
end

function win.On.DebugToggle.Clicked(ev)
	debugLogVisible = not debugLogVisible
	items.DebugLog.Hidden = not debugLogVisible
	items.DebugToggle.Text = debugLogVisible and "Hide" or "Show"
	appendLog(items, "INFO", debugLogVisible and "Debug log expanded" or "Debug log collapsed")
end

function win.On.AnimationLengthSlider.ValueChanged(ev)
	local seconds = sliderValueToAnimationSeconds(items.AnimationLengthSlider.Value)
	setAnimationLengthText(items, seconds)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Animation Length: " .. string.format("%.4f", config.animationLengthSeconds) .. "s")
end

local function logAnimationChange(items, label)
	readConfigFromUI(items)
	appendLog(items, "INFO", label)
	appendLog(items, "INFO", "Animation In: " .. selectedAnimations(config.animationIn))
	appendLog(items, "INFO", "Animation Out: " .. selectedAnimations(config.animationOut))
end

function win.On.AnimInFade.Clicked(ev)
	logAnimationChange(items, "Animation In Fade changed")
end

function win.On.AnimInBlur.Clicked(ev)
	logAnimationChange(items, "Animation In Blur changed")
end

function win.On.AnimInSlide.Clicked(ev)
	logAnimationChange(items, "Animation In Slide changed")
end

function win.On.AnimInScale.Clicked(ev)
	logAnimationChange(items, "Animation In Scale changed")
end

function win.On.AnimInRotate.Clicked(ev)
	logAnimationChange(items, "Animation In Rotate changed")
end

function win.On.AnimOutFade.Clicked(ev)
	logAnimationChange(items, "Animation Out Fade changed")
end

function win.On.AnimOutBlur.Clicked(ev)
	logAnimationChange(items, "Animation Out Blur changed")
end

function win.On.AnimOutSlide.Clicked(ev)
	logAnimationChange(items, "Animation Out Slide changed")
end

function win.On.AnimOutScale.Clicked(ev)
	logAnimationChange(items, "Animation Out Scale changed")
end

function win.On.AnimOutRotate.Clicked(ev)
	logAnimationChange(items, "Animation Out Rotate changed")
end

function win.On.GenerateText.Clicked(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Place Text clicked")
	logCurrentConfig(items)

	local engineState = configToEngineState(config)

	local ok, placed = pcall(function()
		return TitleInsert.placeText(resolve, config.text, engineState)
	end)

	if not ok then
		appendLog(items, "ERROR", "Failed to create TextPlus: " .. tostring(placed))
		return
	end

	if placed then
		if TitleInsert.lastInfo then
			for line in tostring(TitleInsert.lastInfo):gmatch("[^\n]+") do
				appendLog(items, line:match("^Warning:") and "WARN" or "INFO", line)
			end
		end
		appendLog(items, "INFO", "Text generated successfully")
		dispatcher:ExitLoop()
	else
		appendLog(items, "ERROR", TitleInsert.lastError or "Failed to create TextPlus")
	end
end

win:Show()
dispatcher:RunLoop()
win:Hide()
