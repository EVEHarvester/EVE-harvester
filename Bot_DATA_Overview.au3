; overview window
Global $GLB_overviewWindow[2]

Global $GLB_overviewWindowDefaultLocation[2] = [768, 141]

Global $GLB_overviewContentItems = 14

;настройка поиска объектов
Global $GLB_ObjectSearch[2]
Global $GLB_ObjectSearchIconSize = 18
Global $GLB_ObjectSearchDividerSize = 1
Global $GLB_ObjectSearch_click[5]

;overview tabs
Global $GLB_OverviewDefaultTab[4]
Global $GLB_OverviewAsteroidTab[4]
Global $GLB_OverviewAsteroidLTab[4]
Global $GLB_OverviewContainerTab[4]
Global $GLB_OverviewNPCTab[4]
Global $GLB_OverviewDronesTab[4]

Global $GLB_activeTabDetector[3] = [19, 0x222426, 40]; dY, color, dColor
Global $GLB_sortingDetectorDistance[4]
Global $GLB_sortingDetectorIcon[4]

Global $GLB_OverviewObjectLocked[8] = [-7, 9, 4, 9, 0xFFFDF5, 0x929495, 0xFFFDF5, 30] ;left shift x:y, right shift x:y, color, deselected color, selected color, color range

;overview object detection
Global $GLB_OverviewNPCBig[2] = [0, 3]
Global $GLB_OverviewNPCMedium[2] = [-1, 4]
Global $GLB_OverviewNPCSmall[2] = [-1, 6]
Global $GLB_OverviewNPCTower[4] = [0, 8, 0xD31818, 25]
Global $GLB_OverviewCorpHangar[4] = [2, 5, 0xD3D3D3, 25]
Global $GLB_OverviewDestination[4] = [-1, 5, 0xE7E702, 25]
Global $GLB_OverviewGate[4] = [-1, 5, 0xE7E7E7, 1]

;faction
Global $GLB_OverviewDomination[4] = [95, 6, 0xBCBDBC, 25]
Global $GLB_OverviewShadow[4] = [102, 6, 0xD2D2D2, 25]
Global $GLB_OverviewDread[4] = [95, 5, 0xBDBEBE, 25]
Global $GLB_OverviewSentient[4] = [118, 5, 0xBDBEBE, 25]

;NPC color
Global $GLB_NPCColor = 0xC11313
;station or empty wreck or gate color
;Global $GLB_StationColor = 0xFFFFFF
;own(white) wreck color
Global $GLB_OwnWreckColor = 0xDBDADA
;used(gray) wreck color
Global $GLB_UsedWreckColor = 0x7B7A7A
;shared(blue) wreck color
Global $GLB_SharedWreckColor = 0x2C6DD9
;shared used(dark blue) wreck color
Global $GLB_SharedUsedWreckColor = 0x1C3F7B
;green ships color
;Global $GLB_GreenShipColor = 0x0F4E0F
;asteroid text color
Global $GLB_AsteroidTextColor = 0xCACACB
Global $GLB_AsteroidTextColor2 = 0xFFFFFF
;container color
Global $GLB_ContainerColor = 0xFFFFFF
;fleet color
Global $GLB_FleetColor[2] = [0x6F3596, 50]

; update ocr data from GUI
Func DATA_UpdateOverviewOCR()
	Local $OCROverviewX = Int(GUICtrlRead($GUI_OCROverviewX))
	Local $OCROverviewY = Int(GUICtrlRead($GUI_OCROverviewY))

	Dim $GLB_overviewWindow[2] = [$OCROverviewX, $OCROverviewY]

	Dim $GLB_ObjectSearch[2] = [$GLB_overviewWindow[0] + 16, $GLB_overviewWindow[1] + 64]
	Dim $GLB_ObjectSearch_click[5] = [$GLB_ObjectSearch[0] + 90, $GLB_ObjectSearch[1] + $GLB_ObjectSearchIconSize/2, 90, 3, 5]

	Dim $GLB_OverviewDefaultTab[4] = [$GLB_overviewWindow[0] + 24, $GLB_overviewWindow[1] + 32, 5, 2]
	Dim $GLB_OverviewAsteroidTab[4] = [$GLB_overviewWindow[0] + 75, $GLB_overviewWindow[1] + 32, 5, 2]
	Dim $GLB_OverviewAsteroidLTab[4] = [$GLB_overviewWindow[0] + 122, $GLB_overviewWindow[1] + 32, 5, 2]
	Dim $GLB_OverviewContainerTab[4] = [$GLB_overviewWindow[0] + 122, $GLB_overviewWindow[1] + 32, 5, 2]
	Dim $GLB_OverviewNPCTab[4] = [$GLB_overviewWindow[0] + 157, $GLB_overviewWindow[1] + 32, 5, 2]
	Dim $GLB_OverviewDronesTab[4] = [$GLB_overviewWindow[0] + 192, $GLB_overviewWindow[1] + 32, 3, 2]

	Dim $GLB_sortingDetectorDistance[4] = [$GLB_overviewWindow[0] + 96, $GLB_overviewWindow[1] + 56, 0xD1D1D1, 25]
	;DAD9DA
	Dim $GLB_sortingDetectorIcon[4] = [$GLB_overviewWindow[0] + 16, $GLB_overviewWindow[1] + 56, 0xD1D1D1, 25]
EndFunc