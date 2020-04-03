local binser = require "lib/binser"

File = {}

function File.save()
	local name = tostring(os.date("save %a %b %d %H.%M.%S.sav"))
	print(name)
	love.filesystem.write(name , binser.serialize(song))
	love.filesystem.write('last.txt' , name)
end

function File.loadLast()
	if love.filesystem.getInfo( 'last.txt' ) then
		local name = love.filesystem.read( 'last.txt' )
		if love.filesystem.getInfo( name ) then
			song = binser.deserialize(love.filesystem.read(name))[1]
			print("loaded last save")
			return
		end
	else
		love.filesystem.write('last.txt', "a")
	end
	print("no last save found")
end

function File.new()
	song = {}
	song.track = {}
	song.track[1] = {}
end

function File.load(f)
	f:open("r")
	local data = f:read()
	song = binser.deserialize(data)[1]
	Undo.register()
end