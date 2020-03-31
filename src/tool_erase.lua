Erase = {}

Erase.radius = 15
Erase.tempRadius = 15
Erase.name = "erase"

function Erase.mousepressed()
	
end

function Erase.mousedown()
	Erase.tempRadius =  Erase.radius*(0.4+1.2*pres)

	remove = {}
	for i,v in ipairs(song.track[1]) do
		local x,y = View.transform(v.x,v.y)
		local dist = math.sqrt(0.69*(x-mouseX)^2 + (y-mouseY)^2)

		if(dist < Erase.tempRadius) then
			remove[i] = true
		end
	end
	Edit.removeNotes(remove)
end

function Erase.mousereleased()
	Erase.tempRadius = nil
end



