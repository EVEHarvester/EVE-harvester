Func Station_repairDrones()
	;TODO update drones repair
	;LogMessage("Repair all", 1)
	;ACT_OpenFitting()
	;UTL_Wait(2, 3)
	;ACT_RepairAllInStation()
	;ACT_OpenFitting()
EndFunc

Func Station_undock()
	ACT_UndockFromStation()
	GUI_SetLocationAndState("space", "waiting")
	UTL_SetWaitTimestamp(7)
	UTL_SetTimeout("waiting")
EndFunc

Func Station_unloadCargo($cargoType = "general")
	Local $unloadTo = GUICtrlRead($GUI_UnloadToCombo[$GLB_curBot])
	Local $leaveFirstItem = (GUICtrlRead($GUI_leaveOneItemInCargoCheckbox[$GLB_curBot]) = $GUI_CHECKED)

	If $unloadTo = "Items" Or $unloadTo = "POS" Or $unloadTo = "CorpHangar" Then
		If $cargoType == "general" Then
			ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
			UTL_Wait(1, 2)
			ACT_InventoryMoveItems("shipCargo", "stationItems", True, 1)
			ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
			;ACT_MoveAllCargoToItems(True)
			;ACT_StackAll("items")
		ElseIf $cargoType == "ore" Or $cargoType == "stuff" Then
			;ACT_MoveAllCargoToItems($leaveFirstItem)
			;ACT_StackAll("items")
			;ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
			;UTL_Wait(1, 2)

			ACT_InventoryMoveItems("shipCargo", "stationItems", True)
			;ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
		EndIf
	EndIf
EndFunc

; get items(ammo/lenses) from station
Func Station_loadCargo($amount)
	ACT_InventoryActivateItem($GLB_inventoryWindow_treeItemsPosition)
	UTL_Wait(1, 2)
	ACT_InventoryMoveItems("stationItems", "shipCargo", False, 0, False, True)

	UTL_Wait(2, 2.5)
	ACT_RandomSend($amount)
	Send("{ENTER}")
	UTL_Wait(2, 2.5)
	ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
	UTL_Wait(1, 2)
	ACT_StackAll("cargo")
EndFunc