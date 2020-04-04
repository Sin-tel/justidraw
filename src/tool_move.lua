Move = {}

Move.name = "move notes"

Move.preview = true

function Move.mousepressed()
	Move.table = {}
	Move.x = mouseX
	Move.y = mouseY

	local tbl = {}
	local list = {}
	if Selection.isEmpty() then
		tbl = song.track[1]
		local d = math.huge
		local index = 0
		for i,v in ipairs(tbl) do
			local x,y = View.transform(v.x,v.y)
			local dist = math.sqrt((mouseX - x)^2 + (mouseY - y)^2)

			if (dist < d) then
				
				index = i
				d = dist
			end
		end

		local vert = song.track[1][index]

		list = Edit.getNote(vert)
	else
		list = Selection.list
	end

	for i,v in ipairs(list) do
		local n = {}
		n.x = v.x
		n.y = v.y
		n.vert = v
		table.insert(Move.table,n)
	end
end

function Move.mousedown()
	for i,v in ipairs(Move.table) do
		local x,y = View.transform(v.x,v.y)
		local newx = x + mouseX - Move.x
		local newy = y + mouseY - Move.y
		if modifierKeys.shift then
			if math.abs(mouseX - Move.x) < math.abs(mouseY - Move.y) then
				v.vert.x, v.vert.y = View.invTransform(x,newy)
			else
				v.vert.x, v.vert.y = View.invTransform(newx,y)
			end
		else
			v.vert.x, v.vert.y = View.invTransform(newx,newy)
		end
	end
end

function Move.mousereleased()
	
end



