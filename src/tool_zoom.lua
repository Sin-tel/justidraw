Zoom = {}

Zoom.zoomFactor = 0.005

Zoom.name = "zoom"

function Zoom.mousepressed()


	Zoom.ix = mouseX
	Zoom.iy = mouseY

	Zoom.vx = View.x
	Zoom.vy = View.y

	Zoom.zx = View.zoomX
	Zoom.zy = View.zoomY
end

function Zoom.mousedown()
	local zx = math.exp( (mouseX - Zoom.ix)*Zoom.zoomFactor)
	local zy = math.exp(-(mouseY - Zoom.iy)*Zoom.zoomFactor)


	View.zoomX = Zoom.zx * zx
	View.zoomY = Zoom.zy * zy

	View.x = Zoom.vx + (Zoom.ix - Zoom.vx)*(1 - zx)
	View.y = Zoom.vy + (Zoom.iy - Zoom.vy)*(1 - zy)

end

function Zoom.mousereleased()
	
end



