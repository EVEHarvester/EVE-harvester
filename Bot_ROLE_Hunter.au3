; Hunter role proxy function
Func Hunter($location, $state)
	If $location = "station" Then
		If $state = "free" Then
			Hunter_station_free()
		EndIf
	ElseIf $location = "space" Then
		If $state = "free" Then
			Hunter_space_free()
		EndIf
	ElseIf $location = "spot" Then
		If $state = "free" Then
			Hunter_spot_free()
		ElseIf $state = "ammo" Then
			Hunter_spot_ammo()
		EndIf
	ElseIf $location = "pos" Then
		If $state = "free" Then
			Hunter_pos_free()
		ElseIf $state = "ammo" Then
			Hunter_pos_ammo()
		EndIf
	ElseIf $location = "belt" Then
		If $state = "free" Then
			Hunter_belt_free()
		ElseIf $state = "npcWaiting" Then
			Hunter_belt_npcWaiting()
		ElseIf $state = "npc" Then
			Hunter_belt_npc()
		ElseIf $state = "wreck" Then
			Hunter_belt_wreck()
		EndIf
	ElseIf $location = "anomaly" Then
		If $state = "free" Then
			Hunter_anomaly_free()
		ElseIf $state = "npc" Then
			Hunter_anomaly_npc()
		EndIf
	EndIf
EndFunc

Func Hunter_station_free()
	Local $cargo = BOT_CheckCargo()

	BOT_checkInventory()

	; if cargo bar not loaded wait and check cargo again
	If $cargo = 0 Then
		ACT_StackAll("cargo")
		ACT_RandomMouseMoves(1, 500, 0, 1000, 500)
		UTL_Wait(2, 3)
		$cargo = BOT_CheckCargo()
	EndIf

	If Not BOT_checkAlarm("station") Then
		Return True
	EndIf

	If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
		Station_unloadCargo("general")
		$GLB_forcedUnload[$GLB_curBot] = 0
		UTL_Wait(2, 2.5)
		ACT_RandomMouseMoves(1, 500, 0, 1000, 500)
	ElseIf $cargo < 10 Then
		UTL_LogScreen("Ammo to low", "_ammo_load")
		Station_loadCargo(GUICtrlRead($GUI_ammoAmountInput[$GLB_curBot]))
		GUI_SetLocationAndState("station", "delay")
		UTL_Wait(2, 2.5)
		ACT_RandomMouseMoves(1, 500, 0, 1000, 500)
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

Func Hunter_space_free()
	;if enemy was not found in station, but appeared after undock
	If $GLB_stayInStation[$GLB_curBot] <> -5 And $GLB_stayInStation[$GLB_curBot] <> -6 Then
		BOT_CheckLocal()
	EndIf

	Local $cargo = BOT_CheckCargo()
	If $cargo < GUICtrlRead($GUI_fullCargo[$GLB_curBot]) And $GLB_stayInStation[$GLB_curBot] = 0 And $GLB_forcedUnload[$GLB_curBot] = 0 Then
		If $cargo < 5 Then
			Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
			If $POS = "Station" Then
				ACT_DockToStation()
			Else
				; pick up ammo
				ACT_WarpTo("spot")
			EndIf
			Return
		EndIf

		; warp to belt or anomaly
		Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])

		Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
		If $huntPlace = "Belt" Then
			ACT_WarpTo("belts", $curBookmark)
		ElseIf $huntPlace = "Anomaly" Then
			ACT_WarpTo("anomaly", $curBookmark)
		Else
			;TODO unknown hunt place
		EndIf
	Else
		ACT_ActivatePAPTab()
		ACT_DockToStation()
	EndIf
EndFunc

