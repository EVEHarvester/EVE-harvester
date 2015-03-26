; activate inventory item
Func ACT_InventoryActivateItem($position = 1)
	BOT_LogMessage("Activate inventory item " & $position, 1)
	Local $x = $GLB_inventoryWindow_tree[0] + 28
	Local $y = $GLB_inventoryWindow_tree[1] + ($position - 1)*$GLB_inventoryWindow_treeItemSize + Round($GLB_inventoryWindow_treeItemSize/2)
	Local $dX = 5
	Local $dY = Round($GLB_inventoryWindow_treeItemSize/3)
	ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, 1)
EndFunc

; not used in Retribution 1.0.5
#cs
;hide inventory filters
Func ACT_InventoryHideFilters($y)
	ACT_MouseClick("left", $GLB_inventoryWindow_filtersToggle[0], $y, $GLB_inventoryWindow_filtersToggle[2], $GLB_inventoryWindow_filtersToggle[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc
#ce

;scroll to top inventory element
Func ACT_InventoryActivateTopItem()
	ACT_InventoryActivateItem(1)
	UTL_Wait(0.5, 1)
	For $i = 1 To 20 Step 1
		MouseWheel("up", 1)
		UTL_Wait(0.05, 0.1)
	Next
	ACT_InventoryActivateItem(1)
EndFunc

;open inventory element in separate window
Func ACT_InventoryOpenInSeparateWindow($position = 1)
	Local $x = $GLB_inventoryWindow_tree[0] + 27
	Local $y = $GLB_inventoryWindow_tree[1] + ($position - 1)*$GLB_inventoryWindow_treeItemSize + Round($GLB_inventoryWindow_treeItemSize/2)
	Local $dX = 5
	Local $dY = Round($GLB_inventoryWindow_treeItemSize/3)
	Send("{SHIFTDOWN}")
	UTL_Wait(0.1, 0.3)
	ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, 1)
	UTL_Wait(0.1, 0.3)
	Send("{SHIFTUP}")
EndFunc

; move inventory items
Func ACT_InventoryMoveItems($from = "shipCargo", $to = "stationItems", $selectAll = False, $leaveItems = 0, $attrs = False, $moveOnlyPart = False)
	BOT_LogMessage("Move inventory items from  " & $from & " to " & $to & ", leave=" & $leaveItems, 1)

	Local $x1, $y1, $dX1, $dY1
	Local $x2, $y2, $dX2, $dY2

	Switch $from
		Case "shipCargo", "container"
			; click in center of item
			$x1 = $GLB_inventoryWindow_cargo[0] + $GLB_inventoryWindow_cargoItemShift[0] + $GLB_inventoryWindow_cargoItemSize[0]/2
			$y1 = $GLB_inventoryWindow_cargo[1] + $GLB_inventoryWindow_cargoItemShift[1] + $GLB_inventoryWindow_cargoItemSize[1]/5
			$dX1 = Round($GLB_inventoryWindow_cargoItemSize[0]/6)
			$dY1 = Round($GLB_inventoryWindow_cargoItemSize[1]/6)
		Case "corpHangar", "stationItems"
			$x1 = $GLB_corpHangarWindow_cargo[0] + $GLB_inventoryWindow_cargoItemShift[0] + $GLB_inventoryWindow_cargoItemSize[0]/2
			$y1 = $GLB_corpHangarWindow_cargo[1] + $GLB_inventoryWindow_cargoItemShift[1] + $GLB_inventoryWindow_cargoItemSize[1]/2
			$dX1 = Round($GLB_inventoryWindow_cargoItemSize[0]/3)
			$dY1 = Round($GLB_inventoryWindow_cargoItemSize[1]/3)
	EndSwitch

	Switch $to
		Case "shipCargo"
			; drop to inventory line
			$x2 = $GLB_inventoryWindow_tree[0] + 27
			$y2 = $GLB_inventoryWindow_tree[1] + ($GLB_inventoryWindow_treeShipPosition - 1)*$GLB_inventoryWindow_treeItemSize + Round($GLB_inventoryWindow_treeItemSize/2)
			$dX2 = 5
			$dY2 = Round($GLB_inventoryWindow_treeItemSize/3)
		;Case "stationItems"
		;	$x2 = $GLB_inventoryWindow_tree[0] + 27
		;	$y2 = $GLB_inventoryWindow_tree[1] + ($GLB_inventoryWindow_treeItemsPosition - 1)*$GLB_inventoryWindow_treeItemSize + Round($GLB_inventoryWindow_treeItemSize/2)
		;	$dX2 = 5
		;	$dY2 = Round($GLB_inventoryWindow_treeItemSize/3)
		Case "corpHangar", "stationItems"
			$x2 = $GLB_corpHangarWindow_cargo[0] + $GLB_inventoryWindow_cargoItemShift[0] + $GLB_inventoryWindow_cargoItemSize[0]/2
			$y2 = $GLB_corpHangarWindow_cargo[1] + $GLB_inventoryWindow_cargoItemShift[1] + $GLB_inventoryWindow_cargoItemSize[1]/2
			$dX2 = Round($GLB_inventoryWindow_cargoItemSize[0]/3)
			$dY2 = Round($GLB_inventoryWindow_cargoItemSize[1]/3)
		Case "container"
			$x2 = $GLB_inventoryWindow_tree[0] + 27
			$y2 = $GLB_inventoryWindow_tree[1] + ($GLB_inventoryWindow_treeContainerPosition - 1)*$GLB_inventoryWindow_treeItemSize + Round($GLB_inventoryWindow_treeItemSize/2)
			$dX2 = 5
			$dY2 = Round($GLB_inventoryWindow_treeItemSize/3)
		Case "shipSlot"
			Local $slotType = $attrs[0]
			Local $slotNumber  = $attrs[1]
			Local $slotData

			If $slotType = "high" Then
				$slotData = $GLB_activeHighSlot_Item1
			ElseIf $slotType = "medium" Then
				$slotData = $GLB_activeShield_Item1
			ElseIf $slotType = "low" Then
				$slotData = $GLB_activeLowSlot1
			Else
				BOT_LogMessage("Slot not supported: " & $slotType, 1)
				Return False
			EndIf

			$x2 = $slotData[0] + ($slotNumber - 1)*$GLB_slot_ItemShift
			$y2 = $slotData[1] - Round($GLB_slot_ItemSize/2)
			$dX2 = 5
			$dY2 = Round($GLB_slot_ItemSize/5)
	EndSwitch

	; activate needed cargo
	ACT_MouseClick("left", $x1, $y1, $dX1, $dY1, 1, 5, 1)

	; select all if needed
	If $selectAll Then
		UTL_Wait(0.1, 0.3)
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.1, 0.3)
	EndIf

	If $leaveItems = 0 Then
		If $moveOnlyPart Then Send("{SHIFTDOWN}")
		MouseClickDrag("left", $x1, $y1, $x2, $y2, 5)
		If $moveOnlyPart Then Send("{SHIFTUP}")
	Else
		Local $item1[4] = [$x1, $y1, $GLB_inventoryWindow_cargoItemSize[0]/2, $GLB_inventoryWindow_cargoItemSize[1]/2]
		Local $item2[4] = [$x1 + $GLB_inventoryWindow_cargoItemSpace + $GLB_inventoryWindow_cargoItemSize[0], $y1, $GLB_inventoryWindow_cargoItemSize[0]/2, $GLB_inventoryWindow_cargoItemSize[1]/2]
		Local $item3[4] = [$x1 + $GLB_inventoryWindow_cargoItemSpace*2 + $GLB_inventoryWindow_cargoItemSize[0]*2, $y1, $GLB_inventoryWindow_cargoItemSize[0]/2, $GLB_inventoryWindow_cargoItemSize[1]/2]

		If $leaveItems = 1 Then
			BOT_LogMessage("Leaving first item", 1)
			Send("{CTRLDOWN}")
			ACT_MouseClick("left", $item1[0], $item1[1], $item1[2], $item1[3], 1, 5, 1)
			Send("{CTRLUP}")
			If $moveOnlyPart Then Send("{SHIFTDOWN}")
			MouseClickDrag("left", $item2[0], $item2[1], $x2, $y2, 5)
			If $moveOnlyPart Then Send("{SHIFTUP}")
		ElseIf $leaveItems = 2 Then
			BOT_LogMessage("Leaving two items", 1)
			Send("{CTRLDOWN}")
			ACT_MouseClick("left", $item1[0], $item1[1], $item1[2], $item1[3], 1, 5, 1)
			ACT_MouseClick("left", $item2[0], $item2[1], $item2[2], $item2[3], 1, 5, 1)
			Send("{CTRLUP}")
			If $moveOnlyPart Then Send("{SHIFTDOWN}")
			MouseClickDrag("left", $item3[0], $item3[1], $x2, $y2, 5)
			If $moveOnlyPart Then Send("{SHIFTUP}")
		EndIf
	EndIf
EndFunc

;move all cargo to Items
; depricated
Func ACT_MoveAllCargoToItems($leaveFirstItem = False, $leaveTwoItems = False)
	BOT_LogMessage("Unloading cargo to Items", 1)
	ACT_MouseClick("left", $GLB_cargoWindow[0] + 90, $GLB_cargoWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.1, 0.3)
	Send("{CTRLDOWN}a{CTRLUP}")
	UTL_Wait(0.1, 0.3)

	If $leaveFirstItem Then
		BOT_LogMessage("Leaving first item", 1)
		Send("{CTRLDOWN}")
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 52, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		Send("{CTRLUP}")
		MouseClickDrag("left", $GLB_cargoWindow[0] + 127, $GLB_cargoWindow[1] + 121, $GLB_itemsWindow[0]  + 50, $GLB_itemsWindow[1] + 130, 5)
	ElseIf $leaveTwoItems Then
		BOT_LogMessage("Leaving two items", 1)
		Send("{CTRLDOWN}")
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 52, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 127, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		Send("{CTRLUP}")
		MouseClickDrag("left", $GLB_cargoWindow[0] + 196, $GLB_cargoWindow[1] + 121, $GLB_itemsWindow[0]  + 50, $GLB_itemsWindow[1] + 130, 5)
	Else
		MouseClickDrag("left", $GLB_cargoWindow[0] + 50, $GLB_cargoWindow[1] + 100, $GLB_itemsWindow[0]  + 50, $GLB_itemsWindow[1] + 130, 5)
	EndIf
