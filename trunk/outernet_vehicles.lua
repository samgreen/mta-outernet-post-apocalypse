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

function attachPlayerToVehicle(playerSource, commandName)
	local vehicle = getPedOccupiedVehicle(playerSource)
	if vehicle then
		removePedFromVehicle(vehicle)
	else
		local gameVehicles = getElementsByType("vehicle")
		local x, y, z = getElementPosition(playerSource)
		for index, currentVehicle in ipairs(gameVehicles) do
			-- Get the location of this vehicle
			local vehicleX, vehicleY, vehicleZ = getElementPosition(currentVehicle)
			
			-- Check the distance between the player and this vehicle
			if getDistanceBetweenPoints3D(x, y, z, vehicleX, vehicleY, vehicleZ) < 2 then 
				vehicle = currentVehicle 
			end
		end
	end	
	
	attachElements(playerSource, vehicle, 0, -1.3, .85)
end
addCommandHandler("attach", attachPlayerToVehicle)

function createTechnical(playerSource, commandName)
	-- Create and place the Walton
	local x, y, z = getElementPosition(playerSource)
	local vehicle = createVehicle(478, x + 5, y, z)
	
	-- Create a minigun object
	local minigunObject = createObject(2985, 0, 0, 0)
	
	-- Attach a minigun to the roof		
	attachElements(minigunObject, vehicle, 0, -0.75, 0, 0, 0, 90)
end
addCommandHandler("spawntechnical", createTechnical)