Func Hunter_spot_free()
	Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])

	If $GLB_stayInStation[$GLB_curBot] = 0 Then
		BOT_CheckLocal()
	EndIf

	If $GLB_stayInStation[$GLB_curBot] <> 0 Then
		If $POS = "Station" Then
			ACT_DockToStation(True)
		ElseIf $POS = "Station and POS" Or $POS = "POS" Then
			ACT_WarpTo("pos")
		ElseIf $POS = "None" Then
			BOT_checkAlarm("spot")
		EndIf
		Return False
	EndIf

	Local $cargo = BOT_CheckCargo()

	If $cargo < 10 Then
		If $POS = "Station" Then
			ACT_DockToStation(True)
		ElseIf $POS = "Station and POS" Or $POS = "POS" Then
			ACT_WarpTo("pos")
		ElseIf $POS = "None" Then
			GUI_SetLocationAndState("spot", "ammo")
		EndIf
	ElseIf $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
		If $POS = "Station" Then
			ACT_DockToStation(True)
		ElseIf $POS = "Station and POS" Or $POS = "POS" Then
			ACT_WarpTo("pos")
		ElseIf $POS = "None" Then
			$GLB_forcedUnload[$GLB_curBot] = 0
			GUI_SetLocationAndState("spot", "unloading")
		EndIf
	Else
		; warp to belt or anomaly
		Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
		Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
		If $huntPlace = "Belt" Then
			ACT_WarpTo("belts", $curBookmark)
		ElseIf $huntPlace = "Anomaly" Then
			GUI_SetLocationAndState("anomaly", "next")
		Else
			;TODO unknown hunt place
		EndIf
	EndIf
EndFunc

Func Hunter_spot_ammo()
	ACT_SwitchTab("containers")

	Local $posContainer = OCR_CheckContainerPresent()

	If $posContainer <> False Then
		ACT_ClickOverviewObject($posContainer[2])
		Local $distance = Int(EVEOCR_GetOverviewObjectDistance($posContainer[2]))
		If $distance < 2500 Then
			ACT_OpenContainer($posContainer)
			UTL_Wait(2, 3)

			ACT_InventoryActivateItem($GLB_inventoryWindow_treeContainerPosition)
			UTL_Wait(1, 2)
			ACT_InventoryMoveItems("container", "shipCargo")
			UTL_Wait(2, 2.5)
			ACT_RandomSend(GUICtrlRead($GUI_ammoAmountInput[$GLB_curBot]))
			Send("{ENTER}")
			UTL_Wait(2, 2.5)
			ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
			UTL_Wait(1, 2)
			ACT_StackAll("cargo")

			If Not OCR_AmmoLoaded(GUI_GetSlotPosition("high", "gun")) Then
				ACT_MoveAmmoIntoGun(GUI_GetSlotPosition("high", "gun"))
			EndIf

			GUI_SetLocationAndState("spot", "free")
		Else
			ACT_SI_ObjectApproach("container")
			BOT_LogMessage("Container too far away - " & $distance & " m", 1)
		EndIf
	Else
		BOT_LogMessage("Container not found", 1)
		UTL_LogScreen("Container not found", "pos")
		GUI_SetLocationAndState("spot", "noStorage")
	EndIf
EndFunc

Func Hunter_pos_free()
	If $GLB_stayInStation[$GLB_curBot] >= 0 Then
		BOT_CheckLocal()
	EndIf

	Local $cargo = BOT_CheckCargo()
	Local $unloadTo = GUICtrlRead($GUI_UnloadToCombo[$GLB_curBot])

	If Not BOT_checkAlarm("pos") Then
		Return True
	ElseIf $GLB_forcedUnload[$GLB_curBot] = 1 Then
		BOT_LogMessage("Forced unload", 1)
		UTL_LogScreen("Forced unload", "pos")
		GUI_SetLocationAndState("pos", "unloading")
		$GLB_forcedUnload[$GLB_curBot] = 0
	ElseIf $cargo < 10 Then
		ACT_SwitchTab("containers")

		Local $posStorage = OCR_CheckCorpHangarPresent()

		If $posStorage <> False Then
			ACT_ClickOverviewObject($posStorage[2])
			ACT_SI_ObjectApproach("container")
			GUI_SetLocationAndState("pos", "ammo")
		Else
			BOT_LogMessage("No storage found in POS", 1)
			ACT_WarpTo("pos", 1, True)
			$GLB_stayInStation[$GLB_curBot] = 20
		EndIf
	ElseIf $cargo > GUICtrlRead($GUI_fullCargo[$GLB_curBot]) And $unloadTo = "POS" Then
		GUI_SetLocationAndState("pos", "unloading")
	Else
		BOT_WarpTo("Spot")
	EndIf
