local teamRaiders, teamSurvivors, teamInfected

-- Create colshapes
local raiderGateColRectangle = createColRectangle ( -1290, 2434, 15, 25 )

-- This callback is activated once, when the resource is started.
function onResourceStart()
	teamRaiders   = createTeam("Raiders", 200, 10, 10)
	teamSurvivors = createTeam("Survivors", 10, 10, 200)
	teamInfected = createTeam("Infected", 10, 10, 10)
	
	-- Setup our vehicles
	initVehicleSystem()
	
	-- Log out all players, in preparation for login
	-- DEBUG: Commented out to speed debugging
	-- logoutAllPlayers()
	
	-- Connect to SQL
	setupSQL()
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), onResourceStart)

-- This callback is activated once, when the resource is stopping.
function onResourceStop()	
	-- Cleanup our SQL connection and resources
	shutdownSQL()
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), onResourceStop)

-- This function logs out all non-guest players.
function logoutAllPlayers()
	local players = getElementsByType ("player")
	for k, player in ipairs ( players ) do
		account = getPlayerAccount(player)
		if (not isGuestAccount(account)) then
			logOut(player)
		end
	end
end

-- This callback is activated every time a player joins the server.
function onPlayerJoin()
	-- retrieve a table with all flag elements
	local spawnPoints = getElementsByType ( "spawnpoint" )
	-- loop through them
	for key, value in pairs(spawnPoints) do
		-- get our info
		local posX = getElementData ( value, "posX" )
		local posY = getElementData ( value, "posY" )
		local posZ = getElementData ( value, "posZ" )
		local rotZ = getElementData ( value, "rotZ" )
		
		-- Add the info to our spawn manager
		local theSpawnpoint = call(getResourceFromName("spawnmanager"), "createSpawnpoint", posX, posY, posZ, rotZ)
	end

	-- Spawn the player	
	--call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", source, theSpawnpoint)		
	
	setupCharacterSelection(source)
	
	-- Send welcome message
	outputChatBox("Welcome to the wasteland apocalypse of Outernet MTA!", source)
end
addEventHandler("onPlayerJoin", getRootElement(), onPlayerJoin)

function setupCharacterCreation(player)
	return
end

