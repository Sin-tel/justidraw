Qaudio = {}

love.audio.setEffect('reverb', {
	type = 'reverb',
	gain = 0.15,
	decaytime = 3.0,
})


love.audio.setEffect('delay', {
	type = 'echo',
	volume = 0.1,
	delay = 0.157,
	tapdelay = 0.044,
	damping = 0.5,
	feedback = .3,
	spread = 1.0,
})


function Qaudio.load()
	bitDepth = 16
	samplingRate = 44100
	channelCount = 1
	bufferSize = 1024
	pointer = 0
	sd = love.sound.newSoundData(bufferSize, samplingRate, bitDepth, channelCount)
	qs = love.audio.newQueueableSource(samplingRate, bitDepth, channelCount)

	qs:setEffect('reverb')
	--qs:setEffect('delay')

	dspTime = 0.0

	fun = nil
end

function Qaudio.setCallback(f)
	fun = f
end

function Qaudio.update()
	if qs:getFreeBufferCount() == 0 then return end -- only render if we can.
	local samplesToMix = bufferSize -- easy way of doing things.
	for smp = 0, samplesToMix-1 do
		lambda1 = smp/samplesToMix
		lambda2 = (smp+0.5)/samplesToMix
		-- put your generator function here.
		sd:setSample(pointer, fun(dspTime))
		pointer = pointer + 1
		dspTime = dspTime + (1 / samplingRate)
		if pointer >= sd:getSampleCount() then
			pointer = 0
			qs:queue(sd)
			qs:play()
		end
	end
end