EndFunc

Func Hunter_pos_ammo()
	ACT_SwitchTab("containers")

	Local $posCorpHangar = OCR_CheckCorpHangarPresent()

	If $posCorpHangar <> False Then
		ACT_ClickOverviewObject($posCorpHangar[2])
		Local $distance = Int(EVEOCR_GetOverviewObjectDistance($posCorpHangar[2]))
		If $distance < 2500 Then
			ACT_OpenContainer($posCorpHangar, False, True)
			UTL_Wait(2, 3)

			;ACT_InventoryOpenInSeparateWindow(3)
			;UTL_Wait(2, 3)
			ACT_InventoryActivateTopItem()
			UTL_Wait(1, 2)
			ACT_InventoryMoveItems("corpHangar", "shipCargo")

			UTL_Wait(2, 2.5)
			ACT_RandomSend(GUICtrlRead($GUI_ammoAmountInput[$GLB_curBot]))
			Send("{ENTER}")
			UTL_Wait(2, 2.5)

			ACT_CloseCorpHangar()

			ACT_StackAll("cargo")

			If Not OCR_AmmoLoaded(GUI_GetSlotPosition("high", "gun")) Then
				ACT_MoveAmmoIntoGun(GUI_GetSlotPosition("high", "gun"))
			EndIf

			GUI_SetLocationAndState("pos", "skip")
		Else
			ACT_SI_ObjectApproach("container")
			BOT_LogMessage("Corp hangar too far away - " & $distance & " m", 1)
		EndIf
	Else
		BOT_LogMessage("Corp hangar not found", 1)
		UTL_LogScreen("Corp hangar not found", "pos")
		GUI_SetLocationAndState("pos", "noStorage")
	EndIf
EndFunc

