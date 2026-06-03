-- Envy's Text Animator UI - beta 0.0.3.
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
	config.textStyle.font = optionKey(fontOptions, items.FontCombo.CurrentIndex, Config.defaultFont)
	config.textStyle.style = optionKey(fontStyleOptions, items.FontStyleCombo.CurrentIndex, Config.defaultFontStyle)
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
appendLog(items, "INFO", "Loaded fonts: " .. tostring(#fontOptions))
logCurrentConfig(items)

function win.On.EnvysTextAnimatorWindow.Close(ev)
	dispatcher:ExitLoop()
end

function win.On.FollowerCombo.CurrentIndexChanged(ev)
	readConfigFromUI(items)
	appendLog(items, "INFO", "Selected follower: " .. optionLabel(followerOptions, config.follower.mode))
end

function win.On.FontCombo.CurrentIndexChanged(ev)
	local previousStyle = config.textStyle.style
	config.textStyle.font = optionKey(fontOptions, items.FontCombo.CurrentIndex, Config.defaultFont)
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
		appendLog(items, "INFO", "Text generated successfully")
		dispatcher:ExitLoop()
	else
		appendLog(items, "ERROR", "Failed to create TextPlus")
	end
end

win:Show()
dispatcher:RunLoop()
win:Hide()

