local Qaudio = {}

love.audio.setEffect("reverb", {
	type = "reverb",
	gain = 0.3,
	decaytime = 3.0,
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

	dspTime = 0.0

	fun = nil
end

function Qaudio:toggleEffect(effect)
	enabled = not self.effects[effect]
	self.effects[effect] = enabled
	self.qs:setEffect(effect, enabled)
	return enabled
end

function Qaudio:setCallback(f)
	fun = f
end

function Qaudio:update()
	if self.qs:getFreeBufferCount() == 0 then
		return
	end -- only render if we can.
	local samplesToMix = self.bufferSize -- easy way of doing things.
	for smp = 0, samplesToMix - 1 do
		lambda1 = smp / samplesToMix
		lambda2 = (smp + 0.5) / samplesToMix
		-- put your generator function here.
		self.sd:setSample(self.pointer, fun(dspTime))
		self.pointer = self.pointer + 1
		dspTime = dspTime + (1 / self.samplingRate)
		if self.pointer >= self.sd:getSampleCount() then
			self.pointer = 0
			self.qs:queue(self.sd)
			self.qs:play()
		end
	end
end

return Qaudio