Func Hunter_belt_free()
	Local $cargo = BOT_CheckCargo()
	; if window closed on cargo timeout
	If $cargo = -1 Then
		Return False
	EndIf

	If Space_launchDrones() = False Then
		Return False
	EndIf

	ACT_SetView()

	; if allowed to attack NPC and guns present
	If GUICtrlRead($GUI_attackNPCCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetBotGunsAmount() > 0 Then
		; if no ammo in cargo
		If $cargo < 10 Then
			BOT_LogMessage("Too low ammo", 1)
			If GUI_getSecurityStatus() = "Low" Then
				Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
				If $POS = "None" Then
					; warp to first spot with container
					ACT_WarpTo("spot", 1)
				Else
					BOT_WarpTo("Spot")
				EndIf
			Else
				ACT_DockToStation(True)
			EndIf
			Return
		EndIf

		;try to find NPC
		ACT_SwitchTab("npc")
		BOT_CheckSorting("overview", "icon")

		Local $NPC = BOT_CheckNPC()

		If $NPC <> False Then
			UTL_LogScreen("NPC found", "npc")
			BOT_LogMessage("NPC found", 1)
			SPEECH_Notify("overviewNPCFound")

			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($NPC[2]))
			BOT_LogMessage("Distance to NPC at arrival: " & $distance & " m", 1)
			If $distance > GUICtrlRead($GUI_lockDistance[$GLB_curBot]) * 1000 Then
				BOT_LogMessage("NPC too far away at arrival(limit " & GUICtrlRead($GUI_lockDistance[$GLB_curBot]) & " km)", 1)
				$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False
				GUI_SetLocationAndState("belt", "next")
				Return
			EndIf

			ACT_ReactivateGuns()

			If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
				ACT_ActivateModule("middle", "targetPainter")
			EndIf

			ACT_ClickOverviewObject($NPC[2])
			UTL_SetWaitTimestamp(UTL_CalcLockTime($NPC[3]))
			ACT_RandomMouseMoves(1, 50, 0, 700, 500)

			GUI_SetLocationAndState("belt", "npc")

			If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "shield"))  Then
				ACT_ActivateModule("middle", "shield")
			EndIf

			GUI_SetLastActionTime()
			Return True
		Else
			BOT_LogMessage("Suitable NPC not found", 1)
			$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False
			If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
				GUI_SetLocationAndState("belt", "next")
				Return
			EndIf
		EndIf
	EndIf

	; if allowed to loot wreks
	If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED Then
		;try to find Wrek
		ACT_SwitchTab("npc")
		BOT_CheckSorting("overview", "distance")
		Local $overviewSize = False

		Local $wreckType = "any"
		Local $isFaction = False
		If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
			$wreckType = "own"
		EndIf
		If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
			$isFaction = True
		EndIf

		Local $wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)

		If $wreck <> False Then
			BOT_LogMessage("Wreck found", 1)
			If Not BOT_CheckSorting("overview") Then
				$wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)
				;if wreck disapeared
				If $wreck = False Then
					BOT_LogMessage("Wreck disappeared", 1)
					Return
				EndIf
			EndIf
			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($wreck[2]))
			BOT_LogMessage("Distance to wreck: " & $distance & " m", 1)

			If $distance > 150000 Then
				ACT_WarpToOverviewObject($wreck[2])
				GUI_SetLocationAndState("space", "warping")
				Return
			ElseIf $distance < 20000 Then
				ACT_ActivateModule("high", "tractor")
			EndIf

			ACT_ClickOverviewObject($wreck[2])
			ACT_SI_ObjectApproach("wreck")
			GUI_SetLocationAndState("belt", "wreck")
			UTL_SetWaitTimestamp(5)
		Else
			BOT_LogMessage("No wrecks in belt", 1)
			GUI_SetLocationAndState("belt", "next")
		EndIf
	EndIf
EndFunc

Func Hunter_belt_npcWaiting()
	If OCR_CheckNPCPresent() <> False Then
		UTL_LogScreen("New NPC arrived", "npc")
		GUI_SetLocationAndState("belt", "npc")
	EndIf
	BOT_LogMessage("Waiting for NPC", 1)

	;if sudden wreck found
	If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And OCR_CheckWreckPresent() <> False Then
		GUI_SetLocationAndState("belt", "wreck")
	EndIf
EndFunc

