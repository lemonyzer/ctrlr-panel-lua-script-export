showWindowWithBoolResult = function()
	if panel:getBootstrapState() then
		console ("showWindowWithBoolResult panel in bootstrap")
		return
	end

	ret = AlertWindow.showOkCancelBox(
		AlertWindow.QuestionIcon, 
		"Title",
		"Message",
		"OK",
		"Froget it"
	)

	--dl:setText("\n\nshowWindowWithBoolResult\n")
	--	:append("\tbool result=")
	--	:append(tostring(ret))end