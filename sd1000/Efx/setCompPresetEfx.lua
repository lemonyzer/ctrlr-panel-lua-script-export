--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
setCompPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setCompPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_CompLimit_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_CompLimit_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_CompLimit_Preset") then
		efxNum = 3
	else
		console (string.format("setCompPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setCompPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		panel:setPropertyString("panelMidiPauseOut","0")
	end
end 


setCompPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setCompPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))
	
	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setCompPresetEfx_")
		return
	end

	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x40					--	Insert MFX Compressor/Limiter Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage( nrpnHigh, nrpnLow, data )
	end

	-- disable Midi Messages

	-- Update UI (Slider = Parameter values)
	setCompPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell

	-- Set Combobox to Custom

	-- enable Midi Messages
end


setCompPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	--console (string.format("setCompPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))
	console (string.format("setCompPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", tonumber(efxNum,10), tonumber(valueMapped,10), tostring(midiOutputEnabled)))

    panel:setPropertyString("panelMidiPauseOut","1")

    --preset    = panel : getModulatorByName("Efx_CompLimit_Preset"):getModulatorValue()
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_CompLimit_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)

	onOffButtonModName = string.format("Efx%d_Comp_On",efxNum)
	attackModName = string.format("Efx%d_Comp_Attack",efxNum)
	releaseModName = string.format("Efx%d_Comp_Release",efxNum)
	thresholdModName = string.format("Efx%d_Comp_Threshold",efxNum)
	ratioModName = string.format("Efx%d_Comp_Ratio",efxNum)
	boostModName = string.format("Efx%d_Comp_Boost",efxNum)
	boostSliderModName = string.format("Efx%d_Comp_Boost_Slider",efxNum)
	kneeModName = string.format("Efx%d_Comp_Knee",efxNum)
	
    attack = panel : getModulatorByName(attackModName)
    release = panel : getModulatorByName(releaseModName)
    threshold = panel : getModulatorByName(thresholdModName)
    ratio = panel : getModulatorByName(ratioModName)
    boost = panel : getModulatorByName(boostModName)
	boostSlider = panel : getModulatorByName(boostSliderModName)

    onOffButton = panel : getModulatorByName(onOffButtonModName)

	-- Values for all Presets
	-- Preset value for Compressor Knee value is always 0 (Hard Knee). 
	knee = panel : getModulatorByName(kneeModName)
	knee : setModulatorValue((0),false,false, false)

	-- update Label to current Preset Name 
	compPresetLabelModName = string.format("Efx%d_CompLimit_Current_Preset", efxNum)
	compPresetListModName = string.format("Efx%d_CompLimit_Preset", efxNum)
	setEfxPresetLabel(compPresetLabelModName, compPresetListModName, valueMapped)

    if (preset == 0) then
    	onOffButton:setModulatorValue((0),false,false, false)
    else
        onOffButton:setModulatorValue((1),false,false, false)
    end

    if(preset==0 )then
		attack:setModulatorValue((64),false,false, false)
		release:setModulatorValue((0),false,false, false)
		threshold:setModulatorValue((127),false,false, false)
		ratio:setModulatorValue((0),false,false, false)
		boost:setModulatorValue((0),false,false, false)
		boostSlider:setModulatorValue((0),false,false, false)
	

    elseif(preset==1)then
		attack:setModulatorValue((64),false,false, false)
		release:setModulatorValue((0),false,false, false)
		threshold:setModulatorValue((73),false,false, false)
		ratio:setModulatorValue((64),false,false, false)
		boost:setModulatorValue((1),false,false, false)
		boostSlider:setModulatorValue((24),false,false, false)

    elseif(preset==2)then
		attack:setModulatorValue((64),false,false, false)
		release:setModulatorValue((0),false,false, false)
		threshold:setModulatorValue((82),false,false, false)
		ratio:setModulatorValue((84),false,false, false)
		boost:setModulatorValue((2),false,false, false)
		boostSlider:setModulatorValue((32),false,false, false)

    elseif(preset==3)then
		attack:setModulatorValue((64),false,false, false)
		release:setModulatorValue((0),false,false, false)
		threshold:setModulatorValue((73),false,false, false)
		ratio:setModulatorValue((100),false,false, false)
		boost:setModulatorValue((3),false,false, false)
		boostSlider:setModulatorValue((48),false,false, false)

    elseif(preset==4)then
		attack:setModulatorValue((64),false,false, false)
		release:setModulatorValue((0),false,false, false)
		threshold:setModulatorValue((64),false,false, false)
		ratio:setModulatorValue((110),false,false, false)
		boost:setModulatorValue((3),false,false, false)
		boostSlider:setModulatorValue((48),false,false, false)

    elseif(preset==5)then
		attack:setModulatorValue((64),false,false, false)
		release:setModulatorValue((0),false,false, false)
		threshold:setModulatorValue((55),false,false, false)
		ratio:setModulatorValue((117),false,false, false)
		boost:setModulatorValue((4),false,false, false)
		boostSlider:setModulatorValue((64),false,false, false)

    elseif(preset==6)then
        attack:setModulatorValue((64),false,false, false)
        release:setModulatorValue((0),false,false, false)
        threshold:setModulatorValue((109),false,false, false)
        ratio:setModulatorValue((127),false,false, false)
        boost:setModulatorValue((0),false,false, false)
        boostSlider:setModulatorValue((0),false,false, false)

    elseif(preset==7)then
        attack:setModulatorValue((64),false,false, false)
        release:setModulatorValue((0),false,false, false)
        threshold:setModulatorValue((91),false,false, false)
        ratio:setModulatorValue((127),false,false, false)
        boost:setModulatorValue((0),false,false, false)
        boostSlider:setModulatorValue((0),false,false, false)

    elseif(preset==8)then
        attack:setModulatorValue((64),false,false, false)
        release:setModulatorValue((0),false,false, false)
        threshold:setModulatorValue((73),false,false, false)
        ratio:setModulatorValue((127),false,false, false)
        boost:setModulatorValue((0),false,false, false)
        boostSlider:setModulatorValue((0),false,false, false)

    end

    panel:setPropertyString("panelMidiPauseOut","0")

end