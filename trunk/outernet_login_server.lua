function clientAttemptLogin(username, password)
	local userAccount = getAccount(username)
	local tryToLog
	if (client) then
		loginSuccessful = attemptLogin(username, password)
		if (loginSuccessful) then			
			setupCharacterSelection(getPlayerFromName(username))
			
			triggerClientEvent(source,"clientLoginSuccess",getRootElement())
		else
			triggerClientEvent(source,"clientDisplayArea",getRootElement(),"Incorrect login attempt, please try again.", 2)
			triggerClientEvent(source,"clientWrongPassword",getRootElement())
		end
	end
end
addEvent("SubmitLogin",true)
addEventHandler("SubmitLogin",getRootElement(),clientAttemptLogin)

function clientAttemptCreate(username, password)
	if (password ~= nil and password ~= "") then	   
		local createdAccount = addSQLAccount(username, password) 
		if (client and createdAccount ~= false) then
			local loginSuccessful = attemptLogin(username, password)
			if (loginSuccessful) then							
				setupCharacterSelection(getPlayerFromName(username))				
				
				triggerClientEvent(source,"clientLoginSuccess",getRootElement())
			else
				triggerClientEvent(source,"clientDisplayArea",getRootElement(), "Unable to log in to new account, try again.", 1)
			end
		else
			triggerClientEvent(source,"clientDisplayArea",getRootElement(), "Unable to create new account, try again.", 1)
		end
	else
		triggerClientEvent(source,"clientDisplayArea",getRootElement(), "Please enter a password for your new account.", 1)
	end
end
addEvent("SubmitCreate",true)
addEventHandler("SubmitCreate",getRootElement(), clientAttemptCreate)

function checkValidActHandler(thePlayerName)
	local playerAccount = checkSQLAccountExists(source)
	if playerAccount then
		triggerClientEvent(source,"clientReturningUser", getRootElement())
	else
		triggerClientEvent(source,"clientNewUser", getRootElement())
	end
end
addEvent("checkValidAct",true)
addEventHandler("checkValidAct",getRootElement(), checkValidActHandler)

function removePlayerHandler()
	kickPlayer(source)
end
addEvent("removePlayer",true)
addEventHandler("removePlayer",getRootElement(), removePlayerHandler)