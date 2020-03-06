require "tablet"
require "edit"
View = require "view"
Audio = require "audio"
require "file"
require "undo"

require "tool_draw"
require "tool_erase"
require "tool_pan"
require "tool_zoom"




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

--mainFont = love.graphics.newFont("res/GothamRoundedLight.ttf", 22, "normal")
--smallFont = love.graphics.newFont("res/GothamRoundedBook.ttf", 12, "normal")

mainFont = love.graphics.newFont(22)
smallFont = love.graphics.newFont(12)


function love.load()
	math.randomseed(os.time())
	Tablet.init()
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("none")
	love.graphics.setLineWidth(1.0)
	love.graphics.setFont(smallFont)

	love.keyboard.setKeyRepeat( true )


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
	mouseDown[button] = true
	--print("press: " .. button)
	--currentTool = selectedTool

	

	if button == 3 then
		if love.keyboard.isDown("lctrl") then
			currentTool = Zoom
		else
			currentTool = Pan
		end
	end

	currentTool.mousepressed()
end

function mousereleased(button)
	mouseDown[button] = false
	--print("release: " .. button)

	
	currentTool.mousereleased()

	if currentTool ~= Pan and currentTool ~= Zoom then
		Undo.register()
	end

	currentTool = selectedTool
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
	
	if mouseDown[1] or mouseDown[3] then
		currentTool.mousedown()
	else
		if love.keyboard.isDown("lctrl") then
			if selectedTool == Draw then
				currentTool = Erase
			elseif selectedTool == Pan then
				currentTool = Zoom
			end
		else
			currentTool = selectedTool
		end

		if selectedTool == Draw and erase then
			currentTool = Erase
		end
	end

	Audio.update()
end


function love.draw()
	View.draw()
	Draw.draw()
	love.graphics.setColor(.5,.5,.5)
	if currentTool.radius then
		love.graphics.circle("line", mouseX, mouseY, currentTool.radius)
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
	if key == "space" then
		if Audio.isPlaying then
			Audio.stop()
		else
			Audio.seek(View.invTransform(0,0))
			Audio.play()
		end
	elseif key == "delete" then
		File.new()
		Undo.register()
	elseif key == "z" and love.keyboard.isDown("lctrl") and not love.keyboard.isDown("lshift") then
		Undo.undo()
	elseif (key == "y" and love.keyboard.isDown("lctrl")) or (key == "z" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift")) then
		Undo.redo()
	elseif key == "s" and love.keyboard.isDown("lctrl") then
		File.save()
	elseif key == "o" and love.keyboard.isDown("lctrl") then
		--File.load()
		love.system.openURL("file://"..love.filesystem.getSaveDirectory())
	elseif key == "escape" then
		love.event.quit( )
	end
end

function love.quit()
	Tablet.close()
end

function love.filedropped(f)
	File.load(f)
end
