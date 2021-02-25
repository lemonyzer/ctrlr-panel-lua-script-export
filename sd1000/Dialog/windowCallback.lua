function windowCallback(result, window)
	window:setVisible (false)
	dl:setText("\n\nwindowCallback result="..result)

	comboBox = window:getComboBoxComponent("myCombo")
	if comboBox ~= nil then	
		dl:append("\n\tcombo selectedId="..comboBox:getSelectedId())
			:append("\n\tcombo text: \""..comboBox:getText())
			:append("\"")
	end

	textEditor = window:getTextEditor("myTextEditor")
	if textEditor ~= nil then	
		dl:append("\n\ttextEditor contents:\n\"")
			:append(textEditor:getText())
			:append("\"")
	end
end