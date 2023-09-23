local Theme = {}

Theme.default = require("theme_default")

local function fromHex(rgba)
	local rb = tonumber(string.sub(rgba, 2, 3), 16)
	local gb = tonumber(string.sub(rgba, 4, 5), 16)
	local bb = tonumber(string.sub(rgba, 6, 7), 16)

	local r, g, b = love.math.colorFromBytes(rb, gb, bb)
	return { r, g, b }
end

function Theme.load()
	if love.filesystem.getInfo("user_themes.lua") then
		local contents, _ = love.filesystem.read("user_themes.lua")
		Theme.themes = loadstring(contents)()
	else
		local contents, _ = love.filesystem.read("theme_default.lua")
		love.filesystem.write("user_themes.lua", contents)
		Theme.themes = Theme.default
	end
	for _, th in pairs(Theme.themes) do
		-- mix in defaults if missing
		for k, v in pairs(Theme.default.dark) do
			if th[k] == nil then
				th[k] = v
			end
		end

		-- convert hex to rgb
		for k, v in pairs(th) do
			if type(v) == "string" and string.sub(v, 1, 1) == "#" then
				th[k] = fromHex(v)
			end
		end
	end

	Theme.indices = {}
	for k in pairs(Theme.themes) do
		table.insert(Theme.indices, k)
	end
	table.sort(Theme.indices)

	Theme.index = 1
	Theme.setName("dark")

	if love.filesystem.getInfo("theme.txt") then
		local name = love.filesystem.read("theme.txt")
		Theme.setName(name)
	end

	Theme.setCurrent()
end

function Theme.next()
	Theme.index = Theme.index % #Theme.indices + 1
	Theme.setCurrent()
end

function Theme.setCurrent()
	setMessage("theme: " .. Theme.indices[Theme.index])
	Theme.current = Theme.themes[Theme.indices[Theme.index]]
end

function Theme.getName()
	return Theme.indices[Theme.index]
end

function Theme.setName(name)
	for i, v in ipairs(Theme.indices) do
		if v == name then
			Theme.index = i
		end
	end
end

return Theme
