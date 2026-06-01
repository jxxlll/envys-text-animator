-- Envy's Text Animator UI - beta 0.0.2a.
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
	addCandidate(os.getenv("USERPROFILE") and (os.getenv("USERPROFILE") .. "\\Documents\\envys-text-animator\\src") or nil)
	addCandidate(scriptDir)
	addCandidate(dirname(scriptDir))

	for _, candidate in ipairs(candidates) do
		if hasModules(candidate) then
			return candidate
		end
	end

	error("Could not find EnvysTextAnimator modules. Set ENVYS_TEXT_ANIMATOR_ROOT to the folder that contains EnvysTextAnimator.")
end

local SCRIPT_ROOT = resolveScriptRoot()
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

local config = {
	text = Config.defaultText,
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

local function optionKey(options, index, fallback)
	local item = options[(tonumber(index) or 0) + 1]
	return item and item.key or fallback
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
	for index, item in ipairs(options) do
		pcall(function()
			combo:AddItem(item.label)
		end)

		if item.key == selectedKey then
			pcall(function()
				combo.CurrentIndex = index - 1
			end)
		end
	end
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
		animationLengthSeconds = uiConfig.animationLengthSeconds,
	}
end

local function readConfigFromUI(items)
	local text = items.TextInput.PlainText
	if text == nil or text == "" then
		text = Config.defaultText
	end

	config.text = text
	config.follower.mode = optionKey(followerOptions, items.FollowerCombo.CurrentIndex, "char")
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
	config.slideIn.direction = optionKey(slideDirectionOptions, items.SlideInDirectionCombo.CurrentIndex, "up")
	config.slideOut.direction = optionKey(slideDirectionOptions, items.SlideOutDirectionCombo.CurrentIndex, "down")
	config.easing.inType = optionKey(easingOptions, items.EasingInCombo.CurrentIndex, "default")
	config.easing.outType = optionKey(easingOptions, items.EasingOutCombo.CurrentIndex, "default")
	config.animationLengthSeconds = Config.clampAnimationSeconds(numberFromText(getText(items.AnimationLengthInput), Config.defaultAnimationSeconds))
	setAnimationLengthText(items, config.animationLengthSeconds)
	setAnimationLengthSlider(items, config.animationLengthSeconds)

	return config
end

local function logCurrentConfig(items)
	appendLog(items, "INFO", "Selected follower: " .. optionLabel(followerOptions, config.follower.mode))
	appendLog(items, "INFO", "Animation In: " .. selectedAnimations(config.animationIn))
	appendLog(items, "INFO", "Animation Out: " .. selectedAnimations(config.animationOut))
	appendLog(items, "INFO", "Slide In direction: " .. optionLabel(slideDirectionOptions, config.slideIn.direction))
	appendLog(items, "INFO", "Slide Out direction: " .. optionLabel(slideDirectionOptions, config.slideOut.direction))
	appendLog(items, "INFO", "Easing In: " .. optionLabel(easingOptions, config.easing.inType))
	appendLog(items, "INFO", "Easing Out: " .. optionLabel(easingOptions, config.easing.outType))
	appendLog(items, "INFO", "Animation Length: " .. string.format("%.4f", config.animationLengthSeconds) .. "s")
end

