Flatten = {}

Flatten.radius = 30
Flatten.name = "flatten"

function Flatten.mousepressed()
	Flatten.table = {}
	Flatten.x = mouseX
	Flatten.y = mouseY

	if Selection.isEmpty() then
		local d = math.huge
		local index = 0
		for i, v in ipairs(song.track[1]) do
			local x, y = View.transform(v.x, v.y)
			local dist = math.sqrt((mouseX - x) ^ 2 + (mouseY - y) ^ 2)

			if dist < d then
				index = i
				d = dist
			end
		end

		local vert = song.track[1][index]

		Flatten.table = Edit.getNote(vert)
	else
		Flatten.table = Selection.list
	end
end

function Flatten.mousedown()
	local radius = Flatten.radius
	local sum = 0
	local avg = 0
	local weights = {}
	for i, v in ipairs(Flatten.table) do
		local x, y = View.transform(v.x, v.y)
		local dist = math.sqrt(0.69 * (x - mouseX) ^ 2 + (y - mouseY) ^ 2)
		local normal_w = math.exp(-(2 * dist / radius) ^ 2)
		local weight = math.exp(-(dist / radius) ^ 2)
		weights[i] = weight * pres

		avg = avg + v.y * normal_w
		sum = sum + normal_w
	end
	avg = avg / sum
	for i, v in ipairs(Flatten.table) do
		v.y = v.y * (1 - weights[i]) + avg * weights[i]
	end
end

function Flatten.mousereleased() end
