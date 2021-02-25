--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
    -- @value    new numeric value of the modulator
--
setModPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setModPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_Mod_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_Mod_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_Mod_Preset") then
		efxNum = 3
	else
		console (string.format("setModPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setModPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		panel:setPropertyString("panelMidiPauseOut","0")
	end
end 


setModPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setModPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))

	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setModPresetEfx_")
		return
	end

	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x30					--	Insert MFX Chorus/Flanger/Phaser/Tremolo/Rotary Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage( nrpnHigh, nrpnLow, data )
	end

	-- disable Midi Messages

	-- Update UI (Slider = Parameter values)
	setModPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell

	-- Set Combobox to Custom

	-- enable Midi Messages
end


setModPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setModPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", tonumber(efxNum,10), tonumber(valueMapped,10), tostring(midiOutputEnabled)))

	panel:setPropertyString("panelMidiPauseOut","1")

    --preset = panel : getModulatorByName("Efx%d_Mod_Preset"):getModulatorValue()
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_Mod_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)
	
	onOffButtonModName = string.format("Efx%d_Mod_On", efxNum)
	volumeModName = string.format("Efx%d_Mod_Level",efxNum)
	delayModName = string.format("Efx%d_Mod_Time",efxNum)
	feedbackModName = string.format("Efx%d_Mod_Feedback",efxNum)
	hdamphModName = string.format("Efx%d_Mod_Hdamp",efxNum)
	rateModName = string.format("Efx%d_Mod_Rate",efxNum)
	depthModName = string.format("Efx%d_Mod_Depth",efxNum)

	-- Firm5716-EK documented On/Off Control
	onOffButton = panel:getModulatorByName(onOffButtonModName)

--	undokumented Control -> disable!
	shapeModName = string.format("Efx%d_Mod_Shape",efxNum)
	shapeMod = panel : getModulatorByName(shapeModName)
	shapeMod : getComponent() : setProperty ("componentDisabled", 1, false)
	setModulatorMidiMessageType (shapeMod, "9")
	
	
	preHighPassFilterModName = string.format("Efx%d_Mod_Filter",efxNum)

    volume = panel : getModulatorByName(volumeModName)
    delay = panel : getModulatorByName(delayModName)
    feedback = panel : getModulatorByName(feedbackModName)
    hdamph = panel : getModulatorByName(hdamphModName)
    rate = panel : getModulatorByName(rateModName)
    depth = panel : getModulatorByName(depthModName)
	
	preHighPassFilter = panel : getModulatorByName(preHighPassFilterModName)

-- Preset 23: Rotary Slow Controls
	rotarySpeedModName = string.format("Efx%d_Mod_Speed",efxNum)
	rotaryModulationRateModName = string.format("Efx%d_Mod_Rotary_Fast_Mod_Rate",efxNum)
	rotaryAccelerationTimeModName = string.format("Efx%d_Mod_Rotary_Acc_Time",efxNum)
	rotaryDecelerationTimeModName = string.format("Efx%d_Mod_Rotary_Dec_Time",efxNum)

	rotarySpeed = panel : getModulatorByName(rotarySpeedModName)
	rotaryModulationRate = panel : getModulatorByName(rotaryModulationRateModName)
	rotaryAccelerationTime = panel : getModulatorByName(rotaryAccelerationTimeModName)
	rotaryDecelerationTime = panel : getModulatorByName(rotaryDecelerationTimeModName)
	
	if (preset == 23) then
		isNonRotaryPreset = 0
	else
		isNonRotaryPreset = 1
	end

	rotarySpeed : getComponent() : setProperty ("componentDisabled", isNonRotaryPreset, false)
	--rotaryModulationRate : getComponent() : setProperty ("componentDisabled", isNonRotaryPreset, false)
	--rotaryAccelerationTime : getComponent() : setProperty ("componentDisabled", isNonRotaryPreset, false)
	--rotaryDecelerationTime : getComponent() : setProperty ("componentDisabled", isNonRotaryPreset, false)
