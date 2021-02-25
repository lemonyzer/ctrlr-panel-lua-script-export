--
-- Called when a mouse is down on this component
--

InitSerializeProperty = function(--[[ CtrlrComponent --]] comp, --[[ MouseEvent --]] event)

	n = panel:getNumModulators()
	comp:setProperty ("componentDisabled", 1, false)

--	InitSerializePropertyByNonSolidModulatorIndex ()
--	SortedSerializePropertyIndexInitialization ()
--	FullSortedSerializePropertyIndexInitialization()
	FullSortedSerializePropertyIndexInitializationModular()
	
	comp:setProperty ("componentDisabled", 1, false)
	
	b = BubbleMessageComponent(500)
	b:showAt(comp, string.format("Serialization Index initialized! (0 to %d)",n-1), 2500, true, false)

end

InitSerializePropertyByNonSolidModulatorIndex = function(--[[ CtrlrComponent --]] comp, --[[ MouseEvent --]] event)

	n = panel:getNumModulators()
	for i=0,n-1 do
		mod = panel:getModulatorByIndex(i)
		mod:setPropertyInt("serializeIndex",i)
		mod:setPropertyInt("vstIndex",i)
		--console(string.format("mod:getProperty('serializeIndex') == %d",mod:getPropertyInt("serializeIndex")))
	end

end

FullSortedSerializePropertyIndexInitializationModular = function ()

	propertyNameTriggerModChangeMethodOnLoad = "TriggerModChangeMethodOnLoad"
	propertyNamePauseMidiDuringModChangeOnLoad = "PauseMidiDuringModChangeOnLoad"
	--propertyNamePauseMidiDuringModChangeOnLoad "SendMidiMessageWithModChangeOnLoad"

	ClearSerializePropertyIndex ()
	
	listAllModulatorsSorted()

	local midiChannelMod = panel : getModulatorByName ("MIDIChannel") 
	local HqDistortionPreset = panel : getModulatorByName ("HQ_Dist_Preset_Value")
	local HqDistortionOnOff = panel : getModulatorByName ("HQ_Dist_On") 
	local fxTabsMod = panel:getModulatorByName("fxTabs")
	local efxModusMod = panel:getModulatorByName("efxModus")
	--local fxTabsModComp = panel:getComponent("fxTabs")
	--fxTabsModComp:setProperty ("uiTabsCurrentTab", value, false)
	local programSelectionMod = panel:getModulatorByName("programList")
	
	sIndex = 1
	midiChannelMod:setPropertyInt("serializeIndex",sIndex)
	midiChannelMod:setPropertyInt("vstIndex",sIndex)
	midiChannelMod:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 0)
	midiChannelMod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, 0)
	
	sIndex = sIndex+1
	HqDistortionPreset:setPropertyInt("serializeIndex",sIndex)
	HqDistortionPreset:setPropertyInt("vstIndex",sIndex)
	HqDistortionPreset:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 0)
	HqDistortionPreset:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, 0)
	
	sIndex = sIndex+1
	HqDistortionOnOff:setPropertyInt("serializeIndex",sIndex)
	HqDistortionOnOff:setPropertyInt("vstIndex",sIndex)
	HqDistortionOnOff:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 0)
	HqDistortionOnOff:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, 0)
	
	sIndex = sIndex+1
	efxModusMod:setPropertyInt("serializeIndex",sIndex)
	efxModusMod:setPropertyInt("vstIndex",sIndex)
	efxModusMod:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 1)
	efxModusMod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, 0)

	sIndex = sIndex+1
	fxTabsMod:setPropertyInt("serializeIndex",sIndex)
	fxTabsMod:setPropertyInt("vstIndex",sIndex)
	fxTabsMod:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 1)
	fxTabsMod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, 0)
	
	sIndex = sIndex+1
	programSelectionMod:setPropertyInt("serializeIndex",sIndex)
	programSelectionMod:setPropertyInt("vstIndex",sIndex)
	programSelectionMod:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 1)
	programSelectionMod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, 0)
	sIndex = sIndex+1

--	manualyIndexed = sIndex
--	manualyIndexedOffset = sIndex
	
	for efxId=1,3 do
		console ( string.format (" -------- init EFX%d Modulators serialization index property --------", efxId))
		
		arrayName = string.format("efx%dModulators", efxId)
		arrayLength = efxModulatorCounter[efxId]
		pausMidiOnLoad = 1
		overwritePropertyPauseMidi = false
		numOfInit = InitModulatorSerializePropertyFromArray (arrayName, arrayLength, sIndex, pausMidiOnLoad, overwritePropertyPauseMidi)
		
		sIndex = numOfInit+sIndex
		console (string.format ("numOfInit %d for %s", numOfInit, arrayName))
	end
	
	for efxId=1,3 do
		console ( string.format (" -------- init EFX%d Preset Value Modulators serialization index property --------", efxId))
		arrayName = string.format("efx%dPresetValueModulators", efxId)
		arrayLength = efxPresetValueModulatorCounter[efxId]
		pausMidiOnLoad = 0
		overwritePropertyPauseMidi = true
		numOfInit = InitModulatorSerializePropertyFromArray (arrayName, arrayLength, sIndex, pausMidiOnLoad, overwritePropertyPauseMidi)
		sIndex = numOfInit+sIndex
		console (string.format ("numOfInit %d for %s", numOfInit, arrayName))
	end

	console ( string.format (" -------- init HQ Distortion Modulators serialization index property --------", efxId))
	arrayName = string.format("HQDistModulators", 0)
	arrayLength = HQDistModulatorsCounter
	pausMidiOnLoad = 1
	overwritePropertyPauseMidi = false
	numOfInit = InitModulatorSerializePropertyFromArray (arrayName, arrayLength, sIndex, pausMidiOnLoad, overwritePropertyPauseMidi)
	sIndex = numOfInit+sIndex
	console (string.format ("numOfInit %d for %s", numOfInit, arrayName))

	console ( string.format (" -------- init Other (ungrouped) Modulators serialization index property --------", efxId))
	arrayName = string.format("ungroupedModulators", 0)
	arrayLength = ungroupedModulatorsCounter
	pausMidiOnLoad = 1
	overwritePropertyPauseMidi = false
	numOfInit = InitModulatorSerializePropertyFromArray (arrayName, arrayLength, sIndex, pausMidiOnLoad, overwritePropertyPauseMidi)
	sIndex = numOfInit+sIndex
	console (string.format ("numOfInit %d for %s", numOfInit, arrayName))
	
	-- dynamically done by hidden controls STRG+E (Enable MIDI Message on Load)
	
