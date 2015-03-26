Global $GUI_settingsWindow

Global $GUI_settingsNetworkGroup
Global $GUI_settingsAdvancedGroup
Global $GUI_settingsGameplayGroup
Global $GUI_settingsDowntimeGroup
Global $GUI_settingsSpeachGroup
Global $GUI_settingsEmailGroup
Global $GUI_settingsPathsGroup
Global $GUI_settingsLoginGroup
Global $GUI_settingsLicenseGroup
; hotkeys group
Global $GUI_settingsHotkeysGroup
Global $GUI_hotkeyApproach
Global $GUI_hotkeyOrbit
Global $GUI_hotkeyRange
Global $GUI_hotkeyJump

Global $GUI_useSpeechEngine
Global $GUI_useSpeechOnEnemy
Global $GUI_textSpeechOnEnemy
Global $GUI_useSpeechOnNewUser
Global $GUI_textSpeechOnNewUser
Global $GUI_useSpeechTooManyUsers
Global $GUI_textSpeechTooManyUsers
Global $GUI_useSpeechOnNPCFound
Global $GUI_textSpeechOnNPCFound
Global $GUI_useSpeechOnLoot
Global $GUI_textSpeechOnLoot
Global $GUI_useSpeechOnDamage
Global $GUI_textSpeechOnDamage

; email notifications
Global $GUI_useEmailNotifications
Global $GUI_sendEmailOnUpdateNeeded
Global $GUI_textEmailOnUpdateNeeded

Global $GUI_eveSelectPath
Global $GUI_eveSelectButton
Global $GUI_numOfBotsInput
Global $GUI_downtime
Global $GUI_botsDelayInput
Global $GUI_ciclesDelayInput
Global $GUI_allBackOnOneDamageCheckbox
Global $GUI_allBackOnOneDamageInput
Global $GUI_EVEServerInput
Global $GUI_EVEServerTimeoutInput
Global $GUI_NetworkTimeoutInput
Global $GUI_loginErrorDelayInput
Global $GUI_loginMaxErrorsInput
Global $GUI_loginMethodCombo
Global $GUI_containerPasswordDelayInput
Global $GUI_containerPasswordInput
Global $GUI_pingConnectionServer
Global $GUI_allowRemote
Global $GUI_closeTeamViewer
Global $GUI_useTooltipLog
Global $GUI_overviewTabDelay
Global $GUI_enemyTimeoutInput
Global $GUI_monitor
Global $GUI_ApplicationTitleInput
Global $GUI_logoutAfterLoginErrorCheckbox
Global $GUI_EnemyLogoutCheckbox
Global $GUI_enemyWaitBeforeLogoutInput

Global $GUI_licenseLogin
Global $GUI_licensePassword
Global $GUI_registerButton

