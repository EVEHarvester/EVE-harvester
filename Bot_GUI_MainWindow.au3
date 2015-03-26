;windows
Global $GUI_mainWindow

;settings controls
Global $GUI_startButton

Global $GUI_usersList
Global $GUI_usersPage[100]
Global $GUI_lastOpenedUser

; current account data
Global $GUI_currentLocationInput
Global $GUI_currentStateInput
Global $GUI_currentShieldInput
Global $GUI_currentCargoInput
Global $GUI_currentBookmarkInput
Global $GUI_currentAlarmInput
Global $GUI_currentLogInput

Global $GUI_currentLicStatusInput
Global $GUI_currentLicExpirationInput

; menu
Global $GUI_menuUtils
Global $GUI_menuUtils_LA
Global $GUI_menuUtils_SF
Global $GUI_menuUtils_HC

Global $GUI_menuConf
Global $GUI_menuConf_Save
Global $GUI_menuConf_SaveAs
Global $GUI_menuConf_Load
Global $GUI_menuConf_Exit

Global $GUI_menuSettings
Global $GUI_menuSettings_Settings
Global $GUI_menuSettings_OCR

Global $GUI_menuAccounts
Global $GUI_menuAccounts_Add
Global $GUI_menuAccounts_Edit
Global $GUI_menuAccounts_Remove
Global $GUI_menuAccounts_Dublicate

Global $GUI_menuTest
Global $GUI_menuTest_AllGUI
Global $GUI_menuTest_Distance
Global $GUI_menuTest_imageEncoders

Global $GUI_menuAbout
Global $GUI_menuAbout_Manuals
Global $GUI_menuAbout_Help
Global $GUI_menuAbout_About

