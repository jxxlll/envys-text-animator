local Followers = {}

Followers.labels = {
	char = "Character",
	word = "Word",
	line = "Line",
}

Followers.byKey = {
	char = { label = "Character", offset = "CharacterOffset", angle = "CharacterAngleZ", sizeX = "CharacterSizeX", sizeY = "CharacterSizeY", order = 7, delay = 0.6 },
	word = { label = "Word", offset = "CharacterOffset", angle = "CharacterAngleZ", sizeX = "CharacterSizeX", sizeY = "CharacterSizeY", order = 6, delay = 0, wordDelay = 6, wordByWord = true },
	line = { label = "Line", offset = "LineOffset", angle = "LineAngleZ", sizeX = "LineSizeX", sizeY = "LineSizeY", order = 7, delay = 0 },
}

function Followers.get(key)
	return Followers.byKey[key] or Followers.byKey.char
end

function Followers.label(key)
	return Followers.labels[key] or Followers.labels.char
end

return Followers
