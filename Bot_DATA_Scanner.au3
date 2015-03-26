; scanner window
Global $GLB_ScannerWindow

Global $GLB_ScannerWindowDefaultLocation[2] = [447, 1]

Global $GLB_SW_activate_click[4]
Global $GLB_SW_scan_click[4]
Global $GLB_SW_scan_results[2]
Global $GLB_SW_scan_results_itemHeight = 20
Global $GLB_SW_scan_results_delimiterHeight = 0
Global $GLB_ScanWaitTime = 15 ; sec

Global $GLB_SW_scan_coloredResluts[2]
Global $GLB_SW_scan_coloredReslutsMaxItems = 10

Global $GLB_SW_scan_coloredResluts_Ore_pixel1[4] = [1, 1, 0x076D07, 10]
Global $GLB_SW_scan_coloredResluts_Ore_pixel2[4] = [48, 8, 0xB6D4B6, 10]
Global $GLB_SW_scan_coloredResluts_Ore_pixel3[4] = [69, 4, 0xAFD0AF, 10]
Global $GLB_SW_scan_coloredResluts_Ore_pixel4[4] = [65, 10, 0x086E08, 10]

Global $GLB_SW_scan_coloredResluts_ClearIcicle_pixel1[4] = [85, 6, 0x0C700C, 10]
Global $GLB_SW_scan_coloredResluts_ClearIcicle_pixel2[4] = [87, 6, 0xB9D6B9, 10]
Global $GLB_SW_scan_coloredResluts_ClearIcicle_pixel3[4] = [102, 12, 0xB9D6B9, 10]

Global $GLB_ScannerOpenMenuButton[4] = [411, 687, 7, 7]
Global $GLB_ScannerMenuProbeClick[4] = [$GLB_ScannerOpenMenuButton[0], $GLB_ScannerOpenMenuButton[1] - 33, 12, 12]
Global $GLB_ScannerCloseButton[4]

; update ocr data from GUI
Func DATA_UpdateScannerOCR()
	Local $OCRScannerX = Int(GUICtrlRead($GUI_OCRScannerX))
	Local $OCRScannerY = Int(GUICtrlRead($GUI_OCRScannerY))

	Dim $GLB_ScannerWindow[2] = [$OCRScannerX, $OCRScannerY]
	Dim $GLB_SW_scan_click[4] = [$GLB_ScannerWindow[0] + 21, $GLB_ScannerWindow[1] + 118, 10, 10]
	Dim $GLB_SW_activate_click[4] = [$GLB_ScannerWindow[0] + 45, $GLB_ScannerWindow[1] + 27, 10, 3]
	Dim $GLB_ScannerCloseButton[4] = [$GLB_ScannerWindow[0] + 306, $GLB_ScannerWindow[1] + 8, 1, 1]

	Dim $GLB_SW_scan_results[2] = [$GLB_ScannerWindow[0] + 4, $GLB_ScannerWindow[1] + 198]
	Dim $GLB_SW_scan_coloredResluts[2] = [$GLB_ScannerWindow[0] + 144, $GLB_ScannerWindow[1] + 198]
EndFunc