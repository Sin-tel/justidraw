local Erase = {}

Erase.radius = 20
Erase.name = "erase"

function Erase.mousepressed()
	Erase.list = {}
	if Selection.isEmpty() then
		Erase.list = song.track[1]
	else
		Erase.list = Selection.list
	end
end

function Erase.mousedown()
	Erase.tempRadius = Erase.radius * (0.4 + 1.2 * pres)

	local remove = {}

	for i, v in ipairs(Erase.list) do
		local x, y = View.transform(v.x, v.y)
		local dist = math.sqrt(0.69 * (x - mouseX) ^ 2 + (y - mouseY) ^ 2)

		if dist < Erase.tempRadius then
			remove[v] = true
		end
	end
	Edit.remove(remove)
end

function Erase.mousereleased()
	Erase.tempRadius = nil
end

return Erase
