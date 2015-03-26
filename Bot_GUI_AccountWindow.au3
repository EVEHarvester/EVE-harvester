Global $GLB_accountWindowSize[2] = [605, 680]

Global $GUI_accountWindow

;login data arrays
Global $GUI_login[1]
Global $GUI_password[1]
Global $GUI_character[1]
Global $GUI_roles = "Hunter|Belt Miner|Anomaly Miner|Marauder|Courier|Watcher";"Miner|Fleet Miner|Fleet Commander|Transporter"
Global $GUI_loadingCounter[1]
;location arrays
Global $GUI_locationCombo[1]
Global $GUI_allLocations = "login|info|ingame|station|space|belt|anomaly|spot|pos"
;state arrays
Global $GUI_stateCombo[1]
Global $GUI_allStates = "mining|warpWaiting|warping|unloading|container|ammo|npcWaiting|npc|wreck|wreckTractoring|scan|scanned|drones|dronesReturn|joinCommander|commanding|next|error|waiting|delay|closeAndWait|connectionWaiting|noStorage|skip|flying"
;run away on damage checkbox array
Global $GUI_runOnDamageCheckbox[1]
;use shields
Global $GUI_useShieldsCheckbox[1]
;high slot array
Global $GUI_slotHigh[1][8]
;middle slot array
Global $GUI_slotMiddle[1][8]
;low slot array
Global $GUI_slotLow[1][8]
;cargo
Global $GUI_cargo[1]
;full cargo
Global $GUI_fullCargo[1]
;current tabs
Global $GUI_OverviewCurrentTabCombo[1]
Global $GUI_ChatCurrentTabCombo[1]
;login delay
Global $GUI_LaunghDelay[1]
;cargo unload to
Global $GUI_UnloadToCombo[1]
;last action timestamp
Global $GUI_lastActionTS[1]
;window hwnd
Global $GUI_windowHWND[1]
Global $GUI_buttonSetHWND[1]
;enable bot
Global $GUI_enableBot[1]
;is account steam
Global $GUI_isSteam[1]
;bot role
Global $GUI_botRole[1]
;container cargo
Global $GUI_containerCargo[1]
;full container cargo
Global $GUI_fullContainerCargo[1]
;skiped containers
Global $GUI_skipedContainers[1]
;max bookmark
Global $GUI_bookmarkMax[1]
;current bookmark
Global $GUI_bookmarkType[1]
Global $GUI_bokmarkCurrent[1]
Global $GUI_BookmarksList[1]
Global $GUI_BookmarkItem[1]
Global $GUI_buttonBookmarkAdd[1]
Global $GUI_buttonBookmarkRemove[1]
;visible bookmarks
Global $GUI_bookmarkVisible[1]
;current shield
Global $GUI_shieldCurrent[1]
;activate shield
Global $GUI_shieldActivateOn[1]
;critical shield
Global $GUI_shieldCritical[1]
;shield maxactive time
Global $GUI_shieldMaxActiveTime[1]
;shield activated timestamp
Global $GUI_shieldActivatedTS[1]
; use drones
Global $GUI_useDrones[1]
; repair drones
Global $GUI_repairDrones[1]
; repair drones
Global $GUI_waitDrones[1]
; drones type
Global $GUI_dronesType[1]
Global $GUI_forceNPCrespawn[1]
; on drone return action
Global $GUI_dronesOnReturn[1]
; attack NPC
Global $GUI_attackNPCCheckbox[1]
Global $GUI_respawnAmount[1]
Global $GUI_killAllNPCinCurrentBelt[1]
Global $GUI_huntingPlace[1]
Global $GUI_anomaliesDelay[1]
Global $GUI_anomaliesList[1]
Global $GUI_ammoAmountInput[1]
; loot wrecks
Global $GUI_lootWrecksCheckbox[1]
; salvage wrecks
Global $GUI_salvageWrecksCheckbox[1]
; allow fleet
Global $GUI_acceptUnknownFleet[1]
;system security
Global $GUI_systemSecurity[1]
;POS settings
Global $GUI_systemPOS[1]
Global $GUI_lootOnlyFaction[1]
Global $GUI_factionType[1]
Global $GUI_fixView[1]
; leave one item in cargo
Global $GUI_leaveOneItemInCargoCheckbox[1]
; mine at once asteroids amount
Global $GUI_mineAtOnce[1]
; miners reload timeout
Global $GUI_minersReload[1]
Global $GUI_minersReloadTS[1]
;lock distance
Global $GUI_lockDistance[1]
Global $GUI_actionDistance[1]
Global $GUI_scanResolution[1]
Global $GUI_iceCheckPeriod[1]
Global $GUI_oreType[1]
Global $GUI_changeMiningCrystals[1]
;mining limits
Global $GUI_miningLimit[1]
Global $GUI_groupID[1]
;local tweak
Global $GUI_localChatIconSize[1]
Global $GUI_localChatMonitor[1]
Global $GUI_localChatMaxAmountOfUsers[1]
Global $GUI_botSchedule[1]
Global $GUI_botScheduleType[1]
Global $GUI_botScheduleHours[1]
Global $GUI_generateSchedule[1]

;timeouts
Global $GUI_timeoutWaiting[1]
Global $GUI_timeoutWaitingDefault[1]
Global $GUI_timeoutWarp[1]
Global $GUI_timeoutWarpDefault[1]
Global $GUI_timeoutWarpWaiting = 0
Global $GUI_timeoutWarpWaitingDefault = 50 ; sec
Global $GUI_timeoutWarpWaitingTry = 0
Global $GUI_timeoutCargo[1]
Global $GUI_timeoutCargoDefault[1]
Global $GUI_timeoutDrones[1]
Global $GUI_timeoutDronesDefault[1]
Global $GUI_timeoutStation[1]
Global $GUI_timeoutStationDefault[1]
Global $GUI_timeoutTractoring[1]
Global $GUI_timeoutTractoringDefault[1]

; create account GUI
Func GUI_CreateAccountWindow()
	$GUI_accountWindow = GUICreate("Account", $GLB_accountWindowSize[0], $GLB_accountWindowSize[1], Int($GLB_appSize[0]/2))

	; set window events
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_CloseAccountWindow")

	; GUI MESSAGE LOOP
	GUISetState(@SW_HIDE)
EndFunc

;close account window
Func GUI_CloseAccountWindow()
	If $GLB_numOfBots >= ($GUI_lastOpenedUser + 1) Then
		_GUICtrlListBox_ReplaceString($GUI_usersList, $GUI_lastOpenedUser, ($GUI_lastOpenedUser + 1) & "." & GUICtrlRead($GUI_login[$GUI_lastOpenedUser]))
	EndIf
	GUISetState(@SW_HIDE, $GUI_accountWindow)
EndFunc

; add account proxy for gui button
Func GUI_AddAccountCaller()
	Local $newIndex = GUI_AddAccount()
	$GLB_numOfBots+= 1
	UTL_CreateLog($GLB_numOfBots)
	GUI_EditAccount($newIndex)
	$GUI_lastOpenedUser = $newIndex
	GUISetState(@SW_SHOW, $GUI_accountWindow)
EndFunc