;create settings GUI
Func GUI_CreateSettingsWindowGUI()
	$GUI_settingsWindow = GUICreate("Settings", 505, 310)

	Local $treeview = GUICtrlCreateTreeView(5, 5, 150, 300, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetColor(-1, 0x000000)

	Local $licenseitem = GUICtrlCreateTreeViewItem("License", $treeview)
	Local $gameplayitem = GUICtrlCreateTreeViewItem("Gameplay", $treeview)
	Local $loginitem = GUICtrlCreateTreeViewItem("Login", $treeview)
	Local $hotkeysitem = GUICtrlCreateTreeViewItem("Hotkeys", $treeview)
	Local $networkitem = GUICtrlCreateTreeViewItem("Network", $treeview)
	Local $downtimeitem = GUICtrlCreateTreeViewItem("Downtime", $treeview)
	Local $speachitem = GUICtrlCreateTreeViewItem("Voice notifications", $treeview)
	Local $emailitem = GUICtrlCreateTreeViewItem("Email notifications", $treeview)
	Local $pathsitem = GUICtrlCreateTreeViewItem("Paths", $treeview)
	Local $advanceditem = GUICtrlCreateTreeViewItem("Advanced", $treeview)

	GUICtrlSetOnEvent($licenseitem, "GUI_ShowLicenseSettings")
	GUICtrlSetOnEvent($loginitem, "GUI_ShowLoginSettings")
	GUICtrlSetOnEvent($hotkeysitem, "GUI_ShowHotkeySettings")
	GUICtrlSetOnEvent($networkitem, "GUI_ShowNetworkSettings")
	GUICtrlSetOnEvent($advanceditem, "GUI_ShowAdvancedSettings")
	GUICtrlSetOnEvent($gameplayitem, "GUI_ShowGameplaySettings")
	GUICtrlSetOnEvent($downtimeitem, "GUI_ShowDowntimeSettings")
	GUICtrlSetOnEvent($speachitem, "GUI_ShowSpeachSettings")
	GUICtrlSetOnEvent($emailitem, "GUI_ShowEmailSettings")
	GUICtrlSetOnEvent($pathsitem, "GUI_ShowPathsSettings")

	Local $groupSettings[2] = [160, 5]

	; network group
	$GUI_settingsNetworkGroup = GUICtrlCreateGroup ("Network", $groupSettings[0], $groupSettings[1], 340, 300)
		; Check internet connection with site
		GUICtrlCreateLabel("Ping site:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_pingConnectionServer = GUICtrlCreateInput ("www.google.com", $groupSettings[0] + 100, $groupSettings[1] + 15, 150, 20)

		$GUI_allowRemote = GUICtrlCreateCheckbox("Allow remote management", $groupSettings[0] + 10, $groupSettings[1] + 35)
		GUICtrlSetState($GUI_allowRemote, $GUI_UNCHECKED)

		GUICtrlCreateLabel("EVE server:", $groupSettings[0] + 10, $groupSettings[1] + 60)
		$GUI_EVEServerInput = GUICtrlCreateInput ("87.237.38.200", $groupSettings[0] + 100, $groupSettings[1] + 55, 100, 20)

		GUICtrlCreateLabel("EVE server timeout:", $groupSettings[0] + 10, $groupSettings[1] + 80)
		$GUI_EVEServerTimeoutInput = GUICtrlCreateInput ('5', $groupSettings[0] + 100, $groupSettings[1] + 75, 30, 20, $ES_NUMBER)

		GUICtrlCreateLabel("Network timeout:", $groupSettings[0] + 10, $groupSettings[1] + 100)
		$GUI_NetworkTimeoutInput = GUICtrlCreateInput ('15', $groupSettings[0] + 100, $groupSettings[1] + 95, 30, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; hotkeys group
	$GUI_settingsHotkeysGroup = GUICtrlCreateGroup ("Hotkeys", $groupSettings[0], $groupSettings[1], 340, 300)
		; approach hotkey
		GUICtrlCreateLabel("Approach:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_hotkeyApproach = GUICtrlCreateInput ("q", $groupSettings[0] + 100, $groupSettings[1] + 15, 50, 20)

		; orbit hotkey
		GUICtrlCreateLabel("Orbit:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_hotkeyOrbit = GUICtrlCreateInput ("w", $groupSettings[0] + 100, $groupSettings[1] + 35, 50, 20)

		; keep at range hotkey
		GUICtrlCreateLabel("Keep at range:", $groupSettings[0] + 10, $groupSettings[1] + 60)
		$GUI_hotkeyRange = GUICtrlCreateInput ("e", $groupSettings[0] + 100, $groupSettings[1] + 55, 50, 20)

		; jump in gate
		GUICtrlCreateLabel("Jump in gate:", $groupSettings[0] + 10, $groupSettings[1] + 80)
		$GUI_hotkeyJump = GUICtrlCreateInput ("d", $groupSettings[0] + 100, $groupSettings[1] + 75, 50, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; advanced group
	$GUI_settingsAdvancedGroup = GUICtrlCreateGroup ("Advanced", $groupSettings[0], $groupSettings[1], 340, 300)
		;check teamviewer
		$GUI_closeTeamViewer = GUICtrlCreateCheckbox("close TeamViewer advertisement window", $groupSettings[0] + 10, $groupSettings[1] + 20)
		GUICtrlSetState($GUI_closeTeamViewer, $GUI_UNCHECKED)

		; application title
		GUICtrlCreateLabel("Application title:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_ApplicationTitleInput = GUICtrlCreateInput ($initTitleApplication, $groupSettings[0] + 100, $groupSettings[1] + 40, 230, 20)

		;delays
		GUICtrlCreateLabel("Accounts delay(sec):", $groupSettings[0] + 10, $groupSettings[1] + 60)
		$GUI_botsDelayInput = GUICtrlCreateInput ("2", $groupSettings[0] + 100, $groupSettings[1] + 60, 50, 20, $ES_NUMBER)

		GUICtrlCreateLabel("Full cycle delay(sec):", $groupSettings[0] + 10, $groupSettings[1] + 80)
		$GUI_ciclesDelayInput = GUICtrlCreateInput ("1", $groupSettings[0] + 100, $groupSettings[1] + 80, 50, 20, $ES_NUMBER)

		GUICtrlCreateLabel("Use monitor ¹:", $groupSettings[0] + 10, $groupSettings[1] + 100)
		$GUI_monitor = GUICtrlCreateInput ("1", $groupSettings[0] + 100, $groupSettings[1] + 100, 50, 20, $ES_NUMBER)

		; use tooltip log
		$GUI_useTooltipLog = GUICtrlCreateCheckbox("use tooltips for last log message", $groupSettings[0] + 10, $groupSettings[1] + 140)
		GUICtrlSetState($GUI_useTooltipLog, $GUI_UNCHECKED)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; gameplay group
	$GUI_settingsGameplayGroup = GUICtrlCreateGroup ("Gameplay", $groupSettings[0], $groupSettings[1], 340, 300)
		; tab switch delay
		GUICtrlCreateLabel("Overview tab switch delay(sec):", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_overviewTabDelay = GUICtrlCreateInput ("1", $groupSettings[0] + 200, $groupSettings[1] + 20, 50, 20)

		;logout if enemy found
		$GUI_EnemyLogoutCheckbox = GUICtrlCreateCheckbox("If enemy found, logout in safe", $groupSettings[0] + 10, $groupSettings[1] + 40)
		GUICtrlSetState($GUI_EnemyLogoutCheckbox, $GUI_UNCHECKED)

		GUICtrlCreateLabel("If enemy found, wait before logout(min):", $groupSettings[0] + 10, $groupSettings[1] + 60)
		$GUI_enemyWaitBeforeLogoutInput = GUICtrlCreateInput ("15", $groupSettings[0] + 200, $groupSettings[1] + 60, 50, 20, $ES_NUMBER)

		GUICtrlCreateLabel("If enemy found, pause for(min):", $groupSettings[0] + 10, $groupSettings[1] + 80)
		$GUI_enemyTimeoutInput = GUICtrlCreateInput ("60", $groupSettings[0] + 200, $groupSettings[1] + 80, 50, 20, $ES_NUMBER)

		GUICtrlCreateLabel("Container password:", $groupSettings[0] + 10, $groupSettings[1] + 100)
		$GUI_containerPasswordInput = GUICtrlCreateInput ("0000", $groupSettings[0] + 200, $groupSettings[1] + 100, 50, 20)

		GUICtrlCreateLabel("Container password delay(sec):", $groupSettings[0] + 10, $groupSettings[1] + 120)
		$GUI_containerPasswordDelayInput = GUICtrlCreateInput ("7", $groupSettings[0] + 200, $groupSettings[1] + 120, 50, 20, $ES_NUMBER)

		;all back on damage
		$GUI_allBackOnOneDamageCheckbox = GUICtrlCreateCheckbox("return all if one damaged, wait(min):", $groupSettings[0] + 10, $groupSettings[1] + 140)
		GUICtrlSetState($GUI_allBackOnOneDamageCheckbox, $GUI_UNCHECKED)
		$GUI_allBackOnOneDamageInput = GUICtrlCreateInput ("15", $groupSettings[0] + 200, $groupSettings[1] + 140, 50, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; speech group
	$GUI_settingsSpeachGroup = GUICtrlCreateGroup ("Speech(test feature, can be buggy)", $groupSettings[0], $groupSettings[1], 340, 300)
		;use speech engine
		$GUI_useSpeechEngine = GUICtrlCreateCheckbox("use speech engine", $groupSettings[0] + 10, $groupSettings[1] + 20)
		GUICtrlSetState($GUI_useSpeechEngine, $GUI_UNCHECKED)

		;speak when enemy found
		$GUI_useSpeechOnEnemy = GUICtrlCreateCheckbox("when enemy found:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		GUICtrlSetState($GUI_useSpeechOnEnemy, $GUI_UNCHECKED)
		$GUI_textSpeechOnEnemy = GUICtrlCreateInput ("enemy detected", $groupSettings[0] + 10, $groupSettings[1] + 60, 320, 20, $ES_NUMBER)

		;speak when local changed
		$GUI_useSpeechOnNewUser = GUICtrlCreateCheckbox("when new user appeared in local chat:", $groupSettings[0] + 10, $groupSettings[1] + 80)
		GUICtrlSetState($GUI_useSpeechOnNewUser, $GUI_UNCHECKED)
		$GUI_textSpeechOnNewUser = GUICtrlCreateInput ("new user in chat", $groupSettings[0] + 10, $groupSettings[1] + 100, 320, 20, $ES_NUMBER)

		;speak when too many users in local
		$GUI_useSpeechTooManyUsers = GUICtrlCreateCheckbox("when local chat overloaded:", $groupSettings[0] + 10, $groupSettings[1] + 120)
		GUICtrlSetState($GUI_useSpeechTooManyUsers, $GUI_UNCHECKED)
		$GUI_textSpeechTooManyUsers = GUICtrlCreateInput ("chat overloaded", $groupSettings[0] + 10, $groupSettings[1] + 140, 320, 20, $ES_NUMBER)

		;speak when NPC found
		$GUI_useSpeechOnNPCFound = GUICtrlCreateCheckbox("when NPC found:", $groupSettings[0] + 10, $groupSettings[1] + 160)
		GUICtrlSetState($GUI_useSpeechOnNPCFound, $GUI_UNCHECKED)
		$GUI_textSpeechOnNPCFound = GUICtrlCreateInput ("NPC detected", $groupSettings[0] + 10, $groupSettings[1] + 180, 320, 20, $ES_NUMBER)

		;speak when loot
		$GUI_useSpeechOnLoot = GUICtrlCreateCheckbox("when wreck looted:", $groupSettings[0] + 10, $groupSettings[1] + 200)
		GUICtrlSetState($GUI_useSpeechOnLoot, $GUI_UNCHECKED)
		$GUI_textSpeechOnLoot = GUICtrlCreateInput ("looting NPC", $groupSettings[0] + 10, $groupSettings[1] + 220, 320, 20, $ES_NUMBER)

		;speak when damaged
		$GUI_useSpeechOnDamage = GUICtrlCreateCheckbox("when ship critically damaged:", $groupSettings[0] + 10, $groupSettings[1] + 240)
		GUICtrlSetState($GUI_useSpeechOnDamage, $GUI_UNCHECKED)
		$GUI_textSpeechOnDamage = GUICtrlCreateInput ("ship damaged", $groupSettings[0] + 10, $groupSettings[1] + 260, 320, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; email notifications group
	$GUI_settingsEmailGroup = GUICtrlCreateGroup ("Email notifications", $groupSettings[0], $groupSettings[1], 340, 300)
		;use email notifications engine
		$GUI_useEmailNotifications = GUICtrlCreateCheckbox("use email notifications engine", $groupSettings[0] + 10, $groupSettings[1] + 20)
		GUICtrlSetState($GUI_useEmailNotifications, $GUI_UNCHECKED)

		;when client needs update
		$GUI_sendEmailOnUpdateNeeded = GUICtrlCreateCheckbox("when client needs update:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		GUICtrlSetState($GUI_sendEmailOnUpdateNeeded, $GUI_UNCHECKED)
		$GUI_textEmailOnUpdateNeeded = GUICtrlCreateInput ("client needs update. accounts disabled", $groupSettings[0] + 10, $groupSettings[1] + 60, 320, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; paths group
	$GUI_settingsPathsGroup = GUICtrlCreateGroup ("Paths", $groupSettings[0], $groupSettings[1], 340, 300)
		; EVE selector
		GUICtrlCreateLabel("EVE client file:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_eveSelectPath = GUICtrlCreateInput("C:\CCP\EVE\bin\ExeFile.exe", $groupSettings[0] + 10, $groupSettings[1] + 40, 320, 20)
		$GUI_eveSelectButton = GUICtrlCreateButton("Select EVE laungh file [ExeFile.exe]",  $groupSettings[0] + 10, $groupSettings[1] + 60, 320, 20)
		GUICtrlSetOnEvent($GUI_eveSelectButton, "GUI_SelectEVEExe")
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; login group
	$GUI_settingsLoginGroup = GUICtrlCreateGroup ("Login", $groupSettings[0], $groupSettings[1], 340, 300)
		GUICtrlCreateLabel("Login method:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_loginMethodCombo = GUICtrlCreateCombo ("random", $groupSettings[0] + 200, $groupSettings[1] + 20, 100, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_loginMethodCombo, "dblclick|clear", "random")

		$GUI_logoutAfterLoginErrorCheckbox = GUICtrlCreateCheckbox("close client window on login error limit", $groupSettings[0] + 10, $groupSettings[1] + 40)
		GUICtrlSetState($GUI_logoutAfterLoginErrorCheckbox, $GUI_CHECKED)

		GUICtrlCreateLabel("Maximum login errors allowed:", $groupSettings[0] + 10, $groupSettings[1] + 60)
		$GUI_loginMaxErrorsInput = GUICtrlCreateInput ("3", $groupSettings[0] + 200, $groupSettings[1] + 60, 50, 20, $ES_NUMBER)

		GUICtrlCreateLabel("Delay after login error(min):", $groupSettings[0] + 10, $groupSettings[1] + 80)
		$GUI_loginErrorDelayInput = GUICtrlCreateInput ("15", $groupSettings[0] + 200, $groupSettings[1] + 80, 50, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; license group
	$GUI_settingsLicenseGroup = GUICtrlCreateGroup ("License", $groupSettings[0], $groupSettings[1], 340, 300)
		; Check internet connection with site
		GUICtrlCreateLabel("License login:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_licenseLogin = GUICtrlCreateInput ("yourServerLogin", $groupSettings[0] + 100, $groupSettings[1] + 15, 150, 20)

		GUICtrlCreateLabel("License password:", $groupSettings[0] + 10, $groupSettings[1] + 40)
		$GUI_licensePassword = GUICtrlCreateInput ("yourServerPassword", $groupSettings[0] + 100, $groupSettings[1] + 35, 150, 20)

		GUICtrlCreateLabel("Don't have an account?", $groupSettings[0] + 10, $groupSettings[1] + 65)
		$GUI_registerButton = GUICtrlCreateButton ("Register for free",  $groupSettings[0] + 150, $groupSettings[1] + 60, 100, 25, $BS_MULTILINE)
		GUICtrlSetOnEvent($GUI_registerButton, "GUI_AboutWindow_OpenRegister")
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; downtime group
	$GUI_settingsDowntimeGroup = GUICtrlCreateGroup ("Downtime", $groupSettings[0], $groupSettings[1], 340, 300)
		; downtime
		GUICtrlCreateLabel("Schedule:", $groupSettings[0] + 10, $groupSettings[1] + 20)
		$GUI_downtime = GUICtrlCreateInput ("12:30-15:30", $groupSettings[0] + 10, $groupSettings[1] + 40, 320, 20)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; hide non-default panels
	For $i = $GUI_settingsHotkeysGroup To $GUI_downtime
		GUICtrlSetState($i, $GUI_HIDE)
	Next

	_GUICtrlTreeView_SelectItem($treeview, $networkitem)

	; set window events
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_CloseSettingsWindow")

	; GUI MESSAGE LOOP
	GUISetState(@SW_HIDE)
EndFunc

;open settings window
Func GUI_OpenSettingsWindow()
	GUISetState(@SW_SHOW, $GUI_settingsWindow)
EndFunc

;close settings window
Func GUI_CloseSettingsWindow()
	WIN_ChangeWindowTitle($GUI_mainWindow, GUICtrlRead($GUI_ApplicationTitleInput))
	GUISetState(@SW_HIDE, $GUI_settingsWindow)
EndFunc

; hide all settings
Func GUI_HideAllSettings()
	For $i = $GUI_settingsNetworkGroup To $GUI_downtime
		GUICtrlSetState($i, $GUI_HIDE)
	Next
EndFunc

; show hotkeys settings
Func GUI_ShowHotkeySettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsHotkeysGroup To $GUI_hotkeyJump
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show network settings
Func GUI_ShowNetworkSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsNetworkGroup To $GUI_NetworkTimeoutInput
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show advanced settings
Func GUI_ShowAdvancedSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsAdvancedGroup To $GUI_monitor
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show gameplay settings
Func GUI_ShowGameplaySettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsGameplayGroup To $GUI_allBackOnOneDamageInput
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show downtime settings
Func GUI_ShowDowntimeSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsDowntimeGroup To $GUI_downtime
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show speach settings
Func GUI_ShowSpeachSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsSpeachGroup To $GUI_textSpeechOnDamage
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show email settings
Func GUI_ShowEmailSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsEmailGroup To $GUI_textEmailOnUpdateNeeded
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show paths settings
Func GUI_ShowPathsSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsPathsGroup To $GUI_eveSelectButton
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show login settings
Func GUI_ShowLoginSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsLoginGroup To $GUI_loginErrorDelayInput
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc

; show license settings
Func GUI_ShowLicenseSettings()
	GUI_HideAllSettings()
	For $i = $GUI_settingsLicenseGroup To $GUI_registerButton
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc