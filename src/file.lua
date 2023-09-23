local binser = require("lib/binser")

File = {}

function File.getName()
	return tostring(os.date("save %a %b %d %H.%M.%S"))
end

function File.save()
	song.version_major = VERSION_MAJOR
	song.version_minor = VERSION_MINOR
	local name = File.getName() .. ".sav"

	love.filesystem.write(name, binser.serialize(song))
	love.filesystem.write("last.txt", name)
	setMessage("saved: " .. name)
end

function File.loadLast()
	if love.filesystem.getInfo("last.txt") then
		local name = love.filesystem.read("last.txt")
		if love.filesystem.getInfo(name) then
			File.read(love.filesystem.read(name))
			setMessage("loaded last save: " .. name)
			return
		end
	else
		love.filesystem.write("last.txt", "a")
	end
	setMessage("no last save found")
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
	return new
end

function File.new()
	song = File.newSong()
end

function File.load(f)
	f:open("r")
	local data = f:read()
	File.read(data)
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
end
