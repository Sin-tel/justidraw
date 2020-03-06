--[[
interface to track structure
adding notes, cleanup etc

]]

Edit = {}

function Edit.addNote(list)

	pts = {}

	for i,v in ipairs(list) do
		pt = {}
		pt.x = v[1]
		pt.y = v[2]
		pt.w = v[3]

		pts[i] = pt
	end

	for i,v in ipairs(pts) do
		if(pts[i-1]) then
			pts[i].l = pts[i-1]
		end
		if(pts[i+1]) then
			pts[i].r = pts[i+1]
		else
			--set final to 0
			pts[i].w = 0
		end
		table.insert(song.track[1],pts[i])
	end

	
	--[[local first = list[1][1]
	local last = list[#list][1]

	local newTrack = {}
	local leftIndex = 0
	local rightIndex = 0
	for i,v in ipairs(song.track[1]) do
		if v.x < first then
			table.insert(newTrack,v)
			leftIndex = i
		elseif v.x > last then
			rightIndex = i
			break
		end
	end

	pts = {}
	for i,v in ipairs(list) do
		pt = {}
		pt.x = v[1]
		pt.y = v[2]
		pt.w = v[3]
		print(v[3])
		table.insert(pts,pt)
	end

	for i,v in ipairs(pts) do
		if(pts[i-1]) then
			pts[i].l = pts[i-1]
		else
			if leftIndex > 0 and song.track[1][leftIndex].r then
				song.track[1][leftIndex].r = pts[i]
				pts[i].l = song.track[1][leftIndex]
			end
		end
		if(pts[i+1]) then
			pts[i].r = pts[i+1]
		else
			if rightIndex > 0 and song.track[1][rightIndex].l then
				song.track[1][rightIndex].l = pts[i]
				pts[i].r = song.track[1][rightIndex]
			end
		end
		assert(pts[i].r or pts[i].l)
		pts[i].tangent = Edit.getTangent(pts[i])

		
		--pts[i].w = 0.5

		table.insert(newTrack,pts[i])
	end

	for i,v in ipairs(song.track[1]) do
		if v.x > last then
			table.insert(newTrack,v)
		end
	end


	song.track[1] = newTrack]]
end

function Edit.removeNotes(remove)
	for i=#song.track[1],1,-1 do
		if remove[i] then
			local v = song.track[1][i]
			if v.l then
				v.l.w = 0
				v.l.r = nil
			end
			if v.r then
				v.r.l = nil
			end
			table.remove(song.track[1], i)
		end
	end
	Edit.removeSingles()
end

function Edit.removeSingles()
	for i=#song.track[1],1,-1 do
		local v = song.track[1][i]
		if not (v.l or v.r) then
			table.remove(song.track[1], i)
		end
	end
end

function Edit.getTangent(pt)
	if not pt.l then
		return (pt.y - pt.r.y) / (pt.x - pt.r.x)
	elseif not pt.r then
		return (pt.l.y - pt.y) / (pt.l.x - pt.x)
	else
		local m = (pt.l.y - pt.r.y) / (pt.l.x - pt.r.x)
		local m1 = (pt.y - pt.r.y) / (pt.x - pt.r.x)
		local m2 = (pt.l.y - pt.y) / (pt.l.x - pt.x)
	
		
		return m --/ (1 + .05*math.abs(m1-m2))
	end
end