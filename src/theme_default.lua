-- don't remove this line!
local theme = {}

-- default dark theme
theme.dark = {
	-- triplets of colors {red, green, blue} in range 0.0 - 1.0
	background = { 0.0, 0.0, 0.0 },
	text = { 0.9, 0.9, 0.9 },
	envelope = { 0.8, 0.8, 0.8 },
	highlight = { 0.1, 0.8, 1.0 },
	playhead = { 0.7, 0.7, 0.7 },
	draw = { 0.8, 0.2, 0.2 },
	cursor = { 0.6, 0.6, 0.6 },

	-- disabled by default
	vertices = { 0.8, 0.8, 0.8 },
	showVertices = false,

	grid = { 0.9, 0.9, 0.9 },
	showGridTime = true,
	showGridPitch = true,

	-- width of the notes
	lineWidth = 65,

	showTooltip = true,
	showMeter = true,
}

theme.light = {
	background = { 0.95, 0.95, 0.95 },
	cursor = { 0.4, 0.4, 0.4 },
	text = { 0.1, 0.1, 0.1 },
	envelope = { 0.0, 0.0, 0.0 },
	grid = { 0.0, 0.0, 0.0 },
	highlight = { 1.0, 0.2, 0.4 },
	playhead = { 0.3, 0.3, 0.3 },
	draw = { 0.6, 0.2, 0.2 },
}

theme.pink = {
	-- you can also use hex codes for the colors, using this format:
	background = "#ffdde1",
	text = "#642ca9",
	envelope = "#ff36ab",
	grid = "#ff74d4",
	highlight = "#642ca9",
	playhead = "#642ca9",
	cursor = "#642ca9",
}

theme.minimal = {
	envelope = { 1.0, 1.0, 1.0 },

	lineWidth = 80,

	showGridTime = false,
	showGridPitch = false,
	showTooltip = false,
	showMeter = false,
}

-- don't remove this line!
return theme
