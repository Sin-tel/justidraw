require "tablet"
require "edit"
View = require "view"
Audio = require "audio"
require "file"
require "undo"
require "selection"
require "clipboard"

require "tool_draw"
require "tool_erase"
require "tool_pan"
require "tool_zoom"
require "tool_line"
require "tool_grab"
require "tool_move"
require "tool_smooth"
require "tool_flatten"
require "tool_rectselect"
require "tool_envelope"
require "tool_envelopealt"
require "tool_help"




--print console directly
io.stdout:setvbuf("no")

width = 800  
height = 600 

--love.window.setMode(width,height,{vsync=true,fullscreen=true,fullscreentype = "desktop",borderless = true, y=0}) 
love.window.setMode(width,height,{vsync=true,fullscreen=false,fullscreentype = "desktop",borderless = false}) 

width, height = love.window.getMode( )


canvas = love.graphics.newCanvas(width, height)

pres = 0

mouseX, mouseY = 0,0
mousePX, mousePY = 0,0

mouseDown = {false,false,false}
modifierKeys = {}
modifierKeys.ctrl = false
modifierKeys.shift = false
modifierKeys.alt = false

--mainFont = love.graphics.newFont("res/GothamRoundedLight.ttf", 22, "normal")
--smallFont = love.graphics.newFont("res/GothamRoundedBook.ttf", 12, "normal")

mainFont = love.graphics.newFont(22)
smallFont = love.graphics.newFont(12)


minLength = 100
automergeDist = 100

function love.load()
	math.randomseed(os.time())
	Tablet.init()
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("none")
	love.graphics.setLineWidth(1.0)
	love.graphics.setFont(smallFont)

	love.keyboard.setKeyRepeat( true )

	Selection.init()

	selectTool(Draw)
	Audio.load()

	File.new()
	File.loadLast()

	Undo.load()
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
			if selectedTool == Grab or selectedTool == Flatten or selectedTool == Envelope or selectedTool.drawTool then
				currentTool = Smooth
			end
		else
			currentTool = selectedTool
		end

		if selectedTool.drawTool and erase then
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
	if Clipboard.drag then
		Clipboard.drag = false
	else
		mouseDown[button] = true

		setTool()

		if button == 3 then
			if love.keyboard.isDown("lctrl") then
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

function love.wheelmoved(x, y)
	if y > 0 then
		View.zoomX = View.zoomX*1.2
		View.zoomY = View.zoomY*1.2

		View.x = View.x + (mouseX - View.x)*(1 - 1.2)
		View.y = View.y + (mouseY - View.y)*(1 - 1.2)

	elseif y < 0 then
		View.zoomX = View.zoomX/1.2
		View.zoomY = View.zoomY/1.2

		View.x = View.x + (mouseX - View.x)*(1 - 1/1.2)
		View.y = View.y + (mouseY - View.y)*(1 - 1/1.2)
	end
end

function love.update(dt)
	mousePX, mousePY = mouseX, mouseY
	Tablet.update()
	
	if Clipboard.drag then
		Clipboard.dragUpdate()
	else
		if mouseDown[1] or mouseDown[3] then
			currentTool.mousedown()
		end
	end

	Audio.update()
end




function love.draw()
	View.draw()
	if currentTool.draw then
		currentTool.draw()
	end
	
	love.graphics.setColor(.5,.5,.5)
	if currentTool.radius then
		if currentTool.tempRadius then
			love.graphics.circle("line", mouseX, mouseY, currentTool.tempRadius)
		else
			love.graphics.circle("line", mouseX, mouseY, currentTool.radius)
		end
	end
	love.graphics.setColor(.8,.8,.8)
	love.graphics.print(currentTool.name,10,10)

	--[[for i,v in ipairs(Audio.voice) do
		love.graphics.print(math.floor(v.amp*100),10,i*20)
		love.graphics.print(v.delta,100,i*20)
		end]]
	--[[love.graphics.print(#Undo.stack,10,20)
	love.graphics.print(Undo.index,10,30)
	for i,v in ipairs(Undo.stack) do
		love.graphics.print(#v.track[1],50,i*20)
		end]]
	--love.graphics.print(love.filesystem.getSaveDirectory(),10,30)
end


function love.keypressed(key)
	if key == "lshift" or key == "rshift" then
		modifierKeys.shift = true
	elseif key == "lctrl" or key == "rctrl" then
		modifierKeys.ctrl = true
	elseif key == "lalt" or key == "ralt" then
		modifierKeys.alt = true
	end

	setTool()

	if key == "space" then
		if Audio.isPlaying then
			Audio.stop()
		else
			Audio.seek(View.invTransform(0,0))
			Audio.play()
		end
	elseif key == "delete" then
		if Selection.isEmpty() then
			File.new()
		else
			Edit.remove(Selection.mask)
		end
		Undo.register()
	elseif key == "b" then
		selectTool(Draw)
	elseif key == "p" then
		selectTool(Pan)
	elseif key == "l" then
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
	elseif key == "r" then
		selectTool(RectSelect)
	elseif key == "h" then
		currentTool = Help

	elseif key == 'd' and modifierKeys.shift then
		Clipboard.duplicate()
	elseif key == 'd' then
		Selection.deselect()
		Undo.register()
	elseif key == "[" then
		if selectedTool.radius then
			selectedTool.radius = selectedTool.radius*0.9
		end
	elseif key == "]" then
		if selectedTool.radius then
			selectedTool.radius = selectedTool.radius*1.1
		end
	elseif key == "z" and modifierKeys.ctrl and not modifierKeys.shift then
		Undo.undo()
	elseif (key == "y" and modifierKeys.ctrl) or (key == "z" and modifierKeys.ctrl and modifierKeys.shift) then
		Undo.redo()
	elseif key == "s" and modifierKeys.ctrl then
		File.save()
	elseif key == "o" and modifierKeys.ctrl then
		--File.load()
		love.system.openURL("file://"..love.filesystem.getSaveDirectory())
	elseif key == "escape" then
		love.event.quit( )
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
	setTool()
end

function love.quit()
	Tablet.close()
end

function love.filedropped(f)
	File.load(f)
end