EndFunc

;move all Items to cargo
; depricated
Func ACT_MoveAllItemsToCargo($firstItemOnly = False)
	ACT_MouseClick("left", $GLB_itemsWindow[0] + 50, $GLB_itemsWindow[1] + 100, 30, 20, 1, 5, 1)
	If $firstItemOnly Then
		BOT_LogMessage("Get one Item into cargo", 1)
	Else
		BOT_LogMessage("Get all Items into cargo", 1)
		UTL_Wait(0.1, 0.3)
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.1, 0.3)
	EndIf

	MouseClickDrag("left", $GLB_itemsWindow[0] + 50, $GLB_itemsWindow[1] + 100, $GLB_cargoWindow[0]  + 50, $GLB_cargoWindow[1] + 120, 5)
EndFunc

;move all cargo to Corp Hangar
Func ACT_MoveAllCargoToCorpHangar($leaveFirstItem = False, $leaveTwoItems = False, $selectAll = True, $coprHangarWindow = False)
	BOT_LogMessage("Unloading cargo to Corp Hangar", 1)
	ACT_MouseClick("left", $GLB_cargoWindow[0] + 90, $GLB_cargoWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	If $selectAll Then
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.3, 0.5)
	EndIf

	; default corpHangar
	If $coprHangarWindow = False Then
		$coprHangarWindow = $GLB_corpHangarWindow
	EndIf

	If $leaveFirstItem Then
		BOT_LogMessage("Leaving first item", 1)
		Send("{CTRLDOWN}")
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 52, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		Send("{CTRLUP}")
		MouseClickDrag("left", $GLB_cargoWindow[0] + 127, $GLB_cargoWindow[1] + 121, $coprHangarWindow[0]  + 150, $coprHangarWindow[1] + 130, 5)
	ElseIf $leaveTwoItems Then
		BOT_LogMessage("Leaving two items", 1)
		Send("{CTRLDOWN}")
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 52, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 127, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		Send("{CTRLUP}")
		MouseClickDrag("left", $GLB_cargoWindow[0] + 196, $GLB_cargoWindow[1] + 121, $coprHangarWindow[0]  + 150, $coprHangarWindow[1] + 130, 5)
	Else
		MouseClickDrag("left", $GLB_cargoWindow[0] + 50, $GLB_cargoWindow[1] + 100, $coprHangarWindow[0]  + 150, $coprHangarWindow[1] + 130, 5)
	EndIf

	UTL_Wait(1, 1.5)
	Send("{ENTER}")
EndFunc

