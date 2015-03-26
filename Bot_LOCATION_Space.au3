;launch drones
Func Space_launchDrones()
	If GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED Then
		ACT_LaunchDrones()
		OCR_isFreeze()
		UTL_Wait(1, 2)
		If OCR_isFreeze() Then
			BOT_LogMessage("Freeze on drones launch. Waiting 1 minute", 1)
			UTL_Wait(2, 3)
			UTL_SetWaitTimestamp(57)
			Return False
		Else
			ACT_ClickOverviewObject()
			BOT_LogMessage("Drones launched", 1)
		EndIf
	EndIf
	Return True
EndFunc

;return drones
Func Space_returnDrones($location = "belt")
	If GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED Then
		ACT_ReturnDrones()
		If GUICtrlRead($GUI_waitDrones[$GLB_curBot]) = $GUI_CHECKED Then
			GUI_SetLocationAndState($location, "dronesReturn")
			Return False
		Else
			UTL_Wait(2,3)
			BOT_LogMessage("Return drones", 1)
			Return True
		EndIf
	EndIf
	Return True
EndFunc

Func Space_backToBase()
	Local $base = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
	If $base = "Station" Then
		ACT_DockToStation(True)
	ElseIf $base = "Station and POS" Or $base = "POS" Then
		ACT_WarpTo("pos")
	EndIf
EndFunc

; reload mining lasers if needed
Func Space_checkMinersReload()
	Local $reload = GUICtrlRead($GUI_minersReload[$GLB_curBot])
	If $reload <> "No" And (_TimeGetStamp() - $GUI_minersReloadTS[$GLB_curBot]) > Int($reload) And BOT_CheckMining() Then
		BOT_LogMessage("Miners reloading", 1)

		ACT_DeactivateMiners()
		UTL_Wait(0.9, 1)

		Local $amountOfLocks = GUICtrlRead($GUI_mineAtOnce[$GLB_curBot])
		Local $amountOfCurrentLocks = OCR_countLockedObjects()

		; lock more asteroids if needed
		If $amountOfCurrentLocks < $amountOfLocks Then
			Local $needToLock = $amountOfLocks - $amountOfCurrentLocks
			Local $overviewItemsCapacity = $GLB_overviewContentItems
			Local $actionDistance = GUICtrlRead($GUI_actionDistance[$GLB_curBot])

			BOT_LogMessage("Space_checkMinersReload: needToLock=" & $needToLock, 1)
			For $i = 0 To $overviewItemsCapacity Step 1
				If $needToLock = 0 Or EVEOCR_GetOverviewObjectDistance($i + 1) >= $actionDistance*1000 Then
					ExitLoop
				EndIf

				Local $x1 = $GLB_ObjectSearch[0]
				Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)

				If Not OCR_isObjectLocked($x1, $y1) Then
					ACT_ClickOverviewObject($i + 1)
					ACT_SI_ObjectLock("asteroid")
					$needToLock = $needToLock - 1
				EndIf
			Next
		EndIf

		If GUI_getSecurityStatus() = "High" Then
			If $amountOfLocks >= 1 Then
				ACT_ActivateLockedTarget(1)
				ACT_ActivateMining(1, 1)
				ACT_ActivateLockedTarget(1)
			EndIf

			If $amountOfLocks >= 2 Then
				ACT_ActivateLockedTarget(2)
				ACT_ActivateMining(2, 2)
				ACT_ActivateLockedTarget(2)
			EndIf

			If $amountOfLocks = 3 Then
				ACT_ActivateLockedTarget(3)
				ACT_ActivateMining(3, 3)
				ACT_ActivateLockedTarget(3)
			EndIf
		ElseIf GUI_getSecurityStatus() = "Low" Then
			If $amountOfLocks = 1 Then
				$GLB_lastReactivatedSlot[$GLB_curBot] = 1
			ElseIf $amountOfLocks = 2 Then
				;be carefull with capacitor in lowsec
				If $GLB_lastReactivatedSlot[$GLB_curBot] = 2 Then
					$GLB_lastReactivatedSlot[$GLB_curBot] = 1
				Else
					$GLB_lastReactivatedSlot[$GLB_curBot] += 1
				EndIf
			ElseIf $amountOfLocks = 3 Then
				;be carefull with capacitor in lowsec
				If $GLB_lastReactivatedSlot[$GLB_curBot] = 3 Then
					$GLB_lastReactivatedSlot[$GLB_curBot] = 1
				Else
					$GLB_lastReactivatedSlot[$GLB_curBot] += 1
				EndIf
			EndIf

			ACT_ActivateLockedTarget(1)
			ACT_ActivateLockedTarget($GLB_lastReactivatedSlot[$GLB_curBot])
			ACT_ActivateMining($GLB_lastReactivatedSlot[$GLB_curBot], $GLB_lastReactivatedSlot[$GLB_curBot])
		EndIf

		ACT_ClickOverviewObject()

		If Not BOT_CheckMining() Then
			ACT_MouseClick("right", 390, 45, 10, 10, 1, 5, 1)
			ACT_MouseClick("left", 370, 45, 5, 5, 1, 5, 1)
		EndIf

		$GUI_minersReloadTS[$GLB_curBot] = _TimeGetStamp()

		Return False
	EndIf
	Return True
