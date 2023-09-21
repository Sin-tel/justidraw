local Stretch = {}

Stretch.radius = 100
Stretch.name = "transpose / stretch"

function Stretch.mousepressed()
	Stretch.table = {}
	Stretch.x = mouseX
	Stretch.y = mouseY

	local selected = {}
	if Selection.isEmpty() then
		selected = song.track[1]
	else
		selected = Selection.list
	end

	for i, v in ipairs(selected) do
		local n = {}
		n.x = v.x
		n.y = v.y
		n.vert = v

		local x, _ = View.transform(v.x, v.y)
		local distx = math.abs(mouseX - x)

		if x > mouseX then
			n.w = 1
		else
			n.w = math.exp(-(0.4 * distx / Stretch.radius) ^ 2)
		end

		table.insert(Stretch.table, n)
	end
end

function Stretch.mousedown()
	for i, v in ipairs(Stretch.table) do
		local x, y = View.transform(v.x, v.y)

		local stretchx = mouseX - Stretch.x
		local stretchy = mouseY - Stretch.y

		-- print(stretchx)
		stretchx = math.max(stretchx, -Stretch.radius * 2.8)
		if modifierKeys.shift then
			stretchy = 0
		end
		if modifierKeys.ctrl then
			stretchx = 0
		end

		local newx = x + stretchx * v.w
		local newy = y + stretchy * v.w
		v.vert.x, v.vert.y = View.invTransform(newx, newy)
	end
end

function Stretch.mousereleased()
	Edit.resampleAll()
end

return Stretch
