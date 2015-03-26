; BeltMiner role proxy function
Func BeltMiner($location, $state)
	If $location = "station" Then
		If $state = "free" Then
			;BeltMiner_station_free()
		EndIf
	ElseIf $location = "space" Then
		If $state = "free" Then
			;BeltMiner_space_free()
		EndIf
	ElseIf $location = "spot" Then
		If $state = "free" Then
			;BeltMiner_spot_free()
		EndIf
	ElseIf $location = "belt" Then
		If $state = "free" Then
			BeltMiner_belt_free()
		ElseIf $state = "mining" Then
			BeltMiner_belt_mining()
		ElseIf $state = "unloading" Then
			BeltMiner_belt_unloading()
		ElseIf $state = "flying" Then
			BeltMiner_belt_flying()
		ElseIf $state = "dronesReturn" Then
			BeltMiner_belt_dronesReturn()
		EndIf
	EndIf
EndFunc

Func BeltMiner_belt_free()
	;do not mine if NPC found
	If GUI_getSecurityStatus() = "Low" Then
		ACT_SwitchTab("npc")
		Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
		If $NPCcounter <> False And $NPCcounter > 1 Then
			Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
			If $maxBookmark = 1 Then
				BOT_LogMessage("NPC found. Run away from the belt", 1)
				$GLB_stayInStation[$GLB_curBot] = 60 * 3
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("NPC found. Changing belt", 1)
				GUI_SetLocationAndState("belt", "next")
			EndIf
			Return
		EndIf
	EndIf

	If Space_launchDrones() = False Then
		Return False
	EndIf

	ACT_SetView()

	Local $cargo = BOT_CheckCargo()
	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
		GUI_SetLocationAndState("belt", "unloading")
		Return False
	EndIf

	Space_checkMiningCrystals()

	ACT_SwitchTab("asteroids")

	ACT_RandomMouseMoves(1, 0, 0, 512, 760)
	BOT_CheckSorting("overview")

	; if asteroids available for action
	If Space_checkAsteroidDistance() Then
		; try to mine asteroid
		Local $actionDistance = GUICtrlRead($GUI_actionDistance[$GLB_curBot])
		Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($actionDistance, 3)
		$GUI_miningAsteroidNumber[$GLB_curBot] = 1
		BOT_ActivateMining($asteroidsAmount)
	EndIf
EndFunc

Func BeltMiner_belt_mining()
	Local $cargo = BOT_CheckCargo()
	;if cargo is full
	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
		BOT_LogMessage("Cargo is full", 1)
		GUI_SetLocationAndState("belt", "unloading")
		STA_SetIntervalTimestamp("mining_end")
		STA_FinalizeInterval("mining")
		Return True
	EndIf

	;do not mine if NPC found
	If GUI_getSecurityStatus() = "Low" Then
		ACT_SwitchTab("npc")
		Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
		If $NPCcounter <> False And $NPCcounter > 1 Then
			Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
			If $maxBookmark = 1 Then
				BOT_LogMessage("NPC found. Run away from the belt", 1)
				$GLB_stayInStation[$GLB_curBot] = 60 * 3
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("NPC found. Changing belt", 1)
				GUI_SetLocationAndState("belt", "next")
			EndIf
			Return
		EndIf
	EndIf

	If Not BOT_CheckMining() Then
		;if mining interrupted
		BOT_LogMessage("Mining interrupted", 1)
		ACT_SwitchTab("asteroids")

		If Space_checkAsteroidDistance() Then
			BOT_CheckSorting("overview")
			ACT_RandomMouseMoves(1, 0, 0, 512, 760)

			If $GUI_miningAsteroidNumber[$GLB_curBot] >= $GLB_miningTryLimit Then
				BOT_LogMessage("Mined try limit(" & $GLB_miningTryLimit & ") reached. Going to next bookmark", 1)
				$GUI_miningAsteroidNumber[$GLB_curBot] = 0
				GUI_SetLocationAndState("belt", "next")
			Else
				; try to mine next asteroid
				Local $actionDistance = GUICtrlRead($GUI_actionDistance[$GLB_curBot])
				Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($actionDistance, 3)
				$GUI_miningAsteroidNumber[$GLB_curBot] += 1
				BOT_LogMessage("Mining, try #" & $GUI_miningAsteroidNumber[$GLB_curBot], 1)
				ACT_UnlockActiveObject()
				ACT_DeactivateMiners()
				BOT_ActivateMining($asteroidsAmount)
			EndIf
		EndIf
	Else
		If Not Space_checkMinersReload() Then
			$cargo = BOT_CheckCargo()
		EndIf

		; if mining is active
		Local $activateOneOnly = False
		If GUI_getSecurityStatus() = "Low" Then
			$activateOneOnly = True
		EndIf

		;if cargo is full
		If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
			BOT_LogMessage("Cargo is full", 1)
			GUI_SetLocationAndState("belt", "unloading")
			STA_SetIntervalTimestamp("mining_end")
			STA_FinalizeInterval("mining")
			Return True
		EndIf

		Space_checkAsteroidDistance(GUICtrlRead($GUI_mineAtOnce[$GLB_curBot]) + 1)

		BOT_LogMessage("Mining in process", 1)
	EndIf
EndFunc

Func BeltMiner_belt_flying()
	If Space_checkAsteroidDistance() Then
		ACT_StopEngine()

		; deactivate afterburner
		If OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
			ACT_ActivateModule("middle", "afterburner")
		EndIf

		Local $actionDistance = GUICtrlRead($GUI_actionDistance[$GLB_curBot])
		Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($actionDistance, 3)
		$GUI_miningAsteroidNumber[$GLB_curBot] += 1
		BOT_LogMessage("Mining after flying, try #" & $GUI_miningAsteroidNumber[$GLB_curBot], 1)
		ACT_UnlockActiveObject()
		BOT_ActivateMining($asteroidsAmount)
	EndIf
EndFunc

Func BeltMiner_belt_unloading()
	Local $cargo = BOT_CheckCargo()
	Local $fullCargo = GUICtrlRead($GUI_fullCargo[$GLB_curBot])
	If $cargo >= $fullCargo Then
		; deactivate all miners
		If OCR_isActiveHighSlot() Then
			ACT_ActivateModule("high", "miner")
		EndIf

		If Space_returnDrones() Then
			Space_backToBase()
		EndIf
	Else
		GUI_SetLocationAndState("belt", "free")
	EndIf
EndFunc

Func BeltMiner_belt_dronesReturn()
	ACT_SwitchTab("drones")
	Local $drone = OCR_CheckDronePresent()
	If $drone <> False Then
		ACT_ClickOverviewObject()
		UTL_Wait(0.5, 1)
		ACT_SI_ObjectApproach("drone")
		ACT_ReturnCurrentDrone()
		BOT_LogMessage("Waiting for drones", 1)
	Else
		Space_backToBase()
	EndIf
	BOT_CheckTimeout("drones")
EndFunc