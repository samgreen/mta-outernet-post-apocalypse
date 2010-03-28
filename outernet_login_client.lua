local localPlayer = getLocalPlayer()
local localPlayerName = getPlayerName(localPlayer)
local localRootElement = getRootElement()
local newUser
local passwordAttempts = 0
local wdwLogin

function CreateLoginWindow()	
	wdwLogin = guiCreateWindow(.125,.25,.75,.5,"Outernet: Apocalypse Survival Login",true)
	guiWindowSetSizable(wdwLogin,false)
	guiWindowSetMovable(wdwLogin,false)
	
	imgLoginHeader = guiCreateStaticImage(0,0,1,1,"images/LoginHeader.jpg",true,wdwLogin)
		
	lblUser = guiCreateLabel(.77,.81,.1,.05,"Username:",true,wdwLogin)	
	guiLabelSetColor(lblUser,255,255,255)
	guiLabelSetVerticalAlign(lblUser,"center")
	guiLabelSetHorizontalAlign(lblUser,"right",false)
	
	edtUser = guiCreateEdit(.87,.81,.12,.05,localPlayerName,true,wdwLogin)
	guiEditSetReadOnly(edtUser,true)	
		
	lblPass = guiCreateLabel(.77,.87,.1,.05,"Password:",true,wdwLogin)
	guiLabelSetColor(lblPass,255,255,255)
	guiLabelSetVerticalAlign(lblPass,"center")
	guiLabelSetHorizontalAlign(lblPass,"right",false)
	
	edtPass = guiCreateEdit(.87,.87,.12,.05,"",true,wdwLogin)
	guiEditSetMaxLength(edtPass,20)
	guiEditSetMasked(edtPass,true)
	
	btnLogin = guiCreateButton(.87,.93,.21,.05,"Log In",true,wdwLogin)

	guiSetVisible(wdwLogin,false)
end

-- Add this as a handler so that the function will be triggered every time the local player fires.
function onClientPlayerWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	-- Are they using the spray can?
    if weapon == 41 then
    	local positionX, positionY, positionZ = getElementPosition(source)
        fxAddBlood(positionX, positionY, positionZ, 0, 0, 1.0, 3)
    end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer(), onClientPlayerWeaponFire )

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
	function()
		CreateLoginWindow()
		
		-- Hide the chat
	 	showChat(false)
	 
		lblDisplayArea = guiCreateLabel(0.100,0.800,0.800,0.100,"",true)
		guiLabelSetHorizontalAlign(lblDisplayArea,"center",true)
			
		addEventHandler("onClientGUIClick",btnLogin,clientEnterLogin,false) -- Mouseclick on the Login button...
		addEventHandler("onClientGUIAccepted",edtPass,clientEnterLogin,false) --Hitting 'enter' key in password box...

		triggerServerEvent("checkValidAct", localPlayer, localPlayerName) --Check if they have an account to log in to...
	end
)

function clientNewUserHandler() --Called when no account exists for this players name...
	newUser = true
	clientDisplayAreaHandler("No account exists for your username. Please create a password for your new account.", 1)

	if (wdwLogin) then
		guiSetText(btnLogin, "Register")
		
		guiSetVisible(wdwLogin,true)
		guiBringToFront(edtPass) --Puts the cursor into the password box for typing...		
		showCursor(true)
		guiSetInputEnabled(true)
	end	
end
addEvent("clientNewUser",true)
addEventHandler("clientNewUser",localRootElement,clientNewUserHandler)

function clientReturningUserHandler() --Called when there is an existing account for this player's name...
	newUser = false
	clientDisplayAreaHandler("You are using a registered account. Please enter your password now.", 0)

	if (wdwLogin) then
		guiSetText(btnLogin, "Login")
		
		guiSetVisible(wdwLogin,true)
		guiBringToFront(edtPass) --Puts the cursor into the password box for typing...		
		showCursor(true)
		guiSetInputEnabled(true)
	end
end
addEvent("clientReturningUser",true)
addEventHandler("clientReturningUser",localRootElement,clientReturningUserHandler)

function clientEnterLogin()
	if(newUser) then
		triggerServerEvent("SubmitCreate",localRootElement,guiGetText(edtUser),guiGetText(edtPass))
	else
		triggerServerEvent("SubmitLogin",localRootElement,guiGetText(edtUser),guiGetText(edtPass))
	end
end

function modifySpeed()	
	-- Infected only!
	if getPlayerTeam(getLocalPlayer()) ~= teamInfected then return end
	
	
	if getControlState ( "forwards") then
		outputDebugString("Sprinting!")
		local speedX, speedY, speedZ = getElementVelocity(getLocalPlayer())
		if math.abs(speedX) < 150 and math.abs(speedX) < 150 then
			setElementVelocity(getLocalPlayer(), x*2.1, y*2.1, z)
			outputDebugString("Modifying velocity!")
		end
	end
end
addEventHandler ( "onClientRender", localRootElement, modifySpeed )

function clientDisplayAreaHandler(theMessage, errorLevel)
	guiSetText(lblDisplayArea,theMessage)
	
	if errorLevel == 0 then
		-- Green Message
		guiLabelSetColor(lblDisplayArea,0,128,0)
	elseif errorLevel == 1 then
		-- Yellow Message
		guiLabelSetColor(lblDisplayArea,0,255,255)
	elseif errorLevel == 2 then
		-- Red Message
		guiLabelSetColor(lblDisplayArea,255,0,0)
	end
end
addEvent("clientDisplayArea",true)
addEventHandler("clientDisplayArea",localRootElement,clientDisplayAreaHandler)

function clientWrongPasswordHandler(theMessage)
	passwordAttempts = passwordAttempts + 1
	if(passwordAttempts > 3) then
		clientDisplayAreaHandler("Too many failed login attempts. Goodbye.", 2)

		destroyElement(wdwLogin)
		triggerServerEvent("removePlayer",localPlayer)
	end
end
addEvent("clientWrongPassword",true)
addEventHandler("clientWrongPassword",localRootElement,clientWrongPasswordHandler)

function clientLoginSuccessHandler()
	guiSetInputEnabled(false)
	showCursor(false)
	guiSetVisible(wdwLogin,false)
	guiSetVisible(lblDisplayArea,false)
	
	-- Show the chat
	showChat(true)
end
addEvent("clientLoginSuccess",true)
addEventHandler("clientLoginSuccess",localRootElement,clientLoginSuccessHandler)