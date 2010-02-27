local mysqlConnection

function setupSQL()
	mysqlConnection = mysql_connect("localhost", "mtaserver", "808kedavra9;o", "Outernet_MTA", 3306, "/var/run/mysqld/mysqld.sock")
	if mysqlConnection == nil then outputDebugString("Failed to connect to SQL server!") return false end
	
	return true
end

function outputSQLError()
	outputDebugString("Error executing the query: (" .. mysql_errno(mysqlConnection) .. ") :" .. mysql_error(mysqlConnection))
end

function shutdownSQL()
	mysql_close(mysqlConnection)
	
	return true
end

function showInventory()	
	-- TODO: Alter this logic to operate on CharacterIDs other than 1
	inventoryTable = selectSQL("Items INNER JOIN Inventory ON Items.ItemID=Inventory.ItemID", "Items.Name, Items.Description, Inventory.Quantity", "Inventory.CharacterID='1'")
	
	for key, value in ipairs(inventoryTable) do
		outputDebugString(value.Name .. " (" .. value.Quantity .. "): " .. value.Description)
	end
	
	triggerClientEvent("createInventory", getRootElement(), inventoryTable)
	
	--[[if sqlResult then
		local inventoryWindow = guiCreateWindow ( 0.15, 0.15, 0.7, 0.3, "Inventory", true )
		local itemList = guiCreateGridList (0.1, 0.25, 0.35, 0.6, true, inventoryWindow) -- Create the grid list
	    local itemCol = guiGridListAddColumn( itemList, "Quantity", 0.2 ) -- Create a 'players' column in the list
	    local nameCol = guiGridListAddColumn( itemList, "Name", 0.3 ) -- Create a 'players' column in the list
	    local descCol = guiGridListAddColumn( itemList, "Description", 0.5 ) -- Create a 'players' column in the list
	    
		while true do
		    local inventoryItem = mysql_fetch_assoc(sqlResult)
		    if (not inventoryItem) then break end
		 
		    --outputDebugString(inventoryItem["Name"])
		    --outputDebugString(inventoryItem["Description"])
			
	        local row = guiGridListAddRow (itemList)
	        guiGridListSetItemText(itemList, row, itemCol, inventoryItem.Quantity, false, true)	
	        guiGridListSetItemText(itemList, row, nameCol, inventoryItem.Name, false, false)
	        guiGridListSetItemText(itemList, row, descCol, inventoryItem.Description, false, false)
		end
		
		guiSetVisible ( inventoryWindow, true )

		mysql_free_result(sqlResult) -- Freeing the result is IMPORTANT
	else		
		outputSQLError()
	end]]--	
end
addCommandHandler("inventory", showInventory)

function listAllItems()	
	local sqlResult = mysql_query(mysqlConnection, "SELECT ItemID, Name, Description FROM Items;")
	if sqlResult then
		local itemWindow = guiCreateWindow ( 0.15, 0.15, 0.7, 0.3, "Item Browser", true )
		local itemList = guiCreateGridList (0.1, 0.25, 0.35, 0.6, true, itemWindow) -- Create the grid list
	    local itemCol = guiGridListAddColumn( itemList, "ItemID", 0.2 ) -- Create a 'players' column in the list
	    local nameCol = guiGridListAddColumn( itemList, "Name", 0.3 ) -- Create a 'players' column in the list
	    local descCol = guiGridListAddColumn( itemList, "Description", 0.5 ) -- Create a 'players' column in the list
	    
		while true do
		    local inventoryItem = mysql_fetch_assoc(sqlResult)
		    if (not inventoryItem) then break end
		 			
	        local row = guiGridListAddRow (itemList)
	        guiGridListSetItemText(itemList, row, itemCol, inventoryItem.ItemID, false, true)	
	        guiGridListSetItemText(itemList, row, nameCol, inventoryItem.Name, false, false)
	        guiGridListSetItemText(itemList, row, descCol, inventoryItem.Description, false, false)
		end
		
		guiSetVisible ( itemWindow, true )

		mysql_free_result(sqlResult) -- Freeing the result is IMPORTANT
	else		
		outputSQLError()
	end	
end
addCommandHandler("listitems", listAllItems)

-- This function checks the Players table to see if the player has previously registered an account
function checkSQLAccountExists(thePlayer)
	local accountTable = selectSQL("Players", "PlayerID", "PlayerName='" .. getPlayerName(thePlayer) .. "';")
	if accountTable ~= nil then 
		-- Account exists
		return true
	else 
		-- Something went wrong
		return false
	end
end

-- This function encrypts the password sent from the login GUI and tests it against the stored encrypted password in the database
-- Returns true for matching username and password, false otherwise
function attemptLogin(playerName, password)	
	local playerTable = selectSQL("Players", "PlayerID", "PlayerName='" .. playerName .. [[' AND Password=AES_ENCRYPT(']] .. password .. [[', 'Js.TK:?8Lm"HQr69DzbEyvfMRY&a?OrX')]])
	
	if playerTable ~= nil then 
		setElementData(getPlayerFromName(playerName), "PlayerID", playerTable[1]["PlayerID"])
		return true
	else
		-- Something went wrong
		return false
	end	
end

function addSQLAccount(playerName, password)
	local sqlResult = mysql_query(mysqlConnection, "INSERT INTO Players (PlayerName, Password) VALUES('" .. playerName .. [[', AES_ENCRYPT(']] .. password .. [[', 'Js.TK:?8Lm"HQr69DzbEyvfMRY&a?OrX'));]])
	if sqlResult then
		mysql_free_result(sqlResult) -- Freeing the result is IMPORTANT
		
		return true
	else
		outputSQLError()		
	end
	
	-- Something went wrong
	return false
end

-- insertSQL("Players", "PlayerName, Password", "'" .. playerName .. "', AES_ENCRYPT('" .. password .. [[', 'Js.TK:?8Lm"HQr69DzbEyvfMRY&a?OrX'));]])
function insertSQL(tableName, columns, values)
	local sqlResult = mysql_query(mysqlConnection, "INSERT INTO " .. tableName " (" .. columns .. ") VALUES(" .. values .. ");")
	if sqlResult then
		mysql_free_result(sqlResult) -- Freeing the result is IMPORTANT
		
		return true
	else
		outputSQLError()		
	end
	
	-- Something went wrong
	return false
end

function selectSQL(tableName, columns, predicate)
	-- Create a table to store basic information about each character	
	selectResult = {}

	local query = "SELECT " .. columns .. " FROM " .. tableName .. " WHERE " .. predicate .. ";"
	local sqlResult = mysql_query(mysqlConnection, query)
	
	if sqlResult then
		if mysql_num_rows(sqlResult) > 0 then
			while true do
			    local row = mysql_fetch_assoc(sqlResult)
			    if (not row) then break end
			 
			    table.insert(selectResult, row)
			end				
		end
		
		mysql_free_result(sqlResult) -- Freeing the result is IMPORTANT
	else
		outputSQLError()		
	end
	
	-- Return the character details
	return selectResult
end

		
function getAllCharacterInfo(playerName)	
	-- Create a table to store basic information about each character	
	charactersInfo = {}
	
	charactersInfo = selectSQL("Characters", "*", "PlayerID='" .. getElementData(getPlayerFromName(playerName), "PlayerID") .. "'")
	
	-- Return the character details
	return charactersInfo
end