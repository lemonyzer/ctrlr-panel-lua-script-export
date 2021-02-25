function sendNRPNMessage( highByte, lowByte, dataByte )
	
	-- Built Message

	local nrpnMsg = {}

	channel = panel:getPropertyInt ("panelMidiOutputChannelDevice") - 1

	console (string.format("sendNRPNMessage on Channel(0-15)=%d (highByte = %d, lowByte = %d, dataByte = %d)", channel, highByte, lowByte, dataByte))

	--chhannel = panel:getPropertyInt ("panelMidiOutputChannelHost")
	local pre = 0xb0 + channel

	nrpnMsg[1] = string.format("%02x",pre) .. " 63 " .. string.format("%02x",highByte)
	nrpnMsg[2] = string.format("%02x",pre) .. " 62 " .. string.format("%02x",lowByte)
	nrpnMsg[3] = string.format("%02x",pre) .. " 06 " .. string.format("%02x",dataByte)


	-- Send Message
	
	for index=1,3 do

        -- for debugging purposes let's see how that looks like
--        console ("NRPN MSG: "..nrpnMsg[index])

        -- Convert the Table to a Memoryblock
        MemB=MemoryBlock(nrpnMsg[index])

        -- Send patchData to the Synth
		panel:sendMidiMessageNow(CtrlrMidiMessage(MemB))
        -- panel:sendMidi(CtrlrMidiMessage(MemB),0)
	end

end

function sendNRPNMessageWithChannel(channel, highByte, lowByte, dataByte )
	

	console (string.format("sendNRPNMessageWithChannel (0-15) (channel = %d, highByte = %d, lowByte = %d, dataByte = %d)", channel, highByte, lowByte, dataByte))

	-- Built Message

	local nrpnMsg = {}

	--channel = panel:getPropertyInt ("panelMidiOutputChannelDevice")
	--chhannel = panel:getPropertyInt ("panelMidiOutputChannelHost")
	local pre = 0xb0 + channel

	nrpnMsg[1] = string.format("%02x",pre) .. " 63 " .. string.format("%02x",highByte)
	nrpnMsg[2] = string.format("%02x",pre) .. " 62 " .. string.format("%02x",lowByte)
	nrpnMsg[3] = string.format("%02x",pre) .. " 06 " .. string.format("%02x",dataByte)


	-- Send Message
	
	for index=1,3 do

        -- for debugging purposes let's see how that looks like
--        console ("NRPN MSG: "..nrpnMsg[index])

        -- Convert the Table to a Memoryblock
        MemB=MemoryBlock(nrpnMsg[index])

        -- Send patchData to the Synth
		panel:sendMidiMessageNow(CtrlrMidiMessage(MemB))
        -- panel:sendMidi(CtrlrMidiMessage(MemB),0)
	end

end