--
	dl = panel:getLabel("debug")
	if dl ~= nil then
		dl:setText("Panel start\n")
	end

	initLoadingStage(0)
