--[[
camera and drawing


]]

local View = {}

View.x = 0
View.y = 0
View.zoomX = 0.3
View.zoomY = 0.3


function View.draw()
	love.graphics.push()
	love.graphics.translate(View.x, View.y)
	--love.graphics.scale(View.zoomX,View.zoomY)
	local sx,sy = View.zoomX,View.zoomY

	local ix,iy = View.invTransform(0,0)
	local ex,ey = View.invTransform(width,height)



	
	for i= math.floor(iy/100)+1,math.floor(ey/100) do
		love.graphics.setColor(1,1,1,.25*sy)
		if i%12 == 0 then
			love.graphics.setColor(1,1,1,3*sy)
		end
		love.graphics.line(sx*ix,sy*i*100,sx*ex,sy*i*100)
	end
	
	for i= math.floor(ix/100)+1,math.floor(ex/100) do
		love.graphics.setColor(1,1,1,.25*sx)
		if i%4 == 0 then
			love.graphics.setColor(1,1,1,1*sx)
		end
		if i%16 == 0 then
			love.graphics.setColor(1,1,1,4*sx)
		end
		love.graphics.line(sx*i*100,sy*iy,sx*i*100,sy*ey)
	end



	line = {}
	verts = {}
	li = 1
	ii = 100

	love.graphics.setColor(.3,.3,.3)
	for i,v in ipairs(song.track[1]) do
		if v.r then
			love.graphics.polygon("fill", 
				sx*v.x  , sy*(v.y  +v.w*65+1), 
				sx*v.r.x, sy*(v.r.y+v.r.w*65+1),
				sx*v.r.x, sy*(v.r.y-v.r.w*65-1),
				sx*v.x  , sy*(v.y  -v.w*65-1)
				)
			love.graphics.line(sx*v.x  , sy*(v.y  +v.w*65+1), sx*v.r.x, sy*(v.r.y+v.r.w*65+1))
			love.graphics.line(sx*v.x  , sy*(v.y  -v.w*65-1), sx*v.r.x, sy*(v.r.y-v.r.w*65-1))
		end
	end
	
	for i,v in ipairs(song.track[1]) do
		if v.r then
			love.graphics.setColor(.5,.5,.5)
			love.graphics.line(sx*v.x,sy*v.y,sx*v.r.x,sy*v.r.y)
		end
		--love.graphics.setColor(.4,1,1)
		love.graphics.setColor(.5,.5,.5)
		love.graphics.ellipse("fill",sx*v.x,sy*v.y,2,2)
	end

	love.graphics.setColor(0,1,1)
	local at = Audio.time
	love.graphics.line(sx*at,sy*iy,sx*at,sy*ey)



	--[[love.graphics.setColor(0,1,1,0.2)
	for i,v in ipairs(song.track[1]) do
		love.graphics.ellipse("line",v.x,v.y,v.w*65,v.w*65)
	end]]

	love.graphics.pop()
end

function View.invTransform(x,y)
	return (x-View.x)/View.zoomX, (y-View.y)/View.zoomY
end
function View.transform(x,y)
	return x*View.zoomX+View.x, y*View.zoomY+View.y
end

return View