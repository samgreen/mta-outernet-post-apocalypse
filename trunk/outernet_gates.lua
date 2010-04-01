-- Create collision shapes
local eqGateOpener = createColRectangle(-1352, 2155, 20, 20)

local raiderGateColRectangle = createColRectangle(-1290, 2434, 15, 25)
local raiderBotElevColRectangle = createColCuboid(32, 2183, 28, 3, 5, 15)
local raiderTopElevColRectangle = createColCuboid(31, 2190, 121, 4, 3, 2)

function lowerEqGate(thePlayer)   
    moveObject(getElementByID("object (plasticsgate1) (1)"), 4000, -1350.01, 2166.49, 48.80783)
end
addEventHandler("onColShapeLeave", eqGateOpener, lowerEqGate)

function raiseEqGate(thePlayer)	
	moveObject(getElementByID ("object (plasticsgate1) (1)"), 4000, -1350.01, 2166.49, 52.508)
end
addEventHandler("onColShapeHit", eqGateOpener, raiseEqGate)

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
addEventHandler("onColShapeHit", raiderGateColRectangle, raiderGateOpen)
 
-- add raiderGateClose as a handler for when a player leaves the gate colRectangle
function raiderGateClose(thePlayer)
	--if the element that left was player
    if getElementType(thePlayer) == "player" then 
    		-- Ensure they are on the raiders team before we close the gate
    		if getPlayerTeam(thePlayer) ~= teamRaiders then return end
    		
			-- Close the gate
	        moveObject(getElementByID("gateRaiderHQ"), 3500, -1280.4, 2447.1, 87.1)
    end
end
addEventHandler("onColShapeLeave", raiderGateColRectangle, raiderGateClose)

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
addEventHandler("onColShapeHit", raiderBotElevColRectangle, raiderElevatorDown)
addEventHandler("onColShapeLeave", raiderTopElevColRectangle, raiderElevatorDown) 

function raiderElevatorRaise(thePlayer)   
 	if getElementType ( thePlayer ) == "player" then     		
    		if getPlayerTeam(thePlayer) ~= teamRaiders then return end
    		
			-- Raise Elevator
	        moveObject(getElementByID ("raiderElevator"), 10000, 33.0712890625, 2189.341796875, 121.19092559814 )
    end
    
    outputDebugString("raiderElevatorRaise(thePlayer)")
end
addEventHandler("onColShapeLeave", raiderBotElevColRectangle, raiderElevatorRaise)
addEventHandler("onColShapeHit", raiderTopElevColRectangle, raiderElevatorRaise)