Selection = {}

function Selection.init()
	Selection.list = {}
	Selection.mask = {}
end

function Selection.set(mask)
	if selectNotes then
		local newmask = {}

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

	if modifierKeys.ctrl then
		for k in pairs(mask) do
			Selection.mask[k] = nil
		end
	else
		if modifierKeys.shift then
			for k in pairs(mask) do
				Selection.mask[k] = true
			end
		else
			Selection.mask = mask
		end
	end

	Selection.refresh()
end

function Selection.setNormal(mask)
	Selection.mask = mask
	Selection.refresh()
end

function Selection.refresh()
	Selection.list = {}
	for k in pairs(Selection.mask) do
		table.insert(Selection.list, k)
	end
end

function Selection.isEmpty()
	return #Selection.list == 0
end

function Selection.deselect()
	Selection.list = {}
	Selection.mask = {}
end

function Selection.getIndices()
	local list = {}
	for i, v in ipairs(song.track[1]) do
		if Selection.mask[v] then
			table.insert(list, i)
		end
	end
	return list
end

function Selection.setFromIndices(list)
	Selection.mask = {}
	for i, v in ipairs(list) do
		local vert = song.track[1][v]
		Selection.mask[vert] = true
	end
	Selection.refresh()
end
