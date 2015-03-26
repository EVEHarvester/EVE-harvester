Func CONFIG_SaveConfigCaller()
	CONFIG_SaveConfig($GUI_currentConfigFile)
EndFunc

Func CONFIG_SaveAsConfigCaller()
	CONFIG_SaveConfig()
EndFunc

;save config
Func CONFIG_SaveConfig($filepath = False)
	If $filepath = False Then
		$filepath = FileSaveDialog("Select file to save", @ScriptDir, "INI file (*.ini)", 1, "config.ini")

		If StringInStr($filepath, ".ini") = 0 Then
			$filepath = $filepath & ".ini"
		EndIf

		If @error Then
			MsgBox(64, "Save", "File open error!")
			BOT_LogMessage("File open error", 2)
			Return False
		EndIf
	EndIf

	Local $dataMain[55][2]
	$dataMain[0][0] = "eveExe"
	$dataMain[0][1] = GUICtrlRead($GUI_eveSelectPath)
	$dataMain[1][0] = "numOfBots"
	$dataMain[1][1] = $GLB_numOfBots
	$dataMain[2][0] = "downtime"
	$dataMain[2][1] = GUICtrlRead($GUI_downtime)
	$dataMain[3][0] = "overviewTabDelay"
	$dataMain[3][1] = GUICtrlRead($GUI_overviewTabDelay)
	$dataMain[4][0] = "enemyTimeout"
	$dataMain[4][1] = GUICtrlRead($GUI_enemyTimeoutInput)
	$dataMain[5][0] = "monitor"
	$dataMain[5][1] = GUICtrlRead($GUI_monitor)
	$dataMain[6][0] = "appTitle"
	$dataMain[6][1] = GUICtrlRead($GUI_ApplicationTitleInput)
	$dataMain[7][0] = "botsDelay"
	$dataMain[7][1] = GUICtrlRead($GUI_botsDelayInput)
	$dataMain[8][0] = "circlesDelay"
	$dataMain[8][1] = GUICtrlRead($GUI_ciclesDelayInput)
	$dataMain[9][0] = "backAllIfOneDamaged"
	$dataMain[9][1] = (GUICtrlRead($GUI_allBackOnOneDamageCheckbox) = $GUI_CHECKED)
	$dataMain[10][0] = "backAllIfOneDamagedWait"
	$dataMain[10][1] = GUICtrlRead($GUI_allBackOnOneDamageInput)
	$dataMain[11][0] = "loginErrorDelay"
	$dataMain[11][1] = GUICtrlRead($GUI_loginErrorDelayInput)
	$dataMain[12][0] = "hotkeyApproach"
	$dataMain[12][1] = GUICtrlRead($GUI_hotkeyApproach)
	$dataMain[13][0] = "loginErrorsLimit"
	$dataMain[13][1] = GUICtrlRead($GUI_loginMaxErrorsInput)
	$dataMain[14][0] = "hotkeyOrbit"
	$dataMain[14][1] = GUICtrlRead($GUI_hotkeyOrbit)
	$dataMain[15][0] = "eveServer"
	$dataMain[15][1] = GUICtrlRead($GUI_EVEServerInput)
	$dataMain[16][0] = "eveServerTimeout"
	$dataMain[16][1] = GUICtrlRead($GUI_EVEServerTimeoutInput)
	$dataMain[17][0] = "hotkeyRange"
	$dataMain[17][1] = GUICtrlRead($GUI_hotkeyRange)
	$dataMain[18][0] = "hotkeyJump"
	$dataMain[18][1] = GUICtrlRead($GUI_hotkeyJump)
	$dataMain[19][0] = "contPassDelay"
	$dataMain[19][1] = GUICtrlRead($GUI_containerPasswordDelayInput)
	$dataMain[20][0] = "contPass"
	$dataMain[20][1] = GUICtrlRead($GUI_containerPasswordInput)
	$dataMain[21][0] = "pingServer"
	$dataMain[21][1] = GUICtrlRead($GUI_pingConnectionServer)
	$dataMain[22][0] = "checkTeamviewer"
	$dataMain[22][1] = (GUICtrlRead($GUI_closeTeamViewer) = $GUI_CHECKED)
	$dataMain[23][0] = "allowRemote"
	$dataMain[23][1] = (GUICtrlRead($GUI_allowRemote) = $GUI_CHECKED)
	$dataMain[24][0] = "useTooltips"
	$dataMain[24][1] = (GUICtrlRead($GUI_useTooltipLog) = $GUI_CHECKED)
	$dataMain[25][0] = "useSpeechEngine"
	$dataMain[25][1] = (GUICtrlRead($GUI_useSpeechEngine) = $GUI_CHECKED)
	$dataMain[26][0] = "useSpeechOnEnemy"
	$dataMain[26][1] = (GUICtrlRead($GUI_useSpeechOnEnemy) = $GUI_CHECKED)
	$dataMain[27][0] = "textSpeechOnEnemy"
	$dataMain[27][1] = GUICtrlRead($GUI_textSpeechOnEnemy)
	$dataMain[28][0] = "useSpeechOnNewUser"
	$dataMain[28][1] = (GUICtrlRead($GUI_useSpeechOnNewUser) = $GUI_CHECKED)
	$dataMain[29][0] = "textSpeechOnNewUser"
	$dataMain[29][1] = GUICtrlRead($GUI_textSpeechOnNewUser)
	$dataMain[30][0] = "useSpeechTooManyUsers"
	$dataMain[30][1] = (GUICtrlRead($GUI_useSpeechTooManyUsers) = $GUI_CHECKED)
	$dataMain[31][0] = "textSpeechTooManyUsers"
	$dataMain[31][1] = GUICtrlRead($GUI_textSpeechTooManyUsers)
	$dataMain[32][0] = "useSpeechOnNPCFound"
	$dataMain[32][1] = (GUICtrlRead($GUI_useSpeechOnNPCFound) = $GUI_CHECKED)
	$dataMain[33][0] = "textSpeechOnNPCFound"
	$dataMain[33][1] = GUICtrlRead($GUI_textSpeechOnNPCFound)
	$dataMain[34][0] = "useSpeechOnLoot"
	$dataMain[34][1] = (GUICtrlRead($GUI_useSpeechOnLoot) = $GUI_CHECKED)
	$dataMain[35][0] = "textSpeechOnLoot"
	$dataMain[35][1] = GUICtrlRead($GUI_textSpeechOnLoot)
	$dataMain[36][0] = "useSpeechOnDamage"
	$dataMain[36][1] = (GUICtrlRead($GUI_useSpeechOnDamage) = $GUI_CHECKED)
	$dataMain[37][0] = "textSpeechOnDamage"
	$dataMain[37][1] = GUICtrlRead($GUI_textSpeechOnDamage)
	$dataMain[38][0] = "loginMethod"
	$dataMain[38][1] = GUICtrlRead($GUI_loginMethodCombo)
	$dataMain[39][0] = "logoutAfterLoginError"
	$dataMain[39][1] = (GUICtrlRead($GUI_logoutAfterLoginErrorCheckbox) = $GUI_CHECKED)
	$dataMain[40][0] = "logoutOnEnemy"
	$dataMain[40][1] = (GUICtrlRead($GUI_EnemyLogoutCheckbox) = $GUI_CHECKED)
	$dataMain[41][0] = "waitBeforeLogoutOnEnemy"
	$dataMain[41][1] = GUICtrlRead($GUI_enemyWaitBeforeLogoutInput)

	$dataMain[42][0] = "OCRInventoryWindow"
	$dataMain[42][1] = GUICtrlRead($GUI_OCRInventoryX) & "," & GUICtrlRead($GUI_OCRInventoryY)
	$dataMain[43][0] = "OCRChatWindow"
	$dataMain[43][1] = GUICtrlRead($GUI_OCRChatX) & "," & GUICtrlRead($GUI_OCRChatY)
	$dataMain[44][0] = "OCROverviewWindow"
	$dataMain[44][1] = GUICtrlRead($GUI_OCROverviewX) & "," & GUICtrlRead($GUI_OCROverviewY)
	$dataMain[45][0] = "OCRSIWindow"
	$dataMain[45][1] = GUICtrlRead($GUI_OCRSIX) & "," & GUICtrlRead($GUI_OCRSIY)
	$dataMain[46][0] = "OCRPAPWindow"
	$dataMain[46][1] = GUICtrlRead($GUI_OCRPAPX) & "," & GUICtrlRead($GUI_OCRPAPY)
	$dataMain[47][0] = "OCRScannerWindow"
	$dataMain[47][1] = GUICtrlRead($GUI_OCRScannerX) & "," & GUICtrlRead($GUI_OCRScannerY)
	$dataMain[48][0] = "OCRDronesWindow"
	$dataMain[48][1] = GUICtrlRead($GUI_OCRDronesX) & "," & GUICtrlRead($GUI_OCRDronesY)

	$dataMain[49][0] = "NetworkTimeout"
	$dataMain[49][1] = GUICtrlRead($GUI_NetworkTimeoutInput)

	$dataMain[50][0] = "licenseLogin"
	$dataMain[50][1] = GUICtrlRead($GUI_licenseLogin)
	$dataMain[51][0] = "licensePassword"
	$dataMain[51][1] = GUICtrlRead($GUI_licensePassword)

	$dataMain[52][0] = "useEmailNotifications"
	$dataMain[52][1] = (GUICtrlRead($GUI_useEmailNotifications) = $GUI_CHECKED)
	$dataMain[53][0] = "sendEmailOnUpdateNeeded"
	$dataMain[53][1] = (GUICtrlRead($GUI_sendEmailOnUpdateNeeded) = $GUI_CHECKED)
	$dataMain[54][0] = "textEmailOnUpdateNeeded"
	$dataMain[54][1] = GUICtrlRead($GUI_textEmailOnUpdateNeeded)

	IniWriteSection ($filepath, "Main",  $dataMain, 0)

	For $i = 0 To $GLB_numOfBots - 1 Step 1
		IniWriteSection ($filepath, "Bot" & ($i + 1), CONFIG_GetBotData($i), 0)
	Next

	GLB_UpdateOCR()

	$GUI_currentConfigFile = $filepath

	MsgBox(64, "Save", "Configuration saved!")
	BOT_LogMessage("Configuration saved", 2)
