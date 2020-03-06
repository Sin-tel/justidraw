Erase = {}

Erase.radius = 15
Erase.name = "erase"

function Erase.mousepressed()
	
end

function Erase.mousedown()
	Erase.radius = 5+20*pres
	remove = {}
	for i,v in ipairs(song.track[1]) do
		local x,y = View.transform(v.x,v.y)
		local dist = math.sqrt(0.69*(x-mouseX)^2 + (y-mouseY)^2)

		--[[local nn = math.exp(-(dist/Erase.radius)^2)

		v.w = v.w * (1-nn*pres)
		if(dist < Erase.radius and v.w < 0.01) then
			remove[i] = true
		end]]

		if(dist < Erase.radius) then
			remove[i] = true
		end
	end
	Edit.removeNotes(remove)
end

function Erase.mousereleased()
	Erase.radius = 15
end



