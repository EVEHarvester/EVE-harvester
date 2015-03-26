;dll
Global $GLB_dll = DllOpen("user32.dll")

; Error object
Global $GLB_COMError = ObjEvent("AutoIt.Error", "GLB_COMErrFunc")

;application size
Global $GLB_appSize[2] = [390, 335]

;applcation default title
Global $initTitleApplication = 'EVE Harvester'
Global $initTitleEVE = '[TITLE:EVE; CLASS:triuiScreen]'

;ship center in space
Global $GLB_shipCenter[5] = [508, 380]

;windows titles
Global $WIN_titles[1]

;need wait timestamp
Global $GLB_needWait[1]

;need stay in station
Global $GLB_stayInStation[1]

;need forced unload
Global $GLB_forcedUnload[1]

;all belts was flown, full circule
Global $GLB_allBeltsDone[1]

;last reactivated miner slot for lowsec
Global $GLB_lastReactivatedSlot[1]

;last crystal reload time
Global $GLB_lastCrystalReloadTime[1]

;default number of bots
Global $GLB_numOfBots = 0
;default current bot number
Global $GLB_curBot = 0

;log file
Global $GLB_logFileName = "log"
Global $GLB_logFileExtension = "txt"

;bot not running at start
Global $GLB_isRunning = False
Global $GLB_isStopping = False

Global $GLB_notFoundRecord = "notFound"

;downtime and schedule
Global $GLB_downtimeSet[1] = [False]
Global $GLB_scheduleSet[1] = [False]

;loading counter limit
Global $GLB_loadingCounterLimit = 5

Global $GLB_miningTryLimit = 15

; average signature radiuses
Global $GLB_avgSigFrigate = 40
Global $GLB_avgSigCruiser = 120
Global $GLB_avgSigBattleship = 400

;number of fleet join allowed
Global $GLB_allowFleetJoin = 1

;login screen data
Global $GLB_login_pixel1[4] = [562, 683, 0x628A9C, 10]
Global $GLB_login_pixel2[4] = [565, 681, 0x628A9B, 10]
Global $GLB_click_login_name[5] = [506, 685, 40, 3, 5]; x, y, dX, dY, dSpeed
Global $GLB_click_login_pass[5] = [506, 708, 40, 3, 5]
Global $GLB_click_login_connect[5] = [511, 728, 40, 7, 5]

;login screen error data
Global $GLB_loginError_pixel1[6] = [372, 312, 372, 312, 0xFFFBFF, 10]
Global $GLB_loginError_pixel2[6] = [392, 312, 392, 312, 0x00498C, 50]
Global $GLB_click_loginError_close[5] = [513, 475, 2, 2, 5]

;info screen data
Global $GLB_info_pixel1[6] = [450, 70, 450, 70, 0xFFFFFF, 10]
Global $GLB_info_pixel2[6] = [506, 94, 506, 94, 0xFFFFFF, 10]
Global $GLB_info_pixel3[6] = [567, 87, 567, 87, 0xFFFFFF, 10]
Global $GLB_info_pixel4[6] = [648, 684, 648, 684, 0x646464, 75]
Global $GLB_character1_click[5] = [230, 300, 75, 75, 5]
Global $GLB_character2_click[5] = [510, 300, 75, 75, 5]
Global $GLB_character3_click[5] = [790, 300, 75, 75, 5]

;data loading detection pixels
;1st variant
Global $GLB_dataLoading_pixel1[4] = [377, 410, 0xB7B8B7, 10]
Global $GLB_dataLoading_pixel2[4] = [646, 410, 0x707170, 10]
Global $GLB_dataLoading_pixel3[4] = [376, 410, 0x121512, 10]
Global $GLB_dataLoading_pixel4[4] = [647, 410, 0x121512, 10]
;2nd variant
Global $GLB_dataLoading2_pixel1[4] = [377, 397, 0xB7B8B7, 10]
Global $GLB_dataLoading2_pixel2[4] = [646, 397, 0x707170, 10]
Global $GLB_dataLoading2_pixel3[4] = [376, 397, 0x121512, 10]
Global $GLB_dataLoading2_pixel4[4] = [647, 397, 0x121512, 10]

