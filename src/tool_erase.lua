Erase = {}

Erase.radius = 15
Erase.name = "erase"

function Erase.mousepressed()
	
end

function Erase.mousedown()
	local radius =  Erase.radius*(0.3+1.3*pres)


	remove = {}
	for i,v in ipairs(song.track[1]) do
		local x,y = View.transform(v.x,v.y)
		local dist = math.sqrt(0.69*(x-mouseX)^2 + (y-mouseY)^2)

		--[[local nn = math.exp(-(dist/radius)^2)

		v.w = v.w * (1-nn*pres)
		if(dist < Erase.radius and v.w < 0.01) then
			remove[i] = true
		end]]

		if(dist < radius) then
			remove[i] = true
		end
	end
	Edit.removeNotes(remove)
end

function Erase.mousereleased()
	
end



