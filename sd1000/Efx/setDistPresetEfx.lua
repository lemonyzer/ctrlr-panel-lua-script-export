--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
setDistPresetEfx = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)

	methodName = "setDistPresetEfx"
	if (loadingStage ~= nil) then 
		if (loadingStage == getStateValueIgnoredAutomatedOnModChangeEvents()) then
			console (string.format("--------->%s is in state: ignored automated onModChange Event == %s - stop Method", methodName, tostring(loadingCompleteFlag)))
			return
		end
	end

	modName = mod:getProperty("name")
	
	efxNum = 0
	if (modName == "Efx1_Dist_Preset") then
		efxNum = 1
	elseif (modName == "Efx2_Dist_Preset") then
		efxNum = 2
	elseif (modName == "Efx3_Dist_Preset") then
		efxNum = 3
	else
		console (string.format("setDistPresetEfx () executed from mod=%s, should not happen!", modName))
		return
	end
	
	valueMapped = mod:getValueMapped()

	--console ("modName == " .. modName)
	--console ("value == " .. value)
	--console ("valueMapped == " .. valueMapped)

	validPreset = isPresetValid(mod, value)

	if validPreset == true then
		setDistPresetEfx_ (efxNum, valueMapped, true)									-- <--- individuell
		panel:setPropertyString("panelMidiPauseOut","1")						-- not needed ? Component MIDI Implementation set to NONE
		mod:setModulatorValue(mod:getMaxNonMapped(),false,false,false)			-- careful: endless loop LAST ITEM NEEDS MAPPED VALUE=99
		panel:setPropertyString("panelMidiPauseOut","0")
	end
end 