;main menu unic pixel coordinates, color and shade
Global $GLB_mainMenu[6] = [9, 9, 9, 9, 0xDCDDDD, 50]
Global $GLB_MM_Items_click[5] = [18, 654, 5, 5, 5]
Global $GLB_MM_Fleet_click[5] = [18, 474, 5, 5, 5]
Global $GLB_MM_Fitting_click[5] = [18, 223, 5, 5, 5]

;station panel
Global $GLB_activateStationPanel[2] = [785, 231]

;error info data
Global $GLB_errorWindow_pixel1[6] = [375, 292, 0xC2C7C5, 50]
Global $GLB_errorWindow_pixel2[6] = [409, 312, 0xC0C0C0, 50]
Global $GLB_click_EW_close[5] = [513, 475, 2, 2, 5]

;shutdown info data
Global $GLB_shutdownWindow_pixel1[6] = [388, 322, 0xFFFBFF, 10]
Global $GLB_shutdownWindow_pixel2[6] = [409, 312, 0x00498B, 50]
Global $GLB_click_SW_close[5] = [560, 490, 2, 2, 5]

;client update data
Global $GLB_clientUpdateWindow_pixel1[4] = [417, 300, 0xBFC1C3, 30]
Global $GLB_clientUpdateWindow_pixel2[4] = [529, 299, 0xBEBEBE, 30]
Global $GLB_clientUpdateWindow_pixel3[4] = [567, 300, 0xBFBFBF, 30]
Global $GLB_click_CUW_yes[5] = [490, 475, 2, 2, 5]
Global $GLB_click_CUW_no[5] = [533, 475, 2, 2, 5]
; depricated in Crius 1.0
Global $GLB_clientReadyToUpdateUpdateWindow_pixel1[4] = [410, 300, 0xBFC1C4, 30]
Global $GLB_clientReadyToUpdateUpdateWindow_pixel2[4] = [523, 300, 0xBFBFBF, 30]
Global $GLB_clientReadyToUpdateUpdateWindow_pixel3[4] = [569, 300, 0xBFBFBF, 30]

; unable to connect, need update in Crius 1.0
Global $GLB_clientUnableToConnectMessage[6] = [770, 693, 840, 693, 0x999999, 30]

;join fleet dialog
Global $GLB_joinFleetWindow_pixel1[4] = [433, 340, 0x00498C, 50]
Global $GLB_joinFleetWindow_pixel2[4] = [454, 345, 0xC5C9CA, 10]
Global $GLB_joinFleetWindow_pixel3[4] = [534, 345, 0xC5C6C5, 10]
Global $GLB_click_JFW_yes[5] = [533, 516, 14, 5, 5]
Global $GLB_click_JFW_no[5] = [576, 516, 14, 5, 5]

;chat invite dialog
Global $GLB_chatInviteWindow_pixel1[4] = [413, 453, 0x6385AF, 5]
Global $GLB_chatInviteWindow_pixel2[4] = [413, 470, 0x6385AF, 5]
Global $GLB_chatInviteWindow_pixel3[4] = [413, 487, 0x6385AF, 5]
Global $GLB_click_CIW_accept[5] = [436, 436, 14, 1, 5]
Global $GLB_click_CIW_reject[5] = [436, 470, 14, 1, 5]
Global $GLB_click_CIW_ok[5] = [571, 517, 10, 5, 5]

;undock button unic pixel coordinates, color and shade
Global $GLB_undockButton[6] = [955, 158, 0xBF9900, 50]
Global $GLB_undockButton_click[5] = [$GLB_undockButton[0], $GLB_undockButton[1], 12, 8, 5]

;undock from ship pixel coordinates
;Global $GLB_undockFromShipClickPixel[2] = [532, 386]

