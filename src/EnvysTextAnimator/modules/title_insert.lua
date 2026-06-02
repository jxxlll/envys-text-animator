local Config = require("EnvysTextAnimator.modules.config")
local Utils = require("EnvysTextAnimator.modules.utils")
local Generator = require("EnvysTextAnimator.modules.generator")

local TitleInsert = {}

function TitleInsert.getTimeline(resolve)
	local projectManager = resolve:GetProjectManager()
	local project = projectManager and projectManager:GetCurrentProject() or nil
	if not project then
		return nil, nil, "No Resolve project is currently open."
	end

	local timeline = project:GetCurrentTimeline()
	if not timeline then
		return nil, nil, "No current timeline is open."
	end

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

function TitleInsert.tryInsertGeneratedTitle(timeline, compText)
	Utils.ensureDir(Config.titleDir())

	if not Utils.writeAll(Config.titlePath(), compText) then
		print("Could not write generated title: " .. Config.titlePath())
		return nil
	end

	local item = timeline:InsertFusionTitleIntoTimeline(Config.titleName)
	if item then
		return item
	end

	item = timeline:InsertFusionTitleIntoTimeline(Config.titleName .. ".setting")
	if item then
		return item
	end

	print("Generated title was written, but Resolve did not insert it. It may need a script/effects reload.")
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

