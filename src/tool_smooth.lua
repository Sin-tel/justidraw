Smooth = {}

Smooth.radius = 50
Smooth.name = "smooth"

function Smooth.mousepressed()
	Smooth.table = {}
	Smooth.x = mouseX
	Smooth.y = mouseY
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

	if vert then
		while vert.l do
			vert = vert.l
		end

		Smooth.table = {}
		while vert do
			table.insert(Smooth.table,vert)

			vert = vert.r
		end
	end
end

function Smooth.mousedown()
	local radius = Smooth.radius
	local updates = {}
	for i,v in ipairs(Smooth.table) do
		updates[i] = {}
		local x,y = View.transform(v.x,v.y)
		
		local dist = math.sqrt(0.69*(x-mouseX)^2 + (y-mouseY)^2)

		local weight = math.exp(-(dist/radius)^2)*pres

		if v.l and v.r then
			updates[i].dx = (0.5*(v.l.x+v.r.x) - v.x)*weight
			updates[i].dy = (0.5*(v.l.y+v.r.y) - v.y)*weight
			updates[i].dw = (0.5*(v.l.w+v.r.w) - v.w)*weight
		else
			updates[i].dx = 0
			updates[i].dw = 0
			if v.r then
				updates[i].dy = (v.r.y - v.y)*weight
			elseif v.l then
				updates[i].dy = (v.l.y - v.y)*weight
			end
		end

	end
	for i,v in ipairs(Smooth.table) do
		v.x = v.x + updates[i].dx
		v.y = v.y + updates[i].dy
		v.w = v.w + updates[i].dw
	end
end

function Smooth.mousereleased()
	
end