; should be depricated
;Левый верхний угол окна грузового отсека(cargo)
Global $GLB_cargoWindow[2] = [41, 570]
;Настройки области поиска и цвета для определения статуса бара заполнения грузового отсека
Global $GLB_cargoBar[6] = [$GLB_cargoWindow[0] + 147, $GLB_cargoWindow[1] + 63, $GLB_cargoWindow[0] + 244, $GLB_cargoWindow[1] + 63, 0x08596F, 30];155-66,247-69
;cargo window pixels
Global $GLB_cargoDetect1[6] = [$GLB_cargoWindow[0] + 24, $GLB_cargoWindow[1] + 40, $GLB_cargoWindow[0] + 24, $GLB_cargoWindow[1] + 40, 0xF0F4F4, 50]
Global $GLB_cargoDetect2[6] = [$GLB_cargoWindow[0] + 48, $GLB_cargoWindow[1] + 29, $GLB_cargoWindow[0] + 48, $GLB_cargoWindow[1] + 29, 0x2B1804, 100]
Global $GLB_cargoDetect3[6] = [$GLB_cargoWindow[0] + 238, $GLB_cargoWindow[1] + 54, $GLB_cargoWindow[0] + 238, $GLB_cargoWindow[1] + 54, 0xF7F8F8, 100]
;right click cargo window
Global $GLB_CW_rightClick[4] = [$GLB_cargoWindow[0] + 92, $GLB_cargoWindow[1] + 81, 3, 2]
;menu items
Global $GLB_CW_stackAll_click[4] = [$GLB_CW_rightClick[0] + 55, $GLB_CW_rightClick[1] + 55, 25, 3]
Global $GLB_CW_sortBy_click1[4] = [$GLB_CW_rightClick[0] + 60, $GLB_CW_rightClick[1] + 39, 10, 2]
Global $GLB_CW_sortBy_click2[4] = [$GLB_CW_rightClick[0] + 150, $GLB_CW_rightClick[1] + 39, 10, 2]

Global $GLB_CW_bgColor[2] = [0x212422, 5]

;Левый верхний угол окна container
Global $GLB_containerWindow[2] = [41, 370]
;container cargo bar
Global $GLB_containerBar[6] = [$GLB_containerWindow[0] + 149, $GLB_containerWindow[1] + 66, $GLB_containerWindow[0] + 249, $GLB_containerWindow[1] + 66, 0x08596F, 10];155-66,249-66
;container window pixels
Global $GLB_containerDetect1[4] = [$GLB_containerWindow[0] + 24, $GLB_containerWindow[1] + 40, 0xEFF3F3, 10]
Global $GLB_containerDetect2[4] = [$GLB_containerWindow[0] + 31, $GLB_containerWindow[1] + 33, 0xEFF3F3, 10]
;right click container window
Global $GLB_ContW_rightClick[4] = [$GLB_containerWindow[0] + 92, $GLB_containerWindow[1] + 81, 5, 2]
;menu items
Global $GLB_ContW_stackAll_click[4] = [$GLB_ContW_rightClick[0] + 55, $GLB_ContW_rightClick[1] + 55, 25, 3]
Global $GLB_ContW_sortBy_click1[4] = [$GLB_ContW_rightClick[0] + 60, $GLB_ContW_rightClick[1] + 39, 10, 2]
Global $GLB_ContW_sortBy_click2[4] = [$GLB_ContW_rightClick[0] + 150, $GLB_ContW_rightClick[1] + 39, 10, 2]

;ore hold window
Global $GLB_oreHoldWindow[2] = [37, 368]
;ore hold cargo bar
Global $GLB_oreHoldBar[6] = [$GLB_oreHoldWindow[0] + 147, $GLB_oreHoldWindow[1] + 63, $GLB_oreHoldWindow[0] + 243, $GLB_oreHoldWindow[1] + 63, 0x08596F, 20]
;ship ore hold window pixels
Global $GLB_OHW_Detect1[4] = [$GLB_oreHoldWindow[0] + 22, $GLB_oreHoldWindow[1] + 38, 0xEFF3F3, 10]
Global $GLB_OHW_Detect2[4] = [$GLB_oreHoldWindow[0] + 29, $GLB_oreHoldWindow[1] + 31, 0xEFF3F3, 10]

