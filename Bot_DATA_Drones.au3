; drones window
Global $GLB_DronsWindow[2]
Global $GLB_DronColor[2] = [0x135416, 25]

Global $GLB_DronesWindowDefaultLocation[2] = [768, 457]

; update ocr data from GUI
Func DATA_UpdateDronesOCR()
	Local $OCRDronesX = GUICtrlRead($GUI_OCRDronesX)
	Local $OCRDronesY = GUICtrlRead($GUI_OCRDronesY)

	Dim $GLB_DronsWindow[2] = [$OCRDronesX, $OCRDronesY]
EndFunc