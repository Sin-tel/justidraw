require("tablet")
require("edit")
View = require("view")
Audio = require("audio")
Theme = require("theme")
require("file")
require("undo")
require("selection")
require("clipboard")
local helpString = require("help")
local utf8 = require("utf8")

local Draw = require("tool_draw")
local Erase = require("tool_erase")
local Pan = require("tool_pan")
local Zoom = require("tool_zoom")
local Line = require("tool_line")
local Grab = require("tool_grab")
local Move = require("tool_move")
local Smooth = require("tool_smooth")
local Flatten = require("tool_flatten")
local SelectRect = require("tool_select_rect")
local SelectLasso = require("tool_select_lasso")
local Envelope = require("tool_envelope")
local EnvelopeAlt = require("tool_envelopealt")
local Stretch = require("tool_stretch")
local Smudge = require("tool_smudge")

--print console directly
io.stdout:setvbuf("no")

width = 1280
height = 720

-- luacheck: push ignore 121
VERSION_MAJOR = 0
VERSION_MINOR = 3
-- luacheck: pop

love.window.setMode(width, height, {
	vsync = true,
	fullscreen = false,
	fullscreentype = "desktop",
	borderless = false,
	resizable = true,
	minwidth = 640,
	minheight = 480,
})

width, height = love.window.getMode()

pres = 0

preview = true
textInput = false

local textEntered = "song title"

mouseX, mouseY = 0, 0
mousePX, mousePY = 0, 0

mouseDown = { false, false, false }
modifierKeys = {}
modifierKeys.ctrl = false
modifierKeys.shift = false
modifierKeys.alt = false

-- local mainFont = love.graphics.newFont(22)
local smallFont = love.graphics.newFont(16)

minLength = 50
automergeDist = 50
selectNotes = false

local message = ""
local messageTimer = 0.0

local followPlay = false
-- count newlines
local _, helpStringSize = string.gsub(helpString, "\n", "\n")

function setMessage(m)
	message = m
	messageTimer = 2.0
end

function love.load()
	math.randomseed(os.time())
	Theme.load()
	Tablet.init()
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("none")
	love.graphics.setLineWidth(1.0)
	love.graphics.setFont(smallFont)

	love.keyboard.setKeyRepeat(true)

	Selection.init()

	selectTool(Draw)
	Audio.load()

	File.new()
	Undo.load()
	File.loadLast()
end

function selectTool(t)
	selectedTool = t
	currentTool = t
end

function setTool()
	if not (mouseDown[1] or mouseDown[3]) then
		if modifierKeys.ctrl then
			if selectedTool.drawTool then
				currentTool = Erase
			elseif selectedTool == Pan then
				currentTool = Zoom
			elseif selectedTool == Grab then
				currentTool = Move
			elseif selectedTool == Move then
				currentTool = Grab
			end
		elseif modifierKeys.shift then
			if
				selectedTool == Grab
				or selectedTool == Flatten
				or selectedTool == Envelope
				or selectedTool == Smudge
				or selectedTool.drawTool
			then
				currentTool = Smooth
			end
		else
			currentTool = selectedTool
		end

		if selectedTool.drawTool and Tablet.erase then
			currentTool = Erase
		end
	end
end

function love.mousepressed(x, y, button)
	if not tabletInput then
		pres = 0.5
		mousepressed(button)
	end
end

function love.mousereleased(x, y, button)
	if not tabletInput then
		pres = 0
		mousereleased(button)
	end
end

function mousepressed(button)
	if not Clipboard.drag then
		mouseDown[button] = true

		setTool()

		if button == 3 then
			if modifierKeys.ctrl then
				currentTool = Zoom
			else
				currentTool = Pan
			end
		end

		if button ~= 2 then
			currentTool.mousepressed()
		end
	end
end

function mousereleased(button)
	if Clipboard.drag then
		Clipboard.drag = false
	else
		mouseDown[button] = false

		if button ~= 2 then
			currentTool.mousereleased()
		end

		if currentTool ~= Pan and currentTool ~= Zoom then
			Undo.register()
		end

		if button == 3 then
			currentTool = selectedTool
		end
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
		View.zoomX = View.zoomX * 1.2
		View.zoomY = View.zoomY * 1.2

		View.x = View.x + (mouseX - View.x) * (1 - 1.2)
		View.y = View.y + (mouseY - View.y) * (1 - 1.2)
	elseif y < 0 then
		View.zoomX = View.zoomX / 1.2
		View.zoomY = View.zoomY / 1.2

		View.x = View.x + (mouseX - View.x) * (1 - 1 / 1.2)
		View.y = View.y + (mouseY - View.y) * (1 - 1 / 1.2)
	end
end

