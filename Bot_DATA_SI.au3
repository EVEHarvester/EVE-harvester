;selected item window
Global $GLB_SIWindow[2]

Global $GLB_SIWindowDefaultLocation[2] = [768, 1]

;selected item window open detector
Global $GLB_SIWindowOpenDetector[4]
; asteroid lock
Global $GLB_SI_asteroidLock[5]
;asteroid unlock
Global $GLB_SI_asteroidUnlock[6]
Global $GLB_SI_asteroidUnlock_click[5]
;open cargo
Global $GLB_SI_cargoOpen_click[5]
;drone launch
Global $GLB_SI_droneLaunch_click[5]
;drone return
Global $GLB_SI_droneReturn_click[5]
;container unlock
Global $GLB_SI_containerUnlock[4]
Global $GLB_SI_containerUnlock_click[5]
;wreck unlock
Global $GLB_SI_wreckExtendedUnlock[4]
Global $GLB_SI_wreckExtendedUnlock_click[5]
;NPC
Global $GLB_SI_NPCApproach_click[5]
Global $GLB_SI_NPCLock_click[5]
;fleet commander
Global $GLB_SI_FleetCommApproach_click[5]

; update ocr data from GUI
Func DATA_UpdateSIOCR()
	Local $OCRSIX = GUICtrlRead($GUI_OCRSIX)
	Local $OCRSIY = GUICtrlRead($GUI_OCRSIY)

	Dim $GLB_SIWindow[2] = [$OCRSIX, $OCRSIY]

	Dim $GLB_SIWindowOpenDetector[4] = [$GLB_SIWindow[0], $GLB_SIWindow[1] + 15, 0x41454B, 50]

	Dim $GLB_SI_asteroidLock[5] = [$GLB_SIWindow[0] + 154, $GLB_SIWindow[1] + 79, 5, 5, 5]

	Dim $GLB_SI_asteroidUnlock[6] = [$GLB_SIWindow[0] + 108, $GLB_SIWindow[1] + 64, $GLB_SIWindow[0] + 128, $GLB_SIWindow[1] + 84, 0xE80A0A, 50]
	Dim $GLB_SI_asteroidUnlock_click[5] = [$GLB_SIWindow[0] + 118, $GLB_SIWindow[1] + 74, 10, 10, 5]

	Dim $GLB_SI_cargoOpen_click[5] = [$GLB_SIWindow[0] + 66, $GLB_SIWindow[1] + 80, 1, 1, 5]

	Dim $GLB_SI_droneLaunch_click[5] = [$GLB_SIWindow[0] + 118, $GLB_SIWindow[1] + 76, 5, 5, 5]

	Dim $GLB_SI_droneReturn_click[5] = [$GLB_SIWindow[0] + 118, $GLB_SIWindow[1] + 76, 5, 5, 5]

	Dim $GLB_SI_containerUnlock[4] = [$GLB_SIWindow[0] + 142, $GLB_SIWindow[1] + 74, 0xF30101, 50]
	Dim $GLB_SI_containerUnlock_click[5] = [$GLB_SI_containerUnlock[0], $GLB_SI_containerUnlock[1], 5, 5, 5]

	Dim $GLB_SI_wreckExtendedUnlock[4] = [$GLB_SIWindow[0] + 142, $GLB_SIWindow[1] + 86, 0xF30101, 50]
	Dim $GLB_SI_wreckExtendedUnlock_click[5] = [$GLB_SI_wreckExtendedUnlock[0] + 142, $GLB_SI_wreckExtendedUnlock[1] + 86, 5, 5, 5]

	Dim $GLB_SI_NPCApproach_click[5] = [$GLB_SIWindow[0] + 21, $GLB_SIWindow[1] + 80, 5, 5, 5]
	Dim $GLB_SI_NPCLock_click[5] = [$GLB_SIWindow[0] + 154, $GLB_SIWindow[1] + 80, 5, 5, 5]

	Dim $GLB_SI_FleetCommApproach_click[5] = [$GLB_SIWindow[0] + 17, $GLB_SIWindow[1] + 75, 3, 3, 5]
EndFunc