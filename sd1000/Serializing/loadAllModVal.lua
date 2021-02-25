--
-- Called when a mouse is down on this component
--

loadAllModVal = function(--[[ CtrlrComponent --]] comp, --[[ MouseEvent --]] event)

if panel:getBootstrapState() then
		return
	end

	fileToRead = utils.openFileWindow(
		"Open file to read as data",
		File.getSpecialLocation(File.userHomeDirectory),
		"*.*",
		true
	)

	if fileToRead:existsAsFile() then

		-- Update the file path
		--panel:getLabelComponent("lastFileReadPathL"):setText ("> "..fileToRead:getFullPathName())

		if fileToRead:getSize() > 8192 then
				utils.warnWindow(
					"File too big", 
					"Labels are not designed to show too much data, please choose a file that's smaller then 8kb.\
The file you chose is "..fileToRead:getSize().." bytes"
				)
			return
		end

		-- We need a memory block to load our file into, this can be created at some other point in time
		-- if we expect the files to be big and the amount of memory we need is higher, it will pre-allocate
		-- that memory at the moment that MemoryBlock() is called
		-- here we will allocate the amount of memory that is equalt to the size of the file

		fileData = MemoryBlock(fileToRead:getSize())

		-- This method does not return a new memory block, it operates on the one provided by us

		fileToRead:loadFileAsData (fileData)

		-- reset before load
		MegaPanicReset_ (false, false) -- without update ui

		--panel:getLabelComponent("dataContentL"):setText(
		--	fileData:toHexString(1)
		--)

		--panel:setModulatorValuesFromData(fileData,"vstIndex", CtrlrPanel.EncodeNormal, startByte, 1,AreValuesMapped) 

		--setModulatorValuesFromData (const MemoryBlock &dataSource, 
			-- const String &propertyToIndexBy,
			-- const CtrlrByteEncoding byteEncoding,
			-- int propertyOffset,
			-- int bytesPerValue,
			-- const bool useMappedValues)
        --panel:setModulatorValuesFromData(fileData, "serializeIndex", CtrlrPanel.EncodeNormal, 0, 2, false)
		--updateModulatorValuesFromData(fileData)
		--updateModulatorValuesFromDataCustom(fileData)
		updateModulatorValuesFromDataCustomVariableLength(fileData)
	end

end


updateModulatorValuesFromDataCustomVariableLength = function (fileData)
-- two byte values with lsb msb
	console(string.format("updateModulatorValuesFromDataCustomVariableLength (fileData:getSize()==%d)", fileData:getSize() ))

	len = fileData:getSize()
	fileDataString = fileData:toHexString(0)
	console (fileDataString)

	bytesPerValue = 2

	panel:setPropertyString("panelMidiPauseOut","0")

	-- set loading value flag
	--loadingStage = 0
	initLoadingStage(0)
	--loadingCompleteFlag = false
	--panel:getModulatorByName("loadingCompleteMod"):setModulatorValue(0,false,false,false) -- clear ... onvaluechange needs to get triggered!!
	initLoadingCompleteFlag(false)
	-- remove flag in last modulator's on change method
	
	propertyNameTriggerModChangeMethodOnLoad = "TriggerModChangeMethodOnLoad"
	propertyNamePauseMidiDuringModChangeOnLoad = "PauseMidiDuringModChangeOnLoad"
	--propertyNamePauseMidiDuringModChangeOnLoad "SendMidiMessageWithModChangeOnLoad"

	modIndex = 0
	for i=0, len, bytesPerValue do

		modValue = fileData:getBitRange(i * 8, bytesPerValue * 8)

		mod = panel:getModulatorWithProperty ("serializeIndex", modIndex)
		if mod ~= nil then
			modName = mod:getProperty("name")
			if modName ~= nil then
			
				if (isModulatorValid(modName) == true) then
--					console(string.format("loading mod = %s with value = %02x", mod:getProperty("name"), tonumber(modValue,16) ))

					--pauseMidiDuringModChangeOnLoadValue = mod:getPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad)
					--panel:setPropertyInt("panelMidiPauseOut",pauseMidiDuringModChangeOnLoadValue)
					pauseMidiVal = isModulatorTypeMidiPaused (mod, modName)
					panel:setPropertyInt("panelMidiPauseOut",pauseMidiVal)

					mod:setModulatorValue(modValue,false,true,false)
					customValChangeMethod = mod:getProperty("customLuaModulatorValueChange")
					triggerModChangeMethodOnLoadValue = mod:getProperty(propertyNameTriggerModChangeMethodOnLoad)
					if (triggerModChangeMethodOnLoadValue == 1) then
						valChangeMethod = mod:getProperty("luaModulatorValueChange")
						if (valChangeMethod ~= nil) then
							if (valChangeMethod == "-- None") then
								
							else
								console (string.format("modIndex=%d luaModulatorValueChange found: %s(%s,%d)", modIndex, valChangeMethod, mod:getProperty("name"), modValue))
								--valChangeMethod()
								_G[valChangeMethod](mod, modValue)
							end
						end
					end
					
					panel:setPropertyInt("panelMidiPauseOut", 0)
					
				else
				
				end
			else