Func Hunter_belt_npc()
	Local $cargo = BOT_CheckCargo()
	Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])

	; if window closed on cargo timeout
	If $cargo = -1 Then
		Return False
	EndIf

	;if gun active, wait
	If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "gun")) Then
		;activate target painter
		If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
			ACT_ActivateModule("middle", "targetPainter")
		EndIf
		Return
	EndIf

	BOT_CheckSorting("overview", "icon")

	Local $NPC = BOT_CheckNPC()

	; if all NPC killed
	If $NPC = False Then
		$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False

		ACT_ReloadAmmo()

		NET_ReportNPC($curBookmark, False)

		;If GUI_speechAllowed() Then SPEECH_Say(GUICtrlRead($GUI_login[$GLB_curBot]),"NPC истреблено в белте " & $curBookmark & ".")
		BOT_LogMessage("NPC destroyed", 1)

		If $cargo < 10 Then
			BOT_LogMessage("Low ammo", 1)
			If GUI_getSecurityStatus() = "Low" Then
				BOT_WarpTo("Spot")
			Else
				ACT_DockToStation(True)
			EndIf
			Return True
		EndIf

		; if somebody needs help with NPC
		Local $needHelp = NET_GetNPCbelt($GLB_curBot)
		If $needHelp <> False And $curBookmark <> $needHelp Then
			GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $needHelp)
			ACT_WarpTo("belts", $needHelp)
			If GUI_speechAllowed() Then SPEECH_Say(GUICtrlRead($GUI_login[$GLB_curBot]), "Going to help in belt� " & $needHelp & ".")
			Return True
		EndIf

		If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED Then
			GUI_SetLocationAndState("belt", "wreck")
		Else
			GUI_SetLocationAndState("belt", "next")
		EndIf
		Return True
	EndIf

	Local $lockedNPC = OCR_CheckNPCPresent(True)
	If $lockedNPC = False Then
		Local $distance = Int(EVEOCR_GetOverviewObjectDistance($NPC[2]))
		BOT_LogMessage("Distance to NPC: " & $distance & " m", 1)
		If $distance <= GUICtrlRead($GUI_lockDistance[$GLB_curBot]) * 1000 Then
			If $distance >= GUICtrlRead($GUI_actionDistance[$GLB_curBot]) * 1000 Then
				ACT_SI_ObjectRange("npc")

				If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
					ACT_ActivateModule("middle", "afterburner")
				EndIf
			Else
				; deactivate Afterburner
				If OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
					ACT_ActivateModule("middle", "afterburner")
				EndIf
			EndIf
		Else
			BOT_LogMessage("NPC too far away(limit " & GUICtrlRead($GUI_lockDistance[$GLB_curBot]) & " km)", 1)
			$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False
			GUI_SetLocationAndState("belt", "next")
			Return
		EndIf

		ACT_ReactivateGuns() ; wrecks too far avay if start to shoot immedeately

		If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
			ACT_ActivateModule("middle", "targetPainter")
		EndIf

		ACT_ClickOverviewObject($NPC[2])
		UTL_SetWaitTimestamp(UTL_CalcLockTime($NPC[3]))
		ACT_RandomMouseMoves(1, 50, 0, 700, 500)
	Else
		;activate target painter
		If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
			ACT_ActivateModule("middle", "targetPainter")
		EndIf

		ACT_ReactivateGuns()
	EndIf

	GUI_SetLastActionTime()
	BOT_LogMessage("NPC shooting")
EndFunc