;move all ore cargo to Corp Hangar
Func ACT_MoveAllOreCargoToCorpHangar()
	BOT_LogMessage("Unloading ore hold cargo to station Corp Hangar", 1)
	ACT_MouseClick("left", $GLB_oreHoldWindow[0] + 90, $GLB_oreHoldWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	Send("{CTRLDOWN}a{CTRLUP}")
	UTL_Wait(0.3, 0.5)

	MouseClickDrag("left", $GLB_oreHoldWindow[0] + 50, $GLB_oreHoldWindow[1] + 100, $GLB_corpHangarWindow[0]  + 150, $GLB_corpHangarWindow[1] + 130, 5)

	UTL_Wait(1, 1.5)
	Send("{ENTER}")
EndFunc

;move all ship corp hangar cargo to Corp Hangar
Func ACT_MoveAllShipCorpHangarCargoToCorpHangar()
	BOT_LogMessage("Unloading ship corp hangar cargo to station Corp Hangar", 1)
	ACT_MouseClick("left", $GLB_fleetCommanderCorpHangarWindow[0] + 90, $GLB_fleetCommanderCorpHangarWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	Send("{CTRLDOWN}a{CTRLUP}")
	UTL_Wait(0.3, 0.5)

	MouseClickDrag("left", $GLB_fleetCommanderCorpHangarWindow[0] + 50, $GLB_fleetCommanderCorpHangarWindow[1] + 135, $GLB_corpHangarWindow[0]  + 150, $GLB_corpHangarWindow[1] + 130, 5)

	UTL_Wait(1, 1.5)
	Send("{ENTER}")
EndFunc

;move all cargo to ship corp hangar
Func ACT_MoveAllCargoToShipCorpHangar($selectAll = True)
	BOT_LogMessage("Unloading cargo to ship corp hangar", 1)
	ACT_MouseClick("left", $GLB_cargoWindow[0] + 90, $GLB_cargoWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	If $selectAll Then
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.3, 0.5)
	EndIf
	MouseClickDrag("left", $GLB_cargoWindow[0] + 50, $GLB_cargoWindow[1] + 100, $GLB_shipCorpHangarWindow[0]  + 50, $GLB_shipCorpHangarWindow[1] + 150, 5)
	Send("{CTRLUP}")
	UTL_Wait(1, 1.5)
	Send("{ENTER}")
	UTL_Wait(0.1, 0.2)
EndFunc

;move all cargo to conatiner
Func ACT_MoveAllCargoToContainer($selectAll = True, $leaveFirstItem = False)
	BOT_LogMessage("Unloading cargo to container", 1)
	ACT_MouseClick("left", $GLB_cargoWindow[0] + 90, $GLB_cargoWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	If $selectAll Then
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.3, 0.5)
	EndIf

	If $leaveFirstItem Then
		BOT_LogMessage("Leaving first item", 1)
		Send("{CTRLDOWN}")
		ACT_MouseClick("left", $GLB_cargoWindow[0] + 52, $GLB_cargoWindow[1] + 121, 20, 20, 1, 5, 1)
		Send("{CTRLUP}")
		MouseClickDrag("left", $GLB_cargoWindow[0] + 127, $GLB_cargoWindow[1] + 100, $GLB_containerWindow[0]  + 50, $GLB_containerWindow[1] + 130, 5)
	Else
		MouseClickDrag("left", $GLB_cargoWindow[0] + 50, $GLB_cargoWindow[1] + 100, $GLB_containerWindow[0]  + 50, $GLB_containerWindow[1] + 130, 5)
	EndIf

	UTL_Wait(1, 1.5)
	Send("{ENTER}")
	UTL_Wait(0.1, 0.2)
EndFunc

;move all cargo from conatiner
Func ACT_MoveAllCargoFromContainer($toItem = 1, $selectAll = True)
	BOT_LogMessage("Unloading cargo from container", 1)
	ACT_MouseClick("left", $GLB_containerWindow[0] + 90, $GLB_containerWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	If $selectAll Then
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.3, 0.5)
	EndIf
	MouseClickDrag("left", $GLB_containerWindow[0] + 50, $GLB_containerWindow[1] + 100, $GLB_cargoWindow[0]  + 55*$toItem, $GLB_cargoWindow[1] + 130, 5)
	Send("{CTRLUP}")
	UTL_Wait(1, 1.5)
	Send("{ENTER}")
EndFunc

;move all corphangar cargo to ore hold
Func ACT_MoveAllCorpHangarCargoToOreHold($selectAll = True)
	BOT_LogMessage("Unloading corphangar cargo to ore hold", 1)
	ACT_MouseClick("left", $GLB_fleetCommanderCorpHangarWindow[0] + 90, $GLB_fleetCommanderCorpHangarWindow[1] + 150, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	If $selectAll Then
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.3, 0.5)
	EndIf
	MouseClickDrag("left", $GLB_fleetCommanderCorpHangarWindow[0] + 50, $GLB_fleetCommanderCorpHangarWindow[1] + 150, $GLB_oreHoldWindow[0]  + 50, $GLB_oreHoldWindow[1] + 120, 5)
	Send("{CTRLUP}")
	UTL_Wait(1, 1.5)
	Send("{ENTER}")
	UTL_Wait(0.1, 0.2)
EndFunc

;move all corphangar cargo to cargo
Func ACT_MoveAllCorpHangarCargoToCargo($selectAll = True, $coprHangarWindow = False)
	BOT_LogMessage("Unloading corphangar cargo to ship cargo", 1)
	; default corpHangar
	If $coprHangarWindow = False Then
		$coprHangarWindow = $GLB_fleetCommanderCorpHangarWindow
	EndIf

	ACT_MouseClick("left", $coprHangarWindow[0] + 90, $coprHangarWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	If $selectAll Then
		Send("{CTRLDOWN}a{CTRLUP}")
		UTL_Wait(0.3, 0.5)
	EndIf
	MouseClickDrag("left", $coprHangarWindow[0] + 50, $coprHangarWindow[1] + 130, $GLB_cargoWindow[0]  + 50, $GLB_cargoWindow[1] + 120, 5)
	Send("{CTRLUP}")
	UTL_Wait(1, 1.5)
EndFunc

;move ammo into gun
Func ACT_MoveAmmoIntoGun($slot = 1)
	BOT_LogMessage("Move ammo into gun", 1)
	ACT_MouseClick("left", $GLB_cargoWindow[0] + 90, $GLB_cargoWindow[1] + 130, 30, 20, 1, 5, 1)
	UTL_Wait(0.3, 0.5)

	Local $gun_x = $GLB_activeHighSlot_Item1[0] + ($GLB_slot_ItemShift*($slot - 1))
 	Local $gun_y = $GLB_activeHighSlot_Item1[1] - 15

	MouseClickDrag("left", $GLB_cargoWindow[0] + 50, $GLB_cargoWindow[1] + 100, $gun_x, $gun_y, 5)
	UTL_Wait(0.1, 0.2)
EndFunc

;undock from station
Func ACT_UndockFromStation()
	BOT_LogMessage("Undocking ship from station by button", 1)
	ACT_MouseClick("left", $GLB_undockButton_click[0], $GLB_undockButton_click[1], $GLB_undockButton_click[2], $GLB_undockButton_click[3], 1, 5, $GLB_undockButton_click[4], False, True)
EndFunc

; click right click menu item
Func ACT_ClickMenuItem($rightClickPoint, $menuItem = 1, $submenuItem = False)
	Local $menu_x_click = Round($rightClickPoint[0] + Random(-1*$rightClickPoint[2], $rightClickPoint[2]))
	Local $menu_y_click = Round($rightClickPoint[1] + Random(-1*$rightClickPoint[3], $rightClickPoint[3]))

	Local $menuFound = ACT_MouseClick("right", $menu_x_click, $menu_y_click, 1, 1, 1, 5)

	If Not $menuFound Then
		Return False
	EndIf

	Local $menuX0 = $menu_x_click + 13
	Local $menuY0 = $menu_y_click + 1

	Local $x = $menuX0 + 20
	Local $y = $menuY0 + ($menuItem - 1)*$GLB_menu_itemHeight + Round($GLB_menu_itemHeight/2)
	Local $dx = 5
	Local $dy = 2
	Local $speed = 5
	Local $dspeed = 5

	ACT_MouseClick("left", $x, $y, $dx, $dy, 1, $speed, $dspeed)
	BOT_LogMessage("Menu item click: item " & $menuItem & ", [" & $x & "," & $y & "]", 1)

	If $submenuItem <> False Then
		Local $submenu_x_click = $x + 150 + Random(1, 10, 1)
		Local $submenu_y_click = $y + ($submenuItem - 1)*$GLB_menu_itemHeight + Round($GLB_menu_itemHeight/2)

		UTL_Wait(1, 2)
		MouseMove($submenu_x_click, $y, $speed)
		UTL_Wait(0.5, 1)

		ACT_MouseClick("left", $submenu_x_click, $submenu_y_click, $dx, $dy, 1, $speed, $dspeed)
		BOT_LogMessage("Submenu item click: item " & $submenuItem & ", [" & $submenu_x_click & "," & $submenu_y_click & "]", 1)
	EndIf
EndFunc

; scroll people and places window to start
Func ACT_PAPscrollUp($neededPosition)
	Local $visibleBookmark = Int(GUICtrlRead($GUI_bookmarkVisible[$GLB_curBot]))
	Local $currentBookmark = Int(GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
	Local $maxBookmark = Int(GUICtrlRead($GUI_bookmarkMax[$GLB_curBot]))

	;If $neededPosition > $visibleBookmark Or $currentBookmark > $visibleBookmark Or ($currentBookmark = 1 And $maxBookmark <> 1) Then
	ACT_MouseClick("left", $GLB_PAP_activate_click[0], $GLB_PAP_activate_click[1], $GLB_PAP_activate_click[2], $GLB_PAP_activate_click[3], 1, 5, 1)
	UTL_Wait(1, 2)
	Local $scrollUp = $maxBookmark + GUI_BookmarkGetPosition("belts");$neededPosition - $visibleBookmark
	Local $scrollUpRandom = Random(2, 4, 1)

	For $i = 1 To $scrollUp + $scrollUpRandom Step 1
		MouseWheel("up", 1)
		UTL_Wait(0.05, 0.1)
	Next

	BOT_LogMessage("Scroll up=" & $scrollUp & " + " & $scrollUpRandom)
	;EndIf
EndFunc

; scroll people and places window to item
Func ACT_PAPscrollDown($neededPosition)
	Local $visibleBookmark = Int(GUICtrlRead($GUI_bookmarkVisible[$GLB_curBot]))

	If Int($neededPosition) > $visibleBookmark Then
		Local $scrollFix = 0
		If $neededPosition >= 29 Then
			$scrollFix = 3
		ElseIf $neededPosition >= 20 Then
			$scrollFix = 2
		ElseIf $neededPosition >= 10 Then
			$scrollFix = 1
		EndIf

		For $i = 1 To $neededPosition - $visibleBookmark + $scrollFix Step 1
			MouseWheel("down", 1)
			UTL_Wait(0.05, 0.1)
		Next

		BOT_LogMessage("Scroll down=" & ($neededPosition - $visibleBookmark) & ", num=" & $visibleBookmark & ", fix=" & $scrollFix, 1)
	EndIf
EndFunc

; warp to PAP item
Func ACT_WarpTo($object = "station", $position = -1, $aproachOnly = False)
	BOT_LogMessage("Warp to " & $object & ", position=" & $position, 1)
	Local $PAP_position
	Local $PAP_itemCoordinates[5]
	Local $PAP_itemHeight = $GLB_PAPItemSize + $GLB_PAPDividerSize

	Local $visibleBookmark = Int(GUICtrlRead($GUI_bookmarkVisible[$GLB_curBot]))

	Switch StringLower($object)
		Case "station"
			$PAP_position = GUI_BookmarkGetPosition("station")
		Case "spot"
			$PAP_position = GUI_BookmarkGetPosition("spot", $position)
		Case "pos"
			$PAP_position = GUI_BookmarkGetPosition("pos")
		Case "belts"
			$PAP_position = GUI_BookmarkGetPosition("belts") + $position - 1
		Case Else
			MsgBox(64, "Error", "Unknown warp object")
			Return False
	EndSwitch

	; scroll if needed
	ACT_PAPscrollUp($PAP_position)
	ACT_PAPscrollDown($PAP_position)

	; x
	$PAP_itemCoordinates[0] = $GLB_PAP_placesArea[0] + 140
	; y
	$PAP_itemCoordinates[1] = $GLB_PAP_placesArea[1] + ($PAP_position - 1)*$PAP_itemHeight + $PAP_itemHeight/2
	; dX
	$PAP_itemCoordinates[2] = 70
	; dY
	$PAP_itemCoordinates[3] = 1

	; if scrolled use last visible
	If $PAP_position > $visibleBookmark Then
		$PAP_itemCoordinates[1] = $GLB_PAP_placesArea[1] + ($visibleBookmark - 1)*$PAP_itemHeight + $PAP_itemHeight/2
	EndIf

	ACT_ClickMenuItem($PAP_itemCoordinates, 1)

	Switch StringLower($object)
		Case "station"
			GUI_SetLocationAndState("belt", "warpWaiting")
			$GUI_warpDetected[$GLB_curBot] = False
			$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
			UTL_SetTimeout("waiting")
		Case "spot"
			GUI_SetLocationAndState("spot", "warpWaiting")
			$GUI_warpDetected[$GLB_curBot] = False
			$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
			UTL_SetTimeout("waiting")
		Case "pos"
			If Not $aproachOnly Then
				GUI_SetLocationAndState("pos", "warpWaiting")
				$GUI_warpDetected[$GLB_curBot] = False
				$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
				UTL_SetTimeout("waiting")
			EndIf
		Case "belts"
			If Not $aproachOnly Then
				GUI_SetLocationAndState("space", "warpWaiting")
				$GUI_warpDetected[$GLB_curBot] = False
				$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
				UTL_SetTimeout("waiting")
			EndIf
	EndSwitch
EndFunc

; warp to scanner item in 30km range
Func ACT_WarpToScannerItem($position = 1, $aproachOnly = False)
	BOT_LogMessage("Warp to scanner object, position=" & $position, 1)

	Local $itemCoordinates[4]
	; x
	$itemCoordinates[0] = $GLB_SW_scan_results[0] + 75
	; y
	$itemCoordinates[1] = $GLB_SW_scan_results[1] + ($position - 1)*($GLB_SW_scan_results_itemHeight + $GLB_SW_scan_results_delimiterHeight) + $GLB_SW_scan_results_itemHeight/2
	; dX
	$itemCoordinates[2] = 30
	; dY
	$itemCoordinates[3] = 1

	ACT_ClickMenuItem($itemCoordinates, 2, 4)

	If Not $aproachOnly Then
		GUI_SetLocationAndState("anomaly", "warpWaiting")
		$GUI_warpDetected[$GLB_curBot] = False
		$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
		UTL_SetTimeout("waiting")
		UTL_Wait(1, 2)
		Send("{ENTER}")
	EndIf
EndFunc

; warp to scanner item by button
Func ACT_WarpToScannerItemByButton($position = 1)
	BOT_LogMessage("Warp to scanner object by button, position=" & $position, 1)

	Local $itemCoordinates[4]
	; x
	$itemCoordinates[0] = $GLB_SW_scan_coloredResluts[0] + 142
	; y
	$itemCoordinates[1] = $GLB_SW_scan_coloredResluts[1] + ($position - 1)*($GLB_SW_scan_results_itemHeight + $GLB_SW_scan_results_delimiterHeight) + $GLB_SW_scan_results_itemHeight/2
	; dX
	$itemCoordinates[2] = 4
	; dY
	$itemCoordinates[3] = 2

	ACT_MouseClick("left", $itemCoordinates[0], $itemCoordinates[1], $itemCoordinates[2], $itemCoordinates[3], 1, 5, 1)

	GUI_SetLocationAndState("anomaly", "warpWaiting")
	$GUI_warpDetected[$GLB_curBot] = False
	$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
	UTL_SetTimeout("waiting")
	UTL_Wait(1, 2)
	Send("{ENTER}")
EndFunc

;activate scanner window
Func ACT_ActivateScannerWindow()
	ACT_MouseClick("left", $GLB_SW_activate_click[0], $GLB_SW_activate_click[1], $GLB_SW_activate_click[2], $GLB_SW_activate_click[3], 1, 5, 1)
EndFunc

;dock to station
Func ACT_DockToStation($fromBelt = False, $bookmarkType = "station")
	Local $msg
	If $fromBelt Then
		$msg = "from belt or spot"
	Else
		$msg = "from space"
	EndIf
	BOT_LogMessage("Docking ship to station " & $msg, 1)

	Local $PAP_position
	Local $PAP_itemCoordinates[5]
	Local $PAP_itemHeight = $GLB_PAPItemSize + $GLB_PAPDividerSize
	Local $visibleBookmark = Int(GUICtrlRead($GUI_bookmarkVisible[$GLB_curBot]))

	$PAP_position = GUI_BookmarkGetPosition($bookmarkType)

	ACT_PAPscrollUp($PAP_position)
	ACT_PAPscrollDown($PAP_position)

	; x
	$PAP_itemCoordinates[0] = $GLB_PAP_placesArea[0] + 140
	; y
	$PAP_itemCoordinates[1] = $GLB_PAP_placesArea[1] + ($PAP_position - 1)*$PAP_itemHeight + $PAP_itemHeight/2
	; dX
	$PAP_itemCoordinates[2] = 70
	; dY
	$PAP_itemCoordinates[3] = 1

	; if scrolled use last visible
	If $PAP_position > $visibleBookmark Then
		$PAP_itemCoordinates[1] = $GLB_PAP_placesArea[1] + ($visibleBookmark - 1)*$PAP_itemHeight + $PAP_itemHeight/2
	EndIf

	If $fromBelt Then
		ACT_ClickMenuItem($PAP_itemCoordinates, 4)
		GUI_SetLocationAndState("station", "warpWaiting")
		$GUI_warpDetected[$GLB_curBot] = False
		$GUI_timeoutWarpWaiting = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
	Else
		ACT_ClickMenuItem($PAP_itemCoordinates, 2)
		GUI_SetLocationAndState("station", "waiting")
	EndIf

	UTL_SetTimeout("waiting")

	Return True
EndFunc

Func ACT_WarpToOverviewObject($number = 1)
	Local $x = $GLB_ObjectSearch[0]
	Local $y = $GLB_ObjectSearch[1] + ($number - 1)*($GLB_ObjectSearchIconSize + $GLB_ObjectSearchDividerSize) + $GLB_ObjectSearchIconSize/2

	Local $menuFound = ACT_MouseClick("right", $x, $y, 2, 1, 1, 5, 1)

	If Not $menuFound Then
		Return False
	EndIf

	ACT_MouseClick("left", $x + 30, $y + 7, 5, 1, 1, 5, 1)

	UTL_SetTimeout("warp")
EndFunc

;jump to object from Selected Item window
Func ACT_SI_Jump()
	UTL_Wait(0.4, 0.6)
	Send(GUICtrlRead($GUI_hotkeyJump))
	UTL_Wait(0.4, 0.6)
EndFunc

;approach to object from Selected Item window
Func ACT_SI_ObjectApproach($type = "asteroid")
	UTL_Wait(0.4, 0.6)
	Send(GUICtrlRead($GUI_hotkeyApproach))
	UTL_Wait(0.4, 0.6)
EndFunc

;approach to object by menu
Func ACT_ObjectApproach($coordinates)
	Local $menuFound = ACT_MouseClick("right", $coordinates[0], $coordinates[1], 5, 2, 1, 5, 10)

	If $menuFound Then
		ACT_MouseClick("left", $coordinates[0] + 35, $coordinates[1] + 8, 5, 2, 1, 5, 10)
	EndIf
EndFunc

;open container
Func ACT_OpenContainer($coordinates, $byMenu = False, $withShift = False)
   If Not $byMenu Then
	  If $withShift Then
		  Send("{SHIFTDOWN}")
	  EndIf
	  ACT_MouseClick("left", $GLB_SI_cargoOpen_click[0], $GLB_SI_cargoOpen_click[1], $GLB_SI_cargoOpen_click[2], $GLB_SI_cargoOpen_click[3], 1, 5, $GLB_SI_cargoOpen_click[4])
	  If $withShift Then
		  Send("{SHIFTUP}")
	  EndIf
   Else
	  Local $menuFound = ACT_MouseClick("right", $coordinates[0], $coordinates[1], 5, 2, 1, 5, 10)
	  If $menuFound Then
			;If GUI_isMiner() Then
				ACT_MouseClick("left", $coordinates[0] + 25, $coordinates[1] + 152, 5, 2, 1, 5, 10) ;+135
			;ElseIf GUI_isTransporter() Then
			;	ACT_MouseClick("left", $coordinates[0] + 25, $coordinates[1] + 152, 5, 2, 1, 5, 10)
			;EndIf
	  EndIf
   EndIf

	;wait for container password
	For $i = 0 To GUICtrlRead($GUI_containerPasswordDelayInput) Step 1
		UTL_Wait(0.4, 0.6)
		;enter password if needed
		If OCR_ContainerNeedPassword() Then
			Local $pass = GUICtrlRead($GUI_containerPasswordInput)
			BOT_LogMessage("Entering container password - " & $pass)
			ACT_RandomSend($pass)
			Send("{ENTER}")
			ExitLoop
		EndIf
	Next
EndFunc

;open wreck
Func ACT_OpenWreck()
	If OCR_IsWreckExtendedUnlockPresent() Then
		ACT_MouseClick("left", $GLB_SI_cargoOpen_click[0], $GLB_SI_cargoOpen_click[1] + 12, 2, 2, 1, 5, 1)
	Else
		ACT_MouseClick("left", $GLB_SI_cargoOpen_click[0], $GLB_SI_cargoOpen_click[1], $GLB_SI_cargoOpen_click[2], $GLB_SI_cargoOpen_click[3], 1, 5, $GLB_SI_cargoOpen_click[4])
	EndIf
EndFunc

;orbit to nearest asteroid by menu
Func ACT_NearestAsteroidOrbit()
	Local $orbit = "2500"
	BOT_LogMessage("Nearest asteroid orbit to " & $orbit)

	Local $clickPlace[2] = [$GLB_ObjectSearch[0] + 7, $GLB_ObjectSearch[1] + 7]
	MouseClick("right", $clickPlace[0], $clickPlace[1], 1 ,10)
	UTL_Wait(1, 2)
	MouseClick("left", $clickPlace[0] + 30, $clickPlace[1] + 25, 1, 10)
	UTL_Wait(1, 2)

	Local $menuShift = 0

	Switch $orbit
	Case "500m"
		$menuShift = 0
	Case "1000m"
		$menuShift = 1
	Case "2500m"
		$menuShift = 2
	Case "Random"
		$menuShift = Random(0, 2)
	Case Else
		$menuShift = 0
	EndSwitch

	MouseClick("left", $clickPlace[0] - 40, $clickPlace[1] + 25 + $GLB_menu_itemHeight*$menuShift, 1, 10)
EndFunc

;orbit to asteroid by menu
Func ACT_AsteroidOrbit($coordinates)
	Local $orbit = "2500"
	BOT_LogMessage("Asteroid orbit to " & $orbit)

	Local $clickPlace[2] = [$coordinates[0], $coordinates[1]]
	MouseClick("right", $clickPlace[0], $clickPlace[1], 1 ,10)
	UTL_Wait(1, 2)
	MouseClick("left", $clickPlace[0] + 30, $clickPlace[1] + 25, 1, 10)
	UTL_Wait(1, 2)

	Local $menuShift = 0

	Switch $orbit
	Case "500m"
		$menuShift = 0
	Case "1000m"
		$menuShift = 1
	Case "2500m"
		$menuShift = 2
	Case "Random"
		$menuShift = Random(0, 2)
	Case Else
		$menuShift = 0
	EndSwitch

	MouseClick("left", $clickPlace[0] - 40, $clickPlace[1] + 25 + $GLB_menu_itemHeight*$menuShift, 1, 10)
EndFunc

;default orbit to object from Selected Item window
Func ACT_SI_ObjectOrbit($type = "asteroid")
	UTL_Wait(0.4, 0.6)
	Send(GUICtrlRead($GUI_hotkeyOrbit))
	UTL_Wait(0.4, 0.6)
EndFunc

;default range to object from Selected Item window
Func ACT_SI_ObjectRange($type = "asteroid")
	UTL_Wait(0.4, 0.6)
	Send(GUICtrlRead($GUI_hotkeyRange))
	UTL_Wait(0.4, 0.6)
EndFunc

;default lock to object from Selected Item window
Func ACT_SI_ObjectLock($type = "asteroid")
	If $type = "asteroid" Then
		ACT_MouseClick("left", $GLB_SI_asteroidLock[0], $GLB_SI_asteroidLock[1], $GLB_SI_asteroidLock[2], $GLB_SI_asteroidLock[3], 1, 5, $GLB_SI_asteroidLock[4])
	ElseIf $type = "npc" Then
		ACT_MouseClick("left", $GLB_SI_NPCLock_click[0], $GLB_SI_NPCLock_click[1], $GLB_SI_NPCLock_click[2], $GLB_SI_NPCLock_click[3], 1, 5, $GLB_SI_NPCLock_click[4])
	EndIf
EndFunc

;unlock active object
Func ACT_UnlockActiveObject()
	BOT_LogMessage("Unlocking active object", 1)
	If OCR_IsAsteroidUnlockPresent() Then
		ACT_MouseClick("left", $GLB_SI_asteroidUnlock_click[0], $GLB_SI_asteroidUnlock_click[1], $GLB_SI_asteroidUnlock_click[2], $GLB_SI_asteroidUnlock_click[3], 1, 5, $GLB_SI_asteroidUnlock_click[4])
		UTL_Wait(3, 4)
	ElseIf OCR_IsContainerUnlockPresent() Then
		ACT_MouseClick("left", $GLB_SI_containerUnlock_click[0], $GLB_SI_containerUnlock_click[1], $GLB_SI_containerUnlock_click[2], $GLB_SI_containerUnlock_click[3], 1, 5, $GLB_SI_containerUnlock_click[4])
		UTL_Wait(3, 4)
	ElseIf OCR_IsWreckExtendedUnlockPresent() Then
		ACT_MouseClick("left", $GLB_SI_wreckExtendedUnlock_click[0], $GLB_SI_wreckExtendedUnlock_click[1], $GLB_SI_wreckExtendedUnlock_click[2], $GLB_SI_wreckExtendedUnlock_click[3], 1, 5, $GLB_SI_wreckExtendedUnlock_click[4])
		UTL_Wait(3, 4)
	Else
		BOT_LogMessage("Locked object not detected", 1)
	EndIf
EndFunc

;remove lock1 by menu
Func ACT_RemoveLock1ByMenu($isFleetComm = False)
	BOT_LogMessage("Remove lock1 by menu", 1)
	Local $menuFound = ACT_MouseClick("right", $GLB_targetInLock1_click[0], $GLB_targetInLock1_click[1], 1, 1, 1, 5, 1)

	; fleet comm shift
	Local $fcAdd = 0
	If $isFleetComm Then
		$fcAdd = 15
	EndIf

	If $menuFound Then
		ACT_MouseClick("left", $GLB_targetInLock1_click[0] + 78, $GLB_targetInLock1_click[1] + 55 + $fcAdd, 30, 1, 1, 5, 1)
	EndIf
EndFunc

;activate locked target
Func ACT_ActivateLockedTarget($number = 1)
	BOT_LogMessage("Activate locked target " & $number, 1)
	If $number = 1 Then
		ACT_MouseClick("left", $GLB_targetInLock1_click[0], $GLB_targetInLock1_click[1], $GLB_targetInLock1_click[2], $GLB_targetInLock1_click[3], 1, 5, 1)
	ElseIf $number = 2 Then
		ACT_MouseClick("left", $GLB_targetInLock2_click[0], $GLB_targetInLock2_click[1], $GLB_targetInLock2_click[2], $GLB_targetInLock2_click[3], 1, 5, 1)
	ElseIf $number = 3 Then
		ACT_MouseClick("left", $GLB_targetInLock3_click[0], $GLB_targetInLock3_click[1], $GLB_targetInLock3_click[2], $GLB_targetInLock3_click[3], 1, 5, 1)
	EndIf
EndFunc

;click overview object
Func ACT_ClickOverviewObject($object = 1, $byCoordinates = False)
	Local $x, $y
	If $byCoordinates Then
		BOT_LogMessage("Click on overview object [" & $object[0] &":"& $object[1]&"]")
		$x = $GLB_ObjectSearch_click[0]
		$y = $object[1]
	Else
		BOT_LogMessage("Click on overview object " & $object)
		$x = $GLB_ObjectSearch_click[0]
		$y = $GLB_ObjectSearch_click[1] + ($GLB_ObjectSearchIconSize + $GLB_ObjectSearchDividerSize)*($object - 1)
	EndIf
	ACT_MouseClick("left", $x, $y, $GLB_ObjectSearch_click[2], $GLB_ObjectSearch_click[3], 1, 5, $GLB_ObjectSearch_click[4])

	UTL_Wait(1, 1.1)
EndFunc

;activate max speed
Func ACT_GoOnMaxSpeed()
	Sleep(900)
	MouseClick("left", $GLB_maxSpeedButton[0], $GLB_maxSpeedButton[1], 1, 30)
EndFunc

;stop engine
Func ACT_StopEngine()
	;MouseClick("left", $GLB_stopSpeedButton[0], $GLB_stopSpeedButton[1], 1, 30)
	Send("^{SPACE}")
EndFunc

;activate mining
Func ACT_ActivateMining($startModule = 1, $endModule = 8)
	BOT_LogMessage("Activate mining modules " & $startModule & "-" & $endModule, 1)

	Local $wait4lock = 1

	For $s = $startModule - 1 To $endModule - 1 Step 1
		UTL_Wait(0.2, 0.6)
		If GUICtrlRead($GUI_slotHigh[$GLB_curBot][$s]) = "miner" Then
			If OCR_isActiveHighSlot($s +1) Then
				WIN_ActivateWindow($WIN_titles[$GLB_curBot], "before F" & ($s + 1) & " send")
				Send("{F" & ($s + 1) & "}")
				UTL_Wait(2.5, 3.5)
				WIN_ActivateWindow($WIN_titles[$GLB_curBot], "before F" & ($s + 1) & " send")
				Send("{F" & ($s + 1) & "}")
				$wait4lock+= 1
			Else
				WIN_ActivateWindow($WIN_titles[$GLB_curBot], "before F" & ($s + 1) & " send")
				Send("{F" & ($s + 1) & "}")
				$wait4lock+= 1
			EndIf
		EndIf
	Next
EndFunc

;activate module
Func ACT_ActivateModule($level = "high", $type = "gun")
	Local $slots
	Local $preKey
	If $level = "high" Then
		$preKey = ""
		$slots = $GUI_slotHigh
	ElseIf $level = "middle" Then
		$preKey = "!"
		$slots = $GUI_slotMiddle
	ElseIf $level = "low" Then
		$preKey = "^"
		$slots = $GUI_slotLow
	EndIf

	For $s = 0 To 7 Step 1
		UTL_Wait(0.2, 0.6)
		If GUICtrlRead($slots[$GLB_curBot][$s]) = $type Or ($s + 1) = $type Then
			WIN_ActivateWindow($WIN_titles[$GLB_curBot], "before " & $preKey & "F" & ($s + 1) & " send")
			Send($preKey & "{F" & ($s + 1) & "}")
			BOT_LogMessage("Module '" & $type & "' (de)activation in slot №" & ($s + 1), 1)
		EndIf
	Next
EndFunc

; do login
Func ACT_Login()
	Local $rndSwitch = Random(1, 2, 1)
	Local $rndInput = 2;Random(1, 2, 1)

	Local $mode = GUICtrlRead($GUI_loginMethodCombo)

	If $mode = "random" Then
		Local $rndMethod = Random(1, 2, 1)

		If $rndMethod = 1 Then
			$mode = "dblclick"
		ElseIf $rndMethod = 2 Then
			$mode = "clear"
		EndIf
	EndIf

	BOT_LogMessage("Login mode: " & $mode & "(" & $rndSwitch & "," & $rndInput & ")", 1)

	If $mode = "dblclick" Then
		ACT_MouseClick("left", $GLB_click_login_name[0], $GLB_click_login_name[1], $GLB_click_login_name[2], $GLB_click_login_name[3], 2, 5, $GLB_click_login_name[4])
		UTL_Wait(1, 2)
		Send("{DELETE}")

		If Not ACT_RandomSend(GUICtrlRead($GUI_login[$GLB_curBot])) Then
			Return False
		EndIf

		UTL_Wait(1.5, 2)
		If $rndSwitch = 1 Then
			ACT_MouseClick("left", $GLB_click_login_pass[0], $GLB_click_login_pass[1], $GLB_click_login_pass[2], $GLB_click_login_pass[3], 2, 5, $GLB_click_login_pass[4])
		ElseIf $rndSwitch = 2 Then
			Send("{TAB}")
		EndIf

		UTL_Wait(1, 1.5)
		Send("{DELETE}")
	ElseIf $mode = "clear" Then
		ACT_MouseClick("left", $GLB_click_login_name[0], $GLB_click_login_name[1], $GLB_click_login_name[2], $GLB_click_login_name[3], 2, 5, $GLB_click_login_name[4])
		UTL_Wait(0.5, 0.7)
		For $i = 0 To 20 Step 1
			Send("{DELETE}")
			UTL_Wait(0.01, 0.1)
		Next
		For $i = 0 To 20 Step 1
			Send("{BACKSPACE}")
			UTL_Wait(0.01, 0.1)
		Next
		;ACT_MouseClick("left", $GLB_click_login_name[0], $GLB_click_login_name[1], $GLB_click_login_name[2], $GLB_click_login_name[3], 2, 5, $GLB_click_login_name[4])

		If Not ACT_RandomSend(GUICtrlRead($GUI_login[$GLB_curBot])) Then
			Return False
		EndIf

		UTL_Wait(1.5, 2)
		If $rndSwitch = 1 Then
			ACT_MouseClick("left", $GLB_click_login_pass[0], $GLB_click_login_pass[1], $GLB_click_login_pass[2], $GLB_click_login_pass[3], 2, 5, $GLB_click_login_pass[4])
		ElseIf $rndSwitch = 2 Then
			Send("{TAB}")
		EndIf

		UTL_Wait(1, 1.5)
		For $i = 0 To 20 Step 1
			Send("{DELETE}")
			UTL_Wait(0.01, 0.1)
		Next
		For $i = 0 To 20 Step 1
			Send("{BACKSPACE}")
			UTL_Wait(0.01, 0.1)
		Next
	EndIf

	If Not ACT_RandomSend(GUICtrlRead($GUI_password[$GLB_curBot])) Then
		Return False
	EndIf

	UTL_Wait(0.5, 1)
	If $rndInput = 1 Then
		ACT_MouseClick("left", $GLB_click_login_connect[0], $GLB_click_login_connect[1], $GLB_click_login_connect[2], $GLB_click_login_connect[3], 1, 5, $GLB_click_login_connect[4], False, True)
	ElseIf $rndInput = 2 Then
		Send("{ENTER}")
	EndIf

	Return True
EndFunc

;close info window
Func ACT_CloseInfoWindow()
	ACT_MouseClick("left", $GLB_click_EW_close[0], $GLB_click_EW_close[1], $GLB_click_EW_close[2], $GLB_click_EW_close[3], 1, 5, $GLB_click_EW_close[4])
	UTL_Wait(0.5, 1)
EndFunc

;close shutdown window
Func ACT_CloseShutdownInfoWindow()
	ACT_MouseClick("left", $GLB_click_SW_close[0], $GLB_click_SW_close[1], $GLB_click_SW_close[2], $GLB_click_SW_close[3], 1, 5, $GLB_click_SW_close[4])
	UTL_Wait(0.5, 1)
EndFunc

;entering game
Func ACT_EnterGame($character)
	Local $x, $y, $dX, $dY, $speed

	Switch $character
		Case "1"
			$x = $GLB_character1_click[0]
			$y = $GLB_character1_click[1]
			$dX = $GLB_character1_click[2]
			$dY = $GLB_character1_click[3]
			$speed = $GLB_character1_click[4]
		Case "2"
			$x = $GLB_character2_click[0]
			$y = $GLB_character2_click[1]
			$dX = $GLB_character2_click[2]
			$dY = $GLB_character2_click[3]
			$speed = $GLB_character2_click[4]
		Case "3"
			$x = $GLB_character3_click[0]
			$y = $GLB_character3_click[1]
			$dX = $GLB_character3_click[2]
			$dY = $GLB_character3_click[3]
			$speed = $GLB_character3_click[4]
		Case Else
			$x = $GLB_character1_click[0]
			$y = $GLB_character1_click[1]
			$dX = $GLB_character1_click[2]
			$dY = $GLB_character1_click[3]
			$speed = $GLB_character1_click[4]
	EndSwitch

	;Send("{ENTER}")
	UTL_Wait(0.01, 0.1)
	ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, $speed, False, True)
EndFunc

; Отправляет текст на печать, при этом каждый символ отправляется со своей задержкой
; $string - строка для отправки, $max - максимальная задержка, $min - минимальная задерка
Func ACT_RandomSend($string, $min = 20, $max = 200)
    Local $var
    For $i = 1 To StringLen($string)
		If Not WinActive($WIN_titles[$GLB_curBot]) Then
			Return False
		EndIf

        Opt ("SendKeyDownDelay", Random($min,$max))
        $var = StringMid($string, $i, 1)

		If $var = "!" Then
			$var = "{!}"
		ElseIf $var = "#" Then
			$var = "{#}"
		ElseIf $var = "+" Then
			$var = "{+}"
		ElseIf $var = "{" Then
			$var = "{{}"
		ElseIf $var = "}" Then
			$var = "{}}"
		EndIf

        Send($var)
    Next
    Opt("SendKeyDownDelay", 100)
	Return True
EndFunc

; activate tab
Func ACT_SwitchTab($tabname = "asteroids")
	If GUICtrlRead($GUI_OverviewCurrentTabCombo[$GLB_curBot]) = $tabname Then
		BOT_LogMessage("Tab already selected: " & $tabname)
		Return False
	EndIf

	Local $x, $y, $dX, $dY

	Switch $tabname
		Case "default"
			$x = $GLB_OverviewDefaultTab[0]
			$y = $GLB_OverviewDefaultTab[1]
			$dX = $GLB_OverviewDefaultTab[2]
			$dY = $GLB_OverviewDefaultTab[3]
		Case "asteroids"
			$x = $GLB_OverviewAsteroidTab[0]
			$y = $GLB_OverviewAsteroidTab[1]
			$dX = $GLB_OverviewAsteroidTab[2]
			$dY = $GLB_OverviewAsteroidTab[3]
		Case "lensedAsteroids"
			$x = $GLB_OverviewAsteroidLTab[0]
			$y = $GLB_OverviewAsteroidLTab[1]
			$dX = $GLB_OverviewAsteroidLTab[2]
			$dY = $GLB_OverviewAsteroidLTab[3]
		Case "containers"
			$x = $GLB_OverviewContainerTab[0]
			$y = $GLB_OverviewContainerTab[1]
			$dX = $GLB_OverviewContainerTab[2]
			$dY = $GLB_OverviewContainerTab[3]
		Case "npc"
			$x = $GLB_OverviewNPCTab[0]
			$y = $GLB_OverviewNPCTab[1]
			$dX = $GLB_OverviewNPCTab[2]
			$dY = $GLB_OverviewNPCTab[3]
		Case "drones"
			$x = $GLB_OverviewDronesTab[0]
			$y = $GLB_OverviewDronesTab[1]
			$dX = $GLB_OverviewDronesTab[2]
			$dY = $GLB_OverviewDronesTab[3]
		Case Else
	EndSwitch

	ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, 3)

	Local $counter = 0
	While Not OCR_DetectActiveTabPixel($x, $GLB_overviewWindow[1] + $GLB_activeTabDetector[0], $GLB_activeTabDetector[1], $GLB_activeTabDetector[2])
		If $counter = 50 Or $counter = 100 Then
			BOT_LogMessage("Freeze detected: " & $tabname, 1)
			ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, 3)
		EndIf
		$counter+= 1
		UTL_Wait(0.2, 0.21)

		If $counter > 150 Then
			BOT_LogMessage("Long freeze detected: " & $tabname, 1)
			Return False
		EndIf
	WEnd

	Local $delay = GUICtrlRead($GUI_overviewTabDelay)
	UTL_Wait($delay - 0.2, $delay)

	GUICtrlSetData($GUI_OverviewCurrentTabCombo[$GLB_curBot], $tabname)
	BOT_LogMessage("Tab opened: " & $tabname & "(" & $counter*0.15 & " sec)", 1)
	Return True
EndFunc

; activate chat tab
Func ACT_SwitchChatTab($tabname = "local")
	If GUICtrlRead($GUI_ChatCurrentTabCombo[$GLB_curBot]) = $tabname Then
		Return False
	EndIf

	Local $tabLocal = $GLB_LSCW_LocalTab

	Local $x, $y, $dX, $dY

	Switch $tabname
		Case "local"
			$x = $tabLocal[0]
			$y = $tabLocal[1]
			$dX = $tabLocal[2]
			$dY = $tabLocal[3]
		Case "corp"
			$x = $GLB_FCCW_CorpTab[0]
			$y = $GLB_FCCW_CorpTab[1]
			$dX = $GLB_FCCW_CorpTab[2]
			$dY = $GLB_FCCW_CorpTab[3]
		Case Else
	EndSwitch

	ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, 3)

	#cs
	Local $counter = 0
	While Not OCR_DetectActiveTabPixel($x, $GLB_overviewWindow[1] + $GLB_activeTabDetector[0], $GLB_activeTabDetector[1], $GLB_activeTabDetector[2])
		If $counter = 50 Or $counter = 100 Then
			BOT_LogMessage("Freeze detected: " & $tabname, 1)
			ACT_MouseClick("left", $x, $y, $dX, $dY, 1, 5, 3)
		EndIf
		$counter+= 1
		UTL_Wait(0.2, 0.21)

		If $counter > 150 Then
			BOT_LogMessage("Long freeze detected: " & $tabname, 1)
			Return False
		EndIf
	WEnd
	#ce

	UTL_Wait(1, 2)

	GUICtrlSetData($GUI_ChatCurrentTabCombo[$GLB_curBot], $tabname)
	BOT_LogMessage("Chat tab opened: " & $tabname)
	Return True
