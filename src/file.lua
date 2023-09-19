local binser = require("lib/binser")

File = {}

function File.save()
	local name = tostring(os.date("save %a %b %d %H.%M.%S.sav"))
	print(name)
	love.filesystem.write(name, binser.serialize(song))
	love.filesystem.write("last.txt", name)
end

function File.loadLast()
	if love.filesystem.getInfo("last.txt") then
		local name = love.filesystem.read("last.txt")
		if love.filesystem.getInfo(name) then
			File.read(love.filesystem.read(name))
			print("loaded last save")
			return
		end
	else
		love.filesystem.write("last.txt", "a")
	end
	print("no last save found")
end

function File.new()
	song = {}
	song.version = "0.2" -- for versioned save files
	song.track = {}
	song.track[1] = {}
end

function File.load(f)
	f:open("r")
	local data = f:read()
	File.read(data)
end

function File.read(f)
	song = binser.deserialize(f)[1]

	to_remove = {}
	for _, track in ipairs(song.track) do
		for i, v in ipairs(track) do
			-- check nans
			if v.x ~= v.x then
				print(i, "x nan")
				to_remove[v] = true
			end
			if v.y ~= v.y then
				print(i, "y nan")
				to_remove[v] = true
			end
		end
	end
	Edit.remove(to_remove)

	Undo.register()
end
