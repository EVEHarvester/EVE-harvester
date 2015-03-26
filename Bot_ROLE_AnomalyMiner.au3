Global $AnomalyMiner_lastOreAnomalyPosition[1]

; AnomalyMiner role proxy function
Func AnomalyMiner($location, $state)
	If $location = "station" Then
		If $state = "free" Then
			AnomalyMiner_station_free()
		EndIf
	ElseIf $location = "space" Then
		If $state = "free" Then
			AnomalyMiner_space_free()
		EndIf
	ElseIf $location = "anomaly" Then
		If $state = "free" Then
			AnomalyMiner_anomaly_free()
		ElseIf $state = "mining" Then
			AnomalyMiner_anomaly_mining()
		ElseIf $state = "next" Then
			AnomalyMiner_anomaly_next()
		ElseIf $state = "flying" Then
			AnomalyMiner_anomaly_flying()
		EndIf
	ElseIf $location = "spot" Then
		If $state = "free" Then
			AnomalyMiner_spot_free()
		EndIf
	EndIf
EndFunc

Func AnomalyMiner_station_free()
	Local $cargo = BOT_CheckCargo()

	BOT_checkInventory()

	; if cargo bar not loaded wait and check cargo again
	If $cargo = 0 Then
		UTL_Wait(2, 3)
		$cargo = BOT_CheckCargo()
	EndIf

	; hide inventory filters panel
	;BOT_CheckInventoryFilters()

	If Not BOT_checkAlarm("station") Then
		Return True
	EndIf

	If $cargo > 0 Then
		Station_unloadCargo("ore")
		UTL_Wait(2, 2.5)
	Else
		; repair all if drones used
		If GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED And GUICtrlRead($GUI_repairDrones[$GLB_curBot]) = $GUI_CHECKED Then
			Station_repairDrones()
		EndIf

		Station_undock()
	EndIf

	GUI_SetLastActionTime()
	BOT_CheckTimeout("station")
EndFunc

Func AnomalyMiner_space_free()
	ACT_StopEngine()
	ACT_ActivateScannerWindow()

	;if enemy was not found in station, but appeared after undock
	If $GLB_stayInStation[$GLB_curBot] <> -5 And $GLB_stayInStation[$GLB_curBot] <> -6 Then
		BOT_CheckLocal()
	EndIf

	Local $cargo = BOT_CheckCargo()
	If $cargo < 5 And $GLB_stayInStation[$GLB_curBot] = 0 And $GLB_forcedUnload[$GLB_curBot] = 0 Then
		Local $oreNumber
		Local $oreType = GUICtrlRead($GUI_oreType[$GLB_curBot])

		; try to warp in old anomaly
		If $AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] <> -1 Then
			;if anomaly already was found
			Local $oreNumber = OCR_CheckScannerItem($AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot], "ore", $oreType)
			If $oreNumber <> False Then
				; if anomaly still present in old position
				ACT_WarpToScannerItemByButton($oreNumber)
				Return True
			EndIf
		EndIf

		;skan for new position of ore anomaly
		$oreNumber = Space_FindScannerItem("ore", $oreType)
		If $oreNumber <> False Then
			ACT_WarpToScannerItemByButton($oreNumber)
			$AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] = $oreNumber
		Else
			Local $iceCheckPeriod = GUICtrlRead($GUI_iceCheckPeriod[$GLB_curBot])
			$GLB_stayInStation[$GLB_curBot] = $iceCheckPeriod * 60
			$AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] = -1
			ACT_ActivatePAPTab()
			ACT_DockToStation()
		EndIf
	Else
		ACT_ActivatePAPTab()
		ACT_DockToStation()
	EndIf
EndFunc

