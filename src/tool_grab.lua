local Grab = {}

Grab.radius = 50
Grab.name = [[
grab
ctrl: move
]]

function Grab.mousepressed()
	Grab.table = {}
	Grab.x = mouseX
	Grab.y = mouseY

	local tbl
	local list
	if Selection.isEmpty() then
		tbl = song.track[1]

		local d = math.huge
		local index = 0
		for i, v in ipairs(tbl) do
			local x, y = View.transform(v.x, v.y)
			local dist = math.sqrt((mouseX - x) ^ 2 + (mouseY - y) ^ 2)

			if dist < d then
				index = i
				d = dist
			end
		end

		local vert = tbl[index]
		list = Edit.getNote(vert)
	else
		list = Selection.list
	end

	Grab.table = {}
	for i, v in ipairs(list) do
		local n = {}
		n.x = v.x
		n.y = v.y
		n.vert = v

		local x, y = View.transform(v.x, v.y)
		local dist = math.sqrt((mouseX - x) ^ 2 + ((mouseY - y) * 0.7) ^ 2)

		n.w = math.exp(-(0.4 * dist / Grab.radius) ^ 2)

		table.insert(Grab.table, n)
	end
end

function Grab.mousedown()
	for i, v in ipairs(Grab.table) do
		local x, y = View.transform(v.x, v.y)

		local newx = x + (mouseX - Grab.x) * v.w
		local newy = y + (mouseY - Grab.y) * v.w
		v.vert.x, v.vert.y = View.invTransform(newx, newy)

		-- local left = Grab.table[i - 1]
		-- if left then
		-- 	if left.wx >= v.wx and left.vert.x >= v.vert.x then
		-- 		v.vert.x = left.vert.x + (v.x - left.x) * 0.5
		-- 	end
		-- end
	end
	-- for i = #Grab.table, 1, -1 do
	-- 	local v = Grab.table[i]
	-- 	local right = Grab.table[i + 1]
	-- 	if right then
	-- 		if right.wx >= v.wx and right.vert.x <= v.vert.x then
	-- 			v.vert.x = right.vert.x + (v.x - right.x) * 0.5
	-- 		end
	-- 	end
	-- end
end

function Grab.mousereleased()
	Edit.resampleAll()
end

return Grab
