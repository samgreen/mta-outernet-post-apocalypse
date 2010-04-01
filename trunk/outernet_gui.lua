local allWindows

local windowGunSkills
local buttonSmallArmsSkill
local buttonSubMachinegun
local buttonSpecialtySkill
local buttonShotgunSkill
local buttonRifleSkill

local mapVisible = false
local mapImage = nil

function toggleMap()
	mapVisible = not mapVisible
	if mapVisible then 
		guiSetVisible(mapImage, false)
	else 
		guiSetVisible(mapImage, true)	
	end	
end

-- This event is triggered when this file has completed downloading.
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 
	function ()
		-- create the gun skills
		--createGunSkillsWindow()
		
		-- Fix camera clip issues
		setCameraClip(false, false)
 
 		-- Bind a key for the map
 		bindKey("m", "down", toggleMap)
 		
 		-- Create the static map image
 		mapImage = guiCreateStaticImage(10, 10, 864, 864, "images/map.png", false)

		-- enable the players cursor (so they can select and click on the components)
	    -- showCursor(true)
		-- set the input focus onto the GUI, allowing players (for example) to press 'T' without the chatbox opening
	    -- guiSetInputEnabled(true)
	end
)

-- This function creates an inventory window and populates it from data provided
-- in the parameter inventoryTable. The inventoryTable must contain any number of rows
-- with the following keys:
-- 		Quantity
--		Name
--		Description
function createInventoryWindow(inventoryTable)
	-- Create our window
	windowInventory = guiCreateWindow(.1,.25,.4,.5,"Inventory",true)
	itemGridList = guiCreateGridList ( 0, 0.1, 1, 0.9, true, windowInventory)
	guiGridListAddColumn ( itemGridList, "Quantity", 0.1 )
    guiGridListAddColumn ( itemGridList, "Name", 0.3 )
    guiGridListAddColumn ( itemGridList, "Description", 0.7 )

	 for key, value in ipairs(inventoryTable) do 
    	--Loop through all the players, adding them to the table
        local row = guiGridListAddRow ( itemGridList )
        guiGridListSetItemText ( itemGridList, row, 1, value.Quantity, true, false )
        guiGridListSetItemText ( itemGridList, row, 2, value.Name, false, false )
        guiGridListSetItemText ( itemGridList, row, 3, value.Description, false, false )
    end
	
	-- Add the inventory window to our table containing all windows
	table.insert(allWindows, windowInventory)
	
	-- Hide the window until the user requests it.
	guiSetVisible(windowInventory, false)
end
addEvent("createInventory",true)
addEventHandler("createInventory",getRootElement(),createInventoryWindow)  

-- This function creates an item browser window and populates it from data provided
-- in the parameter itemTable. The itemTable must contain any number of rows
-- with the following keys:
-- 		ItemID
--		Name
--		Description
function createItemBrowserWindow(itemTable)
	-- Create our window
	windowItemBrowser = guiCreateWindow(.1,.25,.4,.5,"Item Browser",true)
	itemGridList = guiCreateGridList ( 0, 0.1, 1, 0.9, true, windowItemBrowser)
	guiGridListAddColumn ( itemGridList, "Item ID", 0.1 )
    guiGridListAddColumn ( itemGridList, "Name", 0.3 )
    guiGridListAddColumn ( itemGridList, "Description", 0.7 )

	 for key, value in ipairs(itemTable) do 
    	--Loop through all the players, adding them to the table
        local row = guiGridListAddRow ( itemGridList )
        guiGridListSetItemText ( itemGridList, row, 1, value.ItemID, true, false )
        guiGridListSetItemText ( itemGridList, row, 2, value.Name, false, false )
        guiGridListSetItemText ( itemGridList, row, 3, value.Description, false, false )
    end
	
	-- Add the item browser window to our table containing all windows
	table.insert(allWindows, windowInventory)
	
	-- Hide the window until the user requests it.
	guiSetVisible(windowItemBrowser, false)
end
addEvent("createItemBrowser",true)
addEventHandler("createItemBrowser",getRootElement(),createItemBrowserWindow)

function createGunSkillsWindow()
	-- Create our window
	windowGunSkills = guiCreateWindow(930,396,368,334,"Gun Skills",false)
	buttonSmallArmsSkill = guiCreateButton(9,55,167,78,"Small Arms (0 / 3)",false,windowGunSkills)
	buttonSubMachinegun = guiCreateButton(9,148,167,78,"Sub Machineguns (0 / 3)",false,windowGunSkills)
	buttonShotgunSkill = guiCreateButton(191,55,167,78,"Shotguns (0 / 3)",false,windowGunSkills)
	buttonRifleSkill = guiCreateButton(191,148,167,78,"Rifles (0 / 3)",false,windowGunSkills)
	buttonSpecialtySkill = guiCreateButton(100,241,167,78,"Specialty (0 / 1)",false,windowGunSkills)
	
	addEventHandler("onClientGUIClick", buttonSmallArmsSkill, processSmallArmsSkill, false)
	addEventHandler("onClientGUIClick", buttonSubMachinegun, processSubMachineGunSkill, false)
	addEventHandler("onClientGUIClick", buttonShotgunSkill, processShotgunSkill, false)
	addEventHandler("onClientGUIClick", buttonRifleSkill, processRifleSkill, false)
	addEventHandler("onClientGUIClick", buttonSpecialtySkill, processSpecialtySkill, false)
	
	-- Add the gun skills window to our table containing all windows
	table.insert(allWindows, windowGunSkills)
	
	-- Hide the window until the user requests it.
	guiSetVisible(windowGunSkills, false)	
end
addEvent("createGunSkills",true)
addEventHandler("createGunSkills",getRootElement(),createGunSkillsWindow)

function closeAndResetGUI()
	-- Hide all windows	
	for key, window in pairs(allWindows) do
		guiSetVisible(window, false) 
	end
	
	showCursor(false)
	guiSetInputEnabled(false)
end

function processSmallArmsSkill(button)
	-- Check their skill points, and cancel the event if they have 0
	
	-- TODO: Add one skill point to their small arms skill
	-- 200 points total
	outputChatBox("You increased your small arms skill!")
	
	guiSetVisible(windowGunSkills, false)
	showCursor(false)
	guiSetInputEnabled(false)
end

function processSubMachineGunSkill(button)
	-- Check their skill points, and cancel the event if they have 0
	
	-- TODO: Add one skill point to their small arms skill
	-- 250 points total
	outputChatBox("You increased your sub machinegun skill!")
end

function processShotgunSkill(button)
	-- Check their skill points, and cancel the event if they have 0
	
	-- TODO: Add one skill point to their small arms skill
	-- 200 points total
	outputChatBox("You increased your shotgun skill!")
end

function processRifleSkill(button)
	-- Check their skill points, and cancel the event if they have 0
	
	-- TODO: Add one skill point to their small arms skill
	-- 200 points total
	outputChatBox("You increased your rifle skill!")
end

function processSpecialtySkill(button)
	-- Check their skill points, and cancel the event if they have 0
	
	-- TODO: Add one skill point to their small arms skill
	outputChatBox("You increased your specialty skill!")
end