Func AnomalyMiner_anomaly_free()
	Local $cargo = BOT_CheckCargo()
	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
		GUI_SetLocationAndState("anomaly", "unloading")
		Return True
	EndIf

	Space_checkMiningCrystals()

	ACT_SwitchTab("asteroids")

	Local $asteroid = OCR_CheckAsteroidPresent()
	If $asteroid = False Then
		BOT_LogMessage("Asteroids not found", 1)
		UTL_LogScreen("Asteroids not found")

		GUI_SetLocationAndState("anomaly", "next")
		Return False
	EndIf

	BOT_CheckSorting("overview")

	Local $asteroidDistance = Int(EVEOCR_GetOverviewObjectDistance(1))
	If $asteroidDistance > GUICtrlRead($GUI_miningLimit[$GLB_curBot]) * 1000 Then
		BOT_LogMessage("Asteroids too far away(limit " & GUICtrlRead($GUI_miningLimit[$GLB_curBot]) & " km). Approaching nearest", 1)
		UTL_LogScreen("Asteroids too far away(limit " & GUICtrlRead($GUI_miningLimit[$GLB_curBot]) & " km)")

		ACT_ClickOverviewObject(1)
		ACT_RandomMouseMoves()
		ACT_SI_ObjectApproach()
		UTL_SetWaitTimestamp(10)
		Return False
	EndIf

	ACT_ClickOverviewObject()
	ACT_RandomMouseMoves()

	; try to mine next asteroid
	Local $lockDistance = GUICtrlRead($GUI_lockDistance[$GLB_curBot])
	Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)
	ACT_StopEngine()
	$GUI_miningAsteroidNumber[$GLB_curBot] = 1
	BOT_ActivateMining($asteroidsAmount, "anomaly")
	ACT_RandomMouseMoves()
EndFunc

Func AnomalyMiner_anomaly_mining()
	Local $cargo = BOT_CheckCargo()

	;if cargo is full
	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
		BOT_LogMessage("Cargo is full", 1)
		GUI_SetLocationAndState("anomaly", "unloading")
		STA_SetIntervalTimestamp("mining_end")
		STA_FinalizeInterval("mining")
		Return True
	EndIf

	;do not mine if NPC found
	If GUI_getSecurityStatus() = "Low" Then
		ACT_SwitchTab("npc")
		Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
		If $NPCcounter <> False And $NPCcounter > 1 Then
			BOT_LogMessage("NPC found. Run away from the anomaly", 1)
			$GLB_stayInStation[$GLB_curBot] = 60 * 3
			Space_backToBase()
			Return
		EndIf
	EndIf

	If Not Space_checkMinersReload() Then
		$cargo = BOT_CheckCargo()
	EndIf

	;if mining interrupted
	If Not BOT_CheckMining() Then
		BOT_LogMessage("Mining interrupted", 1)

		ACT_SwitchTab("asteroids")

		Local $asteroid = OCR_CheckAsteroidPresent()
		If $asteroid = False Then
			BOT_LogMessage("Asteroids not found", 1)
			UTL_LogScreen("Asteroids not found")

			GUI_SetLocationAndState("anomaly", "next")
			Return False
		Else
			BOT_CheckSorting("overview")
			ACT_ClickOverviewObject(1)
			ACT_RandomMouseMoves(1, 0, 0, 512, 760)

			Local $asterDistance = Int(EVEOCR_GetOverviewObjectDistance(1))
			If $asterDistance > GUICtrlRead($GUI_miningLimit[$GLB_curBot]) * 1000 Then
				BOT_LogMessage("Asteroids too far away(limit " & GUICtrlRead($GUI_miningLimit[$GLB_curBot]) & " km). Approaching nearest", 1)
				UTL_LogScreen("Asteroids too far away(limit " & GUICtrlRead($GUI_miningLimit[$GLB_curBot]) & " km)")

				ACT_ClickOverviewObject(1)
				ACT_RandomMouseMoves()
				ACT_SI_ObjectApproach()
				UTL_SetWaitTimestamp(10)
				Return False
			EndIf

			; try to mine next asteroid
			Local $lockDistance = GUICtrlRead($GUI_lockDistance[$GLB_curBot])
			Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)
			ACT_StopEngine()
			$GUI_miningAsteroidNumber[$GLB_curBot] += 1
			BOT_LogMessage("Mining try #" & $GUI_miningAsteroidNumber[$GLB_curBot], 1)
			ACT_UnlockActiveObject()
			ACT_DeactivateMiners()
			BOT_ActivateMining($asteroidsAmount, "anomaly")
			ACT_RandomMouseMoves()
		EndIf
		Return True
	EndIf

	Local $activateOneOnly = False
	If GUI_getSecurityStatus() = "Low" Then
		$activateOneOnly = True
	EndIf

	;if cargo is full
	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
		BOT_LogMessage("Cargo is full", 1)
		GUI_SetLocationAndState("anomaly", "unloading")
		STA_SetIntervalTimestamp("mining_end")
		STA_FinalizeInterval("mining")
		Return True
	EndIf

	Space_checkAsteroidDistance(GUICtrlRead($GUI_mineAtOnce[$GLB_curBot]) + 1)

	BOT_LogMessage("Mining in process", 1)
