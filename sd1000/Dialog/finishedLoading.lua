---- Called when the panel has finished loading--finishedLoading = function()
	dl = panel:getLabel("debug")
	if dl ~= nil then
		dl:setText("Panel start\n")
	end

	initLoadingStage(0)
end