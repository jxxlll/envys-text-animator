local Config = require("EnvysTextAnimator.modules.config")
local Utils = require("EnvysTextAnimator.modules.utils")
local Followers = require("EnvysTextAnimator.modules.followers")
local AnimIn = require("EnvysTextAnimator.modules.animations_in")
local AnimOut = require("EnvysTextAnimator.modules.animations_out")

local Generator = {}

function Generator.buildComp(textValue, state, asTitle)
	state = state or {}
	local escapedText = Utils.escapeLuaString(textValue)
	local follower = Followers.get(state.followerMode)
	local animations = state.animations or {}
	local animationsOut = state.animationsOut or {}
	local easingIn = state.easingIn or "setting"
	local easingOut = state.easingOut or "setting"
	local animationSeconds = Config.clampAnimationSeconds(state.animationLengthSeconds)
	local globalOut = Config.globalOutFrame(state.timelineFps, state.durationSeconds, animationSeconds)
	local timing = Config.animationTiming(state.timelineFps, animationSeconds)
	local hasAnimationOut = AnimOut.hasAny(animationsOut)
	local usesWordMaskedBlur = follower.label == "Word" and (animations.blur or animations.fade or animationsOut.blur or animationsOut.fade)
	local wordMaskTextInputs = ""
	if usesWordMaskedBlur then
		wordMaskTextInputs = [[
						SelectElement = Input { Value = 4, },
						ElementShape5 = Input { Value = 2, },
						Level5 = Input { Value = 2, },
						ExtendHorizontal5 = Input { Value = -0.151, },
						Softness5 = Input { Value = 1, },
						EffectMask = Input {
							SourceOp = "BlurMaskText",
							Source = "Output",
						},]]
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
				Input10 = InstanceInput { SourceOp = "Follower1", Source = "Delay", Page = "Controls", Name = "Follower Delay", Default = ]] .. follower.delay .. [[ }
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
						CharacterSpacing = Input { Value = 0.95, },]] .. wordMaskTextInputs .. [[
						StyledText = Input {
							SourceOp = "Follower1",
							Source = "StyledText",
						},
						Font = Input { Value = "Poppins", },
						Style = Input { Value = "SemiBold", },
						Size = Input { Value = 0.09, },
						Center = Input { Value = { 0.5, 0.5 }, },
						VerticalJustificationNew = Input { Value = 3, },
						HorizontalJustificationNew = Input { Value = 3, }
					},
					ViewInfo = OperatorInfo { Pos = { 110, 115.5 } },
				},
				Follower1 = StyledTextFollower {
					CtrlWZoom = false,
					Inputs = {
						Order = Input { Value = 7, },
						Delay = Input { Value = ]] .. follower.delay .. [[, },
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
						SourceEnd = Input { Value = ]] .. timing.outEndFrame .. [[, },
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
