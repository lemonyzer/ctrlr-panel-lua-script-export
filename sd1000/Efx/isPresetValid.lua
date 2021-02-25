function isPresetValid(mod, value)

	--console (string.format("isPresetValid (mod = %s, value = %d) ... mod:getMaxNonMapped() == %d", mod:getProperty("name"), value, mod:getMaxNonMapped()))

	if(mod:getMaxNonMapped() <= 0) then
		showWindowNoValidPreset(mod)
		return false
	end

	if (mod:getMaxNonMapped() <= value) then
		return false
	else	
		return true 
	end

end