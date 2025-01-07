local Qaudio = require("qaudio")
local wav = require("lib/wav_save")

local M = {}

M.peak = 0.0
M.cpuLoad = 0.0

local fr_to_delta = 440 / 44100

local sin = math.sin
local sqrt = math.sqrt
local random = math.random
local TWO_PI = 2 * math.pi

local function clip(x)
	if x <= -1.5 then
		return -1
	elseif x >= 1.5 then
		return 1
	else
		return x - (4 / 27) * x * x * x
	end
end

local function emtptycb()
	return 0
end

local function amp_curve(x)
	return x * x
end

local synth_names = {
	"filter saw",
	"filter square",
	"glassy",
	"sine",
	"noisy sine",
	"warm",
	"semisine",
	"resonant",
}

local function synth_saw(v)
	v.accum = v.accum + TWO_PI * v.delta
	local s = v.amp * sin(v.accum + 2 * v.pout)
	v.pout = (v.pout + s) * 0.5
	return s
end

local function synth_square(v)
	v.accum = v.accum + TWO_PI * v.delta
	local s = v.amp * sin(v.accum + 2 * v.pout * v.pout)
	v.pout = (v.pout + s) * 0.5
	return s
end

local function synth_glass(v)
	v.accum = v.accum + TWO_PI * v.delta
	local s = v.amp * sin(v.accum + 1.6 * v.amp * sin(3 * v.accum))
	return s
end

local function synth_sine(v)
	v.accum = v.accum + TWO_PI * v.delta
	local s = v.amp * sin(v.accum)
	return s
end

local function synth_noisy(v)
	local n = random() - 0.5
	v.pout = v.pout + (n - v.pout) * 0.05
	v.accum = v.accum + TWO_PI * v.delta + 0.4 * sqrt(v.delta) * v.pout * (1.1 - v.amp)
	local s = v.amp * sin(v.accum)
	return s
end

local function synth_warm(v)
	v.accum = v.accum + TWO_PI * v.delta
	local s = v.amp * sin(v.accum + 1.2 * v.amp * sin(v.accum))
	return s
end

local function synth_semisine(v)
	v.accum = v.accum + v.delta
	local x = v.accum - math.floor(v.accum)
	local s1 = (3 * x * x - 2 * x * x * x - x)
	local s = 1.5 * v.amp * (v.pout - s1) / v.delta
	v.pout = s1
	return s
end

local function synth_resonant(v)
	v.accum = v.accum + v.delta
	v.accum = v.accum - math.floor(v.accum)

	local f = (0.5 + 5 * v.amp)
	-- local f = (0.5 + 0.1 * v.amp / (0.01 + v.delta))

	local x = v.accum
	local s = v.amp * (4 * x * (1.0 - x) * (1.0 - x)) * (1 + sin(f * v.accum * TWO_PI))
	return s
end

local function audiocb()
	if M.isPlaying then
		-- 100 pixels in one beat
		M.time = M.time + 4 * 100 * song.bpm / (60 * 44100)

		while M.startTable[M.startIndex] and M.time > M.startTable[M.startIndex].x do
			for i, v in ipairs(M.voice) do
				if not v.active then
					v.vert = M.startTable[M.startIndex]
					v.active = true
					v.accum = 0
					break
				end
			end
			M.startIndex = M.startIndex + 1
		end

		for i, v in ipairs(M.voice) do
			if v.active then
				while v.vert.r and M.time > v.vert.r.x do
					v.vert = v.vert.r
				end
				if not v.vert.r then
					v.target_amp = 0
				else
					local a = (M.time - v.vert.x) / (v.vert.r.x - v.vert.x)
					local yy = (1 - a) * v.vert.y + a * v.vert.r.y
					v.delta = fr_to_delta * 2 ^ (-yy / 1200)
					v.target_amp = amp_curve((1 - a) * v.vert.w + a * v.vert.r.w)
				end
			end
		end
	end

	local out = 0
	for i, v in ipairs(M.voice) do
		if v.active or v.preview then
			v.amp = 0.99 * v.amp + 0.01 * v.target_amp
			local synth = song.synth

			local s
			if synth == 1 then
				s = synth_saw(v)
			elseif synth == 2 then
				s = synth_square(v)
			elseif synth == 3 then
				s = synth_glass(v)
			elseif synth == 4 then
				s = synth_sine(v)
			elseif synth == 5 then
				s = synth_noisy(v)
			elseif synth == 6 then
				s = synth_warm(v)
			elseif synth == 7 then
				s = synth_semisine(v)
			elseif synth == 8 then
				s = synth_resonant(v)
			end

			out = out + s
			if v.amp < 0.001 and v.target_amp == 0 then
				v.preview = false
				v.active = false
			end
		end
	end
	out = out * song.gain

	local newPeak = math.abs(out)
	M.peak = M.peak + 0.00005 * (newPeak - M.peak)
	M.peak = math.max(M.peak, newPeak)

	return clip(out)
