SelectLasso = {}

SelectLasso.name = "select lasso"

SelectLasso.select = true

SelectLasso.points = {}

function SelectLasso.mousepressed()
	SelectLasso.points = {}
	local x, y = View.invTransform(mouseX, mouseY)
	table.insert(SelectLasso.points, { x, y })
end

function SelectLasso.mousedown()
	local n = #SelectLasso.points
	local xp, yp = View.transform(SelectLasso.points[n][1], SelectLasso.points[n][2])
	local dx = mouseX - xp
	local dy = mouseY - yp
	if math.sqrt(dx ^ 2 + dy ^ 2) > 5 then
		local x, y = View.invTransform(mouseX, mouseY)
		table.insert(SelectLasso.points, { x, y })
	end
end

function SelectLasso.boundingBox()
	local xmin, ymin = math.huge, math.huge
	local xmax, ymax = -math.huge, -math.huge

	for i, v in ipairs(SelectLasso.points) do
		xmin = math.min(xmin, v[1])
		ymin = math.min(ymin, v[2])
		xmax = math.max(xmax, v[1])
		ymax = math.max(ymax, v[2])
	end

	return xmin, ymin, xmax, ymax
end

function SelectLasso.mousereleased()
	-- first restrict to bounding box
	local tbl = {}
	local x1, y1, x2, y2 = SelectLasso.boundingBox()
	for i, v in ipairs(song.track[1]) do
		if x1 < v.x and v.x < x2 and y1 < v.y and v.y < y2 then
			table.insert(tbl, v)
		end
	end

	-- raycast upwards
	local mask = {}
	local n = #SelectLasso.points
	for i, v in ipairs(tbl) do
		local count = 0
		for i = 1, n do
			local x1 = SelectLasso.points[i][1]
			local y1 = SelectLasso.points[i][2]
			local x2 = SelectLasso.points[i % n + 1][1]
			local y2 = SelectLasso.points[i % n + 1][2]

			local xv1 = v.x - x1
			local yv1 = v.y - y1
			local xv2 = x2 - x1
			local yv2 = y2 - y1

			if xv2 ~= 0 then
				local t1 = (xv2 * yv1 - xv1 * yv2) / xv2
				local t2 = xv1 / xv2
				if t1 > 0 and t2 > 0 and t2 <= 1.0 then
					count = count + 1
				end
			end
		end
		-- check parity of number of crossings
		if count % 2 == 1 then
			mask[v] = true
		end
	end

	if selectNotes then
		notes = {}
		newmask = {}

		for v in pairs(mask) do
			while v.l do
				v = v.l
			end
			if not newmask[v] then
				newmask[v] = true
				while v do
					newmask[v] = true
					v = v.r
				end
			end
		end
		mask = newmask
	end

	Selection.set(mask)
end

function SelectLasso.draw()
	local n = #SelectLasso.points
	if mouseDown[1] and n >= 2 then
		love.graphics.setColor(0.0, 0.8, 0.8)

		for i = 1, n - 1 do
			local x1, y1 = View.transform(SelectLasso.points[i][1], SelectLasso.points[i][2])
			local x2, y2 = View.transform(SelectLasso.points[i + 1][1], SelectLasso.points[i + 1][2])

			love.graphics.line(x1, y1, x2, y2)
		end
	end
end