EndFunc

; check and reload mining crystals if needed
Func Space_checkMiningCrystals()
	Local $crystalsCheck = GUICtrlRead($GUI_changeMiningCrystals[$GLB_curBot])
	Local $now = _TimeGetStamp()
	Local $diffMax = Int($crystalsCheck)*60*60
	Local $diffCurrent = $now - $GLB_lastCrystalReloadTime[$GLB_curBot]

	If $crystalsCheck <> "No" And $diffCurrent > $diffMax Then
		BOT_LogMessage("Changing crystals", 1)
		Local $attrs[2]

		ACT_InventoryActivateTopItem()

		Local $slots = GUI_GetSlotPosition("high", "miner", True)

		If $slots[0] = True Then
			For $s = 1 To UBound($slots) - 1 Step 1
				BOT_LogMessage("Changing crystal in slot " & $slots[$s], 1)
				Dim $attrs[2] = ["high", $slots[$s]]
				ACT_InventoryMoveItems("shipCargo", "shipSlot", False, 0, $attrs)
				UTL_Wait(0.5, 1)
				Send("{ENTER}")
			Next
		Else
			BOT_LogMessage("Mining slots not set", 1)
		EndIf

		ACT_InventoryActivateItem(3)

		$GLB_lastCrystalReloadTime[$GLB_curBot] = $now
		Return False
	EndIf

	BOT_LogMessage("Crystals are OK", 1)
	Return True
EndFunc

Func Space_checkAsteroidDistance($asteroidNumber = 1)
	Local $location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
	Local $asteroid = OCR_CheckAsteroidPresent()
	If $asteroid = False Then
		BOT_LogMessage("Asteroids not found", 1)
		UTL_LogScreen("Asteroids not found")
		If GUICtrlRead($GUI_bookmarkMax[$GLB_curBot]) = 1 Then
			Space_backToBase()
			$GLB_stayInStation[$GLB_curBot] = -1
		Else
			GUI_SetLocationAndState($location, "next")
		EndIf
		Return False
	Else
		Local $asteroidDistance = Int(EVEOCR_GetOverviewObjectDistance($asteroidNumber))
		Local $limitDistance = GUICtrlRead($GUI_miningLimit[$GLB_curBot]) + $GLB_allBeltsDone[$GLB_curBot]
		If $asteroidNumber = 1 And $asteroidDistance >= $limitDistance * 1000 Then
			Local $faMessage = "Asteroids too far away(limit " & $limitDistance & " km)"
			BOT_LogMessage($faMessage, 1)
			UTL_LogScreen($faMessage, "faraway")

			If GUICtrlRead($GUI_bookmarkMax[$GLB_curBot]) = 1 Then
				Space_backToBase()
				$GLB_stayInStation[$GLB_curBot] = -1
			Else
				GUI_SetLocationAndState($location, "next")
			EndIf
			Return False
		ElseIf $asteroidDistance >= GUICtrlRead($GUI_actionDistance[$GLB_curBot]) * 1000 Then
			; do not fly if we too close to first asteroid
			If $asteroidNumber <> 1 And Int(EVEOCR_GetOverviewObjectDistance(1)) < 1000 Then
				Return False
			EndIf
			;if asteroids not accessible for action
			;fly to asteroids
			ACT_ClickOverviewObject()
			ACT_SI_ObjectApproach()
			; activate afterburner
			If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
				ACT_ActivateModule("middle", "afterburner")
			EndIf
			ACT_RandomMouseMoves()
			GUI_SetLocationAndState($location, "flying")
			Return False
		EndIf
	EndIf
	Return True
EndFunc

;get anomalies list
Func Space_GetScannerAnomaliesList()
	Local $list[$GLB_SW_scan_coloredReslutsMaxItems]
	For $i = 0 To $GLB_SW_scan_coloredReslutsMaxItems - 1 Step 1
		Local $ore = OCR_CheckScannerItem($i + 1, "ore", "all")
		If $ore <> False Then
			_ArrayInsert ($list, $i, "ore")
		Else
			_ArrayInsert ($list, $i, "unknown")
		EndIf
	Next
	Return $list
EndFunc

;is anomaly present in scanner
Func Space_FindScannerItem($type, $subtype = "all")
	For $i = 0 To $GLB_SW_scan_coloredReslutsMaxItems - 1 Step 1
		If $type = "ore" Then
			Local $position = OCR_CheckScannerItem($i + 1, $type, $subtype)
			If $position <> False Then
				Return $position
			EndIf
		EndIf
	Next
	Return False
EndFunc

; count anomalies of type
Func Space_CountScannerItems($type, $subtype = "all")
	Local $anomalies = Space_GetScannerAnomaliesList()
	Local $counter = 0
	For $i = 0 To $GLB_SW_scan_coloredReslutsMaxItems - 1 Step 1
		Local $itemSubtype = OCR_CheckScannerItemSubtype($i + 1, $type)
		If $anomalies[$i] = $type And ($subtype = "all" Or $itemSubtype = $subtype) Then
			$counter=+1
		EndIf
	Next

	BOT_LogMessage("Amount of " & $type & "anomalies: " & $counter, 1)
	Return $counter
EndFunc