--	fxTypes = {"Mix", "EQ", "Dist", "Mod", "Wah", "CompLimit", "Delay", "Other"}
--	fxTypePauseMidi = {0, 0, 0, 0, 0, 0, 0, 0}
	-- for key,fxType in ipairs(fxTypes) do
		-- for efxId=1,3 do
			-- pausMidiOnLoad = fxTypePauseMidi[key]
			-- console ( string.format (" -------- init EFX%d %s Controls serialization index property, pauseMidiOnLoad = %d --------", efxId, fxType, pausMidiOnLoad))
			-- arrayName = string.format ("efx%d%sControls", efxId, fxType)
			-- arrayLength = table.maxn(_G[arrayName])
			
			-- overwritePropertyPauseMidi = true
			-- numOfInit = InitModulatorSerializePropertyFromArray (arrayName, arrayLength, sIndex, pausMidiOnLoad, overwritePropertyPauseMidi)
--			-- sIndex = numOfInit+sIndex
			-- console (string.format ("numOfInit %d for %s", numOfInit, arrayName))
		-- end
	-- end

	switchLoadingCompleteModulatorToEnd(sIndex-1)
	removeSerializeIndexFromUnusedModulators()

end



InitModulatorSerializePropertyFromArray = function (arrayName, arrayLength, propertyStartIndex, pausMidiOnLoad, overwritePropertyPauseMidi)

	initCount = 0
	for k=1, arrayLength do
		register = string.format(arrayName, efxId)
		modName = string.format ("%s", _G[register][k])
		mod = panel:getModulatorByName(modName)
		if (mod ~= nil) then
			propertySerializeIndex = mod:getPropertyInt("serializeIndex")
			if (propertySerializeIndex == -1) then
				
				currentSerializeIndexPos = propertyStartIndex + initCount
				mod:setPropertyInt("serializeIndex",currentSerializeIndexPos)
				mod:setPropertyInt("vstIndex",currentSerializeIndexPos)
				mod:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 0)
--				currentSerializeIndexPos = currentSerializeIndexPos +1
				initCount = initCount +1
			else
				console(string.format("mod = %s already indexed, mod:getProperty('serializeIndex') == %d", mod:getProperty("name"),propertySerializeIndex))
--				manualyIndexedOffset = manualyIndexedOffset -1
			end
			
			propertyPauseMidiValue = mod:getPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad)
			if (propertyPauseMidiValue == -1) then
				mod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, pausMidiOnLoad)
			else
				if (overwritePropertyPauseMidi == true) then
					mod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, pausMidiOnLoad)
				end
			end
			
		else
			console(string.format("mod = %s not found!", modName))
		end
	end
	
	return initCount

end



removeSerializeIndexFromUnusedModulators = function ()
	console(string.format("removeSerializeIndexFromUnusedModulators", 0))
	n = panel:getNumModulators()
	for modIndex=0,n-1 do
		mod = panel:getModulatorByIndex (modIndex)
		
		if (mod ~= nil) then

			if (mod:getProperty("serializeIndex") == -1) then
				mod:removeProperty("serializeIndex")
				mod:setProperty("vstIndex", "", false)
			end

		end
 	end

end

setSerializeIndex = function (mod, i)

end

switchLoadingCompleteModulatorToEnd = function(endIndex)

	--endIndex = panel:getNumModulators() -1
	local loadingCompleteMod = panel:getModulatorByName("loadingCompleteMod")
	
	pos = loadingCompleteMod:getProperty("serializeIndex")
	if (pos ~= endIndex) then
		local endMod = panel:getModulatorWithProperty ("serializeIndex", endIndex)
		loadingCompleteMod:setPropertyInt("serializeIndex", endIndex)
		loadingCompleteMod:setPropertyInt("vstIndex", endIndex)
		endMod:setPropertyInt("serializeIndex", pos)
		endMod:setPropertyInt("vstIndex", pos)
		
		loadingCompleteMod:setPropertyInt(propertyNameTriggerModChangeMethodOnLoad, 1)
		
		loadingCompleteModName = loadingCompleteMod:getProperty("name")
		endModName = endMod:getProperty("name")
	else
		loadingCompleteModName = loadingCompleteMod:getProperty("name")
		endModName = loadingCompleteModName
	end
	

	console(string.format("switchLoadingCompleteModulatorToEnd: pos=%d (%s) <-> endIndex=%d (%s) with a total number of=%d", pos, loadingCompleteModName, endIndex, endModName, panel:getNumModulators()))

end


ClearSerializePropertyIndex = function ()

	console(string.format("ClearSerializePropertyIndex", 0))
	clearValue = -1

	n = panel:getNumModulators()
	for i=0,n-1 do
		mod = panel:getModulatorByIndex(i)
		mod:setPropertyInt("serializeIndex", clearValue)
		mod:setPropertyInt("vstIndex", clearValue)
		mod:setPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad, clearValue)
	end

end