EndFunc

Func CONFIG_GetBotData($i)
	Dim $dataBot[68][2]

	Local $highSlots = "", $middleSlots = "", $lowSlots= ""
	For $s = 0 To 7 Step 1
		$highSlots&= GUICtrlRead($GUI_slotHigh[$i][$s]) & "."
		$middleSlots&= GUICtrlRead($GUI_slotMiddle[$i][$s]) & "."
		$lowSlots&= GUICtrlRead($GUI_slotLow[$i][$s]) & "."
	Next

	Local $bookmarksOrder = ""
	For $o = 0 To _GUICtrlListBox_GetCount($GUI_BookmarksList[$i]) - 1 Step 1
		$bookmarksOrder&= _GUICtrlListBox_GetText($GUI_BookmarksList[$i], $o)
		If $o <> _GUICtrlListBox_GetCount($GUI_BookmarksList[$i]) - 1 Then
			$bookmarksOrder&= "."
		EndIf
	Next

	$dataBot[0][0] = "login"
	$dataBot[0][1] = GUICtrlRead($GUI_login[$i])
	$dataBot[1][0] = "password"
	$dataBot[1][1] = GUICtrlRead($GUI_password[$i])
	$dataBot[2][0] = "location"
	$dataBot[2][1] = GUICtrlRead($GUI_locationCombo[$i])
	$dataBot[3][0] = "state"
	$dataBot[3][1] = GUICtrlRead($GUI_stateCombo[$i])
	$dataBot[4][0] = "backOnDamage"
	$dataBot[4][1] = (GUICtrlRead($GUI_runOnDamageCheckbox[$i]) = $GUI_CHECKED)
	$dataBot[5][0] = "highSlots"
	$dataBot[5][1] = $highSlots
	$dataBot[6][0] = "middleSlots"
	$dataBot[6][1] = $middleSlots
	$dataBot[7][0] = "lowSlots"
	$dataBot[7][1] = $lowSlots
	$dataBot[8][0] = "chatCurrentTab"
	$dataBot[8][1] = GUICtrlRead($GUI_ChatCurrentTabCombo[$i])
	$dataBot[9][0] = "fullCargo"
	$dataBot[9][1] = GUICtrlRead($GUI_fullCargo[$i])
	$dataBot[10][0] = "overviewTab"
	$dataBot[10][1] = GUICtrlRead($GUI_OverviewCurrentTabCombo[$i])
	$dataBot[11][0] = "loginDelay"
	$dataBot[11][1] = GUICtrlRead($GUI_LaunghDelay[$i])
	$dataBot[12][0] = "enableBot"
	$dataBot[12][1] = (GUICtrlRead($GUI_enableBot[$i]) = $GUI_CHECKED)
	$dataBot[13][0] = "role"
	$dataBot[13][1] = GUICtrlRead($GUI_botRole[$i])
	$dataBot[14][0] = "schedule"
	$dataBot[14][1] = GUICtrlRead($GUI_botSchedule[$i])
	$dataBot[15][0] = "fullContainerCargo"
	$dataBot[15][1] = GUICtrlRead($GUI_fullContainerCargo[$i])
	$dataBot[16][0] = "bookmarkMax"
	$dataBot[16][1] = GUICtrlRead($GUI_bookmarkMax[$i])
	$dataBot[17][0] = "bookmarkCurrent"
	$dataBot[17][1] = GUICtrlRead($GUI_bokmarkCurrent[$i])
	$dataBot[18][0] = "useShields"
	$dataBot[18][1] = (GUICtrlRead($GUI_useShieldsCheckbox[$i]) = $GUI_CHECKED)
	$dataBot[19][0] = "shieldCritical"
	$dataBot[19][1] = GUICtrlRead($GUI_shieldCritical[$i])
	$dataBot[20][0] = "shieldActivateOn"
	$dataBot[20][1] = GUICtrlRead($GUI_shieldActivateOn[$i])
	$dataBot[21][0] = "shieldMaxTime"
	$dataBot[21][1] = GUICtrlRead($GUI_shieldMaxActiveTime[$i])
	$dataBot[22][0] = "useDrones"
	$dataBot[22][1] = (GUICtrlRead($GUI_useDrones[$i]) = $GUI_CHECKED)
	$dataBot[23][0] = "dronesType"
	$dataBot[23][1] = GUICtrlRead($GUI_dronesType[$i])
	$dataBot[24][0] = "attackNPC"
	$dataBot[24][1] = (GUICtrlRead($GUI_attackNPCCheckbox[$i]) = $GUI_CHECKED)
	$dataBot[25][0] = "leaveOneItemInCargo"
	$dataBot[25][1] = (GUICtrlRead($GUI_leaveOneItemInCargoCheckbox[$i]) = $GUI_CHECKED)
	$dataBot[26][0] = "bookmarkVisible"
	$dataBot[26][1] = GUICtrlRead($GUI_bookmarkVisible[$i])
	$dataBot[27][0] = "unloadTo"
	$dataBot[27][1] = GUICtrlRead($GUI_UnloadToCombo[$i])
	$dataBot[28][0] = "mineAtOnce"
	$dataBot[28][1] = GUICtrlRead($GUI_mineAtOnce[$i])
	$dataBot[29][0] = "lootWrecks"
	$dataBot[29][1] = (GUICtrlRead($GUI_lootWrecksCheckbox[$i]) = $GUI_CHECKED)
	$dataBot[30][0] = "allowFleet"
	$dataBot[30][1] = GUICtrlRead($GUI_acceptUnknownFleet[$i])
	$dataBot[31][0] = "minersReload"
	$dataBot[31][1] = GUICtrlRead($GUI_minersReload[$i])
	$dataBot[32][0] = "waitingTimeout"
	$dataBot[32][1] = GUICtrlRead($GUI_timeoutWaitingDefault[$i])
	$dataBot[33][0] = "warpTimeout"
	$dataBot[33][1] = GUICtrlRead($GUI_timeoutWarpDefault[$i])
	$dataBot[34][0] = "cargoTimeout"
	$dataBot[34][1] = GUICtrlRead($GUI_timeoutCargoDefault[$i])
	$dataBot[35][0] = "dronesTimeout"
	$dataBot[35][1] = GUICtrlRead($GUI_timeoutDronesDefault[$i])
	$dataBot[36][0] = "stationTimeout"
	$dataBot[36][1] = GUICtrlRead($GUI_timeoutStationDefault[$i])
	$dataBot[37][0] = "repairDrones"
	$dataBot[37][1] = (GUICtrlRead($GUI_repairDrones[$i]) = $GUI_CHECKED)
	$dataBot[38][0] = "salvageWrecks"
	$dataBot[38][1] = (GUICtrlRead($GUI_salvageWrecksCheckbox[$i]) = $GUI_CHECKED)
	$dataBot[39][0] = "waitDrones"
	$dataBot[39][1] = (GUICtrlRead($GUI_waitDrones[$i]) = $GUI_CHECKED)
	$dataBot[40][0] = "huntingPlace"
	$dataBot[40][1] = GUICtrlRead($GUI_huntingPlace[$i])
	$dataBot[41][0] = "systemSecurity"
	$dataBot[41][1] = GUICtrlRead($GUI_systemSecurity[$i])
	$dataBot[42][0] = "systemPOS"
	$dataBot[42][1] = GUICtrlRead($GUI_systemPOS[$i])
	$dataBot[43][0] = "lockDistance"
	$dataBot[43][1] = GUICtrlRead($GUI_lockDistance[$i])
	$dataBot[44][0] = "miningLimit"
	$dataBot[44][1] = GUICtrlRead($GUI_miningLimit[$i])
	$dataBot[45][0] = "lootOnlyFaction"
	$dataBot[45][1] = (GUICtrlRead($GUI_lootOnlyFaction[$i]) = $GUI_CHECKED)
	$dataBot[46][0] = "groupID"
	$dataBot[46][1] = GUICtrlRead($GUI_groupID[$i])
	$dataBot[47][0] = "localChatIconSize"
	$dataBot[47][1] = GUICtrlRead($GUI_localChatIconSize[$i])
	$dataBot[48][0] = "localChatMonitor"
	$dataBot[48][1] = (GUICtrlRead($GUI_localChatMonitor[$i]) = $GUI_CHECKED)
	$dataBot[49][0] = "localChatMaxAmountOfUsers"
	$dataBot[49][1] = GUICtrlRead($GUI_localChatMaxAmountOfUsers[$i])
	$dataBot[50][0] = "NPCtype"
	$dataBot[50][1] = GUICtrlRead($GUI_factionType[$i])
	$dataBot[51][0] = "bookmarksOrder"
	$dataBot[51][1] = $bookmarksOrder
	$dataBot[52][0] = "fixViewDirection"
	$dataBot[52][1] = GUICtrlRead($GUI_fixView[$i])
	$dataBot[53][0] = "forceNPCrespawn"
	$dataBot[53][1] = GUICtrlRead($GUI_forceNPCrespawn[$i])
	$dataBot[54][0] = "scanResolution"
	$dataBot[54][1] = GUICtrlRead($GUI_scanResolution[$i])
	$dataBot[55][0] = "anomaliesDelay"
	$dataBot[55][1] = GUICtrlRead($GUI_anomaliesDelay[$i])
	$dataBot[56][0] = "anomaliesList"
	$dataBot[56][1] = GUICtrlRead($GUI_anomaliesList[$i])
	$dataBot[57][0] = "respawnAmount"
	$dataBot[57][1] = GUICtrlRead($GUI_respawnAmount[$i])
	$dataBot[58][0] = "iceCheckPeriod"
	$dataBot[58][1] = GUICtrlRead($GUI_iceCheckPeriod[$i])
	$dataBot[59][0] = "oreType"
	$dataBot[59][1] = GUICtrlRead($GUI_oreType[$i])
	$dataBot[60][0] = "changeMiningCrystals"
	$dataBot[60][1] = GUICtrlRead($GUI_changeMiningCrystals[$i])
	$dataBot[61][0] = "actionDistance"
	$dataBot[61][1] = GUICtrlRead($GUI_actionDistance[$i])
	$dataBot[62][0] = "isSteam"
	$dataBot[62][1] = (GUICtrlRead($GUI_isSteam[$i]) = $GUI_CHECKED)
	$dataBot[63][0] = "bookmarkType"
	$dataBot[63][1] = GUICtrlRead($GUI_bookmarkType[$i])
	$dataBot[64][0] = "botScheduleType"
	$dataBot[64][1] = GUICtrlRead($GUI_botScheduleType[$i])
	$dataBot[65][0] = "botScheduleHours"
	$dataBot[65][1] = GUICtrlRead($GUI_botScheduleHours[$i])
	$dataBot[66][0] = "character"
	$dataBot[66][1] = GUICtrlRead($GUI_character[$i])
	$dataBot[67][0] = "ammoAmount"
	$dataBot[67][1] = GUICtrlRead($GUI_ammoAmountInput[$i])

	Return $dataBot
