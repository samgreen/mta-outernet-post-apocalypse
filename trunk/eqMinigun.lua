local eqMgSherrifColRect = createColRectangle ( -1415, 2643, 2, 3 )

local eqMgBridgeTopColRect = createColCuboid ( -1480.5, 2598, 65.912, 2, 2, 3)

local eqMgBridgeBotColRect = createColCuboid ( -1482.82, 2600.75, 63.1058, 2, 2, 3)

local eqMgComSoColRect = createColCuboid ( -1481.3, 2611.87, 58.1562, 2, 2, 3)

local eqMgComWeColRect = createColCuboid ( -1485.82, 2624.48, 58.1312, 2, 2, 3)

function giveMini (thePlayer)
	    
   
      giveWeapon ( thePlayer, 38, 400, true )
	
end 
	

function takeMini (thePlayer)
	    
  
      takeWeapon ( thePlayer, 38 )
end
	

   addEventHandler ( "onColShapeHit", eqMgSherrifColRect, giveMini ) 		

   addEventHandler ( "onColShapeLeave", eqMgSherrifColRect, takeMini )

   addEventHandler ( "onColShapeHit", eqMgBridgeTopColRect, giveMini ) 		

   addEventHandler ( "onColShapeLeave", eqMgBridgeTopColRect, takeMini )		
   addEventHandler ( "onColShapeHit", eqMgBridgeBotColRect, giveMini ) 		

   addEventHandler ( "onColShapeLeave", eqMgBridgeBotColRect, takeMini )	    
   addEventHandler ( "onColShapeHit", eqMgComSoColRect, giveMini ) 		

   addEventHandler ( "onColShapeLeave", eqMgComSoColRect, takeMini )		
   addEventHandler ( "onColShapeHit", eqMgComWeColRect, giveMini ) 		

   addEventHandler ( "onColShapeLeave", eqMgComWeColRect, takeMini ) 