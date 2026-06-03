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