EndFunc

;preload config
Func CONFIG_PreLoadConfig()
	Local $filepath = FileOpenDialog("Select file to load", @ScriptDir, "INI file (*.ini)", 1, "config.ini")

	If @error Then
		Return False
	EndIf

	CONFIG_LoadConfig($filepath)
EndFunc

;load config
Func CONFIG_LoadConfig($filepath)
	BOT_LogMessage("Configuration load from " & $filepath, 2)
	$GUI_currentConfigFile = $filepath

	CONFIG_ResetConfig()
	BOT_LogMessage("Configuration reseted", 2)

	Local $evePath = IniRead($filepath, "Main", "eveExe", $GLB_notFoundRecord)
	Local $numOfBots = IniRead($filepath, "Main", "numOfBots", $GLB_notFoundRecord)
	Local $downtime = IniRead($filepath, "Main", "downtime", $GLB_notFoundRecord)
	Local $appTitle = IniRead($filepath, "Main", "appTitle", $GLB_notFoundRecord)
	Local $botsDelay = IniRead($filepath, "Main", "botsDelay", $GLB_notFoundRecord)
	Local $circlesDelay = IniRead($filepath, "Main", "circlesDelay", $GLB_notFoundRecord)
	Local $backAllIfOneDamaged = IniRead($filepath, "Main", "backAllIfOneDamaged", $GLB_notFoundRecord)
	Local $backAllIfOneDamagedWait = IniRead($filepath, "Main", "backAllIfOneDamagedWait", $GLB_notFoundRecord)
	Local $actionWaitLimit = IniRead($filepath, "Main", "actionWaitLimit", $GLB_notFoundRecord)
	Local $eveServer = IniRead($filepath, "Main", "eveServer", $GLB_notFoundRecord)
	Local $eveServerTimeout = IniRead($filepath, "Main", "eveServerTimeout", $GLB_notFoundRecord)
	Local $NetworkTimeout = IniRead($filepath, "Main", "NetworkTimeout", $GLB_notFoundRecord)
	Local $loginErrorDelay = IniRead($filepath, "Main", "loginErrorDelay", $GLB_notFoundRecord)
	Local $loginErrorsLimit = IniRead($filepath, "Main", "loginErrorsLimit", $GLB_notFoundRecord)
	Local $contPassDelay = IniRead($filepath, "Main", "contPassDelay", $GLB_notFoundRecord)
	Local $contPass = IniRead($filepath, "Main", "contPass", $GLB_notFoundRecord)
	Local $pingServer = IniRead($filepath, "Main", "pingServer", $GLB_notFoundRecord)
	Local $checkTeamviewer = IniRead($filepath, "Main", "checkTeamviewer", $GLB_notFoundRecord)
	Local $useSpeechEngine = IniRead($filepath, "Main", "useSpeechEngine", $GLB_notFoundRecord)
	Local $overviewTabDelay = IniRead($filepath, "Main", "overviewTabDelay", $GLB_notFoundRecord)
	Local $enemyTimeout = IniRead($filepath, "Main", "enemyTimeout", $GLB_notFoundRecord)
	Local $monitor = IniRead($filepath, "Main", "monitor", $GLB_notFoundRecord)
	Local $allowRemote = IniRead($filepath, "Main", "allowRemote", $GLB_notFoundRecord)

	Local $hotkeyApproach = IniRead($filepath, "Main", "hotkeyApproach", $GLB_notFoundRecord)
	Local $hotkeyOrbit = IniRead($filepath, "Main", "hotkeyOrbit", $GLB_notFoundRecord)
	Local $hotkeyRange = IniRead($filepath, "Main", "hotkeyRange", $GLB_notFoundRecord)
	Local $hotkeyJump = IniRead($filepath, "Main", "hotkeyJump", $GLB_notFoundRecord)

	Local $useTooltips = IniRead($filepath, "Main", "useTooltips", $GLB_notFoundRecord)

	Local $useSpeechOnEnemy = IniRead($filepath, "Main", "useSpeechOnEnemy", $GLB_notFoundRecord)
	Local $textSpeechOnEnemy = IniRead($filepath, "Main", "textSpeechOnEnemy", $GLB_notFoundRecord)
	Local $useSpeechOnNewUser = IniRead($filepath, "Main", "useSpeechOnNewUser", $GLB_notFoundRecord)
	Local $textSpeechOnNewUser = IniRead($filepath, "Main", "textSpeechOnNewUser", $GLB_notFoundRecord)
	Local $useSpeechTooManyUsers = IniRead($filepath, "Main", "useSpeechTooManyUsers", $GLB_notFoundRecord)
	Local $textSpeechTooManyUsers = IniRead($filepath, "Main", "textSpeechTooManyUsers", $GLB_notFoundRecord)
	Local $useSpeechOnNPCFound = IniRead($filepath, "Main", "useSpeechOnNPCFound", $GLB_notFoundRecord)
	Local $textSpeechOnNPCFound = IniRead($filepath, "Main", "textSpeechOnNPCFound", $GLB_notFoundRecord)
	Local $useSpeechOnLoot= IniRead($filepath, "Main", "useSpeechOnLoot", $GLB_notFoundRecord)
	Local $textSpeechOnLoot = IniRead($filepath, "Main", "textSpeechOnLoot", $GLB_notFoundRecord)
	Local $useSpeechOnDamage = IniRead($filepath, "Main", "useSpeechOnDamage", $GLB_notFoundRecord)
	Local $textSpeechOnDamage = IniRead($filepath, "Main", "textSpeechOnDamage", $GLB_notFoundRecord)

	Local $useEmailNotifications = IniRead($filepath, "Main", "useEmailNotifications", $GLB_notFoundRecord)
	Local $sendEmailOnUpdateNeeded = IniRead($filepath, "Main", "sendEmailOnUpdateNeeded", $GLB_notFoundRecord)
	Local $textEmailOnUpdateNeeded = IniRead($filepath, "Main", "textEmailOnUpdateNeeded", $GLB_notFoundRecord)

	Local $loginMethod = IniRead($filepath, "Main", "loginMethod", $GLB_notFoundRecord)
	Local $logoutAfterLoginError = IniRead($filepath, "Main", "logoutAfterLoginError", $GLB_notFoundRecord)

	Local $logoutOnEnemy = IniRead($filepath, "Main", "logoutOnEnemy", $GLB_notFoundRecord)
	Local $waitBeforeLogoutOnEnemy = IniRead($filepath, "Main", "waitBeforeLogoutOnEnemy", $GLB_notFoundRecord)

	Local $licenseLogin = IniRead($filepath, "Main", "licenseLogin", $GLB_notFoundRecord)
	Local $licensePasssword = IniRead($filepath, "Main", "licensePassword", $GLB_notFoundRecord)

	CONFIG_LoadOCRData($filepath)
	BOT_LogMessage("Configuration OCR loaded", 2)

	If $licenseLogin <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_licenseLogin, $licenseLogin)
	If $licensePasssword <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_licensePassword, $licensePasssword)

	If $waitBeforeLogoutOnEnemy <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_enemyWaitBeforeLogoutInput, $waitBeforeLogoutOnEnemy)

	If $logoutOnEnemy = "True" Then
		GUICtrlSetState($GUI_EnemyLogoutCheckbox, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_EnemyLogoutCheckbox, $GUI_UNCHECKED)
	EndIf

	If $loginMethod <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_loginMethodCombo, $loginMethod)

	If $logoutAfterLoginError = "True" Then
		GUICtrlSetState($GUI_logoutAfterLoginErrorCheckbox, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_logoutAfterLoginErrorCheckbox, $GUI_UNCHECKED)
	EndIf

	If $useSpeechOnEnemy = "True" Then
		GUICtrlSetState($GUI_useSpeechOnEnemy, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechOnEnemy, $GUI_UNCHECKED)
	EndIf
	If $textSpeechOnEnemy <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textSpeechOnEnemy, $textSpeechOnEnemy)

	If $useSpeechOnNewUser = "True" Then
		GUICtrlSetState($GUI_useSpeechOnNewUser, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechOnNewUser, $GUI_UNCHECKED)
	EndIf
	If $textSpeechOnEnemy <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textSpeechOnNewUser, $textSpeechOnEnemy)

	If $useSpeechTooManyUsers = "True" Then
		GUICtrlSetState($GUI_useSpeechTooManyUsers, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechTooManyUsers, $GUI_UNCHECKED)
	EndIf
	If $textSpeechTooManyUsers <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textSpeechTooManyUsers, $textSpeechTooManyUsers)

	If $useSpeechOnNPCFound = "True" Then
		GUICtrlSetState($GUI_useSpeechOnNPCFound, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechOnNPCFound, $GUI_UNCHECKED)
	EndIf
	If $textSpeechOnNPCFound <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textSpeechOnNPCFound, $textSpeechOnNPCFound)

	If $useSpeechOnLoot = "True" Then
		GUICtrlSetState($GUI_useSpeechOnLoot, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechOnLoot, $GUI_UNCHECKED)
	EndIf
	If $textSpeechOnLoot <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textSpeechOnLoot, $textSpeechOnLoot)

	If $useSpeechOnDamage = "True" Then
		GUICtrlSetState($GUI_useSpeechOnDamage, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechOnDamage, $GUI_UNCHECKED)
	EndIf
	If $textSpeechOnDamage <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textSpeechOnDamage, $textSpeechOnDamage)

	If $appTitle <> $GLB_notFoundRecord Then
		GUICtrlSetData($GUI_ApplicationTitleInput, $appTitle)
		WIN_ChangeWindowTitle($GUI_mainWindow, $appTitle)
	EndIf

	; email settings
	If $useEmailNotifications = "True" Then
		GUICtrlSetState($GUI_useEmailNotifications, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useEmailNotifications, $GUI_UNCHECKED)
	EndIf

	If $sendEmailOnUpdateNeeded = "True" Then
		GUICtrlSetState($GUI_sendEmailOnUpdateNeeded, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_sendEmailOnUpdateNeeded, $GUI_UNCHECKED)
	EndIf
	If $textEmailOnUpdateNeeded <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_textEmailOnUpdateNeeded, $textEmailOnUpdateNeeded)

	GUICtrlSetData($GUI_monitor, $monitor)

	GUICtrlSetData($GUI_enemyTimeoutInput, $enemyTimeout)

	GUICtrlSetData($GUI_eveSelectPath, $evePath)
	GUICtrlSetData($GUI_numOfBotsInput, $numOfBots)

	GUICtrlSetData($GUI_EVEServerInput, $eveServer)
	GUICtrlSetData($GUI_EVEServerTimeoutInput, $eveServerTimeout)
	If $NetworkTimeout <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_NetworkTimeoutInput, $NetworkTimeout)

	GUICtrlSetData($GUI_loginErrorDelayInput, $loginErrorDelay)
	GUICtrlSetData($GUI_loginMaxErrorsInput, $loginErrorsLimit)

	GUICtrlSetData($GUI_containerPasswordDelayInput, $contPassDelay)
	GUICtrlSetData($GUI_containerPasswordInput, $contPass)

	GUICtrlSetData($GUI_pingConnectionServer, $pingServer)

	If $downtime <> $GLB_notFoundRecord Then GUICtrlSetData($GUI_downtime, $downtime)

	GUICtrlSetData($GUI_overviewTabDelay, $overviewTabDelay)

	If $checkTeamviewer = "True" Then
		GUICtrlSetState($GUI_closeTeamViewer, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_closeTeamViewer, $GUI_UNCHECKED)
	EndIf

	If $useSpeechEngine = "True" Then
		GUICtrlSetState($GUI_useSpeechEngine, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useSpeechEngine, $GUI_UNCHECKED)
	EndIf

	If $useTooltips = "True" Then
		GUICtrlSetState($GUI_useTooltipLog, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_useTooltipLog, $GUI_UNCHECKED)
	EndIf

	If $allowRemote = "True" Then
		GUICtrlSetState($GUI_allowRemote, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_allowRemote, $GUI_UNCHECKED)
	EndIf

	GUICtrlSetData($GUI_botsDelayInput, $botsDelay)
	GUICtrlSetData($GUI_ciclesDelayInput, $circlesDelay)

	If $backAllIfOneDamaged = "True" Then
		GUICtrlSetState($GUI_allBackOnOneDamageCheckbox, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_allBackOnOneDamageCheckbox, $GUI_UNCHECKED)
	EndIf
	GUICtrlSetData($GUI_allBackOnOneDamageInput, $backAllIfOneDamagedWait)

	GUICtrlSetData($GUI_hotkeyApproach, $hotkeyApproach)
	GUICtrlSetData($GUI_hotkeyOrbit, $hotkeyOrbit)
	GUICtrlSetData($GUI_hotkeyRange, $hotkeyRange)
	GUICtrlSetData($GUI_hotkeyJump, $hotkeyJump)

	Local $arrBotData[68]

	For $i = 0 To $numOfBots - 1 Step 1
		BOT_LogMessage("Configuration account load " & $i, 2)
		$arrBotData[0] = IniRead($filepath, "Bot" & ($i + 1), "login", $GLB_notFoundRecord)
		$arrBotData[1] = IniRead($filepath, "Bot" & ($i + 1), "password", $GLB_notFoundRecord)
		$arrBotData[2] = IniRead($filepath, "Bot" & ($i + 1), "location", $GLB_notFoundRecord)
		$arrBotData[3] = IniRead($filepath, "Bot" & ($i + 1), "state", $GLB_notFoundRecord)
		$arrBotData[4] = IniRead($filepath, "Bot" & ($i + 1), "backOnDamage", $GLB_notFoundRecord)
		$arrBotData[5] = IniRead($filepath, "Bot" & ($i + 1), "highSlots", $GLB_notFoundRecord)
		$arrBotData[6] = IniRead($filepath, "Bot" & ($i + 1), "middleSlots", $GLB_notFoundRecord)
		$arrBotData[7] = IniRead($filepath, "Bot" & ($i + 1), "lowSlots", $GLB_notFoundRecord)
		$arrBotData[8] = IniRead($filepath, "Bot" & ($i + 1), "chatCurrentTab", $GLB_notFoundRecord)
		$arrBotData[9] = IniRead($filepath, "Bot" & ($i + 1), "fullCargo", $GLB_notFoundRecord)
		$arrBotData[10] = IniRead($filepath, "Bot" & ($i + 1), "overviewTab", $GLB_notFoundRecord)
		$arrBotData[11] = IniRead($filepath, "Bot" & ($i + 1), "loginDelay", $GLB_notFoundRecord)
		$arrBotData[12] = IniRead($filepath, "Bot" & ($i + 1), "enableBot", $GLB_notFoundRecord)
		$arrBotData[13] = IniRead($filepath, "Bot" & ($i + 1), "role", $GLB_notFoundRecord)
		$arrBotData[14] = IniRead($filepath, "Bot" & ($i + 1), "schedule", $GLB_notFoundRecord)
		$arrBotData[15] = IniRead($filepath, "Bot" & ($i + 1), "fullContainerCargo", $GLB_notFoundRecord)
		$arrBotData[16] = IniRead($filepath, "Bot" & ($i + 1), "bookmarkMax", $GLB_notFoundRecord)
		$arrBotData[17] = IniRead($filepath, "Bot" & ($i + 1), "bookmarkCurrent", $GLB_notFoundRecord)
		$arrBotData[18] = IniRead($filepath, "Bot" & ($i + 1), "useShields", $GLB_notFoundRecord)
		$arrBotData[19] = IniRead($filepath, "Bot" & ($i + 1), "shieldCritical", $GLB_notFoundRecord)
		$arrBotData[20] = IniRead($filepath, "Bot" & ($i + 1), "shieldActivateOn", $GLB_notFoundRecord)
		$arrBotData[21] = IniRead($filepath, "Bot" & ($i + 1), "shieldMaxTime", $GLB_notFoundRecord)
		$arrBotData[22] = IniRead($filepath, "Bot" & ($i + 1), "useDrones", $GLB_notFoundRecord)
		$arrBotData[23] = IniRead($filepath, "Bot" & ($i + 1), "dronesType", $GLB_notFoundRecord)
		$arrBotData[24] = IniRead($filepath, "Bot" & ($i + 1), "attackNPC", $GLB_notFoundRecord)
		$arrBotData[25] = IniRead($filepath, "Bot" & ($i + 1), "leaveOneItemInCargo", $GLB_notFoundRecord)
		$arrBotData[26] = IniRead($filepath, "Bot" & ($i + 1), "bookmarkVisible", $GLB_notFoundRecord)
		$arrBotData[27] = IniRead($filepath, "Bot" & ($i + 1), "unloadTo", $GLB_notFoundRecord)
		$arrBotData[28] = IniRead($filepath, "Bot" & ($i + 1), "mineAtOnce", $GLB_notFoundRecord)
		$arrBotData[29] = IniRead($filepath, "Bot" & ($i + 1), "lootWrecks", $GLB_notFoundRecord)
		$arrBotData[30] = IniRead($filepath, "Bot" & ($i + 1), "allowFleet", $GLB_notFoundRecord)
		$arrBotData[31] = IniRead($filepath, "Bot" & ($i + 1), "minersReload", $GLB_notFoundRecord)
		$arrBotData[32] = IniRead($filepath, "Bot" & ($i + 1), "waitingTimeout", $GLB_notFoundRecord)
		$arrBotData[33] = IniRead($filepath, "Bot" & ($i + 1), "warpTimeout", $GLB_notFoundRecord)
		$arrBotData[34] = IniRead($filepath, "Bot" & ($i + 1), "cargoTimeout", $GLB_notFoundRecord)
		$arrBotData[35] = IniRead($filepath, "Bot" & ($i + 1), "dronesTimeout", $GLB_notFoundRecord)
		$arrBotData[36] = IniRead($filepath, "Bot" & ($i + 1), "stationTimeout", $GLB_notFoundRecord)
		$arrBotData[37] = IniRead($filepath, "Bot" & ($i + 1), "repairDrones", $GLB_notFoundRecord)
		$arrBotData[38] = IniRead($filepath, "Bot" & ($i + 1), "salvageWrecks", $GLB_notFoundRecord)
		$arrBotData[39] = IniRead($filepath, "Bot" & ($i + 1), "waitDrones", $GLB_notFoundRecord)
		$arrBotData[40] = IniRead($filepath, "Bot" & ($i + 1), "huntingPlace", $GLB_notFoundRecord)
		$arrBotData[41] = IniRead($filepath, "Bot" & ($i + 1), "systemSecurity", $GLB_notFoundRecord)
		$arrBotData[42] = IniRead($filepath, "Bot" & ($i + 1), "systemPOS", $GLB_notFoundRecord)
		$arrBotData[43] = IniRead($filepath, "Bot" & ($i + 1), "lockDistance", $GLB_notFoundRecord)
		$arrBotData[44] = IniRead($filepath, "Bot" & ($i + 1), "miningLimit", $GLB_notFoundRecord)
		$arrBotData[45] = IniRead($filepath, "Bot" & ($i + 1), "lootOnlyFaction", $GLB_notFoundRecord)
		$arrBotData[46] = IniRead($filepath, "Bot" & ($i + 1), "groupID", $GLB_notFoundRecord)
		$arrBotData[47] = IniRead($filepath, "Bot" & ($i + 1), "localChatIconSize", $GLB_notFoundRecord)
		$arrBotData[48] = IniRead($filepath, "Bot" & ($i + 1), "localChatMonitor", $GLB_notFoundRecord)
		$arrBotData[49] = IniRead($filepath, "Bot" & ($i + 1), "localChatMaxAmountOfUsers", $GLB_notFoundRecord)
		$arrBotData[50] = IniRead($filepath, "Bot" & ($i + 1), "NPCtype", $GLB_notFoundRecord)
		$arrBotData[51] = IniRead($filepath, "Bot" & ($i + 1), "bookmarksOrder", $GLB_notFoundRecord)
		$arrBotData[52] = IniRead($filepath, "Bot" & ($i + 1), "fixViewDirection", $GLB_notFoundRecord)
		$arrBotData[53] = IniRead($filepath, "Bot" & ($i + 1), "forceNPCrespawn", $GLB_notFoundRecord)
		$arrBotData[54] = IniRead($filepath, "Bot" & ($i + 1), "scanResolution", $GLB_notFoundRecord)
		$arrBotData[55] = IniRead($filepath, "Bot" & ($i + 1), "anomaliesDelay", $GLB_notFoundRecord)
		$arrBotData[56] = IniRead($filepath, "Bot" & ($i + 1), "anomaliesList", $GLB_notFoundRecord)
		$arrBotData[57] = IniRead($filepath, "Bot" & ($i + 1), "respawnAmount", $GLB_notFoundRecord)
		$arrBotData[58] = IniRead($filepath, "Bot" & ($i + 1), "iceCheckPeriod", $GLB_notFoundRecord)
		$arrBotData[59] = IniRead($filepath, "Bot" & ($i + 1), "oreType", $GLB_notFoundRecord)
		$arrBotData[60] = IniRead($filepath, "Bot" & ($i + 1), "changeMiningCrystals", $GLB_notFoundRecord)
		$arrBotData[61] = IniRead($filepath, "Bot" & ($i + 1), "actionDistance", $GLB_notFoundRecord)
		$arrBotData[62] = IniRead($filepath, "Bot" & ($i + 1), "isSteam", $GLB_notFoundRecord)
		$arrBotData[63] = IniRead($filepath, "Bot" & ($i + 1), "bookmarkType", $GLB_notFoundRecord)
		$arrBotData[64] = IniRead($filepath, "Bot" & ($i + 1), "botScheduleType", $GLB_notFoundRecord)
		$arrBotData[65] = IniRead($filepath, "Bot" & ($i + 1), "botScheduleHours", $GLB_notFoundRecord)
		$arrBotData[66] = IniRead($filepath, "Bot" & ($i + 1), "character", $GLB_notFoundRecord)
		$arrBotData[67] = IniRead($filepath, "Bot" & ($i + 1), "ammoAmount", $GLB_notFoundRecord)

		BOT_LogMessage("Configuration account add " & $i, 2)

		GUI_AddAccount($arrBotData)
		$GLB_numOfBots+= 1
		BOT_LogMessage("Configuration create log " & $i, 2)
		UTL_CreateLog($GLB_numOfBots)
		BOT_LogMessage("Configuration create log " & $i & " - OK", 2)
	Next

	GLB_UpdateOCR()

	GUI_CheckMainMenu()

	BOT_LogMessage("Configuration loaded", 2)
