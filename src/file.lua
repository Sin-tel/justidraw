local binser = require("lib/binser")
local nouns = require("res/nouns")
local adjectives = require("res/adjectives")

File = {}

function File.save()
	song.version_major = VERSION_MAJOR
	song.version_minor = VERSION_MINOR
	local filename = song.name .. ".sav"

	love.filesystem.write(filename, binser.serialize(song))
	love.filesystem.write("last_save", filename)
	setMessage("saved: " .. filename)
end

function File.loadLast()
	if love.filesystem.getInfo("last_save") then
		local name = love.filesystem.read("last_save")
		if love.filesystem.getInfo(name) then
			File.read(love.filesystem.read(name))
			setMessage("loaded last save: " .. name)
			return
		end
	else
		love.filesystem.write("last_save", "a")
	end
	setMessage("no last save found")
end

function File.randomName()
	return adjectives[math.random(#adjectives)] .. " " .. nouns[math.random(#nouns)]
end

function File.newSong()
	local new = {}
	-- versioned save files
	new.version_major = VERSION_MAJOR
	new.version_minor = VERSION_MINOR
	new.bpm = 120
	new.bpmOffset = 0
	new.track = {}
	new.track[1] = {}
	new.gain = 0.125
	new.name = File.randomName()
	return new
end

function File.new()
	song = File.newSong()
	File.setTitle()
end

function File.load(f)
	local filename = f:getFilename()
	local name = filename:match("[^/\\]*.sav$")
	name = name:sub(0, #name - 4)

	f:open("r")
	local data = f:read()
	File.read(data)

	song.name = name
	File.setTitle()
end

function File.setName(name)
	song.name = name
	File.setTitle()
end

function File.setTitle()
	love.window.setTitle("justidraw (" .. song.name .. ")")
end

function File.read(f)
	local file = binser.deserialize(f)[1]

	-- backwards compatibility housekeeping
	if not file.version_major then
		file.version_major = 0
	end
	if not file.version_minor then
		file.version_minor = 2
	end

	if file.version_major ~= VERSION_MAJOR or file.version_minor ~= VERSION_MINOR then
		setMessage(
			"loaded song saved with a previous version! (" .. file.version_major .. "." .. file.version_minor .. ")"
		)
	end

	song = File.newSong()
	for k, v in pairs(file) do
		song[k] = v
	end

	-- remove any NaNs
	local to_remove = {}
	for _, track in ipairs(song.track) do
		for i, v in ipairs(track) do
			if v.x ~= v.x or v.y ~= v.y or v.w ~= v.w then
				print(i, "NaN")
				to_remove[v] = true
			end
		end
	end
	Edit.remove(to_remove)

	Undo.register()

	File.setTitle()
end