-- DEBUG --				 console(string.format("mod with property serializeIndex==%d has no name!!! value = %d", modIndex, modValue))
			end
		else
			 console(string.format("mod with property serializeIndex==%d not found!!! value = %d", modIndex, modValue))
		end
		
		modIndex = modIndex +1
	end

	updateAllPresetLabels ()

	--nextLoadingStage()
	--initLoadingCompleteFlag(true)
	-- load fxTab
	--efxId = fileData:getBitRange(2 * 8, bytesPerValue * 8)
	--panel:getComponent("fxTabs"):setProperty ("uiTabsCurrentTab", efxId, false)
	--console(string.format("load fxTab == %d", efxId ))
end

isModulatorValid = function (modName)

	sModName = String(modName)
	if (sModName:startsWith("Efx")) then
		if (sModName:endsWith("Preset")) then
			console (string.format("%s is not Valid for loading",modName))
			return false
		end
	end
	
	return true
end

updateAllPresetLabels = function ()

	n = panel:getNumModulators() -1

	for modIndex=0, n do
		mod = panel:getModulatorByIndex(modIndex)
		if mod ~= nil then
			modName = mod:getProperty("name")
			if (String(modName):endsWith ("_Current_Preset") == true) then
				-- mod is Preset Label
				labelComponent = mod : getComponent ()
				labelComponent:setText("Custom")
			end
		end
	end

end

updateModulatorValuesFromDataCustom = function (fileData)
-- two byte values with lsb msb
	console(string.format("updateModulatorValuesFromDataCustom (fileData:getSize()==%d)", fileData:getSize() ))

	len = fileData:getSize()
	fileDataString = fileData:toHexString(0)
	console (fileDataString)


	--for i=0,len,1 do
	--	if (fileData[i] ~= nil) then
	--		console (fileData[i]:toString())
	--	else
	--		console ("fileData == NULL")
	--	end
	--end
	

	modIndex = 0
	for i=1,len,2 do
		--console(fileDataString:substring(i,i+2))
		modValue = string.sub(fileDataString,i,i+1)
		--console(modValue)
		--console(string.format("modValue == %s == %d == %x", modValue, tonumber(modValue,10), tonumber(modValue,16) ))
		--console(string.format("modValue == %s == %x", modValue, tonumber(modValue,16) ))

		mod = panel:getModulatorWithProperty ("serializeIndex", modIndex)
		if mod ~= nil then
			if mod:getProperty("name") ~= nil then
				console(string.format("mod = %s with value = %02x", mod:getProperty("name"), tonumber(modValue,16) ))
				--mod:setModulatorValue((tonumber(modValue,16)),false,true,false)
			else
				console(string.format("mod with property serializeIndex==%d has no name!!! value = %d", modIndex, modValue))
			end
		else
			console(string.format("mod with property serializeIndex==%d not found!!! value = %d", modIndex, modValue))
		end
		
		--mod = panel:getModulatorByIndex(modIndex)
		--mod:setModulatorValue((tonumber(modValue,16)),false,true,false)
		modIndex = modIndex +1
	end

	return
end

updateModulatorValuesFromDataCustomOneByte = function (fileData)

	console(string.format("updateModulatorValuesFromDataCustom (fileData:getSize()==%d)", fileData:getSize() ))

	len = fileData:getSize()
	fileDataString = fileData:toHexString(0)
	console (fileDataString)


	--for i=0,len,1 do
	--	if (fileData[i] ~= nil) then
	--		console (fileData[i]:toString())
	--	else
	--		console ("fileData == NULL")
	--	end
	--end
	

	modIndex = 0
	for i=1,len,2 do
		--console(fileDataString:substring(i,i+2))
		modValue = string.sub(fileDataString,i,i+1)
		--console(modValue)
		--console(string.format("modValue == %s == %d == %x", modValue, tonumber(modValue,10), tonumber(modValue,16) ))
		--console(string.format("modValue == %s == %x", modValue, tonumber(modValue,16) ))

		mod = panel:getModulatorWithProperty ("serializeIndex", modIndex)
		if mod ~= nil then
			if mod:getProperty("name") ~= nil then
				console(string.format("mod = %s with value = %02x", mod:getProperty("name"), tonumber(modValue,16) ))
				mod:setModulatorValue((tonumber(modValue,16)),false,true,false)
			else
				console(string.format("mod with property serializeIndex==%d has no name!!!", modIndex))
			end
		else
			console(string.format("mod with property serializeIndex==%d not found!!!", modIndex))
		end
		
		--mod = panel:getModulatorByIndex(modIndex)
		--mod:setModulatorValue((tonumber(modValue,16)),false,true,false)
		modIndex = modIndex +1
	end

	return
end

updateModulatorValuesFromData = function (fileData)

	len = fileData:getSize()
	fileDataString = fileData:toHexString(0)
	console (fileDataString)


	--for i=0,len,1 do
	--	if (fileData[i] ~= nil) then
	--		console (fileData[i]:toString())
	--	else
	--		console ("fileData == NULL")
	--	end
	--end
	

	modIndex = 0
	for i=1,len,2 do
		--console(fileDataString:substring(i,i+2))
		modValue = string.sub(fileDataString,i,i+1)
		console(modValue)
		--console(string.format("modValue == %s == %d == %x", modValue, tonumber(modValue,10), tonumber(modValue,16) ))
		console(string.format("modValue == %s == %x", modValue, tonumber(modValue,16) ))

		mod = panel:getModulatorByIndex(modIndex)
		mod:setModulatorValue((tonumber(modValue,16)),false,true,false)
		modIndex = modIndex +1
	end

	return
end


extractSingleModValueFromData = function ( memBlock, index )

	memBlockDataString = fileData:toHexString(0)
	singleModValue = string.sub(memBlockDataString,index,index+1)
	return singleModValue
end