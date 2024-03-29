local Draw = {}

Draw.points = {}
Draw.lastpoint = {}
Draw.name = [[
freehand draw
ctrl: erase
shift: smooth
]]

Draw.preview = true
Draw.drawTool = true

Draw.radius = 5

Draw.x = 0
Draw.y = 0

function Draw.mousepressed()
	Draw.points = {}

	Draw.x = mouseX
	Draw.y = mouseY

	local pt = { Draw.x, Draw.y, pres }
	table.insert(Draw.points, pt)
	Draw.lastpoint = pt
end

function Draw.mousedown()
	local dx = mouseX - Draw.x
	local dy = mouseY - Draw.y

	local l = math.sqrt(dx ^ 2 + dy ^ 2)
	if l > Draw.radius then
		Draw.x = mouseX - (Draw.radius * dx / l)
		Draw.y = mouseY - (Draw.radius * dy / l)
	end

	if not (Draw.lastpoint[1] == Draw.x and Draw.lastpoint[2] == Draw.y) then
		Draw.removePoints()
		local pt = { Draw.x, Draw.y, pres }
		table.insert(Draw.points, pt)
		table.sort(Draw.points, function(a, b)
			return a[1] < b[1]
		end)
		Draw.lastpoint = pt
	end
end

function Draw.removePoints()
	local rev = false
	local x1 = Draw.lastpoint[1]
	local x2 = mouseX
	if x1 > x2 then
		x1, x2 = x2, x1
		rev = true
	end

	local newTable = {}
	for k, v in ipairs(Draw.points) do
		if not (v[1] > x1 and v[1] < x2 or (rev and v[1] == x1) or (not rev and v[1] == x2)) then
			table.insert(newTable, { v[1], v[2], v[3] })
		end
	end
	Draw.points = newTable
end

function Draw.mousereleased()
	for i, v in ipairs(Draw.points) do
		v[1], v[2] = View.invTransform(v[1], v[2])
	end
	if #Draw.points > 2 then
		Draw.keep = {}
		for i in ipairs(Draw.points) do
			Draw.keep[i] = false
		end
		Draw.keep[1] = true
		Draw.keep[#Draw.points] = true

		Draw.simplify(1, #Draw.points, true)

		local newTable = {}
		for i, v in ipairs(Draw.points) do
			if Draw.keep[i] then
				table.insert(newTable, v)
			end
		end
		Draw.points = newTable

		table.sort(Draw.points, function(a, b)
			return a[1] < b[1]
		end)

		Edit.addNote(Draw.points)
	end
	Draw.points = {}

	Edit.resampleAll()
end

function Draw.simplify(i1, i2, alwaysKeep)
	local first = Draw.points[i1]
	local last = Draw.points[i2]

	Draw.keep[i1] = true
	Draw.keep[i2] = true

	local vx = last[1] - first[1]
	local vy = last[2] - first[2]

	local x1 = first[1]
	local y1 = first[2]
	local m = vy / vx

	local dmax = -1
	local index = 0
	for i = i1 + 1, i2 - 1 do
		local x = Draw.points[i][1]
		local dy = math.abs(Draw.points[i][2] - (y1 + m * (x - x1))) / math.sqrt(1 + m * m)

		local t = (x - x1) / vx
		dy = dy + math.abs(Draw.points[i][3] - (last[3] * t + first[3] * (1 - t))) * 20
		if dy > dmax then
			dmax = dy
			index = i
		end
	end

	if dmax > 2 or (alwaysKeep and index > 0) then
		Draw.simplify(i1, index)
		Draw.simplify(index, i2)
	end
end

function Draw.draw()
	-- love.graphics.setColor(Theme.current.cursor)

	-- if not mouseDown[1] then
	-- 	Draw.x = mouseX
	-- 	Draw.y = mouseY
	-- end

	-- love.graphics.ellipse("line", Draw.x, Draw.y, 5)

	love.graphics.setColor(Theme.current.draw)
	for i = 1, #Draw.points - 1 do
		local v1 = Draw.points[i]
		local v2 = Draw.points[i + 1]

		love.graphics.polygon(
			"fill",
			v1[1],
			(v1[2] + v1[3] * 10 + 1),
			v2[1],
			(v2[2] + v2[3] * 10 + 1),
			v2[1],
			(v2[2] - v2[3] * 10 - 1),
			v1[1],
			(v1[2] - v1[3] * 10 - 1)
		)
	end
end

return Draw
