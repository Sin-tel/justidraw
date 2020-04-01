Selection = {}

function Selection.init()
	Selection.list = {}
	Selection.mask = {}
end

function Selection.set(mask)
	if modifierKeys.ctrl then
		for i,v in pairs(mask) do
			Selection.mask[i] = nil
		end
	else
		if modifierKeys.shift then
			for i,v in pairs(mask) do
				Selection.mask[i] = true
			end
		else
			Selection.mask = mask
		end
	end

	Selection.refresh()
end

function Selection.refresh()
	Selection.list = {}
	for i,v in pairs(Selection.mask) do
		table.insert(Selection.list,i)
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
	for i,v in ipairs(song.track[1]) do
		if Selection.mask[v] then
			table.insert(list,i)
		end
	end
	return list
end

function Selection.setFromIndices(list)
	Selection.mask = {}
	for i,v in ipairs(list) do
		local vert = song.track[1][v]
		Selection.mask[vert] = true
	end
	Selection.refresh()
end