local win = dispatcher:AddWindow({
	ID = "EnvysTextAnimatorWindow",
	WindowTitle = Config.appName .. " - " .. Config.version,
	Geometry = { 100, 100, 520, 740 },
	Spacing = 7,
	Margin = 16,
}, ui:VGroup{
	ID = "Root",
	Spacing = 7,

	ui:VGroup{
		ID = "HeaderInputStack",
		Spacing = 10,
		ui:Label{
			ID = "LogoHeader",
			Text = logoHtml,
			MinimumSize = { 460, 88 },
			Alignment = { AlignHCenter = true, AlignVCenter = true },
		},
		ui:TextEdit{
			ID = "TextInput",
			PlainText = "",
			PlaceholderText = Config.defaultText,
			MinimumSize = { 460, 104 },
		},
	},

	ui:VGroup{
		Spacing = 6,
		ui:Label{ ID = "FollowerLabel", Text = "Follower" },
		ui:ComboBox{ ID = "FollowerCombo" },
	},

	ui:HGroup{
		Spacing = 18,
		ui:VGroup{
			Spacing = 6,
			ui:Label{ ID = "AnimationInLabel", Text = "Animation In" },
			ui:HGroup{
				Spacing = 12,
				ui:CheckBox{ ID = "AnimInSlide", Text = "Slide" },
				ui:ComboBox{ ID = "SlideInDirectionCombo", MinimumSize = { 92, 22 } },
			},
			ui:HGroup{
				Spacing = 12,
				ui:CheckBox{ ID = "AnimInBlur", Text = "Blur" },
				ui:CheckBox{ ID = "AnimInRotate", Text = "Rotate" },
			},
			ui:HGroup{
				Spacing = 12,
				ui:CheckBox{ ID = "AnimInFade", Text = "Fade" },
				ui:CheckBox{ ID = "AnimInScale", Text = "Scale" },
			},
		},
		ui:VGroup{
			Spacing = 6,
			ui:Label{ ID = "AnimationOutLabel", Text = "Animation Out" },
			ui:HGroup{
				Spacing = 12,
				ui:CheckBox{ ID = "AnimOutSlide", Text = "Slide" },
				ui:ComboBox{ ID = "SlideOutDirectionCombo", MinimumSize = { 92, 22 } },
			},
			ui:HGroup{
				Spacing = 12,
				ui:CheckBox{ ID = "AnimOutBlur", Text = "Blur" },
				ui:CheckBox{ ID = "AnimOutRotate", Text = "Rotate" },
			},
			ui:HGroup{
				Spacing = 12,
				ui:CheckBox{ ID = "AnimOutFade", Text = "Fade" },
				ui:CheckBox{ ID = "AnimOutScale", Text = "Scale" },
			},
		},
	},

	ui:Label{ ID = "EasingLabel", Text = "Easing" },
	ui:HGroup{
		Spacing = 10,
		ui:VGroup{
			Spacing = 4,
			ui:Label{ ID = "EasingInLabel", Text = "Easing In" },
			ui:ComboBox{ ID = "EasingInCombo" },
		},
		ui:VGroup{
			Spacing = 4,
			ui:Label{ ID = "EasingOutLabel", Text = "Easing Out" },
			ui:ComboBox{ ID = "EasingOutCombo" },
		},
	},

	ui:VGroup{
		Spacing = 4,
		ui:Label{ ID = "AnimationLengthLabel", Text = "Animation Length (sec)" },
		ui:HGroup{
			Spacing = 10,
			ui:Slider{
				ID = "AnimationLengthSlider",
				Minimum = animationSecondsToSliderValue(Config.minAnimationSeconds),
				Maximum = animationSecondsToSliderValue(Config.maxAnimationSeconds),
				Value = animationSecondsToSliderValue(Config.defaultAnimationSeconds),
				MinimumSize = { 340, 24 },
			},
			ui:LineEdit{
				ID = "AnimationLengthInput",
				Text = string.format("%.4f", Config.defaultAnimationSeconds),
				MinimumSize = { 110, 24 },
			},
		},
	},

	ui:Button{
		ID = "CustomBezierPlaceholder",
		Text = "Custom Bezier - Coming Later",
		Enabled = false,
		MinimumSize = { 460, 26 },
	},

	ui:Label{ ID = "DebugLogLabel", Text = "Debug Log" },
	ui:TextEdit{
		ID = "DebugLog",
		ReadOnly = true,
		PlainText = "",
		MinimumSize = { 460, 90 },
	},

	ui:Label{
		ID = "TrackLockNote",
		Text = "Tip: lock the track underneath before placing text.",
		Alignment = { AlignHCenter = true, AlignVCenter = true },
		MinimumSize = { 460, 20 },
	},

	ui:Button{
		ID = "GenerateText",
		Text = "Place Text",
		MinimumSize = { 460, 38 },
	},
})

local items = win:GetItems()

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
logCurrentConfig(items)

function win.On.EnvysTextAnimatorWindow.Close(ev)
	dispatcher:ExitLoop()
end

function win.On.FollowerCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Selected follower: " .. optionLabel(followerOptions, config.follower.mode))
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
		appendLog(items, "INFO", "Text generated successfully")
		dispatcher:ExitLoop()
	else
		appendLog(items, "ERROR", "Failed to create TextPlus")
	end
end

win:Show()
dispatcher:RunLoop()
win:Hide()