EndFunc

Func AnomalyMiner_anomaly_flying()
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

Func AnomalyMiner_anomaly_next()
	Local $oreType = GUICtrlRead($GUI_oreType[$GLB_curBot])
	Local $anomalies = Space_GetScannerAnomaliesList()
	Local $oreAnomaliesCounter = Space_CountScannerItems("ore", $oreType)
	If $oreAnomaliesCounter > 1 Then
		For $i = 0 To UBound($anomalies) - 1 Step 1
			Local $anomalyPosition = $i + 1
			If $anomalies[$i] = "ore" And OCR_CheckScannerItemSubtype($i + 1, "ore") = $oreType And $anomalyPosition > $AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] Then
				ACT_WarpToScannerItemByButton($anomalyPosition)
				$AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] = $anomalyPosition
				Return True
			EndIf
		Next
	EndIf

	; back to base and wait if all steroids mined and all belt are passed
	Local $iceCheckPeriod = GUICtrlRead($GUI_iceCheckPeriod[$GLB_curBot])
	$GLB_stayInStation[$GLB_curBot] = $iceCheckPeriod * 60
	$AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] = -1
	Space_backToBase()
	Return False
EndFunc

Func AnomalyMiner_spot_free()
	Local $Base = GUICtrlRead($GUI_systemPOS[$GLB_curBot])

	If $GLB_stayInStation[$GLB_curBot] = 0 Then
		BOT_CheckLocal()
	EndIf

	If $GLB_stayInStation[$GLB_curBot] <> 0 Then
		If $Base = "None" Then
			BOT_checkAlarm("spot")
		Else
			Space_backToBase()
		EndIf
		Return False
	EndIf

	Local $cargo = BOT_CheckCargo()

	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
		If $Base = "None" Then
			$GLB_forcedUnload[$GLB_curBot] = 0
			GUI_SetLocationAndState("spot", "unloading")
		Else
			Space_backToBase()
		EndIf
	Else
		Local $oreNumber
		Local $oreType = GUICtrlRead($GUI_oreType[$GLB_curBot])

		; try to warp in old anomaly
		If $AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] <> -1 Then
			;if anomaly already was found
			Local $oreNumber = OCR_CheckScannerItem($AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot], "ore", $oreType)
			If $oreNumber <> False Then
				; if anomaly still present in old position
				ACT_WarpToScannerItemByButton($oreNumber)
				Return True
			EndIf
		EndIf

		;skan for new position of ore anomaly
		$oreNumber = Space_FindScannerItem("ore", $oreType)
		If $oreNumber <> False Then
			ACT_WarpToScannerItemByButton($oreNumber)
			$AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] = $oreNumber
		Else
			Local $iceCheckPeriod = GUICtrlRead($GUI_iceCheckPeriod[$GLB_curBot])
			$GLB_stayInStation[$GLB_curBot] = $iceCheckPeriod * 60
			$AnomalyMiner_lastOreAnomalyPosition[$GLB_curBot] = -1
			ACT_ActivatePAPTab()
			ACT_DockToStation()
		EndIf
	EndIf
EndFunc