;orca corp hangar window
Global $GLB_fleetCommanderCorpHangarWindow[2] = [362, 140]
Global $GLB_fleetCommanderCorpHangarBar[6] = [$GLB_fleetCommanderCorpHangarWindow[0] + 147, $GLB_fleetCommanderCorpHangarWindow[1] + 63, $GLB_fleetCommanderCorpHangarWindow[0] + 244, $GLB_fleetCommanderCorpHangarWindow[1] + 63, 0x0A5C72, 40]
Global $GLB_FCCHW_Detect1[4] = [$GLB_fleetCommanderCorpHangarWindow[0] + 22, $GLB_fleetCommanderCorpHangarWindow[1] + 38, 0xEFF3F3, 10]
Global $GLB_FCCHW_Detect2[4] = [$GLB_fleetCommanderCorpHangarWindow[0] + 29, $GLB_fleetCommanderCorpHangarWindow[1] + 31, 0xEFF3F3, 10]

Global $GLB_FCCHW_rightClick[4] = [$GLB_fleetCommanderCorpHangarWindow[0] + 88, $GLB_fleetCommanderCorpHangarWindow[1] + 120, 3, 2]
;menu items
Global $GLB_FCCHW_stackAll_click[4] = [$GLB_FCCHW_rightClick[0] + 55, $GLB_FCCHW_rightClick[1] + 55, 25, 3]
Global $GLB_FCCHW_sortBy_click1[4] = [$GLB_FCCHW_rightClick[0] + 60, $GLB_FCCHW_rightClick[1] + 39, 10, 2]
Global $GLB_FCCHW_sortBy_click2[4] = [$GLB_FCCHW_rightClick[0] + 150, $GLB_FCCHW_rightClick[1] + 39, 10, 2]

;ship corp hangar
Global $GLB_shipCorpHangarWindow[2] = [511, 247]
Global $GLB_shipCorpHangarBar[6] = [$GLB_shipCorpHangarWindow[0] + 148, $GLB_shipCorpHangarWindow[1] + 64, $GLB_shipCorpHangarWindow[0] + 246, $GLB_shipCorpHangarWindow[1] + 64, 0x095A70, 40]
;ship corp hangar window pixels
Global $GLB_SCHW_Detect1[4] = [$GLB_shipCorpHangarWindow[0] + 24, $GLB_shipCorpHangarWindow[1] + 40, 0xEFF3F3, 10]
Global $GLB_SCHW_Detect2[4] = [$GLB_shipCorpHangarWindow[0] + 31, $GLB_shipCorpHangarWindow[1] + 33, 0xEFF3F3, 10]

;POS corp hangar
Global $GLB_POSCorpHangarWindow[2] = [512, 1]

; corp hangar tabs
Global $GLB_corpHangarStationTabsShift[4][4] = [[37, 80, 17, 3],[92, 80, 17, 3],[149, 80, 17, 3],[206, 80, 17, 3]]
Global $GLB_corpHangarTabsShift[4][4] = [[37, 100, 17, 3],[92, 100, 17, 3],[149, 100, 17, 3],[206, 100, 17, 3]]

;engine detection pixels
Global $GLB_engineActive[4] = [547, 712, 0x4F8EC5, 2]

;Items window
Global $GLB_itemsWindow[2] = [294, 0]
;right click items window
Global $GLB_IW_rightClick[4]
;menu items
Global $GLB_IW_stackAll_click[4]
Global $GLB_IW_sortBy_click1[4]
Global $GLB_IW_sortBy_click2[4]

;Corp Hangar window
Global $GLB_corpHangarWindow[3] = [502, 181, 0xEFF3F3]
Global $GLB_CH_open_click[4] = [880, 753, 4, 3]

; Wreck window
; should be depricated
Global $GLB_wreckWindow[2] = [41, 369]
Global $GLB_wreckWindowClose[2] = [$GLB_wreckWindow[0] + 240, $GLB_wreckWindow[1] + 8]
Global $GLB_wreckWindowLootAll[4] = [$GLB_wreckWindow[0] + 125, $GLB_wreckWindow[1] + 185, 20, 5]

;right click menu detection
Global $GLB_menu_rightClick[6] = [15, 1, 18, 4, 0x111511, 10]
Global $GLB_menu_itemHeight = 15

;fleet window
Global $GLB_FWindow[2] = [512, 247]
Global $GLB_FW_createFleet_pixel[6] = [$GLB_FWindow[0] + 85, $GLB_FWindow[1] + 23, $GLB_FWindow[0] + 135, $GLB_FWindow[1] + 32, 0x9EA1A0, 10]