EndFunc

; load OCR config data
Func CONFIG_LoadOCRData($filepath)
	Local $inventory = IniRead($filepath, "Main", "OCRInventoryWindow", $GLB_notFoundRecord)
	Local $chat = IniRead($filepath, "Main", "OCRChatWindow", $GLB_notFoundRecord)
	Local $overview = IniRead($filepath, "Main", "OCROverviewWindow", $GLB_notFoundRecord)
	Local $si = IniRead($filepath, "Main", "OCRSIWindow", $GLB_notFoundRecord)
	Local $scanner = IniRead($filepath, "Main", "OCRScannerWindow", $GLB_notFoundRecord)
	Local $drones= IniRead($filepath, "Main", "OCRDronesWindow", $GLB_notFoundRecord)
	Local $pap = IniRead($filepath, "Main", "OCRPAPWindow", $GLB_notFoundRecord)
	Local $coordinates[2]

	If $inventory <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($inventory, ",")
		GUICtrlSetData($GUI_OCRInventoryX, $coordinates[0])
		GUICtrlSetData($GUI_OCRInventoryY, $coordinates[1])
	EndIf

	If $chat <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($chat, ",")
		GUICtrlSetData($GUI_OCRChatX, $coordinates[0])
		GUICtrlSetData($GUI_OCRChatY, $coordinates[1])
	EndIf

	If $overview <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($overview, ",")
		GUICtrlSetData($GUI_OCROverviewX, $coordinates[0])
		GUICtrlSetData($GUI_OCROverviewY, $coordinates[1])
	EndIf

	If $si <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($si, ",")
		GUICtrlSetData($GUI_OCRSIX, $coordinates[0])
		GUICtrlSetData($GUI_OCRSIY, $coordinates[1])
	EndIf

	If $scanner <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($scanner, ",")
		GUICtrlSetData($GUI_OCRScannerX, $coordinates[0])
		GUICtrlSetData($GUI_OCRScannerY, $coordinates[1])
	EndIf

	If $drones <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($drones, ",")
		GUICtrlSetData($GUI_OCRDronesX, $coordinates[0])
		GUICtrlSetData($GUI_OCRDronesY, $coordinates[1])
	EndIf

	If $pap <> $GLB_notFoundRecord Then
		$coordinates = _StringExplode($pap, ",")
		GUICtrlSetData($GUI_OCRPAPX, $coordinates[0])
		GUICtrlSetData($GUI_OCRPAPY, $coordinates[1])
	EndIf
EndFunc

; reset config
Func CONFIG_ResetConfig()
	GUICtrlSetData($GUI_numOfBotsInput, "0")

	For $i = $GLB_numOfBots - 1 To 0 Step -1
		GUI_RemoveAccount($i)
	Next

	$GLB_numOfBots = 0
	GUICtrlSetState($GUI_startButton, $GUI_DISABLE)
EndFunc