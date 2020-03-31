require "qaudio"

local M = {}

bpm = 120

local function audiocb()
	if M.isPlaying then
		M.time = M.time + 4*100*bpm/(60*44100)

		while M.startTable[M.startIndex] and M.time > M.startTable[M.startIndex].x do
			for i,v in ipairs(M.voice) do
				if not v.active then
					v.vert = M.startTable[M.startIndex]
					v.active = true
					break
				end
			end
			M.startIndex = M.startIndex + 1
		end

		for i,v in ipairs(M.voice) do
			if v.active then
				while v.vert.r and M.time > v.vert.r.x do
					v.vert = v.vert.r
				end
				if not v.vert.r then
					v.active = false
					v.amp = 0
				else
					local a = (M.time - v.vert.x) / (v.vert.r.x - v.vert.x)

					local yy = (1-a)*v.vert.y + a*v.vert.r.y
					local fr = 440*2^(-yy/1200)
					v.delta = fr*2*math.pi/44100
					v.amp = (1-a)*v.vert.w + a*v.vert.r.w
				end
			end
		end
	end
	local out = 0
	for i,v in ipairs(M.voice) do
		if v.active then
			v.accum = v.accum + v.delta
			local s = v.amp*math.sin(v.accum + 2*v.pout)
			v.pout = s
			out = out + s
		end
	end
	out = clip(out*0.5)
	
	return out
end

function M.load()
	M.voiceLimit = 100

	M.voice = {}
	for i = 1,M.voiceLimit do
		M.voice[i] = {}
		M.voice[i].amp = 0
		M.voice[i].accum = 0
		M.voice[i].delta = 440*2*math.pi/44100
		M.voice[i].pout = 0
		M.voice[i].active = false
		M.voice[i].vert = nil
	end

	Qaudio.load()
	Qaudio.setCallback(audiocb)

	M.time = 0
	M.isPlaying = false
	M.startTable = {}
end

function M.update()
	Qaudio.update()

	
	if not M.isPlaying then
		for i,v in ipairs(M.voice) do
			v.amp = 0
			v.active = false
		end
	end

	if mouseDown[1] and currentTool.preview and not M.isPlaying then

		M.voice[M.voiceLimit].amp = pres
		M.voice[M.voiceLimit].active = pres
		
		local x,y = View.invTransform(mouseX,mouseY)
		local fr = 440*2^(-y/1200)
		M.voice[M.voiceLimit].delta = fr*2*math.pi/44100
	
		local j = 1

		for i,v in ipairs(song.track[1]) do
			local x,y = View.invTransform(mouseX,mouseY)
			if v.r and v.x <= x and v.r.x > x then
				
				local a = (x - v.x) / (v.r.x - v.x)
				
				local yy = (1-a)*v.y + a*v.r.y
				local fr = 440*2^(-yy/1200)
				M.voice[j].delta = fr*2*math.pi/44100
				M.voice[j].amp = (1-a)*v.w + a*v.r.w
				M.voice[j].active = true
				if j < M.voiceLimit then
					j = j + 1
				end
			end
		end
	end
	
end

function M.seek(t)
	M.time = t
end

function M.play()
	M.isPlaying = true
	M.startTable = {}
	for i,v in ipairs(song.track[1]) do
		if not v.l then
			table.insert(M.startTable,v)
		end
		
	end
	table.sort(M.startTable, function(a,b) return a.x < b.x end)
	
	M.startIndex = 1

	while M.startTable[M.startIndex] and M.time > M.startTable[M.startIndex].x do
		for i,v in ipairs(M.voice) do
			if v.active then
				while v.vert.r and v.vert.r.x < M.time do
					v.vert = v.vert.r
					if not v.vert.r then
						v.active = false
					end
				end
			end

			if not v.active then
				v.vert = M.startTable[M.startIndex]
				v.active = true
				break
			end
		end

		M.startIndex = M.startIndex + 1
	end
end

function M.stop()
	M.isPlaying = false
	for i,v in ipairs(M.voice) do
		v.active = false
	end
end

function clip(x)
	if x <= -1.5 then
		return -1
	elseif x >= 1.5 then
		return 1
	else
		return x - (4/27)*x*x*x
	end
end

return M