function setupCharacterSelection(player)
	-- Load all the characters from the account
	local characterInfo = getAllCharacterInfo(getPlayerName(player))
	
	-- If they do not have any characters registered to this account, send them to character creation
	if ( type( characterInfo ) == "table" and #characterInfo == 0 ) or not characterInfo then setupCharacterCreation(player) return end
	
	for index,character in ipairs(characterInfo) do
		outputDebugString("Name: " .. character.Name .. "(" .. character.CharacterID .. ")")
		outputDebugString("Biography: " .. character.Biography)
		
		-- Create an NPC for each
		
	end
	
	-- Bind keys for switching between characters
	
	-- Fade in
	fadeCamera(player, true, 5)
	
	-- Freeze them in place
	--toggleAllControls(player, false, false) 
	
	-- Set the player up in front of the Fort Carson sign
	spawnPlayer(player, 163.984863, 1213.388305, 21.501449)	
	setPedRotation(player, 221.263046)
	
	-- Make the player do the smoking animation
	setPedAnimation(player, "SMOKING", "M_smklean_loop", 10, true)
	
	-- TODO: Put the player in another dimension so they can't be harmed
	
	setCameraTarget(source, source)
	-- Set up the camera
	--setCameraMatrix(player, 169, 1201, 25, 170, 1225, 20)
end

function openItemBrowser()
	local allItems = selectSQL("Items", "*", "1")
	
	triggerClientEvent("createItemBrowser",getRootElement(), allItems)
end
addCommandHandler("items", openItemBrowser)

function spawnCharacter(characterID)
	-- Focus the camera on the player
	setCameraTarget(source, source)
end
addCommandHandler("spawn", spawnCharacter)

-- This callback is activated everytime a player is killed
function onPlayerWasted ( ammo, attacker, weapon, bodypart )
	fadeCamera(source, false, 4.5)
	
	-- If an infected player died, reset their team
	-- TODO: Instead of assigning them to the nil team, we should assign them to their previous team
	-- raiders or survivors.
	if getPlayerTeam(source) == teamInfected then setPlayerTeam(source, nil) end
	
	-- if there was an attacker
	if ( attacker ) then
		-- we declare our variable outside the following checks
		local tempString
		-- if the element that killed him was a player,
		if ( getElementType ( attacker ) == "player" ) then
			-- put the attacker, victim and weapon info in the string
			tempString = getPlayerName ( attacker ).." killed "..getPlayerName ( source ).." ("..getWeaponNameFromID ( weapon )..")"
		-- else, if it was a vehicle,
		elseif ( getElementType ( attacker ) == "vehicle" ) then
			-- we'll get the name from the attacker vehicle's driver
			local tempString = getPlayerName ( getVehicleController ( attacker ) ).." killed "..getPlayerName ( source ).." ("..getWeaponNameFromID ( weapon )..")"
		end
		-- if the victim was shot in the head, append a special message
		if ( bodypart == 9 ) then
			tempString = tempString.." (HEADSHOT!)"
		-- else, just append the bodypart name
		else
			tempString = tempString.." ("..getBodyPartName ( bodypart )..")"
		end
		-- display the message
		outputChatBox ( tempString )
	-- if there was no attacker,
	else
		-- output a death message without attacker info
		if weapon and bodypart then
			outputChatBox ( getPlayerName ( source ).." died. ("..getWeaponNameFromID ( weapon )..") ("..getBodyPartName ( bodypart )..")" )
		elseif weapon then
			outputChatBox ( getPlayerName ( source ).." died. ("..getWeaponNameFromID ( weapon )..")")
		elseif bodypart then
			outputChatBox ( getPlayerName ( source ).." died. ("..getBodyPartName ( bodypart )..")" )
		end
		
	end

	setTimer( setupSpawn, 5000, 1, source)	
end
addEventHandler ( "onPlayerWasted", getRootElement(), onPlayerWasted )

function setupSpawn(player)
	fadeCamera(player, true)
	-- TODO: Add logic to determine player spawn location (team, etc)
	call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", player, theSpawnpoint)
end

function joinraiders (source)
	setPlayerTeam(source, teamRaiders)
	
	local spawnPoints = getElementsByType ( "spawnpoint" )
	for key, value in pairs(spawnPoints) do
		-- get our info
		local posX = getElementData ( value, "posX" )
		local posY = getElementData ( value, "posY" )
		local posZ = getElementData ( value, "posZ" )
		local rotZ = getElementData ( value, "rotZ" )
		
		-- Add the info to our spawn manager
		local theSpawnpoint = call(getResourceFromName("spawnmanager"), "createSpawnpoint", posX, posY, posZ, rotZ) --Create the spawnpoint.
		call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", source, theSpawnpoint)
	end
	
	outputChatBox("You joined the blood thirsty raiders.", source)
end
addCommandHandler ( "joinraiders", joinraiders )

function joinsurvivors(source)
	setPlayerTeam(source, teamSurvivors)
	
	outputChatBox("You joined the Fort Carson survivors.", source)
end
addCommandHandler("joinsurvivors", joinsurvivors)

function infectPlayer(thePlayer, commandName)
	-- Add the player to the infected team
	setPlayerTeam(thePlayer, teamInfected)
	-- Maximum Blur
	setPlayerBlurLevel(thePlayer, 255)	
	-- Topless red neck skin
	setPedSkin(thePlayer, 162)
	-- Set to a drunk? walking style
	-- setPedWalkingStyle 
	-- Slightly reduced gravity
	setPedGravity(thePlayer, 0.006)
	-- Custom generic nametag
	setPlayerNametagText(thePlayer, "Infected Zombie")
	-- In bright red
	setPlayerNametagColor(thePlayer, 255, 0, 0)
	-- Take all of their weapons
	takeAllWeapons(thePlayer)
	
	-- Give them a spray can
	giveWeapon(thePlayer, 41, 1000, true)
	-- Setup a timer for increased velocity
	--setTimer (setInfectedVelocity, 300, 0, thePlayer)
	
	-- Inform the player
	outputChatBox("You have been infected with god knows what.", thePlayer)
end
addCommandHandler("infectme", infectPlayer)

function setInfectedVelocity(infectedPlayer)
	-- We only want this bonus to apply to infected players
	if getPlayerTeam(infectedPlayer) == teamInfected then
		local speedX, speedY, speedZ = getElementVelocity(infectedPlayer)
		outputDebugString("Speed was " .. speedX .. ", " .. speedY .. ", " .. speedZ)
		setElementVelocity(infectedPlayer, speedX*1.3, speedY*1.3, speedZ)
		
		local speedX, speedY, speedZ = getElementVelocity(infectedPlayer)	
		outputDebugString("Speed is " .. speedX .. ", " .. speedY .. ", " .. speedZ, 3, 128, 0, 0)
	else 
		-- TODO: Kill the timer
	end
end

function onVehicleStartEnter(thePlayer, seat, jacked, door)
    -- Are they infected?
    if getPlayerTeam(thePlayer) == teamInfected then 
    	-- Did they try to jack another player?
    	if jacked ~= false then 
    		-- Allow it
			return
		else
			-- Otherwise do not allow them to enter the vehicles
	    	cancelEvent()
	    	outputChatBox("You can't possibly drive this in your current condition.", thePlayer) 
		end    	   	
    end
end
addEventHandler("onVehicleStartEnter", getRootElement(), onVehicleStartEnter)

-- add raiderGateOpen as a handler for when a player enters the gate colRectangle
function raiderGateOpen(thePlayer)
	--if the element that entered was player     
    if getElementType(thePlayer) == "player" then 
    		-- Ensure they are on the raiders team before we open the gate
    		if getPlayerTeam(thePlayer) ~= teamRaiders then 
    			outputChatBox([[A raider shouts at you, "Can't you read the sign?! I'm reloading, and you're trespassing. I'll give you to the count of one!"]], thePlayer)
    			return
    		end
    		
	        -- Open the gate
	        moveObject(getElementByID("gateRaiderHQ"), 3500, -1272.2, 2449.6, 87.1)
    end
end
addEventHandler ( "onColShapeHit", raiderGateColRectangle, raiderGateOpen )
 
-- add raiderGateClose as a handler for when a player leavesthe gate colRectangle
function raiderGateClose(thePlayer)
	--if the element that left was player
    if getElementType ( thePlayer ) == "player" then 
    		-- Ensure they are on the raiders team before we close the gate
    		if getPlayerTeam(thePlayer) ~= teamRaiders then return end
    		
			-- Close the gate
	        moveObject(getElementByID("gateRaiderHQ"), 3500, -1280.4, 2447.1, 87.1)
    end
end
addEventHandler ( "onColShapeLeave", raiderGateColRectangle, raiderGateClose )

local raiderBotElevColRectangle = createColCuboid ( 32, 2183, 28, 3, 5, 15)
local raiderTopElevColRectangle = createColCuboid ( 31, 2190, 121, 4, 3, 2)

function raiderElevatorDown (thePlayer)	    
    if getElementType(thePlayer) == "player" then 
    		if getPlayerTeam(thePlayer) ~= teamRaiders then 
    			outputChatBox([[A raider shouts at you, "Get the fuck away from my elevator ya son of a bitch!"]], thePlayer)
    			return
    		end
    		
	        -- Lower Elevator
	        moveObject(getElementByID ("raiderElevator"), 10000, 33.0712890625, 2189.341796875, 38.440925598145 )
    end
    
    outputDebugString("raiderElevatorDown(thePlayer)")
end
addEventHandler ( "onColShapeHit", raiderBotElevColRectangle, raiderElevatorDown )
addEventHandler ( "onColShapeLeave", raiderTopElevColRectangle, raiderElevatorDown ) 

function raiderElevatorRaise(thePlayer)   
 	if getElementType ( thePlayer ) == "player" then     		
    		if getPlayerTeam(thePlayer) ~= teamRaiders then return end
    		
			-- Raise Elevator
	        moveObject(getElementByID ("raiderElevator"), 10000, 33.0712890625, 2189.341796875, 121.19092559814 )
    end
    
    outputDebugString("raiderElevatorRaise(thePlayer)")
end
addEventHandler ( "onColShapeLeave", raiderBotElevColRectangle, raiderElevatorRaise )
addEventHandler ( "onColShapeHit", raiderTopElevColRectangle, raiderElevatorRaise )