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
