--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
setAmpPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setAmpPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_Mix_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_Mix_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_Mix_Preset") then
		efxNum = 3
	else
		console (string.format("setAmpPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setAmpPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		--panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		--panel:setPropertyString("panelMidiPauseOut","0")
	else
		if(mod:getMaxNonMapped() < value) then
			setEfxPresetLabel(string.format("Efx%d_Mix_Current_Preset", efxNum), "Custom")
		end
	end
end


setAmpPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setAmpPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))
	
	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setAmpPresetEfx_")
		return
	end
		
	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x20					--	Insert MFX AMP-Model Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage (nrpnHigh,nrpnLow,data)
	end

	setAmpPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell
end


setAmpPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setAmpPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))
    panel:setPropertyString("panelMidiPauseOut","1")

    --preset = panel : getModulatorByName("Efx1_Mix_Preset"):getModulatorValue()
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_Mix_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)

	-- update Label to current Preset Name 
	PresetLabelModName = string.format("Efx%d_Mix_Current_Preset", efxNum)
	PresetListModName = string.format("Efx%d_Mix_Preset", efxNum)
	setEfxPresetLabel(PresetLabelModName, PresetListModName, valueMapped)

    inputGain= panel : getModulatorByName(string.format("Efx%d_Mix_Gain", efxNum))
    loCutFreq= panel : getModulatorByName(string.format("Efx%d_Mix_LoCutFreq", efxNum))
    hiCutFreq= panel : getModulatorByName(string.format("Efx%d_Mix_HiCutFreq", efxNum))
    compPreset= panel : getModulatorByName(string.format("Efx%d_CompLimit_Preset", efxNum))
    distPreset= panel : getModulatorByName(string.format("Efx%d_Dist_Preset", efxNum))
    WahPreset= panel : getModulatorByName(string.format("Efx%d_Wah_Preset", efxNum))
    eqPreset= panel : getModulatorByName(string.format("Efx%d_EQ_Preset", efxNum))

	outputLevel = panel : getModulatorByName(string.format("Efx%d_Mix_OutputLevel", efxNum))
	outputLevel : setModulatorValue((127),false,false, false)

    if(preset==0)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((0),false,false, false)
        hiCutFreq:setModulatorValue((127),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((0),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((0),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,0,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,0,false)

    elseif(preset==1)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((25),false,false, false)
        hiCutFreq:setModulatorValue((90),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((0),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((1),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,0,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,1,false)

    elseif(preset==2)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((40),false,false, false)
        hiCutFreq:setModulatorValue((127),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((1),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((2),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,1,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,2,false)

    elseif(preset==3)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((25),false,false, false)
        hiCutFreq:setModulatorValue((90),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((2),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((3),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,2,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,3,false)

    elseif(preset==4)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((40),false,false, false)
        hiCutFreq:setModulatorValue((70),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((9),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((4),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,9,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,4,false)

    elseif(preset==5)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((30),false,false, false)
        hiCutFreq:setModulatorValue((80),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((8),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((5),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,8,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,5,false)

    elseif(preset==6)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((40),false,false, false)
        hiCutFreq:setModulatorValue((80),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((7),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((6),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,7,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,6,false)

    elseif(preset==7)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((30),false,false, false)
        hiCutFreq:setModulatorValue((70),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((12),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((7),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,12,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,7,false)

    elseif(preset==8)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((30),false,false, false)
        hiCutFreq:setModulatorValue((70),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((13),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((8),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,13,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,8,false)

    elseif(preset==9)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((30),false,false, false)
        hiCutFreq:setModulatorValue((70),false,false, false)

        --compPreset:setModulatorValue((1),false,false, false)
        --distPreset:setModulatorValue((12),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((9),false,false, false)
		setCompPresetEfx_Parameters(efxNum,1,false)
		setDistPresetEfx_Parameters(efxNum,12,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,9,false)

    elseif(preset==10)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((20),false,false, false)
        hiCutFreq:setModulatorValue((80),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((7),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((10),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,7,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,10,false)

    elseif(preset==11)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((20),false,false, false)
        hiCutFreq:setModulatorValue((80),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((7),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((11),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,7,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,11,false)

    elseif(preset==12)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((20),false,false, false)
        hiCutFreq:setModulatorValue((80),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((8),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((12),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,8,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,12,false)

    elseif(preset==13)then
        inputGain:setModulatorValue((90),false,false, false)
        loCutFreq:setModulatorValue((20),false,false, false)
        hiCutFreq:setModulatorValue((80),false,false, false)

        --compPreset:setModulatorValue((0),false,false, false)
        --distPreset:setModulatorValue((9),false,false, false)
        --WahPreset:setModulatorValue((0),false,false, false)
        --eqPreset:setModulatorValue((13),false,false, false)
		setCompPresetEfx_Parameters(efxNum,0,false)
		setDistPresetEfx_Parameters(efxNum,9,false)
		setWahPresetEfx_Parameters(efxNum,0,false)
		setEQPresetEfx_Parameters(efxNum,13,false)
    end


    panel:setPropertyString("panelMidiPauseOut","0")

    end
