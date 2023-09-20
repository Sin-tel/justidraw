--[[
interface to track structure
adding notes, cleanup etc
]]

Edit = {}

function Edit.addNote(list)
	pts = {}

	for i, v in ipairs(list) do
		pt = {}
		pt.x = v[1]
		pt.y = v[2]
		pt.w = v[3]

		pts[i] = pt
	end

	local first = pts[1]
	local last = pts[#pts]

	for i, v in ipairs(pts) do
		if pts[i - 1] then
			pts[i].l = pts[i - 1]
		end
		if pts[i + 1] then
			pts[i].r = pts[i + 1]
		else
			--set final to 0
			pts[i].w = 0
		end
		table.insert(song.track[1], pts[i])
	end

	for i, v in ipairs(song.track[1]) do
		if not v.l then
			local dist = math.sqrt((last.x - v.x) ^ 2 + (last.y - v.y) ^ 2)
			if dist < automergeDist and v ~= first then
				Edit.merge(last, v, true)
				break
			end
		end
	end

	for i, v in ipairs(song.track[1]) do
		if not v.r then
			local dist = math.sqrt((first.x - v.x) ^ 2 + (first.y - v.y) ^ 2)
			if dist < automergeDist and v ~= last then
				Edit.merge(v, first)
				break
			end
		end
	end
end

function Edit.getNote(vert)
	local tbl = {}
	if vert then
		while vert.l do
			vert = vert.l
		end

		while vert do
			table.insert(tbl, vert)

			vert = vert.r
		end
	end

	return tbl
end

function Edit.add(list)
	for i, v in ipairs(list) do
		table.insert(song.track[1], v)
	end
end

function Edit.join()
	if #Selection.list == 0 then
		setMessage("selection is empty")
		return
	end
	local vset = {}
	local vlist = {}
	for v in pairs(Selection.mask) do
		while v.l do
			v = v.l
		end
		if not vset[v] then
			vset[v] = true
			table.insert(vlist, v)
		end
	end

	if #vlist == 1 then
		setMessage("only one note selected")
		return
	end

	table.sort(vlist, function(a, b)
		return a.x < b.x
	end)

	for i = 1, #vlist - 1 do
		v1 = vlist[i]
		v2 = vlist[i + 1]

		while v1.r do
			v1 = v1.r
		end

		Edit.merge(v1, v2)
	end

	Selection.deselect()
end

function Edit.merge(v1, v2)
	assert(not v1.r)
	assert(not v2.l)

	local newx = (v1.x + v2.x) * 0.5

	if v1.l.x < newx and newx < v2.r.x then
		v1.x = newx
		v1.y = (v1.y + v2.y) * 0.5
		v1.w = math.max(v1.w, v2.w)

		v1.r = v2.r
		v2.r.l = v1

		for i, v in ipairs(song.track[1]) do
			if v == v2 then
				table.remove(song.track[1], i)
				Selection.mask[v] = nil
				break
			end
		end
	end
	Selection.refresh()
end

function Edit.collapse(index)
	local v = song.track[1][index]

	if v.l and v.r then
		v.l.r = v.r
		v.r.l = v.l
	end

	table.remove(song.track[1], index)
	Selection.mask[v] = nil
	Selection.refresh()
end

function Edit.remove(verts)
	for i = #song.track[1], 1, -1 do
		local v = song.track[1][i]
		if verts[v] then
			if v.l then
				v.l.w = 0
				v.l.r = nil
			end
			if v.r then
				v.r.l = nil
			end
			table.remove(song.track[1], i)
			Selection.mask[v] = nil
		end
	end
	Edit.removeSingles()
end

function Edit.removeSingles()
	for i = #song.track[1], 1, -1 do
		local v = song.track[1][i]
		if not (v.l or v.r) then
			table.remove(song.track[1], i)
			Selection.mask[v] = nil
		end
	end
	Selection.refresh()
end

function Edit.getTangent(pt)
	if not pt.l then
		return (pt.y - pt.r.y) / (pt.x - pt.r.x)
	elseif not pt.r then
		return (pt.l.y - pt.y) / (pt.l.x - pt.x)
	else
		return (pt.l.y - pt.r.y) / (pt.l.x - pt.r.x)
	end
end

function Edit.resampleAll()
	list = {}
	for i, v in ipairs(song.track[1]) do
		if not v.l then
			table.insert(list, v)
		end
	end

	while true do
		local count = 0
		for i, v in ipairs(list) do
			while v.r do
				local nextv = v.r

				local dx = v.x - v.r.x
				local dy = v.y - v.r.y

				if math.sqrt(dx ^ 2 + dy ^ 2) > 150 then
					local nx = (v.x + v.r.x) * 0.5
					local ny = (v.y + v.r.y) * 0.5
					local nw = (v.w + v.r.w) * 0.5

					local new = { x = nx, y = ny, w = nw }

					v.r = new
					nextv.l = new
					new.l = v
					new.r = nextv

					table.insert(song.track[1], new)
					count = count + 1
				end

				v = nextv
			end
		end
		if count == 0 then
			break
		end
	end
end
