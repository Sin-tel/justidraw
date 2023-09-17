RectSelect = {}

RectSelect.name = "rectangular selection"

RectSelect.select = true

function RectSelect.mousepressed()
	RectSelect.ix = mouseX
	RectSelect.iy = mouseY
end

function RectSelect.mousedown() end

function RectSelect.mousereleased()
	local mask = {}

	local x1, y1 = View.invTransform(RectSelect.ix, RectSelect.iy)
	local x2, y2 = View.invTransform(mouseX, mouseY)
	if x1 > x2 then
		x1, x2 = x2, x1
	end
	if y1 > y2 then
		y1, y2 = y2, y1
	end

	for i, v in ipairs(song.track[1]) do
		if x1 < v.x and v.x < x2 and y1 < v.y and v.y < y2 then
			mask[v] = true
		end
	end

	Selection.set(mask)
end

function RectSelect.draw()
	if mouseDown[1] then
		love.graphics.setColor(0.0, 0.8, 0.8)
		love.graphics.rectangle("line", RectSelect.ix, RectSelect.iy, mouseX - RectSelect.ix, mouseY - RectSelect.iy)
	end
end
