function initVehicleSystem()
	local gameVehicles = getElementsByType("vehicle")
	for k,v in ipairs(gameVehicles) do
		-- The default behavior does not respawn vehicles automatically.
		-- We can enable this ourselves, for every vehicle here.
		toggleVehicleRespawn ( v, true )
		setVehicleRespawnDelay ( v, 30000 )
		setVehicleIdleRespawnDelay ( v, 120000 )
	end
end