Func Hunter_belt_wreck()
	; wait for salvage
	If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
		If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
			BOT_LogMessage("Waiting during salvaging", 1)
			Return
		EndIf
	EndIf

	Local $fullCargo = GUICtrlRead($GUI_fullCargo[$GLB_curBot])
	Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])

	; check cargo
	If BOT_CheckCargo() > $fullCargo Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
		GUI_SetLocationAndState("belt", "unloading")
		Return
	EndIf

	; if new npc arrived, stop looting and destroy them
	Local $NPC = BOT_CheckNPC()
	If $NPC <> False Then
		SPEECH_Notify("overviewNPCFound")
		UTL_LogScreen("New NPC arrived during wreck utilization", "npc")
		GUI_SetLocationAndState("belt", "npc")
		If OCR_IsWreckLock1Present() Then
			ACT_RemoveLock1ByMenu()
		EndIf
		Return
	EndIf

	Local $overviewSize = False
	Local $needHelp = NET_GetNPCbelt($GLB_curBot)
	If $needHelp <> False And $curBookmark <> $needHelp And $needHelp < GUICtrlRead($GUI_bookmarkMax[$GLB_curBot]) Then
		; if somebody needs help with NPC
		GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $needHelp)
		BOT_LogMessage("Help with NPC in belt " & $needHelp, 1)
		ACT_WarpTo("belts", $needHelp)
		If GUI_speechAllowed() Then SPEECH_Say(GUICtrlRead($GUI_login[$GLB_curBot]), "Going to help with npc� " & $needHelp & ".")
		Return
	EndIf

	ACT_SwitchTab("npc")

	Local $wreckType = "any"
	Local $isFaction = False
	If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
		$wreckType = "own"
	EndIf
	If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
		$isFaction = True
	EndIf

	Local $wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)

	If $wreck <> False Then
		If Not BOT_CheckSorting("overview") Then
			$wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)
			;if wreck disapeared
			If $wreck = False Then
				BOT_LogMessage("Wreck disappeared", 1)
				Return
			EndIf
		EndIf

		If OCR_IsWreckLock1Present() Then
			ACT_RemoveLock1ByMenu()
		EndIf

		ACT_RandomMouseMoves(1, 0, 0, 512, 760)
		Local $distance = Int(EVEOCR_GetOverviewObjectDistance($wreck[2]))

		BOT_LogMessage("Distance to wreck: " & $distance & " m", 1)

		If $distance > 150000 Then
			ACT_WarpToOverviewObject($wreck[2])
			GUI_SetLocationAndState("space", "warping")
			Return
		ElseIf $distance < 20000 Then
			If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
				ACT_ActivateModule("high", "tractor")
			EndIf
		EndIf

		ACT_ClickOverviewObject($wreck[2])
		ACT_SI_ObjectApproach("wreck")
		ACT_RandomMouseMoves(1, 0, 0, 512, 760)

		; if wreck was opened
		If $wreck[3] = "empty.used" Or $wreck[3] = "empty.ushared" Then
			; check and activate salvage
			If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
				If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
					ACT_ActivateModule("high", "salvager")
					ACT_ClickOverviewObject($wreck[2])
					Return
				EndIf
			EndIf
		Else
			If $distance < 2500 Then
				BOT_LogMessage("Loot wreck " & $wreck[2] & " at start", 1)
				ACT_OpenWreck()
				UTL_Wait(3, 4)
				UTL_LogScreen("Loot wreck, before", "loot")
				ACT_LootAll()
				UTL_Wait(3, 4)

				; if cargo empty, wreck window not closed
				If BOT_CheckCargo() = 0 Then
					ACT_InventoryActivateTopItem()
					GUI_SetLocationAndState("belt", "wreck")
					Return
				EndIf
				;UTL_LogScreen("Loot wreck, after", "loot")

				;deactivate tractor
				If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
					ACT_ActivateModule("high", "tractor")
				EndIf

				; check and activate salvage
				If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
					If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
						ACT_ActivateModule("high", "salvager")
						ACT_ClickOverviewObject($wreck[2])
					EndIf
				EndIf

				; force faction unload
				If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
					$GLB_forcedUnload[$GLB_curBot] = 1
				EndIf

				Return
			EndIf

			;activate afterburner
			If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
				ACT_ActivateModule("middle", "afterburner")
			EndIf
		EndIf

		UTL_SetTimeout("tractoring")
		GUI_SetLocationAndState("belt", "wreckTractoring")
		UTL_SetWaitTimestamp(5)
	Else
		BOT_LogMessage("No more wrecks", 1)
		GUI_SetLocationAndState("belt", "next")
		UTL_SetTimeout("cargo")
	EndIf
EndFunc

