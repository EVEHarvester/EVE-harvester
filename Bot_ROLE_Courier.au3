; Courier role proxy function
Func Courier($location, $state)
	If $location = "station" Then
		If $state = "free" Then
			Courier_station_free()
		EndIf
	ElseIf $location = "space" Then
		If $state = "free" Then
			Courier_space_free()
		ElseIf $state = "flying" Then
			Courier_space_flying()
		EndIf
	EndIf
EndFunc

Func Courier_station_free()
	Local $cargo = BOT_CheckCargo()

	; if window closed on cargo timeout
	If $cargo = -1 Then
		Return False
	EndIf

	BOT_checkInventory()

	If Not BOT_checkAlarm("station") Then
		Return True
	EndIf

	ACT_ActivatePAPTab()
	Local $PAP_bookmarkStationState = OCR_getPNPItemType(GUI_BookmarkGetPosition("station"))
	Local $PAP_bookmarkDestinationState = OCR_getPNPItemType(GUI_BookmarkGetPosition("destination"))

	; if we are in start station
	If $PAP_bookmarkStationState = "current" Then
		BOT_LogMessage("Load cargo", 1)
		ACT_InventoryMoveItems("stationItems", "shipCargo", True)
		UTL_Wait(1, 2)
		Send("{ENTER}")

		; if cargo bar not loaded wait and check cargo again
		If $cargo = 0 Then
			UTL_Wait(2, 3)
			$cargo = BOT_CheckCargo()
		EndIf

		; if still no cargo, load 1 cargo position
		If $cargo = 0 Then
			ACT_StackAll("stationHangar")
			ACT_RandomMouseMoves(1, 500, 0, 1000, 500)
			UTL_Wait(2, 3)
			BOT_LogMessage("Load one cargo position", 1)
			ACT_InventoryMoveItems("stationItems", "shipCargo", False)
			UTL_Wait(1, 2)
			Send("{ENTER}")
			UTL_Wait(1, 2)
			$cargo = BOT_CheckCargo()
		EndIf

		If $cargo = 0 Then
			;all cargo transported, stop bot
			BOT_LogMessage("All cargo transported", 1)
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			BOT_CloseWindow("All cargo transported. Bot disabled")
			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return True
		Else
			If $PAP_bookmarkDestinationState <> "destination" Then
				BOT_LogMessage("Set new destination", 1)
				ACT_SetDestination(GUI_BookmarkGetPosition("destination"))
			EndIf
			Station_undock()
		EndIf
	ElseIf $PAP_bookmarkDestinationState = "current" Then
		If $cargo > 0 Then
			BOT_LogMessage("Unload cargo", 1)
			Station_unloadCargo("stuff")
		EndIf
		If $PAP_bookmarkStationState <> "destination" Then
			BOT_LogMessage("Set new base", 1)
			ACT_SetDestination(GUI_BookmarkGetPosition("station"))
		EndIf
		Station_undock()
	EndIf

	GUI_SetLastActionTime()

	BOT_CheckTimeout("station")
EndFunc

Func Courier_space_free()
	;if enemy was not found in station, but appeared after undock
	If $GLB_stayInStation[$GLB_curBot] <> -5 And $GLB_stayInStation[$GLB_curBot] <> -6 Then
		BOT_CheckLocal()
	EndIf

	Local $cargo = BOT_CheckCargo()
	Local $PAP_bookmark1 = OCR_getPNPItemType(1)
	Local $PAP_bookmark2 = OCR_getPNPItemType(2)

	If $PAP_bookmark1 = "destination" Then
		If $cargo > 5 And $GLB_stayInStation[$GLB_curBot] = 0 Then
			BOT_LogMessage("Too many cargo or alert, return to station", 1)
			ACT_ActivatePAPTab()
			ACT_DockToStation(False, "destination")
			Return True
		EndIf
	ElseIf $PAP_bookmark2 = "destination" Then
		If $cargo = 0 And $GLB_stayInStation[$GLB_curBot] = 0 Then
			BOT_LogMessage("Too low cargo or alert, return to station", 1)
			ACT_ActivatePAPTab()
			ACT_DockToStation()
			Return True
		EndIf
	EndIf

	ACT_SwitchTab("default")
	Local $dest = OCR_CheckDestinationPresent()

	If $dest <> False Then
		ACT_ClickOverviewObject($dest[2])
		ACT_SI_Jump()
		UTL_Wait(1, 2)
		ACT_ClickOverviewObject($dest[2])
	EndIf
	GUI_SetLocationAndState("space", "flying")
EndFunc

Func Courier_space_flying()
	If OCR_WrapIsActive() Then
		BOT_LogMessage("Warp is active, flying", 1)
		Return True
	ElseIf OCR_JumpIsActive() Then
		BOT_LogMessage("Jump is active, flying", 1)
		Return True
	ElseIf OCR_DockJumpActivateGateIsActive() Then
		BOT_LogMessage("Dock/Jump/Activate Gate is active, flying", 1)
		Send("{SPACE}")
		Return True
	ElseIf OCR_EngineIsActive() Then
		BOT_LogMessage("Engine active, flying", 1)
		Return True
	EndIf

	ACT_SwitchTab("default")
	Local $dest = OCR_CheckDestinationPresent()

	If $dest <> False Then
		BOT_LogMessage("Go to destination", 1)
		ACT_ClickOverviewObject($dest[2])
		ACT_SI_Jump()
		UTL_Wait(1, 2)
		ACT_ClickOverviewObject($dest[2])
	Else
		UTL_Wait(3, 4)

		$dest = OCR_CheckDestinationPresent()
		If $dest <> False Then
			BOT_LogMessage("Exiting jump", 1)
			GUI_SetLocationAndState("space", "flying")
			Return
		EndIf

		ACT_SetView()
		UTL_Wait(2, 3)

		If OCR_CheckGatePresent(1) = False Then
			BOT_LogMessage("Jumping gate", 1)
			If Random(0, 1) > 0.5 Then
				ACT_ClickOverviewObject(2)
			EndIf
		Else
			BOT_LogMessage("Dock to destination", 1)
			ACT_ActivatePAPTab()
			Local $PAP_bookmark1 = OCR_getPNPItemType(1)
			Local $PAP_bookmark2 = OCR_getPNPItemType(2)
			If $PAP_bookmark1 = "destination" Then
				ACT_DockToStation(True)
			ElseIf $PAP_bookmark2 = "destination" Then
				ACT_DockToStation(True, "destination")
			Else
				UTL_LogScreen("Destination not found", "destination")
				ACT_RandomMouseMoves(1, 50, 0, 700, 500)
			EndIf
		EndIf
	EndIf
EndFunc