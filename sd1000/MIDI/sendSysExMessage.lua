function sendSysExMessage(msgData)

	--xx = tonumber(fxModeValue,16)

	--XX = 0x00 -- don't care

	--msgData = { 0xF0, 0x41, 0x00, 0x42, 0x12, 0x40, combinedByte, 0x22, 0x00, XX, 0xF7 }		--<-- Reset: track in normal mode

	console (string.format("sendSysExMessage (msgData=%s)", MemoryBlock(msgData):toHexString(1)))

--	for k,v in pairs(msgData) do console(string.format("SysEx: %d,%02x", k,v)) end
	--console ( tostring(msgData) )

	newMidiMessage = CtrlrMidiMessage( msgData )
	panel:sendMidiMessageNow(newMidiMessage)

end