function LockManager()
	-- Your method code here
end



lock = function (efxId)

	lock = string.format("%sLock",efxId)
	if ( G[lock] == true ) then
		return
	end

end



unlock = function (efxId)

	lock = string.format("%sLock",efxId)
	if ( G[lock] == true ) then
		return
	end

end



isLocked = function (efxId)
	
	lock = string.format("%sLock",efxId)
	if ( G[lock] == true ) then
		return
	end
	return true

end