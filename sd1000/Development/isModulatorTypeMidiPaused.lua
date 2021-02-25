function isModulatorTypeMidiPaused (mod, modName)


	for i=1,3 do
		currentEfxCompareString = string.format("Efx%d_", i)
		if (String(modName):startsWith(currentEfxCompareString)) then
		
			-- "Efx1_Mix"
			--  0123456
			strLen = String(modName):length()
			group = String(modName):substring(5, strLen)
			if (String(group):startsWith ("Mix")) then
				groupName = "Mix"
			elseif (String(group):startsWith ("EQ")) then
				groupName = "EQ"
			elseif (String(group):startsWith ("Dist")) then
				groupName = "Dist"
			elseif (String(group):startsWith ("Mod")) then
				groupName = "Mod"
			elseif (String(group):startsWith ("Wah")) then
				groupName = "Wah"
			elseif (String(group):startsWith ("Comp")) then
				groupName = "CompLimit"
			elseif (String(group):startsWith ("Delay")) then
				groupName = "Delay"
			else
				groupName = "Other"
				--unhandledGroupName = MemoryBlock(group):toString()	-- wrong format 
				--unhandledGroupName = group:__add("")
				unhandledGroupName = group
				console (string.format("xxxxmod=%sxxxx should not happen xxxxxxxx groupName = %s", mod:getProperty("name"), unhandledGroupName))
			end
			
			return getGroupMidiPauseSetting (groupName)
				
		end
	end
	
	currentCompareString = "HQ_"
	groupName = "HQDist"
	if (String(modName):startsWith(currentCompareString)) then
		return getGroupMidiPauseSetting (groupName)
	end
	
	masterControls = { "Reverb", "Chorus", "Portamento", "Pedal"}
	
	for key,value in ipairs(masterControls) do
		currentMasterCompareString = string.format("MA_%s", value)
		if (String(modName):startsWith(currentMasterCompareString)) then
			groupName = value
			return getGroupMidiPauseSetting (groupName)
		end
	end
	
	currentCompareString = "MA_"
	groupName = "MA"
	if (String(modName):startsWith(currentCompareString)) then
		return getGroupMidiPauseSetting (groupName)
	end
	
	modPausePropertyValue = mod:getPropertyInt(propertyNamePauseMidiDuringModChangeOnLoad)
	if (modPausePropertyValue ~= nil) then
		console (string.format("%s no group found, use PauseProperty=%d", modName, modPausePropertyValue))
		return modPausePropertyValue
	else
		console (string.format("%s no group found, PAUSE MIDI = true", modName))
		return 1
	end
end


getGroupMidiPauseSetting = function (groupName)

		groupSettingMod = panel : getModulatorByName (string.format("dev_MIDI_Enable_%s", groupName))
		groupValue = groupSettingMod : getModulatorValue ()
		
		if (groupValue == 1) then
			return 0					-- send enabled, pause = 0
		else
			return 1					-- send disabled, pause = 1
		end
		
end