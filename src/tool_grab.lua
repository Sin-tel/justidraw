Grab = {}

Grab.radius = 50
Grab.name = "grab and nudge"

function Grab.mousepressed()
	Grab.table = {}
	Grab.x = mouseX
	Grab.y = mouseY
	local d = 10000
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

		Grab.table = {}
		while vert do
			
			local n = {}
			n.x = vert.x
			n.y = vert.y
			n.vert = vert

			local x,y = View.transform(vert.x,vert.y)
			local dist = math.abs(mouseX - x)--math.sqrt((mouseX - x)^2 + (mouseY - y)^2)
			n.w  = math.exp(-(0.7*dist/Grab.radius)^2)

			table.insert(Grab.table,n)

			vert = vert.r
		end
	end
end

function Grab.mousedown()
	for i,v in ipairs(Grab.table) do
		local x,y = View.transform(v.x,v.y)
		local newx = x + (mouseX - Grab.x)*v.w
		local newy = y + (mouseY - Grab.y)*v.w
		v.vert.x, v.vert.y = View.invTransform(newx,newy)
	end
end

function Grab.mousereleased()
	
end



