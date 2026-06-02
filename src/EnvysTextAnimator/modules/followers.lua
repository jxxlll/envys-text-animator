local Followers = {}

Followers.labels = {
	char = "Character",
	word = "Word",
	line = "Line",
}

Followers.byKey = {
	char = { label = "Character", offset = "CharacterOffset", angle = "CharacterAngleZ", sizeX = "CharacterSizeX", sizeY = "CharacterSizeY", delay = 0.6 },
	word = { label = "Word", offset = "WordOffset", angle = "WordAngleZ", sizeX = "WordSizeX", sizeY = "WordSizeY", delay = 0.6 },
	line = { label = "Line", offset = "LineOffset", angle = "LineAngleZ", sizeX = "LineSizeX", sizeY = "LineSizeY", delay = 0 },
}

function Followers.get(key)
	return Followers.byKey[key] or Followers.byKey.char
end

function Followers.label(key)
	return Followers.labels[key] or Followers.labels.char
end

return Followers

