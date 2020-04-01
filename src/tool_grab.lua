Grab = {}

Grab.radius = 25
Grab.name = "grab"

function Grab.mousepressed()
	Grab.table = {}
	Grab.x = mouseX
	Grab.y = mouseY
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
	local initVert = vert
	local ix,iy = View.transform(vert.x,vert.y)

	local initIndex = 0

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
			local distx = math.abs(mouseX - x)
			local disty = math.sqrt((ix - x)^2 + (iy - y)^2)
			n.wx  = math.exp(-(0.4*distx/Grab.radius)^2)
			n.wy  = math.exp(-(0.7*disty/Grab.radius)^2)

	
			if vert == initVert then
				initIndex = #Grab.table+1
			end

			table.insert(Grab.table,n)

			vert = vert.r
		end
	end
end

function Grab.mousedown()
	for i,v in ipairs(Grab.table) do
		local x,y = View.transform(v.x,v.y)

		local newx = x + (mouseX - Grab.x)*v.wx
		local newy = y + (mouseY - Grab.y)*v.wy
		v.vert.x, v.vert.y = View.invTransform(newx,newy)

		local left = Grab.table[i-1]
		local right = Grab.table[i+1]
		if left then
			if left.wx >= v.wx and left.vert.x >= v.vert.x then
				v.vert.x = left.vert.x + (v.x - left.x)*0.5

			end
		end
	end
	for i = #Grab.table,1,-1 do
		local v = Grab.table[i]
		local left = Grab.table[i-1]
		local right = Grab.table[i+1]
		if right then
			if right.wx >= v.wx and right.vert.x <= v.vert.x then
				v.vert.x = right.vert.x + (v.x - right.x)*0.5

			end
		end
	end
end

function Grab.mousereleased()
	
end



