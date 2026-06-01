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