;hisec fleet commander chat window
Global $GLB_FCCWindow[2] = [768, 248]
Global $GLB_FCCW_LocalTab[4] = [$GLB_FCCWindow[0] + 33, $GLB_FCCWindow[1] + 11, 2, 2]
Global $GLB_FCCW_CorpTab[4] = [$GLB_FCCWindow[0] + 94, $GLB_FCCWindow[1] + 11, 2, 2]

Global $GLB_FCCW_CorpMembers[2] = [$GLB_FCCWindow[0] + 102, $GLB_FCCWindow[1] + 39]
Global $GLB_FCCW_CorpMemberHeight = 37
Global $GLB_FCCW_CorpMemberStatus[5] = [135, 20, 0x1B7B1B, 0x7B25B4, 10]; dX, dY, notInFleet color, inFleet color,dColor

;locked targets
Global $GLB_targetInLock1_click[4] = [712, 47, 20, 20]
Global $GLB_targetInLock2_click[4] = [600, 47, 20, 20]
Global $GLB_targetInLock3_click[4] = [488, 47, 20, 20]

;Global $GLB_targetLockModuleShift = 98

; wreck in lock
Global $GLB_wreckInLock1[4] = [671, 87, 0x9D0B0E, 10]
; fleet commander in lock
Global $GLB_fleetCommInLock1[4] = [689, 71, 0x7925B6, 10]

; high slot items
Global $GLB_activeHighSlot_Item1[4] = [632, 646, 0x676E6A, 70]
Global $GLB_slot_ItemShift = 51
Global $GLB_slot_ItemSize = 46

Global $GLB_ammoLoadedShift[4] = [-4, -15, 0x000000, 5]

; active shield items
Global $GLB_activeShield_Item1[4] = [657, 690, 0x69706C, 70]

; active low slot items
Global $GLB_activeLowSlot1[4] = [632, 734, 0x69706C, 70]

; fitting window
Global $GLB_FittingWindow[2] = [48, 12]
Global $GLB_FitW_shipMenu_click[2] = [$GLB_FittingWindow[0]+238, $GLB_FittingWindow[1]+249]
Global $GLB_FitW_close_click[2] = [$GLB_FittingWindow[0]+705, $GLB_FittingWindow[1]+7]

;container login detector
Global $GLB_ContainerLoginPixel[4] = [401, 351, 0xA0A1A0, 20]

;warp status detection(color for enabled)
Global $GLB_stopSpeedButton[2] = [464, 700]
Global $GLB_maxSpeedButton[2] = [558, 700]

;warping indication pixels
Global $GLB_warpState1[4] = [418, 486, 0xBAC0C2, 25];W
Global $GLB_warpState2[4] = [460, 486, 0xBAC0C2, 25];P
Global $GLB_warpState3[4] = [582, 486, 0xBAC0C2, 25];I
;Global $GLB_warpState4[4] = [548, 535, 0x828385, 75];C
;Global $GLB_warpState5[4] = [578, 540, 0xC5C7C9, 75];E

;jumping indication pixels
Global $GLB_jumpState1[4] = [474, 490, 0xBEC0C2, 25];J
Global $GLB_jumpState2[4] = [491, 490, 0xBEC0C2, 25];M
Global $GLB_jumpState3[4] = [542, 491, 0xBEC0C2, 25];G

;dock,jump, activate gate indication pixels
Global $GLB_dockjumpactivateState1[4] = [381, 514, 0xC0C1C1, 25];D
Global $GLB_dockjumpactivateState2[4] = [488, 515, 0xC0C0C1, 25];/
Global $GLB_dockjumpactivateState3[4] = [635, 514, 0xC1C1C2, 25];E

;damage indicator pixels
Global $GLB_damageColor = 0xFF2625
Global $GLB_damageColorRange = 80
Global $GLB_shieldIndicator[20][2] = [ _
	[445, 658], _ ; 5%
	[445, 651], _ ; 10%
	[450, 641], _ ; 15%
	[455, 632], _ ; 20%
	[462, 624], _ ; 25%
	[470, 616], _ ; 30%
	[479, 611], _ ; 35%
	[489, 606], _ ; 40%
	[502, 603], _ ; 45%
	[513, 602], _ ; 50%
	[524, 604], _ ; 55%
	[534, 606], _ ; 60%
	[541, 610], _ ; 65%
	[550, 614], _ ; 70%
	[558, 621], _ ; 75%
	[564, 626], _ ; 80%
	[569, 635], _ ; 85%
	[575, 645], _ ; 90%
	[578, 655], _ ; 95%
	[580, 668] _ ; 100%
]

