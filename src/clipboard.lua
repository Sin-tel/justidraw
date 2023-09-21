Clipboard = {}

Clipboard.drag = false

function Clipboard.duplicate()
	if not Selection.isEmpty() then
		local list = Selection.list
		local new = deepcopy(list)

		local newMask = {}
		for i, v in ipairs(new) do
			newMask[v] = true
		end
		Clipboard.table = {}
		for i, v in ipairs(new) do
			if not newMask[v.r] then
				v.r = nil
			end
			if not newMask[v.l] then
				v.l = nil
			end

			local n = {}
			n.x = v.x
			n.y = v.y
			n.vert = v
			table.insert(Clipboard.table, n)
		end

		Selection.setNormal(newMask)

		Edit.add(new)
		Clipboard.drag = true
		Clipboard.ix = mouseX
		Clipboard.iy = mouseY
	end
end

function Clipboard.dragUpdate()
	for i, v in ipairs(Clipboard.table) do
		local x, y = View.transform(v.x, v.y)
		local newx = x + mouseX - Clipboard.ix
		local newy = y + mouseY - Clipboard.iy
		if modifierKeys.shift then
			if math.abs(mouseX - Clipboard.ix) < math.abs(mouseY - Clipboard.iy) then
				v.vert.x, v.vert.y = View.invTransform(x, newy)
			else
				v.vert.x, v.vert.y = View.invTransform(newx, y)
			end
		else
			v.vert.x, v.vert.y = View.invTransform(newx, newy)
		end
	end
end
