function setEfxPresetLabel(labelModName, comboModName, valueMapped)

--	console (string.format ("setEfxPresetLabel (labelModName = %s, comboModName = %s, valueMapped = %d)", labelModName, comboModName, tonumber(valueMapped,10)))

	currentPresetLabel = panel : getModulatorByName(labelModName) : getComponent ()
	currentPresetCombo = panel : getModulatorByName(comboModName) : getComponent ()
	if currentPresetCombo ~= nil then

	else
		console ("presetCombo ==  NIL")
		return
	end

	valueMap = currentPresetCombo : getValueMap ()
	if valueMap ~= nil then

	else
		console ("valueMap ==  NIL")
		return
	end
	

	index = valueMap : getIndexForValue (valueMapped)
--	console ("index =" .. index .. " for mapped Value = " .. valueMapped)
	presetName = valueMap : getTextForIndex(index)
	if presetName ~= nil then

	else
		console ("presetName ==  NIL")
		return
	end
	--error --console ("presetName = " .. presetName)				-- error
	--error --console ("presetName = " .. String(presetName))		-- error
	--error --console ("presetName = " .. presetName .. " @index =" .. string.format("%d",index) .. " for mapped Value = " .. string.format("%d",valueMapped))
--	console ("@index = " .. index)
--	console ("mappedValue = " .. valueMapped)

	-- set Label Component Text
	currentPresetLabel:setText(presetName)

end