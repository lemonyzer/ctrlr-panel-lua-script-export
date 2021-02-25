--
-- Called when a mouse is down on this component
--

saveAllModVal = function(--[[ CtrlrComponent --]] comp, --[[ MouseEvent --]] event)

	serializeEasy()

end


serializeEasy = function(--[[ CtrlrComponent --]] comp, --[[ MouseEvent --]] event)

	console("serializeEasy")

	if panel:getBootstrapState() then
		return
	end

	fileToWrite = utils.saveFileWindow(
		"Save content as data",
		File.getSpecialLocation(File.userHomeDirectory),
		"*.bin",
		true
	)

	if fileToWrite:isValid() == false then
		return
	end

	-- Let's see if the file exists
	if fileToWrite:existsAsFile() == false then
		
		-- The file is not there, that's ok, let's try to create it
		if fileToWrite:create() == false then

			-- Ooooh we can't create it, we need to fail here
			utils.warnWindow ("File write", "The destination file does not exist, and i can't create it")

			return
		end
	end

	--dataToWrite = MemoryBlock (panel:getModulatorValuesAsData ())
	--getModulatorValuesAsData(
		-- const String &propertyToIndexBy,
		-- const CtrlrByteEncoding byteEncoding,
		-- const int bytesPerValue,
		-- const bool useMappedValues)

	bytesPerValue = 2
	dataToWrite = panel:getModulatorValuesAsData("serializeIndex", CtrlrPanel.EncodeNormal, bytesPerValue, false)

	fileDataString = dataToWrite:toHexString(0)
	console (fileDataString)

	-- DEBUG
	debugMode = "short"
	--debugMode = "full"
	serializeEasyDebug (dataToWrite, bytesPerValue, debugMode)
	
	if fileToWrite:replaceWithData (dataToWrite) == false then
		utils.warnWindow ("File write", "Failed to write data to file: "..fileToWrite.getFullPathName())
	end

end

serializeEasyDebug = function ( dataToWrite, bytesPerValue, debugMode )

	console(string.format("serializeEasyDebug (dataToWrite:getSize()==%d, bytesPerValue=%d)", dataToWrite:getSize(),bytesPerValue ))

	len = dataToWrite:getSize() 

	modIndex=0
	for i=0,len,bytesPerValue do
		modValue = dataToWrite:getBitRange(i * 8, bytesPerValue * 8)
		mod = nil
		mod = panel:getModulatorWithProperty ("serializeIndex", modIndex)
		if mod ~= nil then
			if mod:getProperty("name") ~= nil then
				console(string.format("save mod = %s with value = %d", mod:getProperty("name"), modValue ))
			else
				if (debugMode ~= "short") then
					console(string.format("mod with property serializeIndex==%d has no name!!! value = %d", modIndex, modValue))
				end
			end
		else
			console(string.format("mod with property serializeIndex==%d not found!!! value = %d", modIndex, modValue))
		end

		modIndex=modIndex+1
	end

end


saveEasyNewDebugInformationStyle = function ()

	bytesPerValue = 2
	dataToWrite = panel:getModulatorValuesAsData("serializeIndex", CtrlrPanel.EncodeNormal, bytesPerValue, false)
	
	len = dataToWrite:getSize() 

	modIndex=0
	for i=0,len,bytesPerValue do
		modValue = dataToWrite:getBitRange(i * 8, bytesPerValue * 8)
		mod = panel:getModulatorWithProperty ("serializeIndex", modIndex)

		if (dataToWrite:getByte(i) ~= nil) then
			console(string.format("dataToWrite:getByte(%d) = %s == %s",i,dataToWrite:getByte(i),modValue))
			--console(string.format("dataToWrite[%d] =",i))
		else
			console(string.format("dataToWrite:getByte(%d) = NULL == %s",i,modValue))
		end
		modIndex=modIndex+1
	end

end


saveEasyOldStyle = function ()

	bytesPerValue = 2
	dataToWrite = panel:getModulatorValuesAsData("serializeIndex", CtrlrPanel.EncodeNormal, bytesPerValue, false)
	
	len = dataToWrite:getSize() 

	fileDataString = dataToWrite:toHexString(0)
	n=1
	for i=1,len,1 do
		modValue = string.sub(fileDataString,n,n+1)
		n=n+bytesPerValue
		if (dataToWrite[i] ~= nil) then
			console(string.format("dataToWrite[%d] = %s == %s",i,dataToWrite[i],modValue))
			--console(string.format("dataToWrite[%d] =",i))
		else
			console(string.format("dataToWrite[%d] = NULL == %s",i,modValue))
		end
	end

end