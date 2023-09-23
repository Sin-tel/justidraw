local Smudge = {}

Smudge.radius = 50
Smudge.name = [[
smudge
ctrl: add vibrato
]]

Smudge.preview = false

function Smudge.mousepressed()
	Smudge.table = {}
	Smudge.x = mouseX
	Smudge.y = mouseY
	if Selection.isEmpty() then
		Smudge.table = song.track[1]
	else
		Smudge.table = Selection.list
	end
end

function Smudge.mousedown()
	local radius = Smudge.radius
	local dx, dy = mouseX - mousePX, mouseY - mousePY
	for i, v in ipairs(Smudge.table) do
		local x, y = View.transform(v.x, v.y)
		local dist = math.sqrt((x - mouseX) ^ 2 + (y - mouseY) ^ 2)

		local weight = math.exp(-(dist / radius) ^ 2) * pres

		if weight > 0.01 then
			if modifierKeys.ctrl then
				v.y = v.y + math.sin(v.x / 35) * weight * 3
			else
				v.x = v.x + dx * weight * 2
				v.y = v.y + dy * weight * 2
			end
		end
	end
end

function Smudge.mousereleased()
	Edit.resampleAll()
end

return Smudge
