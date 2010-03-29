local mysqlConnection

function setupSQL()
	mysqlConnection = mysql_connect(SQL_HOSTNAME, SQL_USERNAME, SQL_PASSWORD, SQL_DATABASE, 3306, SQL_SOCKET)
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
	
	triggerClientEvent("createInventory", getRootElement(), inventoryTable)
end
addCommandHandler("inventory", showInventory)

function listAllItems()	
	-- TODO: Verify admin level before showing all items	
	itemTable = selectSQL("Items", "ItemID, Name, Description", "1")
	
	triggerClientEvent("createItemBrowser", getRootElement(), itemTable)
end
addCommandHandler("items", listAllItems)

-- This function checks the Players table to see if the player has previously registered an account
function checkSQLAccountExists(playerName)
	local accountTable = selectSQL("Players", "PlayerID", "PlayerName='" .. playerName .. "'")
	if #accountTable ~= 0 then 
		-- Account exists
		setElementData(getPlayerFromName(playerName), "PlayerID", accountTable[1].PlayerID)
		return true
	else 
		-- Something went wrong
		return false
	end
end

-- This function encrypts the password sent from the login GUI and tests it against the stored encrypted password in the database
-- Returns true for matching username and password, false otherwise
function attemptLogin(playerName, password)	
	local playerTable = selectSQL("Players", "PlayerID", "PlayerName='" .. playerName .. [[' AND Password=AES_ENCRYPT(']] .. password .. "', '" .. AES_PASSKEY .. "')")
	
	-- Is the length of the player table something other than zero?
	if #playerTable ~= 0 then 
		-- Successful login		
		return true
	else
		-- Something went wrong
		return false
	end	
end

function addSQLAccount(playerName, password)	
	local createdAccount = insertSQL("Players", "PlayerName, Password", "'" .. playerName .. [[', AES_ENCRYPT(']] .. password .. "', '" .. AES_PASSKEY .. "')")
	if createdAccount then
		checkSQLAccountExists(playerName)
		return true
	end
	
	-- Something went wrong
	return false
end

function getAllCharacterInfo(playerName)	
	-- Create a table to store basic information about each character	
	charactersInfo = {}
	
	local playerID = getElementData(getPlayerFromName(playerName), "PlayerID")
	if playerID ~= nil and playerID ~= false then
		charactersInfo = selectSQL("Characters", "*", "PlayerID='" .. playerID .. "'")
	end
	
	-- Return the character details
	return charactersInfo
end

-- Helper function to insert values in to SQL
function insertSQL(tableName, columns, values)
	local sqlResult = mysql_query(mysqlConnection, "INSERT INTO " .. tableName .. " (" .. columns .. ") VALUES(" .. values .. ");")
	if sqlResult then
		mysql_free_result(sqlResult) -- Freeing the result is IMPORTANT
		
		return true
	else
		outputSQLError()		
	end
	
	-- Something went wrong
	return false
end

-- Helper function to retrieve values from SQL
function selectSQL(tableName, columns, predicate)
	-- Create a table to store basic information about each character	
	selectResult = {}

	local query = "SELECT " .. columns .. " FROM " .. tableName .. " WHERE " .. predicate .. ";"
	
	-- DEBUG --
	outputDebugString(query)
	-----------
	
	local sqlResult = mysql_query(mysqlConnection, query)
	
	if sqlResult then
		if mysql_num_rows(sqlResult) > 0 then
			while true do
			    local row = mysql_fetch_assoc(sqlResult)
			    if (not row) then break end
			 
			 	-- DEBUG --
			 	for key, value in pairs(row) do
			 		outputDebugString(key .. ": " .. value)
			 	end
			 	-----------
			 	
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