Func Hunter_anomaly_free()
	Local $NPCAttack = (GUICtrlRead($GUI_attackNPCCheckbox[$GLB_curBot]) = $GUI_CHECKED)
	Local $loot = (GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED)

	;try to find NPC
	ACT_SwitchTab("npc")
	UTL_Wait(1, 2)

	BOT_CheckSorting("overview", "icon")

	Local $NPC = OCR_GetNPC("tower", True)
	Local $NPCRow = 1
	If $NPC = False Then
		$NPC = OCR_CheckNPCPresent()
	Else
		BOT_LogMessage("NPC tower found in anomaly", 1)
		$NPCRow = $NPC[2]
	EndIf

	If $NPCAttack And $NPC <> False Then
		BOT_LogMessage("NPC found in anomaly", 1)

		; if not tower, sort by distance
		If $NPC[3] <> 4 Then
			BOT_CheckSorting("overview", "distance")
		EndIf

		Local $distance = Int(EVEOCR_GetOverviewObjectDistance($NPCRow))
		BOT_LogMessage("Distance to NPC at arrival: " & $distance & " m", 1)

		If $distance <= GUICtrlRead($GUI_lockDistance[$GLB_curBot]) * 1000 Then
			ACT_ReactivateGuns()

			If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
				ACT_ActivateModule("middle", "targetPainter")
			EndIf
		Else
			BOT_LogMessage("NPC too far away at arrival(limit " & GUICtrlRead($GUI_lockDistance[$GLB_curBot]) & " km)", 1)
		EndIf

		ACT_ClickOverviewObject($NPCRow)
		UTL_SetWaitTimestamp(UTL_CalcLockTime($NPC[3]))
		ACT_SI_ObjectRange("npc")
		GUI_SetLocationAndState("anomaly", "npc")
		ACT_RandomMouseMoves()
		GUI_SetLastActionTime()
	ElseIf $loot Then
		GUI_SetLocationAndState("anomaly", "wreck")
	Else
		GUI_SetLocationAndState("anomaly", "next")
	EndIf
EndFunc

Func Hunter_anomaly_npc()
	;if gun active, wait
	If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "gun")) Then
		;activate target painter
		If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
			ACT_ActivateModule("middle", "targetPainter")
		EndIf
		Return
	EndIf

	Local $cargo = BOT_CheckCargo()
	Local $NPC = OCR_CheckNPCPresent()

	; if all NPC killed
	If $NPC = False Then
		BOT_LogMessage("NPC destroyed in anomaly", 1)

		; close expedition window
		Send("{ENTER}")

		ACT_ReloadAmmo()

		If $cargo < 10 Then
			BOT_LogMessage("Low ammo", 1)
			If GUI_getSecurityStatus() = "Low" Then
				BOT_WarpTo("Spot")
			Else
				ACT_DockToStation(True)
			EndIf
			Return True
		EndIf

		If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED Then
			GUI_SetLocationAndState("anomaly", "wreck")
		Else
			GUI_SetLocationAndState("anomaly", "next")
		EndIf
		Return True
	EndIf

	Local $lockedNPC = OCR_CheckNPCPresent(True)
	; lock npc
	If $lockedNPC = False Then
		$NPC = OCR_GetNPC("tower", True)
		Local $NPCRow = 1
		If $NPC = False Then
			$NPC = OCR_CheckNPCPresent()
		Else
			BOT_LogMessage("More NPC tower found in anomaly", 1)
			$NPCRow = $NPC[2]
		EndIf

		If $NPC <> False Then
			BOT_CheckSorting("overview", "distance")

			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($NPCRow))
			BOT_LogMessage("Distance to NPC: " & $distance & " m", 1)

			If $distance <= GUICtrlRead($GUI_lockDistance[$GLB_curBot]) * 1000 Then
				ACT_ReactivateGuns()

				If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
					ACT_ActivateModule("middle", "targetPainter")
				EndIf
				ACT_ClickOverviewObject($NPCRow)
			Else
				BOT_LogMessage("NPC too far away(limit " & GUICtrlRead($GUI_lockDistance[$GLB_curBot]) & " km)", 1)
				ACT_ClickOverviewObject($NPCRow)
				ACT_SI_ObjectApproach("npc")
			EndIf

			Local $amount = OCR_CheckNPCPresent(False, "any", True)
			If $amount > 2 Then
				ACT_SI_ObjectRange("npc")
			Else
				ACT_SI_ObjectApproach("npc")
			EndIf

			UTL_SetWaitTimestamp(UTL_CalcLockTime($NPC[3]))
			ACT_RandomMouseMoves()
		EndIf
		Return True
	Else
		;reactivate target painter
		If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
			ACT_ActivateModule("middle", "targetPainter")
		EndIf

		ACT_ReactivateGuns()
	EndIf

	GUI_SetLastActionTime()
	BOT_LogMessage("NPC shooting in anomaly")
EndFunc