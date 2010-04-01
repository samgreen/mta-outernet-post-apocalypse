-- Define resourceRoot as a shortcut
local resourceRoot = getResourceRootElement(getThisResource())
-- Define teams
local teams = {}

-- This callback is activated once, when the resource is started.
function onOuternetStart()
	-- Initialize the teams
	teams.Raiders   = createTeam("Raiders", 200, 10, 10)
	teams.Survivors = createTeam("Survivors", 10, 10, 200)
	teams.Infected = createTeam("Infected", 10, 10, 10)
	
	-- Add all of our spawn points to the spawnmanager resource
	-- Retrieve a table with all the spawnpoint elements
	local spawnPoints = getElementsByType("spawnpoint")
	-- loop through them
	for key, spawnPoint in pairs(spawnPoints) do
		-- get our info
		local posX = getElementData(spawnPoint, "posX")
		local posY = getElementData(spawnPoint, "posY")
		local posZ = getElementData(spawnPoint, "posZ")
		local rotZ = getElementData(spawnPoint, "rotZ")
		
		-- Add the info to our spawn manager
		call(getResourceFromName("spawnmanager"), "createSpawnpoint", posX, posY, posZ, rotZ)
	end
	
	-- Setup our vehicles
	initVehicleSystem()
	
	-- Log out all players, in preparation for login
	-- DEBUG: Commented out to speed debugging
	-- logoutAllPlayers()
	
	-- Finally, connect to SQL
	setupSQL()
end
addEventHandler("onResourceStart", resourceRoot, onOuternetStart)

-- This callback is activated once, when the resource is stopping.
function onOuternetStop()	
	-- Cleanup our SQL connection and resources
	shutdownSQL()
end
addEventHandler("onResourceStop", resourceRoot, onOuternetStop)

-- This callback is activated every time a player joins the server.
function onPlayerJoin()
	-- Spawn the player	
	call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", source)		
	
	--setupCharacterSelection(source)
	
	-- Send welcome message
	outputChatBox("Welcome to the wasteland apocalypse of Outernet MTA!", source)
end
addEventHandler("onPlayerJoin", getRootElement(), onPlayerJoin)

-- This callback is activated everytime a player is killed
function onPlayerWasted(ammo, attacker, weapon, bodypart)
	fadeCamera(source, false, 4.5)
	
	-- If an infected player died, reset their team
	-- TODO: Instead of assigning them to the nil team, we should assign them to their previous team
	-- raiders or survivors.
	if getPlayerTeam(source) == teamInfected then setPlayerTeam(source, nil) end
	
	-- if there was an attacker
	if ( attacker ) then
		-- we declare our variable outside the following checks
		local tempString = ""
		-- if the element that killed him was a player,
		if ( getElementType ( attacker ) == "player" ) then
			-- put the attacker, victim and weapon info in the string
			tempString = getPlayerName ( attacker ).." killed "..getPlayerName ( source ).." ("..getWeaponNameFromID ( weapon )..")"
		-- else, if it was a vehicle,
		elseif ( getElementType ( attacker ) == "vehicle" ) then
			-- we'll get the name from the attacker vehicle's driver
			tempString = getPlayerName ( getVehicleController ( attacker ) ).." killed "..getPlayerName ( source ).." ("..getWeaponNameFromID ( weapon )..")"
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
addEventHandler("onPlayerWasted", getRootElement(), onPlayerWasted)

function setupCharacterCreation(player)
	outputChatBox("Creating new character.", player)
	return
end

function previousCharacter()

end

function nextCharacter()

end

function setupCharacterSelection(player)
	-- Fade in
	fadeCamera(player, true, 5)
	
	-- Load all the characters from the account
	local characterInfo = getAllCharacterInfo(getPlayerName(player))
	
	-- If they do not have any characters registered to this account, send them to character creation
	--if ( type( characterInfo ) == "table" and #characterInfo == 0 ) or not characterInfo then setupCharacterCreation(player) return end
	if #characterInfo == 0 then setupCharacterCreation(player) return end
	
	for index, character in ipairs(characterInfo) do	
		-- Create an NPC for each
		local characterPed = createPed(character.Skin, 160.984863 + index * 3, 1213.388305, 21.501449)
		setPedRotation(characterPed, 221.263046)
	end
	
	-- Bind keys for switching between characters
	bindKey("arrow_l", "down", previousCharacter)
    bindKey("arrow_r", "down", nextCharacter)
    
    outputChatBox("Use the arrow keys to select your character.", player)
    
	-- Set the player up in front of the Fort Carson sign
	spawnPlayer(player, 163.984863, 1213.388305, 21.501449)	
	setPedRotation(player, 221.263046)
	
	-- Make the player do the smoking animation
	setPedAnimation(player, "SMOKING", "M_smklean_loop", 10, true)
	
	-- TODO: Put the player in another dimension so they can't be harmed
	
	setCameraTarget(player, player)
	-- Set up the camera
	setCameraMatrix(player, 169, 1201, 25, 170, 1225, 20)
end

function openItemBrowser()
	local allItems = selectSQL("Items", "*", "1")
	
	triggerClientEvent("createItemBrowser",getRootElement(), allItems)
end
addCommandHandler("items", openItemBrowser)

function setupSpawn(player)
	fadeCamera(player, true)
	-- TODO: Add logic to determine player spawn location (team, etc)
	call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", player)
end

function joinraiders (source)
	setPlayerTeam(source, teamRaiders)
	
	call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", source)
	
	outputChatBox("You joined the blood thirsty raiders.", source)
end
addCommandHandler("joinraiders", joinraiders)

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
		-- Otherwise do not allow them to enter the vehicles
		cancelEvent()
		outputChatBox("You can't possibly drive this in your current condition.", thePlayer)    	
    end
end
addEventHandler("onVehicleStartEnter", getRootElement(), onVehicleStartEnter)