EndFunc

;mouse click with random shift
Func ACT_MouseClick($button, $x, $y, $dX = 0, $dY = 0, $clicks = 1, $speed = 10, $dSpeed = 0, $allowRandomMouseMovesBefore = False, $allowRandomMouseMovesAfter = False)
	If $allowRandomMouseMovesBefore Then
		ACT_RandomMouseMoves()
	EndIf

	Local $x_click = Round($x + Random(-1*$dX, $dX))
	Local $y_click = Round($y + Random(-1*$dY, $dY))

	If Not WIN_ActivateWindow($WIN_titles[$GLB_curBot], "before " & $button & " mouse click") Then
		BOT_LogMessage("Window for mouse click - " & $button & "[" & $x_click & ";" & $y_click & "] not found", 1)
		Return False
	EndIf

	BOT_LogMessage("Mouse click - " & $button & "[" & $x_click & ";" & $y_click & "]")
	MouseClick($button, $x_click, $y_click, $clicks, $speed + Random($dSpeed))
	UTL_Wait(0.5, 1)

	If $button = "right" Then
		Local $startTS = _TimeGetStamp()
		While Not OCR_DetectRightClickMenu($x_click, $y_click)
			If _TimeGetStamp() - $startTS > 5 Then
				BOT_LogMessage("Right click menu timeout")
				Return False
			EndIf
			BOT_LogMessage("Right click menu NOT found")
			UTL_LogScreen("Right click menu NOT found")
			UTL_Wait(0.5, 1)
		WEnd
		BOT_LogMessage("Right click menu detected")
	EndIf

	If $allowRandomMouseMovesAfter Then
		ACT_RandomMouseMoves()
	EndIf

	Return True
