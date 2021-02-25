--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
setDelayPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setDelayPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_Delay_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_Delay_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_Delay_Preset") then
		efxNum = 3
	else
		console (string.format("setDelayPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setDelayPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		panel:setPropertyString("panelMidiPauseOut","0")
	end
end 


setDelayPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setDelayPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))

	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setDelayPresetEfx_")
		return
	end
	
	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x58					--	Insert MFX Delay Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage( nrpnHigh, nrpnLow, data )
	end

	-- disable Midi Messages

	-- Update UI (Slider = Parameter values)
	setDelayPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell

	-- Set Combobox to Custom

	-- enable Midi Messages
end


setDelayPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setDelayPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", tonumber(efxNum,10), tonumber(valueMapped,10), tostring(midiOutputEnabled)))

    panel:setPropertyString("panelMidiPauseOut","1")

    --preset = panel : getModulatorByName("Efx%d_Delay_Preset"):getModulatorValue()
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_Delay_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)
	
	onOffButtonModName = string.format("Efx%d_Delay_On",efxNum)
	modeModName = string.format("Efx%d_Delay_Mode",efxNum)
	levelModName = string.format("Efx%d_Delay_Level",efxNum)
	delayTimeModName = string.format("Efx%d_Delay_Time",efxNum)
	feedbackModName = string.format("Efx%d_Delay_Feedback",efxNum)
	hdampModName = string.format("Efx%d_Delay_Hdamp",efxNum)
	preLowPassModName = string.format("Efx%d_Delay_PreLp",efxNum)

    mode = panel : getModulatorByName(modeModName)
    level = panel : getModulatorByName(levelModName)
    delayTime = panel : getModulatorByName(delayTimeModName)
    feedback = panel : getModulatorByName(feedbackModName)
	hdamp = panel : getModulatorByName(hdampModName)
	preLowPass = panel : getModulatorByName(preLowPassModName)
	
	onOffButton = panel : getModulatorByName(onOffButtonModName)

	-- Values for all Presets
	hdamp : setModulatorValue((0),false,false, false)
	preLowPass : setModulatorValue((127),false,false, false)

	-- update Label to current Preset Name 
	PresetLabelModName = string.format("Efx%d_Delay_Current_Preset", efxNum)
	PresetListModName = string.format("Efx%d_Delay_Preset", efxNum)
	setEfxPresetLabel(PresetLabelModName, PresetListModName, valueMapped)

    if(preset == 0) then
        onOffButton:setModulatorValue((0), false, false, false)
    else
        onOffButton:setModulatorValue((1), false, false, false)
    end

    if(preset==0)then
		mode : setModulatorValue((0),false,false, false)
		level : setModulatorValue((0),false,false, false)
		delayTime : setModulatorValue((0),false,false, false)
		feedback : setModulatorValue((0),false,false, false)

    elseif(preset==1)then
		mode : setModulatorValue((0),false,false, false)
		level : setModulatorValue((64),false,false, false)
		delayTime : setModulatorValue((20),false,false, false)
		feedback : setModulatorValue((8),false,false, false)

    elseif(preset==2)then
		mode : setModulatorValue((0),false,false, false)
		level : setModulatorValue((64),false,false, false)
		delayTime : setModulatorValue((35),false,false, false)
		feedback : setModulatorValue((20),false,false, false)

    elseif(preset==3)then
		mode : setModulatorValue((1),false,false, false)
		level : setModulatorValue((64),false,false, false)
		delayTime : setModulatorValue((50),false,false, false)
		feedback : setModulatorValue((16),false,false, false)

    elseif(preset==4)then
		mode : setModulatorValue((1),false,false, false)
		level : setModulatorValue((64),false,false, false)
		delayTime : setModulatorValue((70),false,false, false)
		feedback : setModulatorValue((32),false,false, false)
    end

    panel:setPropertyString("panelMidiPauseOut","0")

    end