;create main window GUI
Func GUI_CreateMainWindowGUI()
	$GUI_mainWindow = GuiCreate($initTitleApplication, $GLB_appSize[0], $GLB_appSize[1], 0, 0)

	; menu Configuration
	$GUI_menuConf = GUICtrlCreateMenu("&File")
	$GUI_menuConf_Load = GUICtrlCreateMenuItem("Load ...", $GUI_menuConf)
	GUICtrlSetOnEvent($GUI_menuConf_Load, "CONFIG_PreLoadConfig")
	$GUI_menuConf_Save = GUICtrlCreateMenuItem("Save", $GUI_menuConf)
	GUICtrlSetOnEvent($GUI_menuConf_Save, "CONFIG_SaveConfigCaller")
	GUICtrlSetState($GUI_menuConf_Save, $GUI_DISABLE)
    $GUI_menuConf_SaveAs = GUICtrlCreateMenuItem("Save as ...", $GUI_menuConf)
	GUICtrlSetOnEvent($GUI_menuConf_SaveAs, "CONFIG_SaveAsConfigCaller")
	GUICtrlSetState($GUI_menuConf_SaveAs, $GUI_DISABLE)
	$GUI_menuConf_Exit = GUICtrlCreateMenuItem("Exit", $GUI_menuConf)
	GUICtrlSetOnEvent($GUI_menuConf_Exit, "GUI_CloseMainWindow")

	; menu Accounts
	$GUI_menuAccounts = GUICtrlCreateMenu("&Account")
    $GUI_menuAccounts_Add = GUICtrlCreateMenuItem("Add ...", $GUI_menuAccounts)
	GUICtrlSetOnEvent($GUI_menuAccounts_Add, "GUI_AddAccountCaller")
    $GUI_menuAccounts_Edit = GUICtrlCreateMenuItem("Edit ...", $GUI_menuAccounts)
	GUICtrlSetOnEvent($GUI_menuAccounts_Edit, "GUI_EditAccountCaller")
	GUICtrlSetState($GUI_menuAccounts_Edit, $GUI_DISABLE)
	;$GUI_menuAccounts_Remove = GUICtrlCreateMenuItem("Delete", $GUI_menuAccounts)
	;GUICtrlSetOnEvent($GUI_menuAccounts_Remove, "GUI_RemoveAccountCaller")
	;GUICtrlSetState($GUI_menuAccounts_Remove, $GUI_DISABLE)
	$GUI_menuAccounts_Dublicate = GUICtrlCreateMenuItem("Dublicate", $GUI_menuAccounts)
	GUICtrlSetOnEvent($GUI_menuAccounts_Dublicate, "GUI_DublicateAccount")
	GUICtrlSetState($GUI_menuAccounts_Dublicate, $GUI_DISABLE)

	; menu Settings
	$GUI_menuSettings = GUICtrlCreateMenu("&Settings")
    $GUI_menuSettings_Settings = GUICtrlCreateMenuItem("Preferences ...", $GUI_menuSettings)
	GUICtrlSetOnEvent($GUI_menuSettings_Settings, "GUI_OpenSettingsWindow")
	$GUI_menuSettings_OCR = GUICtrlCreateMenuItem("OCR ...", $GUI_menuSettings)
	GUICtrlSetOnEvent($GUI_menuSettings_OCR, "GUI_OpenOCRWindow")

	; menu Test
	$GUI_menuTest = GUICtrlCreateMenu("&Test")
	$GUI_menuTest_AllGUI = GUICtrlCreateMenuItem("GUI layout", $GUI_menuTest)
	GUICtrlSetOnEvent($GUI_menuTest_AllGUI, "TEST_AllGUI")
    ;$GUI_menuTest_imageEncoders = GUICtrlCreateMenuItem("Image encoders", $GUI_menuTest)
	;GUICtrlSetOnEvent($GUI_menuTest_imageEncoders, "TEST_imageEncoders")

	; menu About
	$GUI_menuAbout = GUICtrlCreateMenu("&Help")
	$GUI_menuAbout_Help = GUICtrlCreateMenuItem("Web-site", $GUI_menuAbout)
	GUICtrlSetOnEvent($GUI_menuAbout_Help, "GUI_AboutWindow_OpenSite")
	$GUI_menuAbout_Manuals = GUICtrlCreateMenuItem("Manuals", $GUI_menuAbout)
	GUICtrlSetOnEvent($GUI_menuAbout_Manuals, "GUI_AboutWindow_OpenDownloadDocuments")
	$GUI_menuAbout_About = GUICtrlCreateMenuItem("About ...", $GUI_menuAbout)
	GUICtrlSetOnEvent($GUI_menuAbout_About, "GUI_ShowAboutWindow")

	; menu Utils
	;$GUI_menuUtils = GUICtrlCreateMenu("&Utils")
    ;$GUI_menuUtils_LA = GUICtrlCreateMenuItem("Log analyzer", $GUI_menuUtils)
	;GUICtrlSetOnEvent($GUI_menuUtils_LA, "GUI_launghLA")
    ;$GUI_menuUtils_SF = GUICtrlCreateMenuItem("Suicide fighter helper", $GUI_menuUtils)
	;GUICtrlSetOnEvent($GUI_menuUtils_SF, "GUI_launghSF")
    ;$GUI_menuUtils_HC = GUICtrlCreateMenuItem("Health checker", $GUI_menuUtils)
	;GUICtrlSetOnEvent($GUI_menuUtils_HC, "GUI_launghHC")

	Local $groupControlsCoord[2] = [5, 0]
	; controls group
	GUICtrlCreateGroup ("", $groupControlsCoord[0], $groupControlsCoord[1], 380, 310)
		GUICtrlCreateLabel("Accounts:", $groupControlsCoord[0] + 5, $groupControlsCoord[1] + 10)
		$GUI_usersList = GUICtrlCreateList("", $groupControlsCoord[0] + 5, $groupControlsCoord[1] + 25, 120, 150)
		GUICtrlSetLimit(-1, 200) ; to limit horizontal scrolling

		GUICtrlCreateLabel("Stats:", $groupControlsCoord[0] + 135, $groupControlsCoord[1] + 10)
		; current bot location
		GUICtrlCreateLabel("Location:", $groupControlsCoord[0] + 135, $groupControlsCoord[1] + 25)
		$GUI_currentLocationInput = GUICtrlCreateInput ("", $groupControlsCoord[0] + 135, $groupControlsCoord[1] + 40, 75, 20)
		GUICtrlSetState($GUI_currentLocationInput, $GUI_DISABLE)

		; current bot state
		GUICtrlCreateLabel("State:", $groupControlsCoord[0] + 135, $groupControlsCoord[1] + 65)
		$GUI_currentStateInput = GUICtrlCreateInput ("", $groupControlsCoord[0] + 135, $groupControlsCoord[1] + 80, 75, 20)
		GUICtrlSetState($GUI_currentStateInput, $GUI_DISABLE)

		; current bot cargo
		GUICtrlCreateLabel("Cargo(%):", $groupControlsCoord[0] + 215, $groupControlsCoord[1] + 25)
		$GUI_currentCargoInput = GUICtrlCreateInput ("", $groupControlsCoord[0] + 215, $groupControlsCoord[1] + 40, 75, 20)
		GUICtrlSetState($GUI_currentCargoInput, $GUI_DISABLE)

		; current bot shield
		GUICtrlCreateLabel("Shield(%):", $groupControlsCoord[0] + 215, $groupControlsCoord[1] + 65)
		$GUI_currentShieldInput = GUICtrlCreateInput ("", $groupControlsCoord[0] + 215, $groupControlsCoord[1] + 80, 75, 20)
		GUICtrlSetState($GUI_currentShieldInput, $GUI_DISABLE)

		; current bot bookmark
		GUICtrlCreateLabel("Bookmark:", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 25)
		$GUI_currentBookmarkInput = GUICtrlCreateInput ("", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 40, 75, 20)
		GUICtrlSetState($GUI_currentBookmarkInput, $GUI_DISABLE)

		; current bot alarm
		GUICtrlCreateLabel("Alarm:", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 65)
		$GUI_currentAlarmInput = GUICtrlCreateInput ("", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 80, 75, 20)
		GUICtrlSetState($GUI_currentAlarmInput, $GUI_DISABLE)

		; button start/stop
		$GUI_startButton = GUICtrlCreateButton ("Start",  $groupControlsCoord[0] + 135, $groupControlsCoord[1] + 125, 50, 50, $BS_MULTILINE)
		GUICtrlSetOnEvent($GUI_startButton, "BOT_Start")
		GUICtrlSetState($GUI_startButton, $GUI_DISABLE)

		; license status
		GUICtrlCreateLabel("License type:", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 115)
		$GUI_currentLicStatusInput = GUICtrlCreateInput ("Unknown", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 130, 75, 20)
		GUICtrlSetState($GUI_currentLicStatusInput, $GUI_DISABLE)

		; license expiration
		GUICtrlCreateLabel("Lic expiration:", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 155)
		$GUI_currentLicExpirationInput = GUICtrlCreateInput ("Unknown", $groupControlsCoord[0] + 295, $groupControlsCoord[1] + 170, 75, 20)
		GUICtrlSetState($GUI_currentLicExpirationInput, $GUI_DISABLE)

		; current log
		GUICtrlCreateLabel("Log:", $groupControlsCoord[0] + 5, $groupControlsCoord[1] + 180)
		$GUI_currentLogInput = GuiCtrlCreateEdit("", $groupControlsCoord[0] + 5, $groupControlsCoord[1] + 195, 370, 110, BitOR($ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; set window events
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_CloseMainWindow")

	; GUI MESSAGE LOOP
	GuiSetState(@SW_SHOW)
EndFunc

;close main window
Func GUI_CloseMainWindow()
	STA_LogStatistics()
	BOT_LogMessage("Bot window closed", 2)
	DllClose($GLB_dll)
	GUIDelete()
	Exit 0
EndFunc

; set current bot data to main tab
Func GUI_setCurrentBotData()
	_GUICtrlListBox_SetCurSel($GUI_usersList, $GLB_curBot)

	GUICtrlSetData($GUI_currentLocationInput, GUICtrlRead($GUI_locationCombo[$GLB_curBot]))
	GUICtrlSetData($GUI_currentStateInput, GUICtrlRead($GUI_stateCombo[$GLB_curBot]))
	GUICtrlSetData($GUI_currentCargoInput, GUICtrlRead($GUI_cargo[$GLB_curBot]))
	GUICtrlSetData($GUI_currentShieldInput, GUICtrlRead($GUI_shieldCurrent[$GLB_curBot]))
	GUICtrlSetData($GUI_currentBookmarkInput, GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))

	Local $alarm = GUI_getAlarmText($GLB_stayInStation[$GLB_curBot])

	GUICtrlSetData($GUI_currentAlarmInput, $alarm)

	_GUICtrlEdit_SetText($GUI_currentLogInput, "")
EndFunc

; check menu items
Func GUI_CheckMainMenu()
	If _GUICtrlListBox_GetCount($GUI_usersList) = 0 Then
		GUICtrlSetState($GUI_menuAccounts_Edit, $GUI_DISABLE)
		GUICtrlSetState($GUI_menuAccounts_Remove, $GUI_DISABLE)
		GUICtrlSetState($GUI_menuConf_Save, $GUI_DISABLE)
		GUICtrlSetState($GUI_menuConf_SaveAs, $GUI_DISABLE)
		GUICtrlSetState($GUI_menuAccounts_Dublicate, $GUI_DISABLE)
	Else
		GUICtrlSetState($GUI_menuAccounts_Edit, $GUI_ENABLE)
		GUICtrlSetState($GUI_menuAccounts_Remove, $GUI_ENABLE)
		GUICtrlSetState($GUI_menuConf_Save, $GUI_ENABLE)
		GUICtrlSetState($GUI_menuConf_SaveAs, $GUI_ENABLE)
		GUICtrlSetState($GUI_menuAccounts_Dublicate, $GUI_ENABLE)
	EndIf
EndFunc

; get alarm text
Func GUI_getAlarmText($alarmId)
	Local $text

	Switch $alarmId
		Case 0
			$text = "No"
		Case -1
			$text = "Disabling bot"
		Case -2
			$text = "Maintenance"
		Case -2.1
			$text = "Scheduled stop"
		Case -3
			$text = "Armor damaged"
		Case -4
			$text = "FleetComm offline"
		Case -5
			$text = "Enemy found"
		Case -6
			$text = "Local overloaded"
		Case Else
			$text = "Unknown"
	EndSwitch

	Return $text
EndFunc