EndFunc

;random mouse moves
Func ACT_RandomMouseMoves($numOfMoves = 1, $x1 = 50, $y1 = 0, $x2 = 0, $y2 = 0, $speed = 5)
	If $x2 = 0 And $y2 = 0 Then
		Local $winSize = WIN_GetWindowSize($WIN_titles[$GLB_curBot])
		If $winSize = False Then
			Return False
		EndIf
		$x2 = $winSize[0]
		$y2 = $winSize[1]
	EndIF

	For $i = 1 To $numOfMoves Step 1
		Local $x = Random($x1, $x2)
		Local $y = Random($y1, $y2)

		MouseMove($x, $y, $speed)
		UTL_Wait(0.5, 1)
	Next
EndFunc

;launch drones
Func ACT_LaunchDrones()
	Local $dronesInShip[2] = [$GLB_DronsWindow[0] + 77, $GLB_DronsWindow[1] + 32]
	#cs
	Local $menuFound = ACT_MouseClick("right", $dronesInShip[0], $dronesInShip[1], 20, 2, 1, 5, 10)

	If $menuFound Then
		ACT_MouseClick("left", $dronesInShip[0] + 50, $dronesInShip[1] + 10, 10, 2, 1, 5, 10)
	EndIf
	#ce

	ACT_MouseClick("left", $dronesInShip[0], $dronesInShip[1], 20, 2, 1, 5, 1)
	UTL_Wait(0.9, 1)
	ACT_MouseClick("left", $dronesInShip[0], $dronesInShip[1], 20, 2, 1, 5, 1)

	ACT_MouseClick("left", $GLB_SI_droneLaunch_click[0], $GLB_SI_droneLaunch_click[1], $GLB_SI_droneLaunch_click[2], $GLB_SI_droneLaunch_click[3], 1, $GLB_SI_droneLaunch_click[4], 1)
