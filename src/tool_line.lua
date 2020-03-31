Line = {}

Line.points = {}
Line.lastpoint = {}
Line.name = "draw lines"

Line.preview = true
Line.draw = true

function Line.mousepressed()	
	Line.points = {}

	local pt = {mouseX,mouseY,pres}
	table.insert(Line.points,pt)
	Line.lastpoint = pt

	Line.first = {mouseX,mouseY}
end

function Line.mousedown()
	if not (Line.lastpoint[1] == mouseX and Line.lastpoint[2] == mouseY) then
		Line.removePoints()
		local pt = {mouseX,mouseY,pres}
		table.insert(Line.points,pt)
		table.sort( Line.points, function (a,b) return a[1] < b[1] end )
		Line.lastpoint = pt
	end

	if love.keyboard.isDown("lalt") then
		for i,v in ipairs(Line.points) do
			local dx = v[1] - Line.first[1]
			local m = (mouseY - Line.first[2]) / (mouseX - Line.first[1])



			v[2] = dx*m + Line.first[2]

			Line.removePointsLine()
		end
	else
		for i,v in ipairs(Line.points) do
			v[2] = mouseY
		end
	end
end

function Line.removePointsLine()
	newTable = {}
	for  k,v in ipairs(Line.points) do
		sign = 1
		if mouseX < Line.first[1] then
			sign = -1
		end
		if sign*Line.first[1] <= sign*v[1] and sign*v[1] <= sign*mouseX then
			table.insert(newTable,v)
		end
	end
	Line.points = newTable
end

function Line.removePoints()
	local rev = false
	local x1 = Line.lastpoint[1]
	local x2 = mouseX
	if x1 > x2 then
		x1,x2 = x2,x1
		rev = true
	end

	newTable = {}
	for  k,v in ipairs(Line.points) do
		if v[1] > x1 and v[1] < x2 or (rev and v[1] == x1)  or ((not rev) and v[1] == x2) then
			
		else
			table.insert(newTable,{v[1],v[2],v[3]})
		end
	end
	Line.points = newTable
end

function Line.mousereleased()
	for i,v in ipairs(Line.points) do
		v[1],v[2] = View.invTransform(v[1],v[2])
	end
	if(#Line.points > 2) then

		Line.keep = {}
		for i in ipairs(Line.points) do
			Line.keep[i] = false
		end
		Line.keep[1] = true
		Line.keep[#Line.points] = true
		
		Line.simplify(1,#Line.points,true)

		Line.setMinimumSegments()
	
		newTable = {}
		for i,v in ipairs(Line.points) do
			if Line.keep[i] then
				table.insert(newTable,v)
			end
		end
		Line.points = newTable

		table.sort( Line.points, function (a,b) return a[1] < b[1] end )

		
		
		Edit.addNote(Line.points)
	end
	Line.points = {}
end
function Line.setMinimumSegments()
	local d = 0
	for i in ipairs(Line.points) do
		if i > 1 then
			if not Line.keep[i] then
				local first = Line.points[i-1]
				local last = Line.points[i]
				local vx = last[1] - first[1]
				local vy = last[2] - first[2]
				d = d + math.sqrt(vx*vx+vy*vy)
				if d > minLength then
					Line.keep[i] = true
					d = 0
				end
			else
				d = 0
			end
		end
	end
end
function Line.simplify(i1,i2,alwaysKeep)
	
	newTable = {}

	local first = Line.points[i1]
	local last = Line.points[i2]

	Line.keep[i1] = true
	Line.keep[i2] = true

	local vx = last[1] - first[1]
	local vy = last[2] - first[2]

	

	local x1 = first[1]
	local y1 = first[2]
	local m = vy/vx

	local dmax = 0
	local index = 0
	for i = i1+1,i2-1 do
		local x = Line.points[i][1]

		local t = (x-x1)/vx
		dy = math.abs(Line.points[i][3] - (last[3]*t + first[3]*(1-t)))*20
		if dy > dmax then
			dmax = dy
			index = i
		end
	end

	if dmax > 1 or (alwaysKeep and index > 0) then
		Line.simplify(i1,index)
		Line.simplify(index,i2)
	end
end

function Line.draw()
	--[[local i = 1
	local line = {}
	for  k,v in ipairs(Line.points) do
		line[i] = v[1]
		line[i+1] = v[2]
		i = i + 2
	end

	love.graphics.setColor(.7,.0,.0)
	if(#line >= 4) then
		love.graphics.line(line)
	end]]


	love.graphics.setColor(.7,.0,.0)
	for i = 1, #Line.points-1 do
		local v1 = Line.points[i]
		local v2 = Line.points[i+1]

		--love.graphics.line(v1[1],v1[2],v2[1],v2[2])

		love.graphics.polygon("fill", 
				v1[1], (v1[2]+v1[3]*10+1), 
				v2[1], (v2[2]+v2[3]*10+1),
				v2[1], (v2[2]-v2[3]*10-1),
				v1[1], (v1[2]-v1[3]*10-1)
				)

	end


end

