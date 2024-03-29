local SelectRect = {}

SelectRect.name = [[
rectangular selection
shift: add
ctrl: subtract
]]

SelectRect.select = true

function SelectRect.mousepressed()
	SelectRect.ix = mouseX
	SelectRect.iy = mouseY
end

function SelectRect.mousedown() end

function SelectRect.mousereleased()
	local mask = {}

	local x1, y1 = View.invTransform(SelectRect.ix, SelectRect.iy)
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

function SelectRect.draw()
	if mouseDown[1] then
		love.graphics.setColor(Theme.current.cursor)
		love.graphics.rectangle("line", SelectRect.ix, SelectRect.iy, mouseX - SelectRect.ix, mouseY - SelectRect.iy)
	end
end

return SelectRect
