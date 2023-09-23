local Qaudio = {}

love.audio.setEffect("reverb", {
	type = "reverb",
	gain = 0.3,
	decaytime = 3.5,
})

love.audio.setEffect("echo", {
	type = "echo",
	volume = 0.13,
	delay = 0.17,
	tapdelay = 0.12,
	damping = 0.1,
	feedback = 0.5,
	spread = 1.0,
})

local callback = nil
local cpuLoad = 0.0

function Qaudio:load()
	local bitDepth = 16
	local channelCount = 1

	self.samplingRate = 44100
	self.pointer = 0
	self.bufferSize = 1024

	self.sd = love.sound.newSoundData(self.bufferSize, self.samplingRate, bitDepth, channelCount)
	self.qs = love.audio.newQueueableSource(self.samplingRate, bitDepth, channelCount)

	self.qs:setEffect("reverb")

	self.effects = {}
	self.effects["reverb"] = true
	self.effects["echo"] = false
end

function Qaudio:toggleEffect(effect)
	local enabled = not self.effects[effect]
	self.effects[effect] = enabled
	self.qs:setEffect(effect, enabled)
	return enabled
end

function Qaudio:setCallback(f)
	callback = f
end

function Qaudio:update()
	local time = love.timer.getTime()
	while self.qs:getFreeBufferCount() > 0 do
		local samplesToMix = self.bufferSize -- easy way of doing things.
		for _ = 0, samplesToMix - 1 do
			self.sd:setSample(self.pointer, callback())
			self.pointer = self.pointer + 1
			if self.pointer >= self.sd:getSampleCount() then
				self.pointer = 0
				self.qs:queue(self.sd)
				self.qs:play()
			end
		end
	end
	local elapsed = love.timer.getTime() - time
	local cpuNew = elapsed * self.samplingRate / self.bufferSize
	cpuLoad = cpuLoad + 0.05 * (cpuNew - cpuLoad)
	cpuLoad = math.max(cpuLoad, cpuNew)

	return cpuLoad
end

return Qaudio