function love.update(dt)
	mousePX, mousePY = mouseX, mouseY
	Tablet.update()

	messageTimer = messageTimer - dt

	if Clipboard.drag then
		Clipboard.dragUpdate()
	else
		if mouseDown[1] or mouseDown[3] then
			currentTool.mousedown()
		end
	end

	Audio.update()

	if followPlay and Audio.isPlaying then
		local vx, _ = View.transform(Audio.timeSmooth, 0)
		if vx / width > 0.33 then
			View.x = -Audio.timeSmooth * View.zoomX + width * 0.33
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(Theme.current.background)
	View.draw()
	if currentTool.draw then
		currentTool.draw()
	end

	love.graphics.setColor(Theme.current.cursor)
	if currentTool.radius then
		if currentTool.tempRadius then
			love.graphics.circle("line", mouseX, mouseY, currentTool.tempRadius)
		else
			love.graphics.circle("line", mouseX, mouseY, currentTool.radius)
		end
	end

	if love.keyboard.isDown("i") and not textInput then
		local f = love.graphics.getFont()
		local c = Theme.current.background
		love.graphics.setColor(c[1], c[2], c[3], 0.65)
		local w = f:getWidth(helpString)
		local h = f:getHeight(helpString) * helpStringSize
		love.graphics.rectangle("fill", 0, 0, w + 20, h + 20)

		love.graphics.setColor(Theme.current.text)
		love.graphics.print(helpString, 10, 10)
	elseif Theme.current.showTooltip then
		love.graphics.setColor(Theme.current.text)
		love.graphics.print(selectedTool.name, 10, 10)
	end

	if messageTimer > 0 then
		love.graphics.setColor(Theme.current.text)
		love.graphics.print(message, 10, height - 30)
	end

	if Theme.current.showMeter then
		love.graphics.setColor(Theme.current.background)
		love.graphics.rectangle("fill", width - 100, 10, 80, 10)
		love.graphics.rectangle("fill", width - 100, 25, 80, 10)
		local peak = 20 * math.log(Audio.peak) / math.log(10)
		local clip = false
		if peak > -3.0 then
			clip = true
		end
		peak = math.max(peak, -40.0)
		peak = math.min(peak, 0)
		peak = 1 + peak / 40
		love.graphics.setColor(0.8, 0.8, 0.05)
		love.graphics.rectangle("fill", width - 100, 10, 80 * Audio.cpuLoad, 10)
		if clip then
			love.graphics.setColor(0.8, 0.1, 0.1)
		else
			love.graphics.setColor(0.1, 0.8, 0.1)
		end
		love.graphics.rectangle("fill", width - 100, 25, 80 * peak, 10)
		love.graphics.setColor(Theme.current.cursor)
		love.graphics.rectangle("line", width - 100, 10, 80, 10)
		love.graphics.rectangle("line", width - 100, 25, 80, 10)
	end

	if textInput then
		local c = Theme.current.background
		love.graphics.setColor(c[1], c[2], c[3], 0.65)
		love.graphics.rectangle("fill", 0, 0, width, height)

		local f = love.graphics.getFont()
		local w = f:getWidth(textEntered)
		local w2 = f:getWidth("project name:")
		local h = f:getHeight(textEntered)

		love.graphics.setColor(Theme.current.text)

		love.graphics.print("project name:", math.floor((width - w2) * 0.5), math.floor((height - h) * 0.5 - h))
		love.graphics.print(textEntered, math.floor((width - w) * 0.5), math.floor((height - h) * 0.5))
	end
end

