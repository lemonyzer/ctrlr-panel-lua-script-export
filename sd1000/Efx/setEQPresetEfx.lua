--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
setEQPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setEQPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_EQ_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_EQ_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_EQ_Preset") then
		efxNum = 3
	else
		console (string.format("setEQPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setEQPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		panel:setPropertyString("panelMidiPauseOut","0")
	end
end


setEQPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setEQPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))

	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setEQPresetEfx_")
		return
	end

	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x70					--	Insert MFX AMP-Model Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage (nrpnHigh, nrpnLow, data)
	end

	-- disable Midi Messages

	-- Update UI (Slider = Parameter values)
	setEQPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell

	-- Set Combobox to Custom

	-- enable Midi Messages
end


setEQPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setEQPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", tonumber(efxNum,10), tonumber(valueMapped,10), tostring(midiOutputEnabled)))

    panel:setPropertyString("panelMidiPauseOut","1")

    --preset = panel : getModulatorByName("Efx%d_EQ_Preset"):getModulatorValue()
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_EQ_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)
	
	onOffButtonModName = string.format("Efx%d_EQ_On",efxNum)
	
	lowGainModName = string.format("Efx%d_EQ_LowGain",efxNum)
	lowMidGainModName = string.format("Efx%d_EQ_LowMidGain",efxNum)
	HighMidGainModName = string.format("Efx%d_EQ_HighMidGain",efxNum)
	HighGainModName = string.format("Efx%d_EQ_HighGain",efxNum)
	
	lowGainSliderModName = string.format("Efx%d_EQ_LowGain_Slider",efxNum)
	lowMidGainSliderModName = string.format("Efx%d_EQ_LowMidGain_Slider",efxNum)
	HighMidGainSliderModName = string.format("Efx%d_EQ_HighMidGain_Slider",efxNum)
	HighGainSliderModName = string.format("Efx%d_EQ_HighGain_Slider",efxNum)
	
	lowFreqModName = string.format("Efx%d_EQ_LowFreq",efxNum)
	lowMidFreqModName = string.format("Efx%d_EQ_LowMidFreq",efxNum)
	highMidFreqModName = string.format("Efx%d_EQ_HighMidFreq",efxNum)
	highFreqModName = string.format("Efx%d_EQ_HighFreq",efxNum)
	lowMidQModName = string.format("Efx%d_EQ_LowMidQ",efxNum)
	highMidQModName = string.format("Efx%d_EQ_HighMidQ",efxNum)
	
	onOffButton = panel : getModulatorByName(onOffButtonModName)
	
    lowGain = panel : getModulatorByName(lowGainModName)
    lowMidGain= panel : getModulatorByName(lowMidGainModName)
    HighMidGain= panel : getModulatorByName(HighMidGainModName)
    HighGain= panel : getModulatorByName(HighGainModName)

    lowGainSlider = panel : getModulatorByName(lowGainSliderModName)
    lowMidGainSlider= panel : getModulatorByName(lowMidGainSliderModName)
    HighMidGainSlider= panel : getModulatorByName(HighMidGainSliderModName)
    HighGainSlider= panel : getModulatorByName(HighGainSliderModName)

    lowFreq= panel : getModulatorByName(lowFreqModName)
    lowMidFreq= panel : getModulatorByName(lowMidFreqModName)
    highMidFreq= panel : getModulatorByName(highMidFreqModName)
    highFreq= panel : getModulatorByName(highFreqModName)
    lowMidQ= panel : getModulatorByName(lowMidQModName)
    highMidQ= panel : getModulatorByName(highMidQModName)

	-- update Label to current Preset Name 
	PresetLabelModName = string.format("Efx%d_EQ_Current_Preset", efxNum)
	PresetListModName = string.format("Efx%d_EQ_Preset", efxNum)
	setEfxPresetLabel(PresetLabelModName, PresetListModName, valueMapped)

    if (preset >= 0) then
    	onOffButton:setModulatorValue((1), false, false, false)
    end

    if(preset==0)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((64),false,false, false)
    HighMidGain:setModulatorValue((64),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((64),false,false, false)
    HighMidGainSlider:setModulatorValue((64),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((24),false,false, false)
    highMidFreq:setModulatorValue((64),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((0),false,false, false)
    highMidQ:setModulatorValue((64),false,false, false)


    elseif(preset==1)then
    lowGain:setModulatorValue((80),false,false, false)
    lowMidGain:setModulatorValue((30),false,false, false)
    HighMidGain:setModulatorValue((90),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((80),false,false, false)
    lowMidGainSlider:setModulatorValue((30),false,false, false)
    HighMidGainSlider:setModulatorValue((90),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((20),false,false, false)
    highMidFreq:setModulatorValue((50),false,false, false)
    highFreq:setModulatorValue((60),false,false, false)
    lowMidQ:setModulatorValue((0),false,false, false)
    highMidQ:setModulatorValue((80),false,false, false)


    elseif(preset==2)then
    lowGain:setModulatorValue((90),false,false, false)
    lowMidGain:setModulatorValue((20),false,false, false)
    HighMidGain:setModulatorValue((110),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((90),false,false, false)
    lowMidGainSlider:setModulatorValue((20),false,false, false)
    HighMidGainSlider:setModulatorValue((110),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((26),false,false, false)
    highMidFreq:setModulatorValue((113),false,false, false)
    highFreq:setModulatorValue((50),false,false, false)
    lowMidQ:setModulatorValue((30),false,false, false)
    highMidQ:setModulatorValue((100),false,false, false)


    elseif(preset==3)then
    lowGain:setModulatorValue((80),false,false, false)
    lowMidGain:setModulatorValue((40),false,false, false)
    HighMidGain:setModulatorValue((90),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((80),false,false, false)
    lowMidGainSlider:setModulatorValue((40),false,false, false)
    HighMidGainSlider:setModulatorValue((90),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((28),false,false, false)
    highMidFreq:setModulatorValue((30),false,false, false)
    highFreq:setModulatorValue((40),false,false, false)
    lowMidQ:setModulatorValue((0),false,false, false)
    highMidQ:setModulatorValue((40),false,false, false)


    elseif(preset==4)then
    lowGain:setModulatorValue((60),false,false, false)
    lowMidGain:setModulatorValue((80),false,false, false)
    HighMidGain:setModulatorValue((80),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((60),false,false, false)
    lowMidGainSlider:setModulatorValue((80),false,false, false)
    HighMidGainSlider:setModulatorValue((80),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((100),false,false, false)
    lowMidFreq:setModulatorValue((64),false,false, false)
    highMidFreq:setModulatorValue((7),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((0),false,false, false)
    highMidQ:setModulatorValue((30),false,false, false)


    elseif(preset==5)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((30),false,false, false)
    HighMidGain:setModulatorValue((80),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((30),false,false, false)
    HighMidGainSlider:setModulatorValue((80),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((50),false,false, false)
    lowMidFreq:setModulatorValue((42),false,false, false)
    highMidFreq:setModulatorValue((28),false,false, false)
    highFreq:setModulatorValue((60),false,false, false)
    lowMidQ:setModulatorValue((100),false,false, false)
    highMidQ:setModulatorValue((20),false,false, false)


    elseif(preset==6)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((20),false,false, false)
    HighMidGain:setModulatorValue((85),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((20),false,false, false)
    HighMidGainSlider:setModulatorValue((85),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((80),false,false, false)
    lowMidFreq:setModulatorValue((40),false,false, false)
    highMidFreq:setModulatorValue((30),false,false, false)
    highFreq:setModulatorValue((40),false,false, false)
    lowMidQ:setModulatorValue((20),false,false, false)
    highMidQ:setModulatorValue((40),false,false, false)


    elseif(preset==7)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((50),false,false, false)
    HighMidGain:setModulatorValue((100),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((50),false,false, false)
    HighMidGainSlider:setModulatorValue((100),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((80),false,false, false)
    lowMidFreq:setModulatorValue((50),false,false, false)
    highMidFreq:setModulatorValue((35),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((0),false,false, false)
    highMidQ:setModulatorValue((70),false,false, false)

    elseif(preset==8)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((20),false,false, false)
    HighMidGain:setModulatorValue((70),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((20),false,false, false)
    HighMidGainSlider:setModulatorValue((70),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((80),false,false, false)
    lowMidFreq:setModulatorValue((30),false,false, false)
    highMidFreq:setModulatorValue((30),false,false, false)
    highFreq:setModulatorValue((80),false,false, false)
    lowMidQ:setModulatorValue((30),false,false, false)
    highMidQ:setModulatorValue((50),false,false, false)


    elseif(preset==9)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((20),false,false, false)
    HighMidGain:setModulatorValue((75),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((20),false,false, false)
    HighMidGainSlider:setModulatorValue((75),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((32),false,false, false)
    highMidFreq:setModulatorValue((25),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((64),false,false, false)
    highMidQ:setModulatorValue((50),false,false, false)


    elseif(preset==10)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((75),false,false, false)
    HighMidGain:setModulatorValue((30),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)
    lowFreq:setModulatorValue((40),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((75),false,false, false)
    HighMidGainSlider:setModulatorValue((30),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)
    lowFreq:setModulatorValue((40),false,false, false)

    lowMidFreq:setModulatorValue((10),false,false, false)
    highMidFreq:setModulatorValue((8),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((20),false,false, false)
    highMidQ:setModulatorValue((70),false,false, false)


    elseif(preset==11)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((64),false,false, false)
    HighMidGain:setModulatorValue((90),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((64),false,false, false)
    HighMidGainSlider:setModulatorValue((90),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowMidFreq:setModulatorValue((20),false,false, false)
    highMidFreq:setModulatorValue((30),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((64),false,false, false)
    highMidQ:setModulatorValue((60),false,false, false)


    elseif(preset==12)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((64),false,false, false)
    HighMidGain:setModulatorValue((70),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((64),false,false, false)
    HighMidGainSlider:setModulatorValue((70),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((20),false,false, false)
    highMidFreq:setModulatorValue((64),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((64),false,false, false)
    highMidQ:setModulatorValue((64),false,false, false)


    elseif(preset==13)then
    lowGain:setModulatorValue((64),false,false, false)
    lowMidGain:setModulatorValue((80),false,false, false)
    HighMidGain:setModulatorValue((50),false,false, false)
    HighGain:setModulatorValue((64),false,false, false)

    lowGainSlider:setModulatorValue((64),false,false, false)
    lowMidGainSlider:setModulatorValue((80),false,false, false)
    HighMidGainSlider:setModulatorValue((50),false,false, false)
    HighGainSlider:setModulatorValue((64),false,false, false)

    lowFreq:setModulatorValue((40),false,false, false)
    lowMidFreq:setModulatorValue((10),false,false, false)
    highMidFreq:setModulatorValue((6),false,false, false)
    highFreq:setModulatorValue((127),false,false, false)
    lowMidQ:setModulatorValue((80),false,false, false)
    highMidQ:setModulatorValue((70),false,false, false)
    end

    panel:setPropertyString("panelMidiPauseOut","0")

    end