local eqGateOpener = createColRectangle ( -1352, 2155, 20, 20 )


   function lowerEqGate (thePlayer)		
	        
	        moveObject(getElementByID ("object (plasticsgate1) (1)"), 4000, -1350.01, 2166.49, 48.80783 )
    end

    function raiseEqGate (thePlayer)		
	        
	        moveObject(getElementByID ("object (plasticsgate1) (1)"), 4000, -1350.01, 2166.49, 52.508 )
    end


addEventHandler ( "onColShapeHit", eqGateOpener, raiseEqGate )

addEventHandler ( "onColShapeLeave", eqGateOpener, lowerEqGate )