function love.keypressed(key)
	if key == "lshift" or key == "rshift" then
		modifierKeys.shift = true
	elseif key == "lctrl" or key == "rctrl" then
		modifierKeys.ctrl = true
	elseif key == "lalt" or key == "ralt" then
		modifierKeys.alt = true
	end

	if textInput then
		if key == "backspace" then
			local byteoffset = utf8.offset(textEntered, -1)
			if byteoffset then
				textEntered = string.sub(textEntered, 1, byteoffset - 1)
			end
		elseif key == "return" then
			local name = textEntered
			-- trim spaces
			name = string.gsub(name, "^%s*(.-)%s*$", "%1")

			if name == "" then
				name = File.randomName()
			end
			File.setName(name)
			textInput = false
		elseif key == "escape" then
			textInput = false
		end
	else
		setTool()

		if key == "space" then
			if Audio.isPlaying then
				Audio.stop()
			else
				Audio.seek(View.invTransform(0, 0))
				Audio.play()
			end
		elseif key == "o" and modifierKeys.ctrl then
			love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
		elseif key == "r" and modifierKeys.ctrl then
			Audio.render()
		elseif key == "t" and modifierKeys.ctrl then
			Theme.next()
		elseif key == "n" and modifierKeys.ctrl then
			print(song.name)
			textEntered = song.name
			textInput = true
		elseif key == "f" and modifierKeys.ctrl then
			if followPlay then
				followPlay = false
				setMessage("follow off")
			else
				followPlay = true
				setMessage("follow on")
				if not Audio.isPlaying then
					Audio.seek(View.invTransform(0, 0))
				end
			end
		elseif key == "p" and modifierKeys.shift then
			if preview then
				preview = false
				setMessage("preview off")
			else
				preview = true
				setMessage("preview on")
			end
		elseif key == "e" and modifierKeys.shift then
			local enabled = Audio.toggleEffect("echo")
			if enabled then
				setMessage("echo on")
			else
				setMessage("echo off")
			end
		elseif key == "r" and modifierKeys.shift then
			local enabled = Audio.toggleEffect("reverb")
			if enabled then
				setMessage("reverb on")
			else
				setMessage("reverb off")
			end
		elseif key == "n" and modifierKeys.shift then
			if selectNotes then
				selectNotes = false
				setMessage("select vertices")
			else
				selectNotes = true
				setMessage("select notes")
			end
		elseif key == "delete" or key == "backspace" then
			if Selection.isEmpty() then
				File.new()
			else
				Edit.remove(Selection.mask)
			end
			Undo.register()
		elseif key == "b" then
			selectTool(Draw)
		elseif key == "o" then
			selectTool(Pan)
		elseif key == "p" then
			selectTool(Line)
		elseif key == "g" then
			selectTool(Grab)
		elseif key == "m" then
			selectTool(Move)
		elseif key == "e" then
			selectTool(Erase)
		elseif key == "s" and not modifierKeys.ctrl then
			selectTool(Smooth)
		elseif key == "f" then
			selectTool(Flatten)
		elseif key == "n" then
			selectTool(EnvelopeAlt)
		elseif key == "h" then
			selectTool(Envelope)
		elseif key == "r" then
			selectTool(SelectRect)
		elseif key == "l" then
			selectTool(SelectLasso)
		elseif key == "t" then
			selectTool(Stretch)
		elseif key == "u" then
			selectTool(Smudge)
		elseif key == "j" then
			Edit.join()
			Edit.resampleAll()
		elseif key == "d" and modifierKeys.shift then
			Clipboard.duplicate()
		elseif key == "d" then
			Selection.deselect()
			Undo.register()
		elseif key == "[" then
			if selectedTool.radius then
				selectedTool.radius = selectedTool.radius * 0.9
			end
		elseif key == "]" then
			if selectedTool.radius then
				selectedTool.radius = selectedTool.radius * 1.1
			end
		elseif key == "+" or key == "kp+" or key == "=" then
			song.bpm = math.min(math.max(song.bpm + 4, 32), 320)
			setMessage("bpm: " .. song.bpm)
		elseif key == "-" or key == "kp-" then
			song.bpm = math.min(math.max(song.bpm - 4, 32), 320)
			setMessage("bpm: " .. song.bpm)
		elseif key == "left" then
			song.bpmOffset = song.bpmOffset - 1
		elseif key == "right" then
			song.bpmOffset = song.bpmOffset + 1
		elseif key == "up" then
			song.gain = song.gain * 1.41421
			song.gain = math.min(song.gain, 0.5)
			setMessage("volume: " .. math.floor(0.5 + 20 * math.log(song.gain) / math.log(10)) .. "dB")
		elseif key == "down" then
			song.gain = song.gain / 1.41421
			setMessage("volume: " .. math.floor(0.5 + 20 * math.log(song.gain) / math.log(10)) .. "dB")
		elseif key == "z" and modifierKeys.ctrl and not modifierKeys.shift then
			Undo.undo()
		elseif (key == "y" and modifierKeys.ctrl) or (key == "z" and modifierKeys.ctrl and modifierKeys.shift) then
			Undo.redo()
		elseif key == "s" and modifierKeys.ctrl then
			File.save()
		elseif key == "escape" then
			love.event.quit()
		end
	end
end

function love.textinput(t)
	if textInput then
		textEntered = textEntered .. t
	end
end

function love.keyreleased(key)
	if key == "lshift" or key == "rshift" then
		modifierKeys.shift = false
	elseif key == "lctrl" or key == "rctrl" then
		modifierKeys.ctrl = false
	elseif key == "lalt" or key == "ralt" then
		modifierKeys.alt = false
	end

	if not textInput then
		setTool()
	end
end

function love.resize(w, h)
	width = w
	height = h
end

function love.quit()
	love.filesystem.write("last_theme", Theme.getName())
	Tablet.close()
end

function love.filedropped(f)
	local filename = f:getFilename()
	if string.sub(filename, -4) == ".sav" then
		File.load(f)
	else
		setMessage("not a save file! (.sav)")
	end
end
