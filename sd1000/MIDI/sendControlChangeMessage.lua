sendControlChangeMessage = function (ccNumber, value)

	pre = 0xb0 + getCurrentMidiChannel(true)
	ccNumberHex = 0x00 + ccNumber
	vv = 0x00 + value

	msgData = { pre, ccNumberHex, vv }		--<-- Reset: track in normal mode

	console (string.format("sendControlChangeMessage (ccNumber = %d, value = %d) ... channel == %d", ccNumber, value, channel))
--	for k,v in pairs(msgData) do console(string.format("CC: %d,%02x", k,v)) end
	--console ( tostring(msgData) )

	newMidiMessage = CtrlrMidiMessage( msgData )
	panel:sendMidiMessageNow(newMidiMessage)

end