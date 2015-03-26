Global $GUI_OCRWindow

; inventory group
Global $GUI_OCRInventoryGroup
Global $GUI_OCRInventoryX
Global $GUI_OCRInventoryY

; chat group
Global $GUI_OCRChatGroup
Global $GUI_OCRChatX
Global $GUI_OCRChatY

; overview group
Global $GUI_OCROverviewGroup
Global $GUI_OCROverviewX
Global $GUI_OCROverviewY

; SI group
Global $GUI_OCRSIGroup
Global $GUI_OCRSIX
Global $GUI_OCRSIY

; Scanner group
Global $GUI_OCRScannerGroup
Global $GUI_OCRScannerX
Global $GUI_OCRScannerY

; Drones group
Global $GUI_OCRDronesGroup
Global $GUI_OCRDronesX
Global $GUI_OCRDronesY

; PAP group
Global $GUI_OCRPAPGroup
Global $GUI_OCRPAPX
Global $GUI_OCRPAPY

; create OCR settings window GUI
Func GUI_CreateOCRWindowGUI()
	$GUI_OCRWindow = GUICreate("OCR", 505, 310)

	Local $treeview = GUICtrlCreateTreeView(5, 5, 200, 300, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetColor(-1, 0x000000)

	Local $inventoryitem = GUICtrlCreateTreeViewItem("Inventory", $treeview)
	Local $chatitem = GUICtrlCreateTreeViewItem("Chat", $treeview)
	Local $overviewitem = GUICtrlCreateTreeViewItem("Overview", $treeview)
	Local $siitem = GUICtrlCreateTreeViewItem("Selected item", $treeview)
	Local $scanneritem = GUICtrlCreateTreeViewItem("Scanner", $treeview)
	Local $dronesitem = GUICtrlCreateTreeViewItem("Drones", $treeview)
	Local $papitem = GUICtrlCreateTreeViewItem("Peoples and Places", $treeview)

	GUICtrlSetOnEvent($inventoryitem, "GUI_ShowInventoryOCR")
	GUICtrlSetOnEvent($chatitem, "GUI_ShowChatOCR")
	GUICtrlSetOnEvent($overviewitem, "GUI_ShowOverviewOCR")
	GUICtrlSetOnEvent($siitem, "GUI_ShowSIOCR")
	GUICtrlSetOnEvent($scanneritem, "GUI_ShowScannerOCR")
	GUICtrlSetOnEvent($dronesitem, "GUI_ShowDronesOCR")
	GUICtrlSetOnEvent($papitem, "GUI_ShowPAPOCR")

	Local $groupSettings[2] = [210, 5]

	; inventory group
	$GUI_OCRInventoryGroup = GUICtrlCreateGroup ("Inventory", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCRInventoryX = GUICtrlCreateInput ($GLB_inventoryWindowDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCRInventoryY = GUICtrlCreateInput ($GLB_inventoryWindowDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; chat group
	$GUI_OCRChatGroup = GUICtrlCreateGroup ("Chat", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCRChatX = GUICtrlCreateInput ($GLB_LSCWDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCRChatY = GUICtrlCreateInput ($GLB_LSCWDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; overview group
	$GUI_OCROverviewGroup = GUICtrlCreateGroup ("Overview", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCROverviewX = GUICtrlCreateInput ($GLB_overviewWindowDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCROverviewY = GUICtrlCreateInput ($GLB_overviewWindowDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; SI group
	$GUI_OCRSIGroup = GUICtrlCreateGroup ("Selected item", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCRSIX = GUICtrlCreateInput ($GLB_SIWindowDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCRSIY = GUICtrlCreateInput ($GLB_SIWindowDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; Drones group
	$GUI_OCRDronesGroup = GUICtrlCreateGroup ("Drones", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCRDronesX = GUICtrlCreateInput ($GLB_DronesWindowDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCRDronesY = GUICtrlCreateInput ($GLB_DronesWindowDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; Scanner group
	$GUI_OCRScannerGroup = GUICtrlCreateGroup ("Scanner", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCRScannerX = GUICtrlCreateInput ($GLB_ScannerWindowDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCRScannerY = GUICtrlCreateInput ($GLB_ScannerWindowDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; PAP group
	$GUI_OCRPAPGroup = GUICtrlCreateGroup ("Peoples and places", $groupSettings[0], $groupSettings[1], 290, 300)
		GUICtrlCreateLabel("Windox X coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_OCRPAPX = GUICtrlCreateInput ($GLB_PAPWindowDefaultLocation[0], $groupSettings[0] + 120, $groupSettings[1] + 15, 50, 20)

		GUICtrlCreateLabel("Windox Y coordinate:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_OCRPAPY = GUICtrlCreateInput ($GLB_PAPWindowDefaultLocation[1], $groupSettings[0] + 120, $groupSettings[1] + 35, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; hide non-default panels
	For $i = $GUI_OCRChatGroup To $GUI_OCRPAPY
		GUICtrlSetState($i, $GUI_HIDE)
	Next

	; set window events
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_CloseOCRWindow")

	GLB_UpdateOCR()

	; GUI MESSAGE LOOP
	GUISetState(@SW_HIDE)
EndFunc

; open OCR settings window
Func GUI_OpenOCRWindow()
	GUISetState(@SW_SHOW, $GUI_OCRWindow)
EndFunc

;close OCR window
Func GUI_CloseOCRWindow()
	GUISetState(@SW_HIDE, $GUI_OCRWindow)
EndFunc

; hide all OCR
Func GUI_HideAllOCR()
	For $i = $GUI_OCRInventoryGroup To $GUI_OCRPAPY
		GUICtrlSetState($i, $GUI_HIDE)
	Next
EndFunc

; show inventory settings
Func GUI_ShowInventoryOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCRInventoryGroup To $GUI_OCRInventoryY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show chat settings
Func GUI_ShowChatOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCRChatGroup To $GUI_OCRChatY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show overview settings
Func GUI_ShowOverviewOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCROverviewGroup To $GUI_OCROverviewY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show SI settings
Func GUI_ShowSIOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCRSIGroup To $GUI_OCRSIY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show Scanner settings
Func GUI_ShowScannerOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCRScannerGroup To $GUI_OCRScannerY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show Drones settings
Func GUI_ShowDronesOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCRDronesGroup To $GUI_OCRDronesY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show PAP settings
Func GUI_ShowPAPOCR()
	GUI_HideAllOCR()
	For $i = $GUI_OCRPAPGroup To $GUI_OCRPAPY
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc