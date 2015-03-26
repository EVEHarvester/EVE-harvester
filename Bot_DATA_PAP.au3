;people and places window
Global $GLB_PAP[2]

Global $GLB_PAPWindowDefaultLocation[2] = [283, 141]

Global $GLB_PAP_activateTab_click[4]
Global $GLB_PAP_placesArea[2]
Global $GLB_PAP_activate_click[4]
Global $GLB_PAPItemSize = 20
Global $GLB_PAPDividerSize = 1
Global $GLB_PAPDetector[6]
Global $GLB_PAPsortingDetector[4]
Global $GLB_PAPsortingDetector2[4]
Global $GLB_PAPsortingDetectorFix[2]
Global $GLB_PAPsortingDetectorFix2[2]

Global $GLB_PAPcurrentSysColor[2] = [0x67C167, 5]
Global $GLB_PAPdestinationSysColor[2] = [0xC4C40D, 5]

; update ocr data from GUI
Func DATA_UpdatePAPOCR()
	Local $OCRPAPX = GUICtrlRead($GUI_OCRPAPX)
	Local $OCRPAPY = GUICtrlRead($GUI_OCRPAPY)

	Dim $GLB_PAP[2] = [$OCRPAPX, $OCRPAPY]
	Dim $GLB_PAP_activateTab_click[4] = [$GLB_PAP[0] + 50, $GLB_PAP[1] + 10, 15, 1]
	Dim $GLB_PAP_placesArea[2] = [$GLB_PAP[0] + 9, $GLB_PAP[1] + 147]
	Dim $GLB_PAP_activate_click[4] = [$GLB_PAP_placesArea[0] + 140, $GLB_PAP_placesArea[1] + 10 + $GLB_PAPItemSize, 70, 2] ; $GLB_PAPItemSize 4 Corporation bookmarks
	Dim $GLB_PAPDetector[6] = [$GLB_PAP_placesArea[0], $GLB_PAP_placesArea[1], $GLB_PAP_placesArea[0] + 200, $GLB_PAP_placesArea[1] + 35, 0x68C468, 5]

	Dim $GLB_PAPsortingDetector[4] = [$GLB_PAP[0] + 299, $GLB_PAP[1] + 115, 0xD0D0D0, 25]
	Dim $GLB_PAPsortingDetector2[4] = [$GLB_PAP[0] + 296, $GLB_PAP[1] + 115, 0xD0D0D0, 25]

	Dim $GLB_PAPsortingDetectorFix[2] = [-1, -1]
	Dim $GLB_PAPsortingDetectorFix2[2] = [6, 0]
EndFunc