showWindowWithCombo = function()
	if panel:getBootstrapState() then
		console ("showWindowWithCombo panel in bootstrap")
		return
	end

	comboItems = StringArray()
	comboItems:add ("Item 1")
	comboItems:add ("Item 2")
	comboItems:add ("Item 3")
	comboItems:add ("Item 4")

	modalWindow = AlertWindow("Window title", "A message for the user that will guide him what to do with the window", AlertWindow.InfoIcon)
	modalWindow:addButton("OK", 1, KeyPress(KeyPress.returnKey), KeyPress())
	modalWindow:addButton("Cancel", 0, KeyPress(KeyPress.escapeKey), KeyPress())
	modalWindow:addButton("Unknown", 2, KeyPress(), KeyPress())
	modalWindow:addComboBox ("myCombo", comboItems, "Combo")
	modalWindow:setModalHandler(windowCallback)
		
	--  Never let Lua delete this window (3rd parameter), enter modal state
	modalWindow:runModalLoop()end


showWindowNoValidPreset = function(mod)
	if panel:getBootstrapState() then
		console ("showWindowNoValidPreset panel in bootstrap")
		return
	end

	modalWindow = AlertWindow("Fehler", mod:getProperty("name") .. " muss mindestens einen Preset und einen 'dummy' (Custom) Eintrag besitzen!", AlertWindow.InfoIcon)
	modalWindow:addButton("OK", 1, KeyPress(KeyPress.returnKey), KeyPress())
	modalWindow:setModalHandler(windowCallback)
		
	--  Never let Lua delete this window (3rd parameter), enter modal state
	modalWindow:runModalLoop()end


