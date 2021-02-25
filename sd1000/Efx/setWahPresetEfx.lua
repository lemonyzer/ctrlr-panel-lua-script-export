--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
setWahPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setWahPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_Wah_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_Wah_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_Wah_Preset") then
		efxNum = 3
	else
		console (string.format("setWahPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setWahPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		panel:setPropertyString("panelMidiPauseOut","0")
	end
end 


setWahPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setWahPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))
	
	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setWahPresetEfx_")
		return
	end

	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x50					--	Insert MFX Wah-Wah Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage( nrpnHigh, nrpnLow, data )
	end

	-- disable Midi Messages

	-- Update UI (Slider = Parameter values)
	setWahPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell

	-- Set Combobox to Custom

	-- enable Midi Messages
end


setWahPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setWahPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", tonumber(efxNum,10), tonumber(valueMapped,10), tostring(midiOutputEnabled)))

    panel:setPropertyString("panelMidiPauseOut","1")

    --preset    = panel : getModulatorByName("Efx_Wah_Preset"):getModulatorValue()
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_Wah_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)
	
	filterTypeModName = string.format("Efx%d_Wah_Type", efxNum)
	frequencyModName = string.format("Efx%d_Wah_Position", efxNum)
	resonanceModName = string.format("Efx%d_Wah_Resonance", efxNum)
	sensitivityModName = string.format("Efx%d_Wah_Sensitivity", efxNum)

    filterType = panel : getModulatorByName(filterTypeModName)
    frequency = panel : getModulatorByName(frequencyModName)
    resonance = panel : getModulatorByName(resonanceModName)
    sensitivity = panel : getModulatorByName(sensitivityModName)

	wahPresetLabelModName = string.format("Efx%d_Wah_Current_Preset", efxNum)
	wahPresetListModName = string.format("Efx%d_Wah_Preset", efxNum)
	
	-- update Label to current Preset Name 
	setEfxPresetLabel(wahPresetLabelModName, wahPresetListModName, valueMapped)


    if(preset==0)then

    filterType : setModulatorValue((0),false,false, false)
    frequency : setModulatorValue((127),false,false, false)
    resonance : setModulatorValue((0),false,false, false)
    sensitivity : setModulatorValue((0),false,false, false)

    elseif(preset==1)then
    filterType : setModulatorValue((0),false,false, false)
    frequency : setModulatorValue((67),false,false, false)
    resonance : setModulatorValue((107),false,false, false)
    sensitivity : setModulatorValue((127),false,false, false)

    elseif(preset==2)then
    filterType : setModulatorValue((0),false,false, false)
    frequency : setModulatorValue((50),false,false, false)
    resonance : setModulatorValue((75),false,false, false)
    sensitivity : setModulatorValue((127),false,false, false)

    elseif(preset==3)then
    filterType : setModulatorValue((1),false,false, false)
    frequency : setModulatorValue((70),false,false, false)
    resonance : setModulatorValue((100),false,false, false)
    sensitivity : setModulatorValue((100),false,false, false)

    elseif(preset==4)then
    filterType : setModulatorValue((0),false,false, false)
    frequency : setModulatorValue((127),false,false, false)
    resonance : setModulatorValue((80),false,false, false)
    sensitivity : setModulatorValue((0),false,false, false)

    elseif(preset==5)then
    filterType : setModulatorValue((1),false,false, false)
    frequency : setModulatorValue((64),false,false, false)
    resonance : setModulatorValue((80),false,false, false)
    sensitivity : setModulatorValue((0),false,false, false)

    end

    panel:setPropertyString("panelMidiPauseOut","0")

    end


