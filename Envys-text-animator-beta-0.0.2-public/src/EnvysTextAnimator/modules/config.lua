local Config = {}

Config.titleName = "Envys Text Animator Generated"
Config.appName = "Envy's Text Animator"
Config.version = "beta 0.0.2a"
Config.defaultText = "Your Text Here"
Config.defaultDurationSeconds = 5
Config.defaultTimelineFps = 24
Config.defaultAnimationSeconds = 10 / Config.defaultTimelineFps
Config.minAnimationSeconds = 0.1
Config.maxAnimationSeconds = 1.5
Config.animationEndFrame = 100
Config.stretchStartFrame = 40
Config.stretchEndFrame = 90
Config.tailPaddingFrames = 22

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
	local seconds = tonumber(durationSeconds) or Config.defaultDurationSeconds
	local fps = tonumber(frameRate) or Config.defaultTimelineFps
	local timing = Config.animationTiming(fps, animationSeconds)

	return math.max(timing.sourceEndFrame + 1, math.floor((fps * seconds) + 0.5))
end

function Config.globalOutFrame(frameRate, durationSeconds, animationSeconds)
	return Config.durationFrames(frameRate, durationSeconds, animationSeconds) - 1
end

function Config.animationTiming(frameRate, animationSeconds)
	local fps = tonumber(frameRate) or Config.defaultTimelineFps
	local scale = fps / Config.defaultTimelineFps
	local animationFrameCount = math.max(1, math.floor((fps * Config.clampAnimationSeconds(animationSeconds)) + 0.5))
	local outStartFrame = scaledFrame(Config.stretchEndFrame, scale)
	local outEndFrame = outStartFrame + animationFrameCount

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
		tailPaddingFrames = scaledFrame(Config.tailPaddingFrames, scale),
		sourceEndFrame = outEndFrame + scaledFrame(Config.tailPaddingFrames, scale),
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
