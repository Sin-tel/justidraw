--[[
camera and drawing
]]

local harmonicColorTable = require("harmonics")
local View = {}

View.x = 0
View.y = 0
View.zoomX = 0.3
View.zoomY = 0.3

local function log2(x)
	return math.log(x) / math.log(2)
end

local function drawHarmonics(ix, iy, ex, ey, sx, sy)
	local notes = {}
	local j = 1

	for i, v in ipairs(song.track[1]) do
		local x, y = View.invTransform(mouseX, mouseY)
		if v.r and v.x <= x and v.r.x > x then
			local a = (x - v.x) / (v.r.x - v.x)

			local yy = (1 - a) * v.y + a * v.r.y
			notes[j] = yy

			j = j + 1
		end
	end

	if notes[1] then
		for i, v in ipairs(notes) do
			notes[i] = 2 ^ (-notes[i] / 1200)
		end
		table.sort(notes)
		local f1 = notes[1]
		local bestFit = 1
		local lowestError = math.huge
		for i = 1, 16 do
			local err = 0
			for k, v in ipairs(notes) do
				local f = i * v / f1

				err = err + (math.floor(f + 0.5) - f) ^ 2
			end
			--arbitrary weights
			err = err * i

			if err < lowestError then
				bestFit = i
				lowestError = err
			end
		end

		f1 = f1 / bestFit

		for i, col in pairs(harmonicColorTable) do
			local f = i * f1
			local y = -log2(f) * 1200

			love.graphics.setColor(col)
			love.graphics.print(i, sx * ix + 2, sy * y - 13)
			--love.graphics.setColor(1,0,0,0.5)
			love.graphics.line(sx * ix, sy * y, sx * ex, sy * y)
		end
	end
end

function View.draw()
	love.graphics.push()
	love.graphics.translate(View.x, View.y)
	local sx, sy = View.zoomX, View.zoomY

	local ix, iy = View.invTransform(0, 0)
	local ex, ey = View.invTransform(width, height)

	if not love.keyboard.isDown("y") then
		for i = math.floor(iy / 100) + 1, math.floor(ey / 100) do
			love.graphics.setColor(1, 1, 1, 0.25 * sy)
			if i % 12 == 0 then
				love.graphics.setColor(1, 1, 1, 3 * sy)
			end
			love.graphics.line(sx * ix, sy * i * 100, sx * ex, sy * i * 100)
		end
	end

	for i = math.floor(ix / 100) + 1, math.floor(ex / 100) do
		love.graphics.setColor(1, 1, 1, 0.25 * sx)
		if (i - song.bpmOffset) % 4 == 0 then
			love.graphics.setColor(1, 1, 1, 1 * sx)
		end
		if (i - song.bpmOffset) % 16 == 0 then
			love.graphics.setColor(1, 1, 1, 4 * sx)
		end
		love.graphics.line(sx * i * 100, sy * iy, sx * i * 100, sy * ey)
	end

	love.graphics.setColor(0.35, 0.35, 0.35)
	for i, v in ipairs(song.track[1]) do
		if v.r then
			love.graphics.polygon(
				"fill",
				sx * v.x,
				sy * (v.y + v.w * 65 + 1),
				sx * v.r.x,
				sy * (v.r.y + v.r.w * 65 + 1),
				sx * v.r.x,
				sy * (v.r.y - v.r.w * 65 - 1),
				sx * v.x,
				sy * (v.y - v.w * 65 - 1)
			)
			love.graphics.line(sx * v.x, sy * (v.y + v.w * 65 + 1), sx * v.r.x, sy * (v.r.y + v.r.w * 65 + 1))
			love.graphics.line(sx * v.x, sy * (v.y - v.w * 65 - 1), sx * v.r.x, sy * (v.r.y - v.r.w * 65 - 1))
		end
	end

	local ptSize = math.min(4 * sx, 3)
	local ptSizeSel = math.max(ptSize * 1.2, 2)

	for i, v in ipairs(song.track[1]) do
		if v.r then
			if Selection.mask[v] and Selection.mask[v.r] then
				love.graphics.setColor(0.4, 1, 1)
			else
				love.graphics.setColor(0.7, 0.7, 0.7)
			end
			love.graphics.line(sx * v.x, sy * v.y, sx * v.r.x, sy * v.r.y)
		end
		if Selection.mask[v] then
			love.graphics.setColor(0.4, 1, 1)
			love.graphics.ellipse("fill", sx * v.x, sy * v.y, ptSizeSel, ptSizeSel)
		else
			love.graphics.setColor(0.7, 0.7, 0.7)
			love.graphics.ellipse("fill", sx * v.x, sy * v.y, ptSize, ptSize)
		end
	end

	love.graphics.setColor(0, 1, 1)
	local at = Audio.time
	love.graphics.line(sx * at, sy * iy, sx * at, sy * ey)

	if love.keyboard.isDown("y") then
		drawHarmonics(ix, iy, ex, ey, sx, sy)
	end

	love.graphics.pop()
end

function View.invTransform(x, y)
	return (x - View.x) / View.zoomX, (y - View.y) / View.zoomY
end
function View.transform(x, y)
	return x * View.zoomX + View.x, y * View.zoomY + View.y
end

return View