EndFunc

;return drones
Func ACT_ReturnDrones()
	;Local $dronesInSpace[2] = [$GLB_DronsWindow[0] + 77, $GLB_DronsWindow[1] + 50]
	#cs
	Local $menuFound = ACT_MouseClick("right", $dronesInSpace[0], $dronesInSpace[1], 20, 2, 1, 5, 10)

	If $menuFound Then
		ACT_MouseClick("left", $dronesInSpace[0] + 77, $dronesInSpace[1] + 40, 10, 2, 1, 5, 10)
	EndIf
	#ce
	Send("{SHIFTDOWN}r{SHIFTUP}")
	;ACT_MouseClick("left", $dronesInSpace[0], $dronesInSpace[1], 20, 2, 1, 5, 1)
	;UTL_Wait(0.9, 1)
	;ACT_MouseClick("left", $dronesInSpace[0], $dronesInSpace[1], 20, 2, 1, 5, 1)

	;ACT_MouseClick("left", $GLB_SI_droneReturn_click[0], $GLB_SI_droneReturn_click[1], $GLB_SI_droneReturn_click[2], $GLB_SI_droneReturn_click[3], 1, $GLB_SI_droneReturn_click[4], 1)
EndFunc

;return drone
Func ACT_ReturnCurrentDrone()
	ACT_MouseClick("left", $GLB_SI_droneReturn_click[0], $GLB_SI_droneReturn_click[1], $GLB_SI_droneReturn_click[2], $GLB_SI_droneReturn_click[3], 1, 5, $GLB_SI_droneReturn_click[4])
EndFunc

;reactivate miners
; should be depricated
Func ACT_ReactivateMiners($oneOnly = False)
	Local $miners = GUI_GetBotMinersAmount()

	For $i = 0 To $miners - 1 Step 1
		If Not OCR_isActiveHighSlot($i + 1) Then
			Local $x = $GLB_activeHighSlot_Item1[0] + $GLB_slot_ItemShift*$i
			Local $y = $GLB_activeHighSlot_Item1[1] - 25
			Send("{F" & ($i + 1) & "}")
			BOT_LogMessage("Slot " & ($i + 1) & "(MineModule) reactivated", 1)

			If $oneOnly Then
				ExitLoop
			EndIf
		EndIf
	Next