; create account
Func GUI_AddAccount($arrBotData = False)
	Local $login = ""
	Local $pass = ""
	Local $location = "closed"
	Local $state = "free"
	Local $onDamage = $GUI_CHECKED
	Local $slotDefaultHigh[8]
	Local $slotDefaultMiddle[8]
	Local $slotDefaultLow[8]
	Local $cargo = "0"
	Local $fullCargo = "70"
	Local $loadingCounter = "0"
	Local $overviewTab = "unknown"
	Local $chatCurrentTab = "unknown"
	Local $launghDelay = "0"
	Local $cargoWaitCurrent = "0"
	Local $windowHWND = ""
	Local $enableBot = $GUI_CHECKED
	Local $botRole = "Hunter"
	Local $fullContainerCargo = "90"
	Local $maxBookmark = "0"
	Local $curBookmark = "0"
	Local $useShields = $GUI_UNCHECKED
	Local $shieldCurrent = "100"
	Local $shieldActivateOn = "40"
	Local $shieldCritical = "10"
	Local $shieldMaxActiveTime = "30"
	Local $shieldMaxActiveTime = "30"
	Local $useDrones = $GUI_UNCHECKED
	Local $dronesType = "Combat"
	Local $attackNPC = $GUI_UNCHECKED
	Local $leaveOneItemInCargo = $GUI_UNCHECKED
	Local $visibleBookmark = "7"
	Local $unloadTo = "Items"
	Local $mineAtOnce = "1"
	Local $lootWrecks = $GUI_UNCHECKED
	Local $allowFleet = "No"
	Local $minersReload = "No"
	Local $defaultWaitingTimeout = "5"
	Local $defaultWarpTimeout = "5"
	Local $defaultCargoTimeout = "15"
	Local $defaultDronesTimeout = "5"
	Local $defaulStationTimeout = "5"
	Local $repairDrones = $GUI_UNCHECKED
	Local $salvageWrecks = $GUI_UNCHECKED
	Local $waitDrones = $GUI_UNCHECKED
	Local $systemSecurity = "High"
	Local $systemPOS = "Station"
	Local $lockDistance = "10"
	Local $miningLimit = "30"
	Local $lootOnlyFaction = $GUI_UNCHECKED
	Local $groupID = "0"
	Local $localChatIconSize = "Small"
	Local $localChatMonitor = False
	Local $localChatMaxAmountOfUsers = $GLB_localChatMaxUsersAmountBig
	Local $NPCtype = "Angels"
	Local $bookmarksOrderDefault = True
	Local $fixViewDirection = "down"
	Local $schedule = "12:00-15:00,18:00-19:00"
	Local $forceNPCrespawn = "No"
	Local $huntingPlace = "Belt"
	Local $scanResolution = "120"
	Local $anomaliesDelay = "0"
	Local $anomaliesList = ""
	Local $respawnAmount = "3"
	Local $iceCheckPeriod = "10"
	Local $oreType = "all"
	Local $changeMiningCrystals = "No"
	Local $actionDistance = "15"
	Local $isSteam = False
	Local $bookmarkType = "Personal"
	Local $botScheduleType = "Manual"
	Local $botScheduleHours = "12"
	Local $character = "1"
	Local $ammoAmount = "5000"

	For $s = 0 To 7 Step 1
		$slotDefaultHigh[$s] = "empty"
		$slotDefaultMiddle[$s] = "empty"
		$slotDefaultLow[$s] = "empty"
	Next

	If $arrBotData <> False Then
		$login = $arrBotData[0]
		$pass = $arrBotData[1]
		$location = $arrBotData[2]
		$state = $arrBotData[3]
		$onDamage = $arrBotData[4]

		If $onDamage = "True" Then
			$onDamage = $GUI_CHECKED
		Else
			$onDamage = $GUI_UNCHECKED
		EndIf

		Local $tempSH = StringSplit($arrBotData[5], ".")
		Local $tempSM = StringSplit($arrBotData[6], ".")
		Local $tempSL = StringSplit($arrBotData[7], ".")

		For $s = 0 To 7 Step 1
			$slotDefaultHigh[$s] = $tempSH[$s + 1]
			$slotDefaultMiddle[$s] = $tempSM[$s + 1]
			$slotDefaultLow[$s] = $tempSL[$s + 1]
		Next

		$chatCurrentTab = $arrBotData[8]
		$fullCargo = $arrBotData[9]
		$overviewTab = $arrBotData[10]
		$launghDelay = $arrBotData[11]
		$enableBot = $arrBotData[12]

		If $enableBot = "True" Then
			$enableBot = $GUI_CHECKED
		Else
			$enableBot = $GUI_UNCHECKED
		EndIf

		$botRole = $arrBotData[13]
		$schedule = $arrBotData[14]
		$fullContainerCargo = $arrBotData[15]
		$maxBookmark = $arrBotData[16]
		$curBookmark = $arrBotData[17]
		$useShields = $arrBotData[18]

		If $useShields = "True" Then
			$useShields = $GUI_CHECKED
		Else
			$useShields = $GUI_UNCHECKED
		EndIf

		$shieldCritical = $arrBotData[19]
		$shieldActivateOn = $arrBotData[20]
		$shieldMaxActiveTime = $arrBotData[21]

		$useDrones = $arrBotData[22]
		If $useDrones = "True" Then
			$useDrones = $GUI_CHECKED
		Else
			$useDrones = $GUI_UNCHECKED
		EndIf
		$dronesType = $arrBotData[23]

		$attackNPC = $arrBotData[24]
		If $attackNPC = "True" Then
			$attackNPC = $GUI_CHECKED
		Else
			$attackNPC = $GUI_UNCHECKED
		EndIf

		$leaveOneItemInCargo = $arrBotData[25]
		If $leaveOneItemInCargo = "True" Then
			$leaveOneItemInCargo = $GUI_CHECKED
		Else
			$leaveOneItemInCargo = $GUI_UNCHECKED
		EndIf

		$visibleBookmark = $arrBotData[26]
		$unloadTo = $arrBotData[27]
		$mineAtOnce = $arrBotData[28]

		$lootWrecks = $arrBotData[29]
		If $lootWrecks = "True" Then
			$lootWrecks = $GUI_CHECKED
		Else
			$lootWrecks = $GUI_UNCHECKED
		EndIf

		$allowFleet = $arrBotData[30]
		$minersReload = $arrBotData[31]

		$defaultWaitingTimeout = $arrBotData[32]
		$defaultWarpTimeout = $arrBotData[33]
		$defaultCargoTimeout = $arrBotData[34]
		$defaultDronesTimeout = $arrBotData[35]
		$defaulStationTimeout = $arrBotData[36]

		$repairDrones = $arrBotData[37]
		If $repairDrones = "True" Then
			$repairDrones = $GUI_CHECKED
		Else
			$repairDrones = $GUI_UNCHECKED
		EndIf

		$salvageWrecks = $arrBotData[38]
		If $salvageWrecks = "True" Then
			$salvageWrecks = $GUI_CHECKED
		Else
			$salvageWrecks = $GUI_UNCHECKED
		EndIf

		$waitDrones = $arrBotData[39]
		If $waitDrones = "True" Then
			$waitDrones = $GUI_CHECKED
		Else
			$waitDrones = $GUI_UNCHECKED
		EndIf

		$huntingPlace = $arrBotData[40]

		$systemSecurity = $arrBotData[41]
		$systemPOS = $arrBotData[42]
		$lockDistance = $arrBotData[43]
		$miningLimit = $arrBotData[44]

		$lootOnlyFaction = $arrBotData[45]
		If $lootOnlyFaction = "True" Then
			$lootOnlyFaction = $GUI_CHECKED
		Else
			$lootOnlyFaction = $GUI_UNCHECKED
		EndIf

		$groupID = $arrBotData[46]

		$localChatIconSize = $arrBotData[47]

		$localChatMonitor = $arrBotData[48]
		If $localChatMonitor = "True" Then
			$localChatMonitor = $GUI_CHECKED
		Else
			$localChatMonitor = $GUI_UNCHECKED
		EndIf

		$localChatMaxAmountOfUsers = $arrBotData[49]

		$NPCtype = $arrBotData[50]

		; parse bookmarks
		If $arrBotData[51] <> "notFound" Then
			Local $tempBO = StringSplit($arrBotData[51], ".")
			$bookmarksOrderDefault = False
		EndIf

		$fixViewDirection = $arrBotData[52]
		$forceNPCrespawn = $arrBotData[53]
		$scanResolution = $arrBotData[54]
		$anomaliesDelay = $arrBotData[55]
		$anomaliesList = $arrBotData[56]
		$respawnAmount = $arrBotData[57]
		$iceCheckPeriod = $arrBotData[58]
		$oreType = $arrBotData[59]
		$changeMiningCrystals = $arrBotData[60]

		$actionDistance = $arrBotData[61]

		$isSteam = $arrBotData[62]
		If $isSteam = "True" Then
			$isSteam = $GUI_CHECKED
		Else
			$isSteam = $GUI_UNCHECKED
		EndIf

		$bookmarkType = $arrBotData[63]

		$botScheduleType = $arrBotData[64]
		$botScheduleHours = $arrBotData[65]

		$character = $arrBotData[66]
		$ammoAmount = $arrBotData[67]
	EndIf

	Local $i = $GLB_numOfBots

	; window title
	_ArrayInsert ($WIN_titles, $i, -1)

	_ArrayInsert ($UTL_lastLogRecord, $i, "*|*")

	STA_InitBotData($i)

	_ArrayInsert ($GUI_miningAsteroidNumber, $i)

	_ArrayInsert ($GUI_DATA_LoginErrors, $i, 0)

	_ArrayInsert ($GUI_minersReloadTS, $i)
	_ArrayInsert ($GLB_lastReactivatedSlot, $i, 3)

	;timeouts timestamps
	_ArrayInsert ($GUI_waitingStartTS, $i)
	_ArrayInsert ($GUI_warpStartTS, $i)
	_ArrayInsert ($GUI_cargoStartTS, $i)
	_ArrayInsert ($GUI_dronesStartTS, $i)
	_ArrayInsert ($GUI_stationStartTS, $i)
	_ArrayInsert ($GUI_tractoringStartTS, $i)
	_ArrayInsert ($GUI_warpDetected, $i)

	; bot wait timestamp
	_ArrayInsert ($GLB_needWait, $i)
	_ArrayInsert ($GUI_killAllNPCinCurrentBelt, $i, False)

	_ArrayInsert ($GLB_downtimeSet, $i, False)
	_ArrayInsert ($GLB_scheduleSet, $i, False)

	; bot need to stay in station
	_ArrayInsert ($GLB_stayInStation, $i, 0)

	_ArrayInsert ($GLB_forcedUnload, $i, 0)
	_ArrayInsert ($GLB_allBeltsDone, $i, 0)

	_ArrayInsert ($AnomalyMiner_lastOreAnomalyPosition, $i, -1)
	_ArrayInsert ($GLB_lastCrystalReloadTime, $i, 0)

	GUICtrlSetData($GUI_usersList, ($i + 1) & "." & $login)

	GUISwitch($GUI_accountWindow)

	$GUI_usersPage[$i] = GUICtrlCreateGroup ("", 5, 0, $GLB_accountWindowSize[0] - 10, $GLB_accountWindowSize[1] - 5)

	; general group
	Local $generalGroup[2] = [10, 10]
	GUICtrlCreateGroup ("General", $generalGroup[0], $generalGroup[1], 450, 160)
		; login
		_ArrayInsert ($GUI_login, $i)
		GUICtrlCreateLabel("Login:", $generalGroup[0] + 10, $generalGroup[1] + 15)
		$GUI_login[$i] = GUICtrlCreateInput ($login, $generalGroup[0] + 10, $generalGroup[1] + 30, 100, 20)

		; password
		_ArrayInsert ($GUI_password, $i)
		GUICtrlCreateLabel("Password:", $generalGroup[0] + 10, $generalGroup[1] + 55)
		$GUI_password[$i] = GUICtrlCreateInput ($pass, $generalGroup[0] + 10, $generalGroup[1] + 70, 100, 20, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
		GUICtrlSetLimit($GUI_password[$i], 20)

		; role selector
		_ArrayInsert ($GUI_botRole, $i)
		GUICtrlCreateLabel("Role:", $generalGroup[0] + 10, $generalGroup[1] + 95)
		$GUI_botRole[$i] = GUICtrlCreateCombo ("Hunter", $generalGroup[0] + 10, $generalGroup[1] + 110, 100, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_botRole[$i], $GUI_roles, $botRole)
		GUICtrlSetOnEvent($GUI_botRole[$i], "GUI_onRoleSelect")

		; character selector
		_ArrayInsert ($GUI_character, $i)
		GUICtrlCreateLabel("Character:", $generalGroup[0] + 60, $generalGroup[1] + 140)
		$GUI_character[$i] = GUICtrlCreateCombo ("1", $generalGroup[0] + 115, $generalGroup[1] + 135, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_character[$i], "2|3", $character)

		; location selector
		_ArrayInsert ($GUI_locationCombo, $i)
		GUICtrlCreateLabel("Location:", $generalGroup[0] + 115, $generalGroup[1] + 15)
		$GUI_locationCombo[$i] = GUICtrlCreateCombo ("closed", $generalGroup[0] + 115, $generalGroup[1] + 30, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_locationCombo[$i], $GUI_allLocations, $location)

		; state selector
		_ArrayInsert ($GUI_stateCombo, $i)
		GUICtrlCreateLabel("State:", $generalGroup[0] + 115, $generalGroup[1] + 55)
		$GUI_stateCombo[$i] = GUICtrlCreateCombo ("free", $generalGroup[0] + 115, $generalGroup[1] + 70, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_stateCombo[$i], $GUI_allStates, $state)

		; Group ID
		_ArrayInsert ($GUI_groupID, $i)
		GUICtrlCreateLabel("Group ID:", $generalGroup[0] + 115, $generalGroup[1] + 95)
		$GUI_groupID[$i] = GUICtrlCreateInput ($groupID, $generalGroup[0] + 115, $generalGroup[1] + 110, 75)


		;laungh delay
		_ArrayInsert ($GUI_LaunghDelay, $i)
		GUICtrlCreateLabel("Delay(min):", $generalGroup[0] + 195, $generalGroup[1] + 15)
		$GUI_LaunghDelay[$i] = GUICtrlCreateInput ($launghDelay, $generalGroup[0] + 195, $generalGroup[1] + 30, 75)

		; overview tab
		_ArrayInsert ($GUI_OverviewCurrentTabCombo, $i)
		GUICtrlCreateLabel("Overview tab:", $generalGroup[0] + 195, $generalGroup[1] + 55)
		$GUI_OverviewCurrentTabCombo[$i] = GUICtrlCreateCombo ("unknown", $generalGroup[0] + 195, $generalGroup[1] + 70, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_OverviewCurrentTabCombo[$i], "default|asteroids|containers|npc|drones", $overviewTab)

		; chat tab
		_ArrayInsert ($GUI_ChatCurrentTabCombo, $i)
		GUICtrlCreateLabel("Chat tab:", $generalGroup[0] + 195, $generalGroup[1] + 95)
		$GUI_ChatCurrentTabCombo[$i] = GUICtrlCreateCombo ("unknown", $generalGroup[0] + 195, $generalGroup[1] + 110, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_ChatCurrentTabCombo[$i], "local|corp", $chatCurrentTab)


		; system security
		_ArrayInsert ($GUI_systemSecurity, $i)
		GUICtrlCreateLabel("System security:", $generalGroup[0] + 275, $generalGroup[1] + 15)
		$GUI_systemSecurity[$i] = GUICtrlCreateCombo ("High", $generalGroup[0] + 275, $generalGroup[1] + 30, 80, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_systemSecurity[$i], "Low", $systemSecurity)

		; Base
		_ArrayInsert ($GUI_systemPOS, $i)
		GUICtrlCreateLabel("Base:", $generalGroup[0] + 275, $generalGroup[1] + 55)
		$GUI_systemPOS[$i] = GUICtrlCreateCombo ("Station", $generalGroup[0] + 275, $generalGroup[1] + 70, 80, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_systemPOS[$i], "Station and POS|POS|None", $systemPOS)

		; rotate view
		_ArrayInsert ($GUI_fixView, $i)
		GUICtrlCreateLabel("Rotate view:", $generalGroup[0] + 275, $generalGroup[1] + 95)
		$GUI_fixView[$i] = GUICtrlCreateCombo ("up", $generalGroup[0] + 275, $generalGroup[1] + 110, 80, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_fixView[$i], "down", $fixViewDirection)


		; enable bot
		_ArrayInsert ($GUI_enableBot, $i)
		$GUI_enableBot[$i] = GUICtrlCreateCheckbox("enabled", $generalGroup[0] + 360, 20)
		GUICtrlSetState($GUI_enableBot[$i], $enableBot)
		GUICtrlSetOnEvent($GUI_enableBot[$i], "GUI_CheckBotEnable")

		; enable bot
		_ArrayInsert ($GUI_isSteam, $i)
		$GUI_isSteam[$i] = GUICtrlCreateCheckbox("steam", $generalGroup[0] + 360, 40)
		GUICtrlSetState($GUI_isSteam[$i], $isSteam)

		; allow fleet
		_ArrayInsert ($GUI_acceptUnknownFleet, $i)
		GUICtrlCreateLabel("Allow fleet:", $generalGroup[0] + 360, $generalGroup[1] + 55)
		$GUI_acceptUnknownFleet[$i] = GUICtrlCreateCombo ("Yes", $generalGroup[0] + 360, $generalGroup[1] + 70, 80, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_acceptUnknownFleet[$i], "No|SameBotOnly", $allowFleet)

		;window HWND
		_ArrayInsert ($GUI_windowHWND, $i)
		GUICtrlCreateLabel("Window:", $generalGroup[0] + 360, $generalGroup[1] + 95)
		$GUI_windowHWND[$i] = GUICtrlCreateInput ($windowHWND, $generalGroup[0] + 360, $generalGroup[1] + 110, 80, 20)
		GUICtrlSetState($GUI_windowHWND[$i], $GUI_DISABLE)

		_ArrayInsert ($GUI_buttonSetHWND, $i)
		$GUI_buttonSetHWND[$i] = GUICtrlCreateButton ("set", $generalGroup[0] + 405, $generalGroup[1] + 95, 35, 15)
		GUICtrlSetOnEvent($GUI_buttonSetHWND[$i], "GUI_SetBotWindow")
		GUICtrlSetTip($GUI_buttonSetHWND[$i], "set bot window. click, activate client window and wait 10 seconds")

		; leave one item in cargo
		_ArrayInsert ($GUI_leaveOneItemInCargoCheckbox, $i)
		$GUI_leaveOneItemInCargoCheckbox[$i] = GUICtrlCreateCheckbox("leave one item in cargo", $generalGroup[0] + 275, $generalGroup[1] + 135)
		GUICtrlSetState($GUI_leaveOneItemInCargoCheckbox[$i], $leaveOneItemInCargo)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; bookmarks group
	Local $bookmarksGroup[2] = [460, 10]
	GUICtrlCreateGroup ("Bookmarks", $bookmarksGroup[0], $bookmarksGroup[1], 135, 160)
		; bookmarks order
		_ArrayInsert ($GUI_BookmarksList, $i)
		GUICtrlCreateLabel("Order:", $bookmarksGroup[0] + 5, $bookmarksGroup[1] + 35)
		$GUI_BookmarksList[$i] = GUICtrlCreateList("", $bookmarksGroup[0] + 5, $bookmarksGroup[1] + 50, 80, 55, BitOR($LBS_DISABLENOSCROLL, $WS_VSCROLL))
		GUICtrlSetLimit(-1, 200) ; to limit horizontal scrolling

		If $bookmarksOrderDefault Then
			_GUICtrlListBox_AddString($GUI_BookmarksList[$i], "Station")
			_GUICtrlListBox_AddString($GUI_BookmarksList[$i], "Belts")
		Else
			For $o = 0 To $tempBO[0] - 1 Step 1
				_GUICtrlListBox_AddString($GUI_BookmarksList[$i], $tempBO[$o + 1])
			Next
		EndIf

		_ArrayInsert ($GUI_BookmarkItem, $i)
		$GUI_BookmarkItem[$i] = GUICtrlCreateCombo ("Station", $bookmarksGroup[0] + 5, $bookmarksGroup[1] + 100, 80, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_BookmarkItem[$i], "POS|Spot|Destination", "Spot")

		_ArrayInsert ($GUI_buttonBookmarkAdd, $i)
		$GUI_buttonBookmarkAdd[$i] = GUICtrlCreateButton ("add", $bookmarksGroup[0] + 5, $bookmarksGroup[1] + 125, 30, 25)
		GUICtrlSetOnEvent($GUI_buttonBookmarkAdd[$i], "GUI_BookmarkAdd")
		GUICtrlSetTip($GUI_buttonBookmarkAdd[$i], "add bookmark item to current position")

		_ArrayInsert ($GUI_buttonBookmarkRemove, $i)
		$GUI_buttonBookmarkRemove[$i] = GUICtrlCreateButton ("remove", $bookmarksGroup[0] + 35, $bookmarksGroup[1] + 125, 50, 25)
		GUICtrlSetOnEvent($GUI_buttonBookmarkRemove[$i], "GUI_BookmarkRemove")
		GUICtrlSetTip($GUI_buttonBookmarkRemove[$i], "remove bookmark item to current position")

		; current bookmark
		_ArrayInsert ($GUI_bokmarkCurrent, $i)
		GUICtrlCreateLabel("Current:", $bookmarksGroup[0] + 90, $bookmarksGroup[1] + 35)
		$GUI_bokmarkCurrent[$i] = GUICtrlCreateInput ($curBookmark, $bookmarksGroup[0] + 90, $bookmarksGroup[1] + 50, 40, 20, $ES_NUMBER)

		; bookmarks amount
		_ArrayInsert ($GUI_bookmarkMax, $i)
		GUICtrlCreateLabel("All:", $bookmarksGroup[0] + 90, $bookmarksGroup[1] + 75)
		$GUI_bookmarkMax[$i] = GUICtrlCreateInput ($maxBookmark, $bookmarksGroup[0] + 90, $bookmarksGroup[1] + 90, 40, 20, $ES_NUMBER)

		; bookmarks visible in PAP window
		_ArrayInsert ($GUI_bookmarkVisible, $i)
		GUICtrlCreateLabel("Visible:", $bookmarksGroup[0] + 90, $bookmarksGroup[1] + 115)
		$GUI_bookmarkVisible[$i] = GUICtrlCreateInput ($visibleBookmark, $bookmarksGroup[0] + 90, $bookmarksGroup[1] + 130, 40, 20, $ES_NUMBER)

		; bookmark placeholder type
		_ArrayInsert ($GUI_bookmarkType, $i)
		GUICtrlCreateLabel("Type:", $bookmarksGroup[0] + 5, $bookmarksGroup[1] + 15)
		$GUI_bookmarkType[$i] = GUICtrlCreateCombo ("Personal", $bookmarksGroup[0] + 45, $bookmarksGroup[1] + 15, 80, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_bookmarkType[$i], "Corporation", $bookmarkType)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; local group
	Local $localGroup[2] = [10, 165]
	GUICtrlCreateGroup ("Local chat", $localGroup[0], $localGroup[1], 90, 140)
		; monitor local
		_ArrayInsert ($GUI_localChatMonitor, $i)
		$GUI_localChatMonitor[$i] = GUICtrlCreateCheckbox("monitor local", $localGroup[0] + 5, $localGroup[1] + 15)
		GUICtrlSetState($GUI_localChatMonitor[$i], $localChatMonitor)

		; local record size
		_ArrayInsert ($GUI_localChatIconSize, $i)
		GUICtrlCreateLabel("User size:", $localGroup[0] + 5, $localGroup[1] + 40)
		$GUI_localChatIconSize[$i] = GUICtrlCreateCombo ("Small", $localGroup[0] + 5, $localGroup[1] + 55, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_localChatIconSize[$i], "Big", $localChatIconSize)

		; max amount of users
		_ArrayInsert ($GUI_localChatMaxAmountOfUsers, $i)
		GUICtrlCreateLabel("Amount of users:", $localGroup[0] + 5, $localGroup[1] + 80)
		$GUI_localChatMaxAmountOfUsers[$i] = GUICtrlCreateInput ($localChatMaxAmountOfUsers, $localGroup[0] + 5, $localGroup[1] + 95, 75, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; shield group
	Local $shieldGroup[2] = [100, 165]
	GUICtrlCreateGroup ("Shield", $shieldGroup[0], $shieldGroup[1], 165, 140)
		; use shields
		_ArrayInsert ($GUI_useShieldsCheckbox, $i)
		$GUI_useShieldsCheckbox[$i] = GUICtrlCreateCheckbox("use shields", $shieldGroup[0] + 5, $shieldGroup[1] + 15)
		GUICtrlSetState($GUI_useShieldsCheckbox[$i], $useShields)

		; critical shield
		_ArrayInsert ($GUI_shieldCritical, $i)
		GUICtrlCreateLabel("Critical(%):", $shieldGroup[0] + 5, $shieldGroup[1] + 35)
		$GUI_shieldCritical[$i] = GUICtrlCreateInput ($shieldCritical, $shieldGroup[0] + 5, $shieldGroup[1] + 50, 75, 20, $ES_NUMBER)

		; activate shield on
		_ArrayInsert ($GUI_shieldActivateOn, $i)
		GUICtrlCreateLabel("Activate on(%):", $shieldGroup[0] + 5, $shieldGroup[1] + 75)
		$GUI_shieldActivateOn[$i] = GUICtrlCreateInput ($shieldActivateOn, $shieldGroup[0] + 5, $shieldGroup[1] + 90, 75, 20, $ES_NUMBER)

		; current shield
		_ArrayInsert ($GUI_shieldCurrent, $i)
		GUICtrlCreateLabel("Current(%):", $shieldGroup[0] + 85, $shieldGroup[1] + 15)
		$GUI_shieldCurrent[$i] = GUICtrlCreateInput ($shieldCurrent, $shieldGroup[0] + 85, $shieldGroup[1] + 30, 75)

		; shield max time
		_ArrayInsert ($GUI_shieldMaxActiveTime, $i)
		GUICtrlCreateLabel("Duration(sec):", $shieldGroup[0] + 85, $shieldGroup[1] + 55)
		$GUI_shieldMaxActiveTime[$i] = GUICtrlCreateInput ($shieldMaxActiveTime, $shieldGroup[0] + 85, $shieldGroup[1] + 70, 75, 20, $ES_NUMBER)

		; back on critical damage
		_ArrayInsert ($GUI_runOnDamageCheckbox, $i)
		$GUI_runOnDamageCheckbox[$i] = GUICtrlCreateCheckbox("run on critical", $shieldGroup[0] + 5, $shieldGroup[1] + 110)
		GUICtrlSetState($GUI_runOnDamageCheckbox[$i], $onDamage)

		; shield activated timestamp
		_ArrayInsert ($GUI_shieldActivatedTS, $i)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; cargo group
	Local $cargoGroup[2] = [265, 165]
	GUICtrlCreateGroup ("Ship cargo", $cargoGroup[0], $cargoGroup[1], 85, 140)
		; current cargo
		_ArrayInsert ($GUI_cargo, $i)
		GUICtrlCreateLabel("Current(%):", $cargoGroup[0] + 5, $cargoGroup[1] + 15)
		$GUI_cargo[$i] = GUICtrlCreateInput ($cargo, $cargoGroup[0] + 5, $cargoGroup[1] + 30, 75)
		GUICtrlSetState($GUI_cargo[$i], $GUI_DISABLE)

		; max cargo
		_ArrayInsert ($GUI_fullCargo, $i)
		GUICtrlCreateLabel("Max cargo(%):", $cargoGroup[0] + 5, $cargoGroup[1] + 55)
		$GUI_fullCargo[$i] = GUICtrlCreateInput ($fullCargo, $cargoGroup[0] + 5, $cargoGroup[1] + 70, 75, 20, $ES_NUMBER)

		; unload to
		_ArrayInsert ($GUI_UnloadToCombo, $i)
		GUICtrlCreateLabel("Unload to:", $cargoGroup[0] + 5, $cargoGroup[1] + 95)
		$GUI_UnloadToCombo[$i] = GUICtrlCreateCombo ("Items", $cargoGroup[0] + 5, $cargoGroup[1] + 110, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_UnloadToCombo[$i], "CorpHangar|POS", $unloadTo)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; drones group
	Local $dronesGroup[2] = [350, 165]
	GUICtrlCreateGroup ("Drones", $dronesGroup[0], $dronesGroup[1], 90, 140)
		; use drones
		_ArrayInsert ($GUI_useDrones, $i)
		$GUI_useDrones[$i] = GUICtrlCreateCheckbox("use drones", $dronesGroup[0] + 5, $dronesGroup[1] + 15)
		GUICtrlSetState($GUI_useDrones[$i], $useDrones)

		; repair drones
		_ArrayInsert ($GUI_repairDrones, $i)
		$GUI_repairDrones[$i] = GUICtrlCreateCheckbox("repair", $dronesGroup[0] + 5, $dronesGroup[1] + 35)
		GUICtrlSetState($GUI_repairDrones[$i], $repairDrones)

		; wait drones
		_ArrayInsert ($GUI_waitDrones, $i)
		$GUI_waitDrones[$i] = GUICtrlCreateCheckbox("wait", $dronesGroup[0] + 50, $dronesGroup[1] + 35)
		GUICtrlSetState($GUI_waitDrones[$i], $waitDrones)

		; drones type
		_ArrayInsert ($GUI_dronesType, $i)
		GUICtrlCreateLabel("Type:", $dronesGroup[0] + 5, $dronesGroup[1] + 60)
		$GUI_dronesType[$i] = GUICtrlCreateCombo ("Combat", $dronesGroup[0] + 5, $dronesGroup[1] + 75, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_dronesType[$i], "Mine", $dronesType)

		; after return action
		_ArrayInsert ($GUI_dronesOnReturn, $i)
		GUICtrlCreateLabel("On return:", $dronesGroup[0] + 5, $dronesGroup[1] + 100)
		$GUI_dronesOnReturn[$i] = GUICtrlCreateCombo ("Station", $dronesGroup[0] + 5, $dronesGroup[1] + 115, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_dronesOnReturn[$i], "Spot|Next|POS", "Station")
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; timeouts group
	Local $timeoutsGroup[2] = [440, 165]
	GUICtrlCreateGroup ("Timeouts(in minutes)", $timeoutsGroup[0], $timeoutsGroup[1], 155, 140)
		GUICtrlCreateLabel("Current:", $timeoutsGroup[0] + 60, $timeoutsGroup[1] + 15)
		GUICtrlCreateLabel("Max:", $timeoutsGroup[0] + 100, $timeoutsGroup[1] + 15)

		; waiting timeout
		_ArrayInsert ($GUI_timeoutWaiting, $i)
		_ArrayInsert ($GUI_timeoutWaitingDefault, $i)
		GUICtrlCreateLabel("Waiting:", $timeoutsGroup[0] + 10, $timeoutsGroup[1] + 40)
		$GUI_timeoutWaiting[$i] = GUICtrlCreateInput ("0", $timeoutsGroup[0] + 60, $timeoutsGroup[1] + 35, 30, 20, $ES_NUMBER)
		GUICtrlSetState($GUI_timeoutWaiting[$i], $GUI_DISABLE)
		$GUI_timeoutWaitingDefault[$i] = GUICtrlCreateInput ($defaultWaitingTimeout, $timeoutsGroup[0] + 100, $timeoutsGroup[1] + 35, 30, 20, $ES_NUMBER)

		; warp timeout
		_ArrayInsert ($GUI_timeoutWarp, $i)
		_ArrayInsert ($GUI_timeoutWarpDefault, $i)
		GUICtrlCreateLabel("Warp:", $timeoutsGroup[0] + 10, $timeoutsGroup[1] + 60)
		$GUI_timeoutWarp[$i] = GUICtrlCreateInput ("0", $timeoutsGroup[0] + 60, $timeoutsGroup[1] + 55, 30, 20, $ES_NUMBER)
		GUICtrlSetState($GUI_timeoutWarp[$i], $GUI_DISABLE)
		$GUI_timeoutWarpDefault[$i] = GUICtrlCreateInput ($defaultWarpTimeout, $timeoutsGroup[0] + 100, $timeoutsGroup[1] + 55, 30, 20, $ES_NUMBER)

		; cargo timeout
		_ArrayInsert ($GUI_timeoutCargo, $i)
		_ArrayInsert ($GUI_timeoutCargoDefault, $i)
		GUICtrlCreateLabel("Cargo:", $timeoutsGroup[0] + 10, $timeoutsGroup[1] + 80)
		$GUI_timeoutCargo[$i] = GUICtrlCreateInput ("0", $timeoutsGroup[0] + 60, $timeoutsGroup[1] + 75, 30, 20, $ES_NUMBER)
		GUICtrlSetState($GUI_timeoutCargo[$i], $GUI_DISABLE)
		$GUI_timeoutCargoDefault[$i] = GUICtrlCreateInput ($defaultCargoTimeout, $timeoutsGroup[0] + 100, $timeoutsGroup[1] + 75, 30, 20, $ES_NUMBER)

		; drones timeout
		_ArrayInsert ($GUI_timeoutDrones, $i)
		_ArrayInsert ($GUI_timeoutDronesDefault, $i)
		GUICtrlCreateLabel("Drones:", $timeoutsGroup[0] + 10, $timeoutsGroup[1] + 100)
		$GUI_timeoutDrones[$i] = GUICtrlCreateInput ("0", $timeoutsGroup[0] + 60, $timeoutsGroup[1] + 95, 30, 20, $ES_NUMBER)
		GUICtrlSetState($GUI_timeoutDrones[$i], $GUI_DISABLE)
		$GUI_timeoutDronesDefault[$i] = GUICtrlCreateInput ($defaultDronesTimeout, $timeoutsGroup[0] + 100, $timeoutsGroup[1] + 95, 30, 20, $ES_NUMBER)

		; station timeout
		_ArrayInsert ($GUI_timeoutStation, $i)
		_ArrayInsert ($GUI_timeoutStationDefault, $i)
		GUICtrlCreateLabel("Station:", $timeoutsGroup[0] + 10, $timeoutsGroup[1] + 120)
		$GUI_timeoutStation[$i] = GUICtrlCreateInput ("0", $timeoutsGroup[0] + 60, $timeoutsGroup[1] + 115, 30, 20, $ES_NUMBER)
		GUICtrlSetState($GUI_timeoutStation[$i], $GUI_DISABLE)
		$GUI_timeoutStationDefault[$i] = GUICtrlCreateInput ($defaulStationTimeout, $timeoutsGroup[0] + 100, $timeoutsGroup[1] + 115, 30, 20, $ES_NUMBER)

		; tractoring timeout
		_ArrayInsert ($GUI_timeoutTractoring, $i)
		_ArrayInsert ($GUI_timeoutTractoringDefault, $i)
		;GUICtrlCreateLabel("Tractoring:", 260, 425)
		;$GUI_timeoutTractoring[$i] = GUICtrlCreateInput ("0", 320, 420, 30, 20, $ES_NUMBER)
		;GUICtrlSetState($GUI_timeoutTractoring[$i], $GUI_HIDE)
		;$GUI_timeoutTractoringDefault[$i] = GUICtrlCreateInput ("15", 360, 420, 30, 20, $ES_NUMBER)
		;GUICtrlSetState($GUI_timeoutTractoringDefault[$i], $GUI_HIDE)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; state group
	;GUICtrlCreateGroup ("State", 305, 165, 95, 140)
		; loadings
		_ArrayInsert ($GUI_loadingCounter, $i, 0)
	;	GUICtrlCreateLabel("Loadings:", 315, 180)
	;	$GUI_loadingCounter[$i] = GUICtrlCreateInput ($loadingCounter, 315, 195, 75)
	;	GUICtrlSetState($GUI_loadingCounter[$i], $GUI_DISABLE)

		;last action time
		_ArrayInsert ($GUI_lastActionTS, $i, 0)
	;GUICtrlCreateGroup ("",-99,-99,1,1)

	; npc group
	Local $npcGroup[2] = [10, 300]
	GUICtrlCreateGroup ("NPC", $npcGroup[0], $npcGroup[1], 275, 140)
		; attack NPC
		_ArrayInsert ($GUI_attackNPCCheckbox, $i)
		$GUI_attackNPCCheckbox[$i] = GUICtrlCreateCheckbox("attack NPC", $npcGroup[0] + 10, $npcGroup[1] + 15)
		GUICtrlSetState($GUI_attackNPCCheckbox[$i], $attackNPC)

		; NPC type
		_ArrayInsert ($GUI_factionType, $i)
		GUICtrlCreateLabel("NPC type:", $npcGroup[0] + 10, $npcGroup[1] + 35)
		$GUI_factionType[$i] = GUICtrlCreateCombo ("Angels", $npcGroup[0] + 10, $npcGroup[1] + 50, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_factionType[$i], "Drones|Guristas|Serpentis", $NPCtype)

		; loot wrecks
		_ArrayInsert ($GUI_lootWrecksCheckbox, $i)
		$GUI_lootWrecksCheckbox[$i] = GUICtrlCreateCheckbox("loot wrecks", $npcGroup[0] + 10, $npcGroup[1] + 75)
		GUICtrlSetState($GUI_lootWrecksCheckbox[$i], $lootWrecks)

		; loot only faction
		_ArrayInsert ($GUI_lootOnlyFaction, $i)
		$GUI_lootOnlyFaction[$i] = GUICtrlCreateCheckbox("loot only faction", $npcGroup[0] + 10, $npcGroup[1] + 95)
		GUICtrlSetState($GUI_lootOnlyFaction[$i], $lootOnlyFaction)

		; salvage wrecks
		_ArrayInsert ($GUI_salvageWrecksCheckbox, $i)
		$GUI_salvageWrecksCheckbox[$i] = GUICtrlCreateCheckbox("salvage", $npcGroup[0] + 10, $npcGroup[1] + 115)
		GUICtrlSetState($GUI_salvageWrecksCheckbox[$i], $salvageWrecks)


		; force re-spawn
		_ArrayInsert ($GUI_forceNPCrespawn, $i)
		GUICtrlCreateLabel("Force respawn:", $npcGroup[0] + 100, $npcGroup[1] + 15)
		$GUI_forceNPCrespawn[$i] = GUICtrlCreateCombo ("No", $npcGroup[0] + 100, $npcGroup[1] + 30, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_forceNPCrespawn[$i], "Battleships|Cruisers", $forceNPCrespawn)

		; hunt place
		_ArrayInsert ($GUI_huntingPlace, $i)
		GUICtrlCreateLabel("Hunt place:", $npcGroup[0] + 100, $npcGroup[1] + 55)
		$GUI_huntingPlace[$i] = GUICtrlCreateCombo ("Belt", $npcGroup[0] + 100, $npcGroup[1] + 70, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_huntingPlace[$i], "Anomaly", $huntingPlace)

		; resp limit
		_ArrayInsert ($GUI_respawnAmount, $i)
		GUICtrlCreateLabel("Respawn amount:", $npcGroup[0] + 100, $npcGroup[1] + 95)
		$GUI_respawnAmount[$i] = GUICtrlCreateInput ($respawnAmount, $npcGroup[0] + 100, $npcGroup[1] + 110, 75)


		;ammo amount
		_ArrayInsert ($GUI_ammoAmountInput, $i)
		GUICtrlCreateLabel("Ammo amount:", $npcGroup[0] + 190, $npcGroup[1] + 15)
		$GUI_ammoAmountInput[$i] = GUICtrlCreateInput ($ammoAmount, $npcGroup[0] + 190, $npcGroup[1] + 30, 75, 20, $ES_NUMBER)

		;anomalies list
		_ArrayInsert ($GUI_anomaliesList, $i)
		GUICtrlCreateLabel("Anomalies list:", $npcGroup[0] + 190, $npcGroup[1] + 55)
		$GUI_anomaliesList[$i] = GUICtrlCreateInput ($anomaliesList, $npcGroup[0] + 190, $npcGroup[1] + 70, 75)

		;anomalies delay
		_ArrayInsert ($GUI_anomaliesDelay, $i)
		GUICtrlCreateLabel("Rest delay(min):", $npcGroup[0] + 190, $npcGroup[1] + 95)
		$GUI_anomaliesDelay[$i] = GUICtrlCreateInput ($anomaliesDelay, $npcGroup[0] + 190, $npcGroup[1] + 110, 75)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; container group
	Local $containerGroup[2] = [285, 300]
	GUICtrlCreateGroup ("Container", $containerGroup[0], $containerGroup[1], 90, 140)
		; current container cargo
		_ArrayInsert ($GUI_containerCargo, $i)
		GUICtrlCreateLabel("Current(%):", $containerGroup[0] + 5, $containerGroup[1] + 15)
		$GUI_containerCargo[$i] = GUICtrlCreateInput ("0", $containerGroup[0] + 5, $containerGroup[1] + 30, 75)
		GUICtrlSetState($GUI_containerCargo[$i], $GUI_DISABLE)

		; max container cargo
		_ArrayInsert ($GUI_fullContainerCargo, $i)
		GUICtrlCreateLabel("Max cargo(%):", $containerGroup[0] + 5, $containerGroup[1] + 55)
		$GUI_fullContainerCargo[$i] = GUICtrlCreateInput ($fullContainerCargo, $containerGroup[0] + 5, $containerGroup[1] + 70, 75, 20, $ES_NUMBER)

		; max skipped containers
		_ArrayInsert ($GUI_skipedContainers, $i)
		GUICtrlCreateLabel("Skipped:", $containerGroup[0] + 5, $containerGroup[1] + 90)
		$GUI_skipedContainers[$i] = GUICtrlCreateInput ("0", $containerGroup[0] + 5, $containerGroup[1] + 105, 75, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; shedule group
	Local $sheduleGroup[2] = [375, 300]
	GUICtrlCreateGroup ("Shedule", $sheduleGroup[0], $sheduleGroup[1], 165, 140)
		; schedule
		_ArrayInsert ($GUI_botSchedule, $i)
		GUICtrlCreateLabel("Non-work time:", $sheduleGroup[0] + 10, $sheduleGroup[1] + 15)
		$GUI_botSchedule[$i] = GUICtrlCreateInput ($schedule, $sheduleGroup[0] + 10, $sheduleGroup[1] + 30, 150, 20)

		_ArrayInsert ($GUI_generateSchedule, $i)
		$GUI_generateSchedule[$i] = GUICtrlCreateButton ("generate", $sheduleGroup[0] + 105, $sheduleGroup[1] + 15, 55, 15)
		GUICtrlSetOnEvent($GUI_generateSchedule[$i], "GUI_GenerateSchedule")
		GUICtrlSetTip($GUI_generateSchedule[$i], "generate new random schedule")

		; schedule type
		_ArrayInsert ($GUI_botScheduleType, $i)
		GUICtrlCreateLabel("Schedule type:", $sheduleGroup[0] + 10, $sheduleGroup[1] + 55)
		$GUI_botScheduleType[$i] = GUICtrlCreateCombo ("Manual", $sheduleGroup[0] + 10, $sheduleGroup[1] + 70, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_botScheduleType[$i], "Random", $botScheduleType)

		; shedule random work hours
		_ArrayInsert ($GUI_botScheduleHours, $i)
		GUICtrlCreateLabel("Random work hrs:", $sheduleGroup[0] + 10, $sheduleGroup[1] + 95)
		$GUI_botScheduleHours[$i] = GUICtrlCreateInput ($botScheduleHours, $sheduleGroup[0] + 10, $sheduleGroup[1] + 110, 75, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; slots group
	Local $slotsGroup[2] = [10, 435]
	GUICtrlCreateGroup ("Ship modules", $slotsGroup[0], $slotsGroup[1], 290, 230)
		GUICtrlCreateLabel("High:", $slotsGroup[0] + 40, $slotsGroup[1] + 15)
		GUICtrlCreateLabel("Middle:", $slotsGroup[0] + 125, $slotsGroup[1] + 15)
		GUICtrlCreateLabel("Low:", $slotsGroup[0] + 210, $slotsGroup[1] + 15)

		ReDim $GUI_slotHigh[$i + 1][8]
		ReDim $GUI_slotMiddle[$i + 1][8]
		ReDim $GUI_slotLow[$i + 1][8]

		For $s = 0 To 7 Step 1
			Local $y = $slotsGroup[1] + 30 + $s*25

			GUICtrlCreateLabel("¹" & ($s + 1), 20, $y + 5)
			$GUI_slotHigh[$i][$s] = GUICtrlCreateCombo ("empty", $slotsGroup[0] + 40, $y, 75, 20, $CBS_DROPDOWNLIST)
			GUICtrlSetData($GUI_slotHigh[$i][$s], "gun|miner|tractor|gang|salvager", $slotDefaultHigh[$s])

			$GUI_slotMiddle[$i][$s] = GUICtrlCreateCombo ("empty", $slotsGroup[0] + 125, $y, 75, 20, $CBS_DROPDOWNLIST)
			GUICtrlSetData($GUI_slotMiddle[$i][$s], "shield|afterburner|targetPainter", $slotDefaultMiddle[$s])

			$GUI_slotLow[$i][$s] = GUICtrlCreateCombo ("empty", $slotsGroup[0] + 210, $y, 75, 20, $CBS_DROPDOWNLIST)
			GUICtrlSetData($GUI_slotLow[$i][$s], "damageControl", $slotDefaultLow[$s])
		Next
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; lock group
	Local $lockGroup[2] = [300, 435]
	GUICtrlCreateGroup ("Lock", $lockGroup[0], $lockGroup[1], 110, 230)
		; mine at once
		_ArrayInsert ($GUI_mineAtOnce, $i)
		GUICtrlCreateLabel("Amount of locks:", $lockGroup[0] + 5, $lockGroup[1] + 15)
		$GUI_mineAtOnce[$i] = GUICtrlCreateCombo ("1", $lockGroup[0] + 5, $lockGroup[1] + 30, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_mineAtOnce[$i], "2", $mineAtOnce)

		; lock distance
		_ArrayInsert ($GUI_lockDistance, $i)
		GUICtrlCreateLabel("Lock distance(km):", $lockGroup[0] + 5, $lockGroup[1] + 55)
		$GUI_lockDistance[$i] = GUICtrlCreateInput ($lockDistance, $lockGroup[0] + 5, $lockGroup[1] + 70, 75, 20, $ES_NUMBER)

		; action distance
		_ArrayInsert ($GUI_actionDistance, $i)
		GUICtrlCreateLabel("Action distance(km):", $lockGroup[0] + 5, $lockGroup[1] + 95)
		$GUI_actionDistance[$i] = GUICtrlCreateInput ($actionDistance, $lockGroup[0] + 5, $lockGroup[1] + 110, 75, 20, $ES_NUMBER)

		; scan resolution
		_ArrayInsert ($GUI_scanResolution, $i)
		GUICtrlCreateLabel("Scan resolution(mm):", $lockGroup[0] + 5, $lockGroup[1] + 135)
		$GUI_scanResolution[$i] = GUICtrlCreateInput ($scanResolution, $lockGroup[0] + 5, $lockGroup[1] + 150, 75, 20, $ES_NUMBER)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	; mining group
	Local $miningGroup[2] = [410, 435]
	GUICtrlCreateGroup ("Mining", $miningGroup[0], $miningGroup[1], 130, 230)
		; reload miners
		_ArrayInsert ($GUI_minersReload, $i)
		GUICtrlCreateLabel("Miners reload(sec):", $miningGroup[0] + 5, $miningGroup[1] + 15)
		$GUI_minersReload[$i] = GUICtrlCreateCombo ("No", $miningGroup[0] + 5, $miningGroup[1] + 30, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_minersReload[$i], "20|40|60|80|100", $minersReload)

		; maximum mining distance
		_ArrayInsert ($GUI_miningLimit, $i)
		GUICtrlCreateLabel("Max mining distance(km):", $miningGroup[0] + 5, $miningGroup[1] + 55)
		$GUI_miningLimit[$i] = GUICtrlCreateInput ($miningLimit, $miningGroup[0] + 5, $miningGroup[1] + 70, 75, 20, $ES_NUMBER)

		; ice check period
		_ArrayInsert ($GUI_iceCheckPeriod, $i)
		GUICtrlCreateLabel("Anomaly wait(min):", $miningGroup[0] + 5, $miningGroup[1] + 95)
		$GUI_iceCheckPeriod[$i] = GUICtrlCreateInput ($iceCheckPeriod, $miningGroup[0] + 5, $miningGroup[1] + 110, 75, 20, $ES_NUMBER)

		; ore type
		_ArrayInsert ($GUI_oreType, $i)
		GUICtrlCreateLabel("Ore type:", $miningGroup[0] + 5, $miningGroup[1] + 135)
		$GUI_oreType[$i] = GUICtrlCreateCombo ("all", $miningGroup[0] + 5, $miningGroup[1] + 150, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_oreType[$i], "ClearIcicle", $oreType)

		; change mining crystals
		_ArrayInsert ($GUI_changeMiningCrystals, $i)
		GUICtrlCreateLabel("Change crystals(hrs):", $miningGroup[0] + 5, $miningGroup[1] + 175)
		$GUI_changeMiningCrystals[$i] = GUICtrlCreateCombo ("No", $miningGroup[0] + 5, $miningGroup[1] + 190, 75, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData($GUI_changeMiningCrystals[$i], "3|6|9|12|24", $changeMiningCrystals)
	GUICtrlCreateGroup ("",-99,-99,1,1)

	GUICtrlCreateGroup ("",-99,-99,1,1)

	GUICtrlSetState($GUI_startButton, $GUI_ENABLE)

	GUI_CheckMainMenu()

	GUI_onRoleSelect()

	Return $i
EndFunc

; edit account proxy for gui button
Func GUI_EditAccountCaller()
	GUI_EditAccount()
EndFunc

; edit account settings
Func GUI_EditAccount($index = False)
	If $index == False Then
		$index = _GUICtrlListBox_GetCaretIndex($GUI_usersList)
	EndIf

	If $index == False Or $index = -1 Then
		MsgBox(64, "Account settings", "Select account first.")
		Return
	EndIf

	GUI_HideAllAccounts()

	For $i = $GUI_usersPage[$index] To $GUI_changeMiningCrystals[$index]
		GUICtrlSetState($i, $GUI_SHOW)
	Next

	$GUI_lastOpenedUser = $index

	GUI_onRoleSelect()

	GUISetState(@SW_SHOW, $GUI_accountWindow)
EndFunc

; remove account proxy for gui button
Func GUI_RemoveAccountCaller()
	GUI_RemoveAccount()
	GUI_UpdateListIndexes()
	GUI_CloseAccountWindow()
	GUI_HideAllAccounts()
EndFunc

;remove account
Func GUI_RemoveAccount($botid = False)
	If $botid = False Then
		$botid = _GUICtrlListBox_GetCaretIndex($GUI_usersList)
	EndIf

	_ArrayDelete ($WIN_titles, $botid)

	_ArrayDelete ($UTL_lastLogRecord, $botid)

	; statistics data
	STA_DeinitBotData($botid)

	GUI_DeleteAccountControls($botid)

	; bot wait timestamp
	_ArrayDelete ($GLB_needWait, $botid)

	_ArrayDelete ($GLB_downtimeSet, $botid)
	_ArrayDelete ($GLB_scheduleSet, $botid)

	_ArrayDelete ($GUI_botScheduleType, $botid)
	_ArrayDelete ($GUI_botScheduleHours, $botid)
	_ArrayDelete ($GUI_generateSchedule, $botid)

	_ArrayDelete ($GUI_killAllNPCinCurrentBelt, $botid)

	_ArrayDelete ($GLB_stayInStation, $botid)

	_ArrayDelete ($GLB_forcedUnload, $botid)
	_ArrayDelete ($GLB_allBeltsDone, $botid)

	_ArrayDelete ($GLB_lastReactivatedSlot, $botid)

	; login
	_ArrayDelete ($GUI_login, $botid)

	; password
	_ArrayDelete ($GUI_password, $botid)

	_ArrayDelete ($GUI_character, $botid)

	; role
	_ArrayDelete ($GUI_botRole, $botid)

	; location selector
	_ArrayDelete ($GUI_locationCombo, $botid)

	; state selector
	_ArrayDelete ($GUI_stateCombo, $botid)

	_ArrayDelete ($GUI_salvageWrecksCheckbox, $botid)

	_ArrayDelete ($GUI_runOnDamageCheckbox, $botid)

	_ArrayDelete ($GUI_systemSecurity, $botid)

	_ArrayDelete ($GUI_systemPOS, $botid)

	_ArrayDelete ($GUI_groupID, $botid)

	_ArrayDelete ($GUI_lootOnlyFaction, $botid)

	; slots
	_ArrayDelete ($GUI_slotHigh, $botid)
	_ArrayDelete ($GUI_slotMiddle, $botid)
	_ArrayDelete ($GUI_slotLow, $botid)

	If $GUI_slotHigh = "" Then
		Dim $GUI_slotHigh[1][8]
		Dim $GUI_slotMiddle[1][8]
		Dim $GUI_slotLow[1][8]
	EndIf

	_ArrayDelete ($GUI_miningLimit, $botid)

	; cargo
	_ArrayDelete ($GUI_cargo, $botid)

	; full cargo
	_ArrayDelete ($GUI_fullCargo, $botid)

	; unload to
	_ArrayDelete ($GUI_UnloadToCombo, $botid)

	; loading counter
	_ArrayDelete ($GUI_loadingCounter, $botid)

	; tabs
	_ArrayDelete ($GUI_OverviewCurrentTabCombo, $botid)
	_ArrayDelete ($GUI_ChatCurrentTabCombo, $botid)

	; login delay
	_ArrayDelete ($GUI_LaunghDelay, $botid)

	; enable bot
	_ArrayDelete ($GUI_enableBot, $botid)

	; window hwnd
	_ArrayDelete ($GUI_windowHWND, $botid)
	_ArrayDelete ($GUI_buttonSetHWND, $botid)

	;last action ts
	_ArrayDelete ($GUI_lastActionTS, $botid)

	;lock distance
	_ArrayDelete ($GUI_lockDistance, $botid)

	;miner stat
	;_ArrayDelete ($GUI_statMining, $botid)

	_ArrayDelete ($GUI_containerCargo, $botid)

	; max container cargo
	_ArrayDelete ($GUI_fullContainerCargo, $botid)
	; skiped containers
	_ArrayDelete ($GUI_skipedContainers, $botid)

	;max bookmark
	_ArrayDelete ($GUI_bookmarkMax, $botid)

	_ArrayDelete ($GUI_BookmarksList, $botid)

	;current bookmark
	_ArrayDelete ($GUI_bokmarkCurrent, $botid)
	_ArrayDelete ($GUI_BookmarkItem, $botid)
	_ArrayDelete ($GUI_buttonBookmarkAdd, $botid)
	_ArrayDelete ($GUI_buttonBookmarkRemove, $botid)
	_ArrayDelete ($GUI_bookmarkType, $botid)

	; visible
	_ArrayDelete ($GUI_bookmarkVisible, $botid)

	;use shields
	_ArrayDelete ($GUI_useShieldsCheckbox, $botid)

	_ArrayDelete ($GUI_shieldCurrent, $botid)

	; activate shield on
	_ArrayDelete ($GUI_shieldActivateOn, $botid)

	; critical shield
	_ArrayDelete ($GUI_shieldCritical, $botid)

	;shield activated timestamp
	_ArrayDelete ($GUI_shieldActivatedTS, $botid)

	;drones
	_ArrayDelete ($GUI_useDrones, $botid)
	_ArrayDelete ($GUI_repairDrones, $botid)
	_ArrayDelete ($GUI_waitDrones, $botid)
	_ArrayDelete ($GUI_dronesType, $botid)
	_ArrayDelete ($GUI_dronesOnReturn, $botid)

	; attack NPC
	_ArrayDelete ($GUI_attackNPCCheckbox, $botid)
	_ArrayDelete ($GUI_forceNPCrespawn, $botid)
	_ArrayDelete ($GUI_respawnAmount, $botid)

	_ArrayDelete ($GUI_huntingPlace, $botid)
	_ArrayDelete ($GUI_anomaliesDelay, $botid)
	_ArrayDelete ($GUI_anomaliesList, $botid)
	_ArrayDelete ($GUI_ammoAmountInput, $botid)

	; loot wrecks
	_ArrayDelete ($GUI_lootWrecksCheckbox, $botid)
	_ArrayDelete ($GUI_factionType, $botid)

	; leave one item in cargo
	_ArrayDelete ($GUI_leaveOneItemInCargoCheckbox, $botid)

	; timeouts
	_ArrayDelete ($GUI_timeoutWaiting, $botid)
	_ArrayDelete ($GUI_timeoutWaitingDefault, $botid)

	; warp timeout
	_ArrayDelete ($GUI_timeoutWarp, $botid)
	_ArrayDelete ($GUI_timeoutWarpDefault, $botid)

	; cargo timeout
	_ArrayDelete ($GUI_timeoutCargo, $botid)
	_ArrayDelete ($GUI_timeoutCargoDefault, $botid)

	; drones timeout
	_ArrayDelete ($GUI_timeoutDrones, $botid)
	_ArrayDelete ($GUI_timeoutDronesDefault, $botid)

	; station timeout
	_ArrayDelete ($GUI_timeoutStation, $botid)
	_ArrayDelete ($GUI_timeoutStationDefault, $botid)

	; local chat
	_ArrayDelete ($GUI_localChatIconSize, $botid)
	_ArrayDelete ($GUI_localChatMonitor, $botid)
	_ArrayDelete ($GUI_localChatMaxAmountOfUsers, $botid)

	_ArrayDelete ($GUI_waitingStartTS, $botid)
	_ArrayDelete ($GUI_warpStartTS, $botid)
	_ArrayDelete ($GUI_cargoStartTS, $botid)
	_ArrayDelete ($GUI_dronesStartTS, $botid)
	_ArrayDelete ($GUI_stationStartTS, $botid)
	_ArrayDelete ($GUI_tractoringStartTS, $botid)
	_ArrayDelete ($GUI_warpDetected, $botid)

	_ArrayDelete ($GUI_miningAsteroidNumber, $botid)

	_ArrayDelete ($GUI_mineAtOnce, $botid)

	_ArrayDelete ($GUI_acceptUnknownFleet, $botid)

	_ArrayDelete ($GUI_DATA_LoginErrors, $botid)

	_ArrayDelete ($GUI_minersReloadTS, $botid)

	_ArrayDelete ($GUI_scanResolution, $botid)

	_ArrayDelete ($GUI_iceCheckPeriod, $botid)
	_ArrayDelete ($GUI_oreType, $botid)
	_ArrayDelete ($GUI_changeMiningCrystals, $botid)

	_ArrayDelete ($AnomalyMiner_lastOreAnomalyPosition, $botid)

	_ArrayDelete ($GLB_lastCrystalReloadTime, $botid)

	_ArrayDelete ($GUI_fixView, $botid)

	_ArrayDelete ($GUI_actionDistance, $botid)

	_ArrayDelete ($GUI_isSteam, $botid)


	GUICtrlDelete($GUI_usersPage[$botid])
	_ArrayDelete ($GUI_usersPage, $botid)
	_GUICtrlListBox_DeleteString($GUI_usersList, $botid)

	$GLB_numOfBots-= 1

	If $GUI_lastOpenedUser >= $botid Then
		$GUI_lastOpenedUser-= 1
	EndIf

	GUI_CheckMainMenu()
EndFunc

; dublicate selected account
Func GUI_DublicateAccount()
	Local $index = _GUICtrlListBox_GetCaretIndex($GUI_usersList)

	If $index = -1 Then
		MsgBox(64, "Account dublication", "Select account first.")
		Return
	EndIf

	Local $botData = CONFIG_GetBotData($index)
	Local $adaptedData[UBound($botData)]

	For $i = 0 To UBound($botData) - 1 Step 1
		If $i = 0 Or $i = 1 Then
			$adaptedData[$i] = ""
		Else
			$adaptedData[$i] = $botData[$i][1]
		EndIf
	Next

	Local $newIndex = GUI_AddAccount($adaptedData)
	$GLB_numOfBots+= 1
	GUI_EditAccount($newIndex)
	$GUI_lastOpenedUser = $newIndex
	GUISetState(@SW_SHOW, $GUI_accountWindow)

	_GUICtrlListBox_SetCurSel($GUI_usersList, $newIndex)
EndFunc

; update indexes
Func GUI_UpdateListIndexes()
	For $i = 0 To $GLB_numOfBots - 1 Step 1
		_GUICtrlListBox_ReplaceString($GUI_usersList, $i, ($i + 1) & "." & GUICtrlRead($GUI_login[$i]))
	Next
EndFunc

;set bot window
Func GUI_SetBotWindow()
	$GLB_curBot = _GUICtrlListBox_GetCaretIndex($GUI_usersList)

	GUICtrlSetData($GUI_windowHWND[$GLB_curBot], "Wait...")
	For $i = 0 To 5 Step 1
		UTL_Wait(1, 1.1)
	Next

	Local $activeWindow = WIN_GetActiveWindow()
	$WIN_titles[$GLB_curBot] = $activeWindow[1]

	GUICtrlSetData($GUI_windowHWND[$GLB_curBot], $activeWindow[1])
	BOT_LogMessage("Window " & $activeWindow[1] & " set to bot " & _GUICtrlListBox_GetSelItemsText($GUI_usersList), 2)
EndFunc

;generate new random schedule
Func GUI_GenerateSchedule()
	$GLB_curBot = _GUICtrlListBox_GetCaretIndex($GUI_usersList)

	GUICtrlSetData($GUI_botSchedule[$GLB_curBot], UTL_GenerateSchedule(GUICtrlRead($GUI_botScheduleHours[$GLB_curBot])))
	BOT_LogMessage("Manual schedule generation", 2)
EndFunc

; hide all accounts
Func GUI_HideAllAccounts()
	For $i = $GUI_usersPage[0] To $GUI_changeMiningCrystals[_GUICtrlListBox_GetCount($GUI_usersList) - 1]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
EndFunc

; delete account controls
Func GUI_DeleteAccountControls($account)
	For $i = $GUI_usersPage[$account] To $GUI_changeMiningCrystals[$account]
		GUICtrlDelete($i)
	Next
EndFunc

; enable all options for account
Func GUI_enableAllOptions()
	For $i = $GUI_usersPage[$GLB_curBot] To $GUI_changeMiningCrystals[$GLB_curBot]
		GUICtrlSetState($i, $GUI_ENABLE)
	Next
EndFunc

; on role select callback
Func GUI_onRoleSelect()
	$GLB_curBot = _GUICtrlListBox_GetCaretIndex($GUI_usersList)

	GUI_enableAllOptions()

	; enable when big size users will be fixed
	GUICtrlSetState($GUI_localChatIconSize[$GLB_curBot], $GUI_DISABLE)

	; disable not used options
	Local $role = GUICtrlRead($GUI_botRole[$GLB_curBot])
	Switch $role
		Case "Hunter"
			GUICtrlSetState($GUI_miningLimit[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_mineAtOnce[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_minersReload[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_iceCheckPeriod[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_oreType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_changeMiningCrystals[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_acceptUnknownFleet[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesOnReturn[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_cargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_containerCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_skipedContainers[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_windowHWND[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_timeoutWaiting[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutWarp[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutStation[$GLB_curBot], $GUI_DISABLE)
		Case "Belt Miner"
			;GUICtrlSetState($GUI_mineAtOnce[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_iceCheckPeriod[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_oreType[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_acceptUnknownFleet[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_factionType[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesOnReturn[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_cargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_containerCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_skipedContainers[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_windowHWND[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_timeoutWaiting[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutWarp[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutStation[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_forceNPCrespawn[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_huntingPlace[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_respawnAmount[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesList[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesDelay[$GLB_curBot], $GUI_DISABLE)
		Case "Anomaly Miner"
			;GUICtrlSetState($GUI_mineAtOnce[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_acceptUnknownFleet[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_factionType[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesOnReturn[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_cargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_containerCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_skipedContainers[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_windowHWND[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_timeoutWaiting[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutWarp[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutStation[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_forceNPCrespawn[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_huntingPlace[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_respawnAmount[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesList[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesDelay[$GLB_curBot], $GUI_DISABLE)
		Case "Marauder"
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_acceptUnknownFleet[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_miningLimit[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_mineAtOnce[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_minersReload[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_iceCheckPeriod[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_oreType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_changeMiningCrystals[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesOnReturn[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_cargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_containerCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_skipedContainers[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_windowHWND[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_timeoutWaiting[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutWarp[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutStation[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_forceNPCrespawn[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_huntingPlace[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_respawnAmount[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesList[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesDelay[$GLB_curBot], $GUI_DISABLE)
		Case "Courier"
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_acceptUnknownFleet[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_miningLimit[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_mineAtOnce[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_minersReload[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_iceCheckPeriod[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_oreType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_changeMiningCrystals[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_factionType[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_useDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_useDrones[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_waitDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_waitDrones[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_dronesType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesOnReturn[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_cargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_containerCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_skipedContainers[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_windowHWND[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_timeoutWaiting[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutWarp[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutStation[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_forceNPCrespawn[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_huntingPlace[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_respawnAmount[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesList[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesDelay[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_lockDistance[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_actionDistance[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_scanResolution[$GLB_curBot], $GUI_DISABLE)
		Case "Watcher"
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_attackNPCCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_salvageWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_acceptUnknownFleet[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_miningLimit[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_mineAtOnce[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_minersReload[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_iceCheckPeriod[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_oreType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_changeMiningCrystals[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootWrecksCheckbox[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_lootOnlyFaction[$GLB_curBot], $GUI_UNCHECKED)

			GUICtrlSetState($GUI_factionType[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_useDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_useDrones[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_waitDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_waitDrones[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_repairDrones[$GLB_curBot], $GUI_UNCHECKED)
			GUICtrlSetState($GUI_dronesType[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_dronesOnReturn[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_shieldCurrent[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_cargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_containerCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_skipedContainers[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_windowHWND[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_timeoutWaiting[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutWarp[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutCargo[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutDrones[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_timeoutStation[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_forceNPCrespawn[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_huntingPlace[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_respawnAmount[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesList[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_anomaliesDelay[$GLB_curBot], $GUI_DISABLE)

			GUICtrlSetState($GUI_lockDistance[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_actionDistance[$GLB_curBot], $GUI_DISABLE)
			GUICtrlSetState($GUI_scanResolution[$GLB_curBot], $GUI_DISABLE)
	EndSwitch
EndFunc