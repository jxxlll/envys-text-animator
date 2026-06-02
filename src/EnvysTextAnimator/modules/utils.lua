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