EndFunc

;deactivate miners
Func ACT_DeactivateMiners()
	Local $miners = GUI_GetBotMinersAmount()

	For $i = 0 To $miners - 1 Step 1
		If OCR_isActiveHighSlot($i + 1) Then
			Local $x = $GLB_activeHighSlot_Item1[0] + $GLB_slot_ItemShift*$i
			Local $y = $GLB_activeHighSlot_Item1[1] - 25
			Send("{F" & ($i + 1) & "}")
			BOT_LogMessage("Slot " & ($i + 1) & "(MineModule) deactivated", 1)
		EndIf
	Next
EndFunc

;reactivate gang modules
Func ACT_ReactivateGangModules()
	For $i = 0 To 7 Step 1
		If GUICtrlRead($GUI_slotHigh[$GLB_curBot][$i]) = "gang" And Not OCR_isActiveHighSlot($i + 1) Then
			Local $x = $GLB_activeHighSlot_Item1[0] + $GLB_slot_ItemShift*$i
			Local $y = $GLB_activeHighSlot_Item1[1] - 25
			Send("{F" & ($i + 1) & "}")
			BOT_LogMessage("Slot " & ($i + 1) & "(GangModule) reactivated", 1)
		EndIf
	Next
EndFunc

;reactivate guns
Func ACT_ReactivateGuns()
	For $i = 0 To 7 Step 1
		If GUICtrlRead($GUI_slotHigh[$GLB_curBot][$i]) = "gun" And Not OCR_isActiveHighSlot($i + 1) Then
			;Local $x = $GLB_activeHighSlot_Item1[0] + $GLB_slot_ItemShift*$i
			;Local $y = $GLB_activeHighSlot_Item1[1] - 25
			Send("{F" & ($i + 1) & "}")
			BOT_LogMessage("Slot " & ($i + 1) & " reactivated", 1)
		EndIf
	Next
EndFunc

;set view
Func ACT_SetView()
	Local $dX = Round(Random($GLB_viewRotation[4]))
	Local $dY = Round(Random($GLB_viewRotation[5]))
	Local $x_start, $y_start, $x_end, $y_end

	If GUICtrlRead($GUI_fixView[$GLB_curBot]) = "down" Then
		$x_start = $GLB_viewRotation[0] + $dX
		$y_start = $GLB_viewRotation[1] + $dY
		$x_end = $GLB_viewRotation[2] + $dX
		$y_end = $GLB_viewRotation[3] + $dY
	Else
		$x_start = $GLB_viewRotation[2] + $dX
		$y_start = $GLB_viewRotation[3] + $dY
		$x_end = $GLB_viewRotation[0] + $dX
		$y_end = $GLB_viewRotation[1] + $dY
	EndIf

	MouseMove ( $x_start, $y_start, 5 )
	MouseDown ( "left" )
	MouseMove ( $x_end, $y_end, $GLB_viewRotation[6] )
	MouseUp("left")
	MouseWheel ( "up",  $GLB_viewRotation[7] )
EndFunc

;stack all
Func ACT_StackAll($type)
	Local $clickPoint[4] = [1, 1, 1, 1]

	If $type = "items" Or $type = "cargo" Then
		$clickPoint[0] = $GLB_inventoryWindow_cargo[0] + 5
		$clickPoint[1] = $GLB_inventoryWindow_cargo[1] + 5
		$clickPoint[2] = 1
		$clickPoint[3] = 1
	ElseIf $type = "stationHangar" Then
		$clickPoint[0] = $GLB_corpHangarWindow_cargo[0] + 7
		$clickPoint[1] = $GLB_corpHangarWindow_cargo[1] + 7
		$clickPoint[2] = 1
		$clickPoint[3] = 1
	EndIf

	ACT_ClickMenuItem($clickPoint, 4)

	BOT_LogMessage("Stack all in " & $type, 1)
EndFunc

;sort by name
Func ACT_SortByName($type, $skipIfFirstItemPresent = True)
	Local $x1,$y1,$dx1,$dy1
	Local $x2,$y2,$dx2,$dy2
	Local $x3,$y3,$dx3,$dy3

	If $type = "items" Then
		$x1 = $GLB_IW_rightClick[0]
		$y1 = $GLB_IW_rightClick[1]
		$dx1 = $GLB_IW_rightClick[2]
		$dy1 = $GLB_IW_rightClick[3]

		$x2 = $GLB_IW_sortBy_click1[0]
		$y2 = $GLB_IW_sortBy_click1[1]
		$dx2 = $GLB_IW_sortBy_click1[2]
		$dy2 = $GLB_IW_sortBy_click1[3]

		$x3 = $GLB_IW_sortBy_click2[0]
		$y3 = $GLB_IW_sortBy_click2[1]
		$dx3 = $GLB_IW_sortBy_click2[2]
		$dy3 = $GLB_IW_sortBy_click2[3]
	ElseIf $type = "container" Then
		;skip if need
		If $skipIfFirstItemPresent And OCR_IsFirstItemInContainerPresent() Then
			Return True
		EndIf
		$x1 = $GLB_ContW_rightClick[0]
		$y1 = $GLB_ContW_rightClick[1]
		$dx1 = $GLB_ContW_rightClick[2]
		$dy1 = $GLB_ContW_rightClick[3]

		$x2 = $GLB_ContW_sortBy_click1[0]
		$y2 = $GLB_ContW_sortBy_click1[1]
		$dx2 = $GLB_ContW_sortBy_click1[2]
		$dy2 = $GLB_ContW_sortBy_click1[3]

		$x3 = $GLB_ContW_sortBy_click2[0]
		$y3 = $GLB_ContW_sortBy_click2[1]
		$dx3 = $GLB_ContW_sortBy_click2[2]
		$dy3 = $GLB_ContW_sortBy_click2[3]
	ElseIf $type = "cargo" Then
		;skip if need
		If $skipIfFirstItemPresent And OCR_IsFirstItemInCargoPresent() Then
			Return True
		EndIf

		$x1 = $GLB_CW_rightClick[0]
		$y1 = $GLB_CW_rightClick[1]
		$dx1 = $GLB_CW_rightClick[2]
		$dy1 = $GLB_CW_rightClick[3]

		$x2 = $GLB_CW_sortBy_click1[0]
		$y2 = $GLB_CW_sortBy_click1[1]
		$dx2 = $GLB_CW_sortBy_click1[2]
		$dy2 = $GLB_CW_sortBy_click1[3]

		$x3 = $GLB_CW_sortBy_click2[0]
		$y3 = $GLB_CW_sortBy_click2[1]
		$dx3 = $GLB_CW_sortBy_click2[2]
		$dy3 = $GLB_CW_sortBy_click2[3]
	ElseIf $type = "fleetCommCorpHangar" Then
		;skip if need
		If $skipIfFirstItemPresent And OCR_IsFirstItemInFleetCommCorpHangarPresent() Then
			Return True
		EndIf

		$x1 = $GLB_FCCHW_rightClick[0]
		$y1 = $GLB_FCCHW_rightClick[1]
		$dx1 = $GLB_FCCHW_rightClick[2]
		$dy1 = $GLB_FCCHW_rightClick[3]

		$x2 = $GLB_FCCHW_sortBy_click1[0]
		$y2 = $GLB_FCCHW_sortBy_click1[1]
		$dx2 = $GLB_FCCHW_sortBy_click1[2]
		$dy2 = $GLB_FCCHW_sortBy_click1[3]

		$x3 = $GLB_FCCHW_sortBy_click2[0]
		$y3 = $GLB_FCCHW_sortBy_click2[1]
		$dx3 = $GLB_FCCHW_sortBy_click2[2]
		$dy3 = $GLB_FCCHW_sortBy_click2[3]
	EndIf

	Local $menuFound = ACT_MouseClick("right", $x1, $y1, $dx1, $dy1, 1, 5, 1)
	If $menuFound Then
		ACT_MouseClick("left", $x2, $y2, $dx2, $dy2, 1, 5, 1)
		ACT_MouseClick("left", $x3, $y3, $dx3, $dy3, 1, 5, 1)
	EndIf
EndFunc

;open corp hangar
Func ACT_OpenCorpHangar()
	ACT_MouseClick("left", $GLB_CH_open_click[0], $GLB_CH_open_click[1], $GLB_CH_open_click[2], $GLB_CH_open_click[3], 1, 5, 10)
	UTL_Wait(2, 3)
EndFunc

;click on ship
Func ACT_ClickOnShip()
	ACT_MouseClick("left", $GLB_shipCenter[0], $GLB_shipCenter[1], 1, 1, 1, 5, 1)
	UTL_Wait(1, 1.1)
EndFunc

;repair
Func ACT_RepairAllInStation()
	Local $shipClick[2] = [480, 397]
	Local $menuFound = ACT_MouseClick("right", $GLB_FitW_shipMenu_click[0], $GLB_FitW_shipMenu_click[1], 2, 2, 1, 5, 1)
	If $menuFound Then
		ACT_MouseClick("left", $GLB_FitW_shipMenu_click[0] + 65, $GLB_FitW_shipMenu_click[1] + 27, 2, 2, 1, 5, 1)
	Else
		Return False
	EndIf

	UTL_Wait(2, 3)
	ACT_MouseClick("left", 575, 520, 2, 2, 1, 5, 1)
	UTL_Wait(2, 3)
	Send("{ENTER}")
	ACT_MouseClick("left", 698, 243, 2, 2, 1, 5, 1)

	Return True
EndFunc