end

function M.resetVoices()
	M.voice = {}
	for i = 1, M.voiceLimit do
		M.voice[i] = {}
		M.voice[i].amp = 0
		M.voice[i].target_amp = 0
		M.voice[i].accum = 0
		M.voice[i].delta = 440 / 44100
		M.voice[i].pout = 0
		M.voice[i].active = false
		M.voice[i].preview = false
		M.voice[i].vert = nil
	end
end

function M.load()
	M.voiceLimit = 100
	M.resetVoices()
	M.time = 0
	M.timeSmooth = 0
	M.isPlaying = false
	M.startTable = {}

	Qaudio:load()
	Qaudio:setCallback(audiocb)
end

function M.update()
	local cpuLoad = Qaudio:update()
	if cpuLoad then
		M.cpuLoad = cpuLoad
	end

	M.timeSmooth = M.timeSmooth + 0.2 * (M.time - M.timeSmooth)

	if not M.isPlaying then
		for i, v in ipairs(M.voice) do
			v.target_amp = 0
		end
	end

	if mouseDown[1] and currentTool.preview and not M.isPlaying and preview then
		local x, y = View.invTransform(mouseX, mouseY)

		if currentTool.drawTool then
			M.voice[M.voiceLimit].target_amp = pres
			M.voice[M.voiceLimit].preview = true
			local fr = 440 * 2 ^ (-y / 1200)
			M.voice[M.voiceLimit].delta = fr / 44100
		end

		local j = 1

		for i, v in ipairs(song.track[1]) do
			if v.r and v.x <= x and v.r.x > x then
				local a = (x - v.x) / (v.r.x - v.x)

				local yy = (1 - a) * v.y + a * v.r.y
				local fr = 440 * 2 ^ (-yy / 1200)
				M.voice[j].delta = fr / 44100
				M.voice[j].target_amp = (1 - a) * v.w + a * v.r.w
				M.voice[j].preview = true
				if j < M.voiceLimit then
					j = j + 1
				end
			end
		end
	end
end

function M.toggleEffect(effect)
	return Qaudio:toggleEffect(effect)
end

function M.seek(t)
	M.time = t
	M.timeSmooth = t
end

function M.play()
	M.isPlaying = true
	M.startTable = {}
	for i, v in ipairs(song.track[1]) do
		if not v.l then
			table.insert(M.startTable, v)
		end
	end
	table.sort(M.startTable, function(a, b)
		return a.x < b.x
	end)

	M.startIndex = 1

	while M.startTable[M.startIndex] and M.time > M.startTable[M.startIndex].x do
		for i, v in ipairs(M.voice) do
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
	for i, v in ipairs(M.voice) do
		v.target_amp = 0
	end
end

function M.render()
	local wait_cursor = love.mouse.getSystemCursor("wait")
	love.mouse.setCursor(wait_cursor)

	local restore_time = M.time

	-- find first and last vertex
	local startTime = math.huge
	local endTime = -math.huge
	for i, v in ipairs(song.track[1]) do
		startTime = math.min(startTime, v.x)
		endTime = math.max(endTime, v.x)
	end

	-- a bit of padding
	startTime = startTime - 100
	endTime = endTime + 100

	-- mute all voices
	M.stop()
	M.resetVoices()

	-- prepare for playback
	M.seek(startTime)
	M.play()

	wav.open()
	local block = {}
	while true do
		for i = 1, 64 do
			local sample = audiocb()
			-- convert to 16bit
			if sample >= 0 then
				sample = sample * 32767
			else
				sample = sample * 32768
			end

			-- interlace
			block[i * 2 - 1] = sample
			block[i * 2] = sample
		end
		wav.append(block)

		if M.time > endTime then
			break
		end
	end
	local filename = song.name .. ".wav"
	wav.close(filename)

	-- flush callback
	Qaudio:setCallback(emtptycb)
	Qaudio:update()
	Qaudio:setCallback(audiocb)

	setMessage("done rendering! (" .. filename .. ")")

	M.stop()
	M.seek(restore_time)

	love.mouse.setCursor()
end

function M.nextSynth()
	song.synth = song.synth + 1
	if song.synth > #synth_names then
		song.synth = 1
	end
	for i, v in ipairs(M.voice) do
		if v.active or v.preview then
			v.pout = 0
			v.accum = 0
			v.amp = 0
		end
	end

	setMessage("synth: " .. synth_names[song.synth])
end

return M
