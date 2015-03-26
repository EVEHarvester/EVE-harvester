; inventory window
Global $GLB_inventoryWindow[2]

Global $GLB_inventoryWindowDefaultLocation[2] = [33, 1]

Global $GLB_inventoryWindow_cargoIndicator[5]
Global $GLB_inventoryWindow_cargo[2]

Global $GLB_inventoryWindow_capsuleSpace_pixel1[4]
Global $GLB_inventoryWindow_capsuleSpace_pixel2[4]

Global $GLB_inventoryWindow_capsuleStation_pixel1[4]
Global $GLB_inventoryWindow_capsuleStation_pixel2[4]

; not used in Retribution 1.0.5
;Global $GLB_inventoryWindow_filtersToggle[4]
;Global $GLB_inventoryWindow_filtersIndicator[4]
;Global $GLB_inventoryWindow_filtersIndicator2[4]

Global $GLB_inventoryWindow_tree[2]
Global $GLB_inventoryWindowDetect1[4]
Global $GLB_inventoryWindowDetect2[4]
Global $GLB_inventoryWindow_lootButton[4]
Global $GLB_inventoryWindow_treeItemSize = 22
Global $GLB_inventoryWindow_treeShipPosition = 1
Global $GLB_inventoryWindow_treeContainerPosition = 2
Global $GLB_inventoryWindow_treeItemsPosition = 3
Global $GLB_inventoryWindow_cargoItemShift[2]
Global $GLB_inventoryWindow_cargoItemSize[2]
Global $GLB_inventoryWindow_cargoItemSpace = 12

; update ocr data from GUI
Func DATA_UpdateInventoryOCR()
	Local $OCRInventoryX = GUICtrlRead($GUI_OCRInventoryX)
	Local $OCRInventoryY = GUICtrlRead($GUI_OCRInventoryY)

	Dim $GLB_inventoryWindow[2] = [$OCRInventoryX, $OCRInventoryY]
	Local $x = $GLB_inventoryWindow[0]
	Local $y = $GLB_inventoryWindow[1]
	Dim $GLB_inventoryWindow_cargoIndicator[5] = [$x + 55, $y + 48, 315, 0x0B4658, 30]; start[x,y], width, color, dColor
	Dim $GLB_inventoryWindow_cargo[2] = [$x + 55, $y + 66]

	;Dim $GLB_inventoryWindow_filtersToggle[4] = [$x + 10, $y + 88, 3, 2]
	;Dim $GLB_inventoryWindow_filtersIndicator[4] = [$x + 214, $y + 88, 0xCBCCCB, 25]
	;Dim $GLB_inventoryWindow_filtersIndicator2[4] = [$x + 214, $y + 107, 0xCBCCCB, 25]

	Dim $GLB_inventoryWindow_capsuleSpace_pixel1[4] = [$x + 230, $y + 47, 0x919191, 20]
	Dim $GLB_inventoryWindow_capsuleSpace_pixel2[4] = [$x + 230, $y + 49, 0x5F5F5F, 20]

	Dim $GLB_inventoryWindow_capsuleStation_pixel1[4] = [$x + 235, $y + 47, 0x919191, 20]
	Dim $GLB_inventoryWindow_capsuleStation_pixel2[4] = [$x + 235, $y + 49, 0x5F5F5F, 20]

	Dim $GLB_inventoryWindow_tree[2] = [$x + 3, $y + 44]
	Dim $GLB_inventoryWindowDetect1[4] = [$x + 452, $y + 29, 0x878787, 50]
	Dim $GLB_inventoryWindowDetect2[4] = [$x + 452, $y + 34, 0x878787, 50]
	Dim $GLB_inventoryWindow_lootButton[4] =[$x + 75, $y + 124, 15, 5]
	Dim $GLB_inventoryWindow_cargoItemShift[2] = [12, 12]
	Dim $GLB_inventoryWindow_cargoItemSize[2] = [64, 64]
EndFunc