;close wrecks
Func ACT_CloseWrecks()
	ACT_MouseClick("left", $GLB_wreckWindowClose[0], $GLB_wreckWindowClose[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;accept chat
Func ACT_AcceptChat()
	ACT_MouseClick("left", $GLB_click_CIW_accept[0], $GLB_click_CIW_accept[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	ACT_MouseClick("left", $GLB_click_CIW_ok[0], $GLB_click_CIW_ok[1], 1, 1, 1, 5, 1)
EndFunc

;reject chat
Func ACT_RejectChat()
	ACT_MouseClick("left", $GLB_click_CIW_reject[0], $GLB_click_CIW_reject[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	ACT_MouseClick("left", $GLB_click_CIW_ok[0], $GLB_click_CIW_ok[1], 1, 1, 1, 5, 1)
EndFunc

;open fleet
Func ACT_OpenFleet()
	ACT_MouseClick("left", $GLB_MM_Fleet_click[0], $GLB_MM_Fleet_click[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;accept fleet
Func ACT_AcceptFleet()
	ACT_MouseClick("left", $GLB_click_JFW_yes[0], $GLB_click_JFW_yes[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
	Send("{ENTER}")
	UTL_Wait(0.3, 0.5)
EndFunc

;reject fleet
Func ACT_RejectFleet()
	ACT_MouseClick("left", $GLB_click_JFW_no[0], $GLB_click_JFW_no[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;create fleet
Func ACT_CreateFleet()
	#cs
	ACT_MouseClick("left", $GLB_FW_createFleet_click[0], $GLB_FW_createFleet_click[1], 1, 1, 1, 5, 1)
	#ce
	Local $x = $GLB_FWindow[0] + 11
	Local $y = $GLB_FWindow[1] + 7

	Local $menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	UTL_Wait(2, 3)
	;If $menuFound Then
		ACT_MouseClick("left", $x + 45, $y + 7, 5, 1, 1, 5, 1)
		UTL_Wait(3, 4)
		ACT_MouseClick("left", $x + 27, $y + 22, 5, 1, 1, 5, 1)
	;EndIf

	UTL_Wait(0.3, 0.5)
EndFunc

;invite to fleet
Func ACT_InviteToFleet($number)
	Local $x = $GLB_FCCW_CorpMembers[0] + 5
	Local $y = $GLB_FCCW_CorpMembers[1] + ($number - 1)*$GLB_FCCW_CorpMemberHeight + 5

	Local $menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	If $menuFound Then
		ACT_MouseClick("left", $x + 40, $y + 164, 5, 1, 1, 5, 1)
		UTL_Wait(1, 2)
		MouseMove($x - 65, $y + 164)
		ACT_MouseClick("left", $x - 65, $y + 180, 5, 1, 1, 25, 1)
	EndIf
EndFunc

;open orca cargo
Func ACT_OpenOrcaCargos()
	Local $x = 480
	Local $y = 465

	MouseMove ( $GLB_viewRotation[0], $GLB_viewRotation[1], 5 )
	MouseDown ( "left" )
	MouseUp("left")
	MouseWheel ( "down",  60 )

	UTL_Wait(1, 2)

	Local $menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	; open cargo
	If $menuFound Then
		ACT_MouseClick("left", $x + 86, $y + 180, 5, 1, 1, 20, 1)
		UTL_Wait(0.5, 1)
	EndIf

	$menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	; open corphangar
	If $menuFound Then
		ACT_MouseClick("left", $x + 86, $y + 210, 5, 1, 1, 20, 1)
		UTL_Wait(0.5, 1)
	EndIf

	$menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	; open ore
	If $menuFound Then
		ACT_MouseClick("left", $x + 86, $y + 226, 5, 1, 1, 20, 1)
		UTL_Wait(0.5, 1)
	EndIf

	MouseMove ( $GLB_viewRotation[0], $GLB_viewRotation[1], 5 )
	MouseDown ( "left" )
	MouseUp("left")
	MouseWheel ( "up",  60 )
EndFunc

;open fleetcom corp hangar
Func ACT_OpenFleetCommCorpHangar($x, $y)
	Local $menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	; open corphangar
	If $menuFound Then
		ACT_MouseClick("left", $x + 64, $y + 164, 10, 1, 1, 5, 1)
		UTL_Wait(0.5, 1)
	EndIf
EndFunc

;open ship corp hangar in station
Func ACT_OpenShipCorpHangarInStation()
	Local $x = $GLB_FitW_shipMenu_click[0]
	Local $y = $GLB_FitW_shipMenu_click[1]

	ACT_MouseClick("left", $x, $y, 1, 1, 1, 5, 1)
	;MouseWheel ( "down",  20 )

	Local $menuFound = ACT_MouseClick("right", $x, $y, 1, 1, 1, 5, 1)
	; open corphangar
	If $menuFound Then
		ACT_MouseClick("left", $x + 70, $y + 85, 10, 1, 1, 5, 1)
		UTL_Wait(0.5, 1)
	EndIf
EndFunc

;activate corp hangar tab
Func ACT_ActivateCorpHangarTab($number, $window)
	Local $shifts

	If _ArrayToString($window, "|") = _ArrayToString($GLB_POSCorpHangarWindow, "|") Then
		$shifts = $GLB_corpHangarTabsShift
	ElseIf _ArrayToString($window, "|") = _ArrayToString($GLB_corpHangarWindow, "|") Then
		$shifts = $GLB_corpHangarStationTabsShift
	EndIf

	ACT_MouseClick("left", $window[0] + $shifts[$number - 1][0], $window[1] + $shifts[$number - 1][1], $shifts[$number - 1][2], $shifts[$number - 1][3], 1, 5, 1)

	UTL_Wait(0.5, 1)
EndFunc

;activate station panel
Func ACT_ActivateStationPanel()
	ACT_MouseClick("left", $GLB_activateStationPanel[0], $GLB_activateStationPanel[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;open fit window
Func ACT_OpenFitting()
	ACT_MouseClick("left", $GLB_MM_Fitting_click[0], $GLB_MM_Fitting_click[1], $GLB_MM_Fitting_click[2], $GLB_MM_Fitting_click[3], 1, 25, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;close corp hangar window
Func ACT_CloseCorpHangar()
	ACT_MouseClick("left", $GLB_corpHangarWindowClose[0], $GLB_corpHangarWindowClose[1], $GLB_corpHangarWindowClose[2], $GLB_corpHangarWindowClose[3], 1, 5, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;close fit window
Func ACT_CloseFitting()
	ACT_MouseClick("left", $GLB_FitW_close_click[0], $GLB_FitW_close_click[1], 1, 1, 1, 5, 1)
	UTL_Wait(0.3, 0.5)
EndFunc

;maximize selected item window
Func ACT_SIWindowMaximize()
	ACT_MouseClick("left", $GLB_SIWindow[0] + 120, $GLB_SIWindow[1] + 7, 10, 1, 2, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;open slots panel
Func ACT_OpenSlotsPanel()
	ACT_MouseClick("left", $GLB_slotsPanelOpen_click[0], $GLB_slotsPanelOpen_click[1], $GLB_slotsPanelOpen_click[2], $GLB_slotsPanelOpen_click[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;activate people and places tab
Func ACT_ActivatePAPTab()
	;Send("!e")
	;UTL_Wait(0.3, 0.5)
	ACT_MouseClick("left", $GLB_PAP_activateTab_click[0], $GLB_PAP_activateTab_click[1], $GLB_PAP_activateTab_click[2], $GLB_PAP_activateTab_click[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

Func ACT_OpenPAPWindow()
	Send("{ALTDOWN}e{ALTUP}")
	UTL_Wait(0.3, 0.5)
EndFunc

;click overview sorting
Func ACT_ClickOverviewSorting($column = "distance")
	If $column = "icon" Then
		ACT_MouseClick("left", $GLB_sortingDetectorIcon[0], $GLB_sortingDetectorIcon[1], 3, 3, 1, 5, 1)
	ElseIf $column = "distance" Then
		ACT_MouseClick("left", $GLB_sortingDetectorDistance[0], $GLB_sortingDetectorDistance[1], 3, 3, 1, 5, 1)
	EndIf
	UTL_Wait(0.5, 1)
EndFunc

;click PAP sorting
Func ACT_ClickPAPSorting()
	ACT_MouseClick("left", $GLB_PAPsortingDetector[0], $GLB_PAPsortingDetector[1], 3, 3, 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;close client update window
Func ACT_CloseClientUpdateWindow()
	ACT_MouseClick("left", $GLB_click_CUW_no[0], $GLB_click_CUW_no[1], $GLB_click_CUW_no[2], $GLB_click_CUW_no[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;open scanner window
Func ACT_OpenScanner()
	ACT_MouseClick("left", $GLB_ScannerOpenMenuButton[0], $GLB_ScannerOpenMenuButton[1], $GLB_ScannerOpenMenuButton[2], $GLB_ScannerOpenMenuButton[3], 1, 5, 1)
	UTL_Wait(2, 3)
	ACT_MouseClick("left", $GLB_ScannerMenuProbeClick[0], $GLB_ScannerMenuProbeClick[1], $GLB_ScannerMenuProbeClick[2], $GLB_ScannerMenuProbeClick[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;close scanner
Func ACT_CloseScanner()
	ACT_MouseClick("left", $GLB_ScannerCloseButton[0], $GLB_ScannerCloseButton[1], $GLB_ScannerCloseButton[2], $GLB_ScannerCloseButton[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;laugh scanner
Func ACT_LaunghScanner()
	ACT_MouseClick("left", $GLB_SW_scan_click[0], $GLB_SW_scan_click[1], $GLB_SW_scan_click[2], $GLB_SW_scan_click[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
EndFunc

;loot all
Func ACT_LootAll()
	ACT_MouseClick("left", $GLB_inventoryWindow_lootButton[0], $GLB_inventoryWindow_lootButton[1], $GLB_inventoryWindow_lootButton[2], $GLB_inventoryWindow_lootButton[3], 1, 5, 1)
	UTL_Wait(0.5, 1)
	Send("{ENTER}")
EndFunc

Func ACT_ReloadAmmo()
	Send("^r")
	UTL_Wait(0.3, 0.5)
EndFunc

Func ACT_OpenCargo()
	Send("!c")
	UTL_Wait(0.3, 0.5)
EndFunc

Func ACT_SetDestination($PAP_position = 1)
	Local $PAP_itemCoordinates[4]
	Local $PAP_itemHeight = $GLB_PAPItemSize + $GLB_PAPDividerSize
	; x
	$PAP_itemCoordinates[0] = $GLB_PAP_placesArea[0] + 140
	; y
	$PAP_itemCoordinates[1] = $GLB_PAP_placesArea[1] + ($PAP_position - 1)*$PAP_itemHeight + $PAP_itemHeight/2
	; dX
	$PAP_itemCoordinates[2] = 70
	; dY
	$PAP_itemCoordinates[3] = 1

	ACT_ClickMenuItem($PAP_itemCoordinates, 2)

	UTL_Wait(0.3, 0.5)
EndFunc