Global $GLB_armorIndicator[2] = [570, 665]

Global $GLB_slotsPanelOpen_click[4] = [567, 678, 3, 3]
Global $GLB_slotsOpenedPixel[4] = [571, 672, 0xE7E7E7, 25]

Global $GLB_scramblingIndicator[4] = [515, 557, 0x79D8D4, 25]
Global $GLB_neutralizingIndicator[4] = [509, 579, 0x2C0000, 25]

;view
Global $GLB_viewRotation[8] = [336, 592, 336, 701, 20, 10, 20, 60]; from, to, dx, dy, speed, zoom

;freeze
Global $GLB_freezeArea[4] = [0, 0, 1024, 768]; from, to, dx, dy

; update ocr data from GUI
Func GLB_UpdateOCR()
	DATA_UpdateOverviewOCR()
	DATA_UpdateChatOCR()
	DATA_UpdateInventoryOCR()
	DATA_UpdatePAPOCR()
	DATA_UpdateSIOCR()
	DATA_UpdateScannerOCR()
	DATA_UpdateDronesOCR()
EndFunc

Func GLB_COMErrFunc()
	Local $errorDetais = "We intercepted a COM Error !"    & @CRLF  & @CRLF & _
             "err.description is: " & @TAB & $GLB_COMError.description  & @CRLF & _
             "err.windescription:"   & @TAB & $GLB_COMError.windescription & @CRLF & _
             "err.number is: "       & @TAB & hex($GLB_COMError.number,8)  & @CRLF & _
             "err.lastdllerror is: "   & @TAB & $GLB_COMError.lastdllerror   & @CRLF & _
             "err.scriptline is: "   & @TAB & $GLB_COMError.scriptline   & @CRLF & _
             "err.source is: "       & @TAB & $GLB_COMError.source       & @CRLF & _
             "err.helpfile is: "       & @TAB & $GLB_COMError.helpfile     & @CRLF & _
             "err.helpcontext is: " & @TAB & $GLB_COMError.helpcontext
	;Msgbox(0, $errorDetais)

	BOT_LogMessage("GLB_COMErrFunc: " & $errorDetais, 2)
EndFunc

; calculate people and places window parameters
; depricated
Func GLB_CalculateWindowsCoordinates()
	#cs
	If GUI_getSecurityStatus() = "High" Then
		$GLB_itemsWindow[0] = 36
		$GLB_itemsWindow[1] = 389
	Else
	#ce
		;$GLB_itemsWindow[0] = 294
		;$GLB_itemsWindow[1] = 0
	;EndIf
	;items window data

	$GLB_IW_rightClick[0] = $GLB_itemsWindow[0] + 87
	$GLB_IW_rightClick[1] = $GLB_itemsWindow[1] + 65
	$GLB_IW_rightClick[2] = 1
	$GLB_IW_rightClick[3] = 1

	$GLB_IW_stackAll_click[0] = $GLB_IW_rightClick[0] + 55
	$GLB_IW_stackAll_click[1] = $GLB_IW_rightClick[1] + 55
	$GLB_IW_stackAll_click[2] = 25
	$GLB_IW_stackAll_click[3] = 3

	$GLB_IW_sortBy_click1[0] = $GLB_IW_rightClick[0] + 60
	$GLB_IW_sortBy_click1[1] = $GLB_IW_rightClick[1] + 39
	$GLB_IW_sortBy_click1[2] = 10
	$GLB_IW_sortBy_click1[3] = 2

	$GLB_IW_sortBy_click2[0] = $GLB_IW_rightClick[0] + 150
	$GLB_IW_sortBy_click2[1] = $GLB_IW_rightClick[1] + 39
	$GLB_IW_sortBy_click2[2] = 10
	$GLB_IW_sortBy_click2[3] = 2
EndFunc