setDistPresetEfx_ = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setDistPresetEfx_ (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", efxNum, valueMapped, tostring(midiOutputEnabled)))
	
	if(efxNum < 1 and efxNum > 3) then
		console ("non valid efxNum, break setDistPresetEfx_")
		return
	end

	if (midiOutputEnabled == true) then
		-- Built Message CC/SysEx
		nrpnHigh = 0x3a	+ (efxNum-1)	--	EFX Modul 0x3a, 0x3b, 0x3c
		nrpnLow = 0x60					--	Insert MFX Distortion Presets 
		data = valueMapped				-- 	int value

		-- Send Message
		sendNRPNMessage( nrpnHigh, nrpnLow, data )
	end

	-- disable Midi Messages

	-- Update UI (Slider = Parameter values)
	setDistPresetEfx_Parameters(efxNum, valueMapped, false)								-- <--- individuell

	-- Set Combobox to Custom

	-- enable Midi Messages
end


setDistPresetEfx_Parameters = function (efxNum, valueMapped, midiOutputEnabled)

	console (string.format("setDistPresetEfx_Parameters (efxNum=%d, valueMapped=%d, midiOutputEnabled=%s)", tonumber(efxNum,10), tonumber(valueMapped,10), tostring(midiOutputEnabled)))

	panel:setPropertyString("panelMidiPauseOut","1")

	--preset = panel : getModulatorByName("Efx1_Dist_Preset"):getModulatorValue()	-- 0x60 == 96
	preset = valueMapped

	PresetValueModName = string.format("Efx%d_Dist_Preset_Value", efxNum)
	PresetValueMod = panel : getModulatorByName(PresetValueModName)
	PresetValueMod : setModulatorValue (preset, false, false, false)
	
	onOffButtonModName = string.format("Efx%d_Dist_On", efxNum)
	preGainModName = string.format("Efx%d_Dist_PreGain", efxNum)
	typeModName = string.format("Efx%d_Dist_Type", efxNum)
	hiCutModName = string.format("Efx%d_Dist_FilterFreq", efxNum)					-- low pass filter frequency == High-Cut Filter Frequency
	resoModName = string.format("Efx%d_Dist_FilterReso", efxNum)					-- low pass filter resonance == Low Lev Cut
	postGainModName = string.format("Efx%d_Dist_PostGain", efxNum)
	driveModName = string.format("Efx%d_Dist_Drive", efxNum)
	rCModName = string.format("Efx%d_Dist_Rc", efxNum)								-- RC type low pass filter value == RC LP Filter

	onOffButton = panel:getModulatorByName(onOffButtonModName)	-- 0x61 == 97

	preGain= panel : getModulatorByName(preGainModName)			-- 0x62 == 98		-- <-- OK
	distType= panel : getModulatorByName(typeModName)			-- 0x63 == 99		-- <-- OK
	hiCut= panel : getModulatorByName(hiCutModName)				-- 0x64 == 100
	reso= panel : getModulatorByName(resoModName)				-- 0x65 == 101
	postGain= panel : getModulatorByName(postGainModName)		-- 0x66 == 102		-- <-- OK
	drive= panel : getModulatorByName(driveModName)				-- 0x67 == 103		-- <-- OK
	rC= panel : getModulatorByName(rCModName)					-- 0x68 == 104

	-- Values for all Presets
	-- Preset value for Hi-Cut Filter Q is always 0. 				-- https://de.wikipedia.org/wiki/G%C3%BCtefaktor
	--preHighPassFilter : setModulatorValue((0),false,false, false)
	
	distPresetLabelModName = string.format("Efx%d_Dist_Current_Preset", efxNum)
	distPresetListModName = string.format("Efx%d_Dist_Preset", efxNum)

	-- update Label to current Preset Name 
	setEfxPresetLabel(distPresetLabelModName, distPresetListModName, valueMapped)

	if(preset == 0) then
		onOffButton:setModulatorValue((0),false,false, false)
	else 
		onOffButton:setModulatorValue((1),false,false, false)
	end

if(preset==0)then
	drive:setModulatorValue((0),false,false, false)
	distType:setModulatorValue((0),false,false, false)
	hiCut:setModulatorValue((127),false,false, false)
	postGain:setModulatorValue((127),false,false, false)
	preGain:setModulatorValue((127),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((0),false,false, false)

elseif(preset==1)then
	drive:setModulatorValue((3),false,false, false)
	distType:setModulatorValue((1),false,false, false)
	hiCut:setModulatorValue((100),false,false, false)
	postGain:setModulatorValue((60),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((1),false,false, false)

elseif(preset==2)then
	drive:setModulatorValue((4),false,false, false)
	distType:setModulatorValue((2),false,false, false)
	hiCut:setModulatorValue((80),false,false, false)
	postGain:setModulatorValue((50),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((2),false,false, false)

elseif(preset==3)then
	drive:setModulatorValue((5),false,false, false)
	distType:setModulatorValue((1),false,false, false)
	hiCut:setModulatorValue((70),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((2),false,false, false)

elseif(preset==4)then
	drive:setModulatorValue((5),false,false, false)
	distType:setModulatorValue((2),false,false, false)
	hiCut:setModulatorValue((70),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==5)then
	drive:setModulatorValue((6),false,false, false)
	distType:setModulatorValue((1),false,false, false)
	hiCut:setModulatorValue((60),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==6)then
	drive:setModulatorValue((6),false,false, false)
	distType:setModulatorValue((2),false,false, false)
	hiCut:setModulatorValue((60),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==7.0)then
	console("Debug floating 7 match: ".. preset)
	drive:setModulatorValue((6),false,false, false)
	distType:setModulatorValue((6),false,false, false)
	hiCut:setModulatorValue((50),false,false, false)
	postGain:setModulatorValue((30),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((80),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==8)then
	console("Debug floating 8 match: ".. preset)
	drive:setModulatorValue((7),false,false, false)
	distType:setModulatorValue((1),false,false, false)
	hiCut:setModulatorValue((40),false,false, false)
	postGain:setModulatorValue((30),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==9)then
	drive:setModulatorValue((5),false,false, false)
	distType:setModulatorValue((5),false,false, false)
	hiCut:setModulatorValue((60),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((80),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==10)then
	drive:setModulatorValue((6),false,false, false)
	distType:setModulatorValue((7),false,false, false)
	hiCut:setModulatorValue((80),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((3),false,false, false)

elseif(preset==11)then
	drive:setModulatorValue((5),false,false, false)
	distType:setModulatorValue((4),false,false, false)
	hiCut:setModulatorValue((110),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((2),false,false, false)

elseif(preset==12)then
	drive:setModulatorValue((7),false,false, false)
	distType:setModulatorValue((3),false,false, false)
	hiCut:setModulatorValue((40),false,false, false)
	postGain:setModulatorValue((40),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((4),false,false, false)

elseif(preset==13)then
	drive:setModulatorValue((7),false,false, false)
	distType:setModulatorValue((0),false,false, false)
	hiCut:setModulatorValue((80),false,false, false)
	postGain:setModulatorValue((30),false,false, false)
	preGain:setModulatorValue((64),false,false, false)
	rC:setModulatorValue((127),false,false, false)
	reso:setModulatorValue((4),false,false, false)

end

panel:setPropertyString("panelMidiPauseOut","0")

end