--

	-- Values for all Presets
	-- Preset value for Pre-High-pass-Filter is always 0 (off). 
	preHighPassFilter : setModulatorValue((0),false,false, false)

	-- update Label to current Preset Name 
	PresetLabelModName = string.format("Efx%d_Mod_Current_Preset", efxNum)
	PresetListModName = string.format("Efx%d_Mod_Preset", efxNum)
	setEfxPresetLabel(PresetLabelModName, PresetListModName, valueMapped)

	if(preset == 0) then
		onOffButton:setModulatorValue((0),false,false, false)
	else 
		onOffButton:setModulatorValue((1),false,false, false)
	end


    if(preset==0)then
		volume: setModulatorValue((0),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((0),false,false, false)
		depth:setModulatorValue((0),false,false, false)

    elseif(preset==1)then
		volume: setModulatorValue((56),false,false, false)
		delay:setModulatorValue((20),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((40),false,false, false)
		depth:setModulatorValue((30),false,false, false)

    elseif(preset==2)then
		volume: setModulatorValue((56),false,false, false)
		delay:setModulatorValue((40),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((30),false,false, false)
		depth:setModulatorValue((30),false,false, false)

    elseif(preset==3)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((26),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((45),false,false, false)
		depth:setModulatorValue((40),false,false, false)

    elseif(preset==4)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((60),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((35),false,false, false)
		depth:setModulatorValue((50),false,false, false)

    elseif(preset==5)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((64),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((40),false,false, false)
		depth:setModulatorValue((70),false,false, false)

    elseif(preset==6)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((80),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((45),false,false, false)
		depth:setModulatorValue((90),false,false, false)

    elseif(preset==7)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((30),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((70),false,false, false)
		depth:setModulatorValue((10),false,false, false)

    elseif(preset==8)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((60),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((60),false,false, false)
		depth:setModulatorValue((20),false,false, false)

    elseif(preset==9)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((30),false,false, false)
		feedback:setModulatorValue((80),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((40),false,false, false)
		depth:setModulatorValue((20),false,false, false)

    elseif(preset==10)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((100),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((20),false,false, false)
		depth:setModulatorValue((20),false,false, false)

    elseif(preset==11)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((8),false,false, false)
		feedback:setModulatorValue((32),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((30),false,false, false)
		depth:setModulatorValue((30),false,false, false)

    elseif(preset==12)then
		volume: setModulatorValue((72),false,false, false)
		delay:setModulatorValue((13),false,false, false)
		feedback:setModulatorValue((72),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((40),false,false, false)
		depth:setModulatorValue((90),false,false, false)

    elseif(preset==13)then
		volume: setModulatorValue((72),false,false, false)
		delay:setModulatorValue((2),false,false, false)
		feedback:setModulatorValue((50),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((20),false,false, false)
		depth:setModulatorValue((90),false,false, false)

    elseif(preset==14)then
		volume: setModulatorValue((72),false,false, false)
		delay:setModulatorValue((6),false,false, false)
		feedback:setModulatorValue((100),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((50),false,false, false)
		depth:setModulatorValue((100),false,false, false)

    elseif(preset==15)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((80),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((50),false,false, false)
		depth:setModulatorValue((50),false,false, false)

    elseif(preset==16)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((90),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((60),false,false, false)
		depth:setModulatorValue((80),false,false, false)

    elseif(preset==17)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((100),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((20),false,false, false)
		depth:setModulatorValue((110),false,false, false)

    elseif(preset==18)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((40),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((120),false,false, false)
		depth:setModulatorValue((60),false,false, false)

    elseif(preset==19)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((20),false,false, false)
		depth:setModulatorValue((60),false,false, false)

    elseif(preset==20)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((20),false,false, false)
		rate:setModulatorValue((40),false,false, false)
		depth:setModulatorValue((70),false,false, false)

    elseif(preset==21)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((40),false,false, false)
		rate:setModulatorValue((60),false,false, false)
		depth:setModulatorValue((90),false,false, false)

    elseif(preset==22)then
		volume: setModulatorValue((64),false,false, false)
		delay:setModulatorValue((0),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((60),false,false, false)
		rate:setModulatorValue((100),false,false, false)
		depth:setModulatorValue((110),false,false, false)

    elseif(preset==23)then
		volume: setModulatorValue((90),false,false, false)
		delay:setModulatorValue((30),false,false, false)
		feedback:setModulatorValue((0),false,false, false)
		hdamph:setModulatorValue((0),false,false, false)
		rate:setModulatorValue((50),false,false, false)
		depth:setModulatorValue((20),false,false, false)

    end

    panel:setPropertyString("panelMidiPauseOut","0")

end