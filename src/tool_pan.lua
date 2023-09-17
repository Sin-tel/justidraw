Pan = {}

Pan.name = "pan"

function Pan.mousepressed()
	Pan.isZoom = false

	Pan.ix = mouseX
	Pan.iy = mouseY

	Pan.vx = View.x
	Pan.vy = View.y
end

function Pan.mousedown()
	View.x = Pan.vx + (mouseX - Pan.ix)
	View.y = Pan.vy + (mouseY - Pan.iy)
end

function Pan.mousereleased() end
