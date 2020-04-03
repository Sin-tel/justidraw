Envelope = {}

Envelope.radius = 30
Envelope.name = "Envelope"

Envelope.preview = true

function Envelope.mousepressed()
	Envelope.table = {}
	Envelope.x = mouseX
	Envelope.y = mouseY
	if Selection.isEmpty() then
		local d = math.huge
		local index = 0
		for i,v in ipairs(song.track[1]) do
			local x,y = View.transform(v.x,v.y)
			local dist = math.sqrt((mouseX - x)^2 + (mouseY - y)^2)

			if (dist < d) then
				index = i
				d = dist
			end
		end
		
		local vert = song.track[1][index]

		Envelope.table = Edit.getNote(vert)
	else
		Envelope.table = Selection.list
	end
end

function Envelope.mousedown()
	local radius = Envelope.radius
	for i,v in ipairs(Envelope.table) do

		local x,y = View.transform(v.x,v.y)
		local dist = math.sqrt(0.7*(x-mouseX)^2 + (y-mouseY)^2)

		local weight = math.exp(-(dist/radius)^2)*pres*0.1

		if modifierKeys.ctrl then
			v.w = v.w*(1-weight)
		else
			v.w = v.w*(1-weight) + 1*weight
		end

	end
	
end

function Envelope.mousereleased()
	
end



