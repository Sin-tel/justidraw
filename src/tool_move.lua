Move = {}

Move.name = "move notes"

function Move.mousepressed()
	Move.table = {}
	Move.x = mouseX
	Move.y = mouseY
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

		
		while vert do
			local n = {}
			n.x = vert.x
			n.y = vert.y
			n.vert = vert
			table.insert(Move.table,n)

			vert = vert.r
		end
	end
end

function Move.mousedown()
	for i,v in ipairs(Move.table) do
		local x,y = View.transform(v.x,v.y)
		local newx = x + mouseX - Move.x
		local newy = y + mouseY - Move.y
		v.vert.x, v.vert.y = View.invTransform(newx,newy)
	end
end

function Move.mousereleased()
	
end



