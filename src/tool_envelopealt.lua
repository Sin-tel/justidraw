EnvelopeAlt = {}

EnvelopeAlt.name = "envelope draw"

EnvelopeAlt.preview = false

function EnvelopeAlt.mousepressed()
	EnvelopeAlt.table = {}
	EnvelopeAlt.x = mouseX
	EnvelopeAlt.y = mouseY
	EnvelopeAlt.w = 0.5
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

	if vert then
		--EnvelopeAlt.x = vert.x
		--EnvelopeAlt.y = vert.y
		--EnvelopeAlt.w = vert.w

		--if Selection.isEmpty() then
		EnvelopeAlt.table = Edit.getNote(vert)
		EnvelopeAlt.w = vert.w
		EnvelopeAlt.prevIndex = 0
		--else
		--	EnvelopeAlt.table = Selection.list
		--end
	end
end

function EnvelopeAlt.mousedown()
	local radius = EnvelopeAlt.radius

	local d = math.huge
	local index = 0

	for i, v in ipairs(EnvelopeAlt.table) do
		local x, y = View.transform(v.x, v.y)
		local dist = math.abs(mouseX - x)

		--v.w = 0

		if dist < d then
			index = i
			d = dist
		end
	end

	local vert = EnvelopeAlt.table[index]

	if vert then
		if EnvelopeAlt.prevIndex == 0 then
			EnvelopeAlt.prevIndex = index
		end
		local i1 = EnvelopeAlt.prevIndex
		local i2 = index

		if i1 > i2 then
			i1, i2 = i2, i1
		end

		local w = EnvelopeAlt.w - 1.5 * (mouseY - EnvelopeAlt.y) / height

		w = math.min(math.max(w, 0), 1)

		for i = i1, i2 do
			EnvelopeAlt.table[i].w = w
		end

		EnvelopeAlt.prevIndex = index
	end
end

function EnvelopeAlt.mousereleased() end
