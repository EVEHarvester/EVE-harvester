#cs
[ScriptVersion]
#ce
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=img/icon.ico
#AutoIt3Wrapper_Outfile=EVEharvester_compiled.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=EVE Harvester
#AutoIt3Wrapper_Res_Fileversion=1.98.9.333
#AutoIt3Wrapper_Res_ProductVersion=1.98.9.333
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_LegalCopyright=IntuoSoft 2013-2015
#AutoIt3Wrapper_Res_Comment=EVE Harvester by IntuoSoft
#AutoIt3Wrapper_Res_SaveSource=n
#AutoIt3Wrapper_Run_Au3Stripper=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Misc.au3>
#include <GUIConstants.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <UpDownConstants.au3>
#include <ComboConstants.au3>
#include <GuiEdit.au3>
#include <GuiListBox.au3>
#include <GuiTreeView.au3>
#include <ButtonConstants.au3>
#include <TreeViewConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <ScreenCapture.au3>
#include <WinAPI.au3>
#include <GDIPlus.au3>
#include <String.au3>
#include <Color.au3>
#include <GuiListView.au3>
#include "include/UnixTime.au3"
#include "include/Rijndael.au3"
#include "include/MathAdditions.au3"
#include "include/Base64.au3"
#include "Bot_DATA_Overview.au3"
#include "Bot_DATA_Chat.au3"
#include "Bot_DATA_Inventory.au3"
#include "Bot_DATA_PAP.au3"
#include "Bot_DATA_SI.au3"
#include "Bot_DATA_Hangar.au3"
#include "Bot_DATA_Scanner.au3"
#include "Bot_DATA_Drones.au3"
#include "Mining_Bot_GLB.au3"
#include "Mining_Bot_GUI.au3"
#include "Mining_Bot_OCR.au3"
#include "Mining_Bot_WIN.au3"
#include "Mining_Bot_ACT.au3"
#include "Mining_Bot_UTL.au3"
#include "Mining_Bot_STA.au3"
#include "Bot_GUI_MainWindow.au3"
#include "Bot_GUI_AccountWindow.au3"
#include "Bot_GUI_SettingsWindow.au3"
#include "Bot_GUI_OCRWindow.au3"
#include "Bot_GUI_AboutWindow.au3"
#include "Bot_LOCATION_Station.au3"
#include "Bot_LOCATION_Space.au3"
#include "Bot_ROLE_Hunter.au3"
#include "Bot_ROLE_BeltMiner.au3"
#include "Bot_ROLE_AnomalyMiner.au3"
#include "Bot_ROLE_Courier.au3"
#include "Bot_ROLE_Watcher.au3"
#include "Bot_CONFIG.au3"
#include "Bot_SPEECH.au3"
#include "Mining_Bot_EVEOCR.au3"
#include "Bot_NET.au3"
#include "Bot_LIC.au3"
#include "Bot_TEST.au3"
#include "Bot_EMAIL.au3"

Opt("GUIOnEventMode", 1) ; enable onEvent functions
Opt("PixelCoordMode", 2) ; count pixels from left upper corner
Opt("MouseCoordMode", 2) ; mouse coordinates from left upper corner
Opt("MustDeclareVars", 1) ; variables should be declared
Opt("SendKeyDelay", 100)
HotKeySet("{PAUSE}", "BOT_Stopping")
TraySetState(2) ; hide tray icon

GUI_initContainers()
NET_InitData()
GUI_CreateGUI()
UTL_CreateDirectories()
UTL_CreateLog()
BOT_CheckAutoLoad()

$WIN_monitor = WIN_GetMonitorCoordinates(GUICtrlRead($GUI_monitor))

While 1
	; remote management
	If LIC_isLicenseInputed() And GUICtrlRead($GUI_allowRemote) = $GUI_CHECKED Then
		NET_remoteCmdCheck()
	EndIf

	; main cycle
	If $GLB_isRunning Then
		For $b = 0 To $GLB_numOfBots - 1 Step 1
			$GLB_curBot = $b

			; test code
			If TEST() Then ContinueLoop

			; if stoped skip all
			If Not $GLB_isRunning Then
				ExitLoop
			EndIf

			GUI_setCurrentBotData()

			; skip account
			; if disabled
			If Not (GUICtrlRead($GUI_enableBot[$GLB_curBot]) = $GUI_CHECKED) Then
				BOT_LogMessage("Account '" & GUICtrlRead($GUI_login[$GLB_curBot]) & "' disabled", 1)
				ContinueLoop
			EndIf

			BOT_UpdateCoordinates()

			; if allowed to close teamviewer window
			If GUICtrlRead($GUI_closeTeamViewer) = $GUI_CHECKED Then
				UTL_CheckTeamViewerWindow()
			EndIf

			UTL_CheckCCPexeFileErrorWindow()

			; check license session
			If LIC_isLicenseInputed() And LIC_SessionNeedUpdate() Then
				LIC_CheckLicense()
			EndIf

			; run account actions
			BOT_Process()

			BOT_LogMessage("Iteration finished in state " & GUICtrlRead($GUI_locationCombo[$GLB_curBot]) & "->" & GUICtrlRead($GUI_stateCombo[$GLB_curBot]) & @CRLF)
			UTL_Wait(GUICtrlRead($GUI_botsDelayInput), GUICtrlRead($GUI_botsDelayInput) + 1)
		Next

		WIN_CloseUnusedWindows()
	ElseIf $GLB_isStopping Then
		BOT_FinalizeStop()
	EndIf
	UTL_Wait(GUICtrlRead($GUI_ciclesDelayInput), GUICtrlRead($GUI_ciclesDelayInput) + 1)
WEnd

;bot main process
Func BOT_Process()
	Local $location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])

	;check downtime
	If GUICtrlRead($GUI_downtime) <> "" And Not $GLB_downtimeSet[$GLB_curBot] And UTL_CheckDowntime() Then
		For $n = 0 To $GLB_numOfBots - 1 Step 1
			; if allready closed
			If $n = $GLB_curBot And $location = "closed" Then
				;for current bot only - wait timestamp set to current only
				BOT_LogMessage("Do not open window. Downtime", 1)
				UTL_SetWaitTimestamp(UTL_CalcScheduleTimeLeft(GUICtrlRead($GUI_downtime)))
				GUI_SetLocationAndState("closed", "delay")
				$GLB_stayInStation[$n] = 0
				GUI_initContainers()
			Else
				$GLB_stayInStation[$n] = -2
				BOT_LogMessage("Set instructions for bot " & $n & ". Downtime", 1)
			EndIf

			$GLB_allBeltsDone[$n] = 0

			; update random schedules
			If GUICtrlRead($GUI_botScheduleType[$n]) = "Random" Then
				GUICtrlSetData($GUI_botSchedule[$n], UTL_GenerateSchedule(GUICtrlRead($GUI_botScheduleHours[$n])))
			EndIf
		Next

		$GLB_downtimeSet[$GLB_curBot] = True
	;check schedule
	ElseIf GUICtrlRead($GUI_botSchedule[$GLB_curBot]) <> "" And Not $GLB_scheduleSet[$GLB_curBot] And UTL_CheckSchedule() Then
		If $location = "closed" Then
			BOT_LogMessage("Do not open window. Scheduled stop", 1)
			UTL_SetWaitTimestamp(UTL_CalcScheduleTimeLeft(GUICtrlRead($GUI_botSchedule[$GLB_curBot])))
			GUI_SetLocationAndState("closed", "delay")
			$GLB_stayInStation[$GLB_curBot] = 0
			GUI_initContainers()
		Else
			$GLB_stayInStation[$GLB_curBot] = -2.1
			BOT_LogMessage("Initiated scheduled stop", 1)
		EndIf
		$GLB_scheduleSet[$GLB_curBot] = True
	ElseIf $GLB_downtimeSet[$GLB_curBot] And Not UTL_CheckDowntime() Then
		$GLB_downtimeSet[$GLB_curBot] = False
	ElseIf $GLB_scheduleSet[$GLB_curBot] And Not UTL_CheckSchedule() Then
		$GLB_scheduleSet[$GLB_curBot] = False
	EndIf

	;check wait timestamp
	If Not UTL_CheckWaitTimestamp() Then
		Return True
	EndIf

	WIN_OrganizeBotWindows($location)

	If $WIN_titles[$GLB_curBot] <> -1 And WinExists($WIN_titles[$GLB_curBot]) And Not WinActive($WIN_titles[$GLB_curBot]) Then
		BOT_LogMessage("Client window hangs. Skip account in this iteration", 1)
		Return False
	EndIf

	; continue actions if possible
	Do
		; if window suddenly closed location could be changed
		$location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
		$state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])

		;detect info window and close it if client not closed
		If $location <> "closed" Then
			If Not BOT_CheckInfoWindows() Then
				Return True
			EndIf
			BOT_CheckJoinFleetWindow()
			BOT_CheckChatInvitationWindow()
			; check selected item window state
			If ($location = "belt" Or $location = "space") And $state <> "waiting" Then
				;BOT_CheckSIWindow(); -> TODO proper detection
				If Not OCR_isSlotsPanelOpened() Then
					ACT_OpenSlotsPanel()
				EndIf
			EndIf
		EndIf

		;fix location if needed
		If $location <> "closed" And Not BOT_CheckLocationAndState($location, $state) Then
			BOT_LogMessage("Bad location found", 1)
			Return True
		EndIf

		; if game is running
		If $location <> "closed" And $location <> "login" And $location <> "info" And $location <> "ingame" Then
			;detect data loading
			If OCR_DetectDataLoading() Then
				BOT_LogMessage("Data loading detected. Waiting", 1)
				Return True
			EndIf

			;check main menu presence
			If Not BOT_CheckMainMenu() Then
				BOT_LogMessage("Main menu not found. Loading...", 1)
				Return True
			EndIf

			;check damage
			If $state <> "warpWaiting" And $state <> "warping" And BOT_CheckDamage($location, $state) Then
				BOT_LogMessage("Damage found", 1)
				If GUICtrlRead($GUI_stateCombo[$GLB_curBot]) <> "warpWaiting" Then
					Return True
				Else
					$location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
					$state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
				EndIf
			EndIf
		EndIf

		;random view fix
		If Random(100) > 97 And ($location = "belt" Or $location = "space" Or $location = "spot" Or $location = "pos") Then
			BOT_LogMessage("Random view fix", 1)
			ACT_SetView()
		EndIf

		;if closed
		If $location = "closed" Then
			BOT_StateClosed()
			;if login
		ElseIf $location = "login" Then
			BOT_StateLogin()
			;if info
		ElseIf $location = "info" Then
			BOT_StateInfo()
			;if in game
		ElseIf $location = "ingame" Then
			BOT_StateInGame()
			;if in station
		ElseIf $location = "station" Then
			BOT_StateStation()
			;if in space
		ElseIf $location = "space" Then
			BOT_StateSpace()
			;if in belt
		ElseIf $location = "belt" Then
			BOT_StateBelt()
			;if in anomaly
		ElseIf $location = "anomaly" Then
			BOT_StateAnomaly()
			;if in spot
		ElseIf $location = "spot" Then
			BOT_StateSpot()
			;if in pos
		ElseIf $location = "pos" Then
			BOT_StatePOS()
		EndIf

		;redetect variables
		$location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
		$state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])

	Until ($state <> "free" And $state <> "next" And $state <> "unloading" And $state <> "warpWaiting") Or Not UTL_CheckWaitTimestamp() Or Not $GLB_isRunning Or $GLB_isStopping Or (GUICtrlRead($GUI_enableBot[$GLB_curBot]) <> $GUI_CHECKED)

	Return True
EndFunc   ;==>BOT_Process

Func BOT_CheckAutoLoad()
	If $CmdLine[0] = 2 Then
		;load config
		CONFIG_LoadConfig($CmdLine[1])
		;start bot
		If $CmdLine[2] = "True" Then
			BOT_Start()
		EndIf
	EndIf
EndFunc   ;==>BOT_CheckAutoLoad

;check closed state
Func BOT_StateClosed()
	If $GLB_stayInStation[$GLB_curBot] = -2 Then
		BOT_LogMessage("Do not laungh window. Downtime", 1)
		UTL_SetWaitTimestamp(UTL_CalcScheduleTimeLeft(GUICtrlRead($GUI_downtime)))
		GUI_SetLocationAndState("closed", "delay")
		$GLB_stayInStation[$GLB_curBot] = 0
		Return
	ElseIf $GLB_stayInStation[$GLB_curBot] = -2.1 Then
		BOT_LogMessage("Do not laungh window. Scheduled stop", 1)
		UTL_SetWaitTimestamp(UTL_CalcScheduleTimeLeft(GUICtrlRead($GUI_botSchedule[$GLB_curBot])))
		GUI_SetLocationAndState("closed", "delay")
		$GLB_stayInStation[$GLB_curBot] = 0
		Return
	ElseIf $GLB_stayInStation[$GLB_curBot] <= -7 And $GLB_stayInStation[$GLB_curBot] >= -10 Then
		BOT_LogMessage("Do not laungh window. License error. Bot disabled", 1)
		GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
		GUI_SetLocationAndState("closed", "free")
		$GLB_stayInStation[$GLB_curBot] = 0
		Return
	EndIf

	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	If $state = "free" Then
		If GUICtrlRead($GUI_LaunghDelay[$GLB_curBot]) > 0 Then
			UTL_SetWaitTimestamp(GUICtrlRead($GUI_LaunghDelay[$GLB_curBot]) * 60)
			GUI_SetLocationAndState("closed", "delay")
		Else
			GUI_SetLocationAndState("closed", "next")
		EndIf
	ElseIf $state = "delay" Then
		GUI_SetLocationAndState("closed", "next")
	ElseIf $state = "next" Then
		If GUICtrlRead($GUI_isSteam[$GLB_curBot]) = $GUI_CHECKED Or WIN_TryOpenWindow() Then
			GUI_SetLocationAndState("closed", "waiting")
		EndIf
	ElseIf $state = "waiting" Then
		; open steam account window if no more windows to open
		If GUICtrlRead($GUI_isSteam[$GLB_curBot]) = $GUI_CHECKED Then
			If GUI_GetAccountsAmount("closed", "waiting") = 1 Then
				WIN_TryOpenSteamWindow()
				While Not WIN_CheckOpenWindow("Steam")
					Sleep(2000)
				WEnd
				WIN_PositionWindow()
				GUI_SetLocationAndState("info", "waiting")
				UTL_SetTimeout("waiting")
			EndIf
		ElseIf WIN_CheckOpenWindow() Then
			WIN_PositionWindow()
			GUI_SetLocationAndState("login", "waiting")
			UTL_SetTimeout("waiting")
		EndIf
	ElseIf $state = "connectionWaiting" Then
		; check connection before login
		If Not BOT_PingServer(GUICtrlRead($GUI_pingConnectionServer)) Then
			BOT_LogMessage("Internet connection not found! Waiting for 1 min", 1)
			UTL_SetWaitTimestamp(1 * 60)
		Else
			GUI_SetLocationAndState("closed", "free")
		EndIf
	Else
		BOT_LogMessage("Unsupported state for close", 1)
		BOT_FixLocationAndState("closed", $state)
	EndIf
	Return True
EndFunc   ;==>BOT_StateClosed

;check login state
Func BOT_StateLogin()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	If $state = "waiting" Then
		If WIN_ActivateWindow($WIN_titles[$GLB_curBot], "login waiting") Then
			UTL_Wait(0.5, 1)
			Local $wPosition = WinGetPos($WIN_titles[$GLB_curBot])
			ACT_MouseClick("left", $wPosition[0] + 50, $wPosition[1] + 50,  10,  10)
			If OCR_DetectLogin() Then
				GUI_SetLocationAndState("login", "free")

				UTL_SetTimeout("waiting", True)
				GUI_SetLastActionTime()
				$GUI_loadingCounter[$GLB_curBot] = 0
				UTL_SetWaitTimestamp(5)
				Return True
			Else
				BOT_incrementLoadingCounter()
			EndIf
		Else
			BOT_incrementLoadingCounter()
		EndIf

		BOT_CheckTimeout("waiting")
	ElseIf $state = "free" Then
		; check login presence before login
		Local $login = GUICtrlRead($GUI_login[$GLB_curBot])
		Local $password = GUICtrlRead($GUI_password[$GLB_curBot])
		If $login = "" Or $password = "" Then
			BOT_CloseWindow("Login. Login data not specified. Bot disabled")
			GUI_SetLocationAndState("closed", "free")
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			Return False
		EndIf

		; check connection before login
		If Not BOT_PingServer(GUICtrlRead($GUI_pingConnectionServer)) Then
			BOT_CloseWindow("Login. Internet connection not found")
			GUI_SetLocationAndState("closed", "connectionWaiting")
			Return False
		EndIf

		If Not BOT_CheckClientUpdateWindow() Or Not BOT_CheckClientNeedUpdate() Then
			Return False
		EndIf

		If GUI_GetAccountsAmount("closed", "waiting") > 0 Then
			BOT_LogMessage("Another account waiting for window, delay login", 1)
			GUI_SetLocationAndState("login", "waiting")
			Return False
		EndIf

		; if orca fleet closed
		If GUI_isFleetCommander() Then
			For $n = 0 To $GLB_numOfBots - 1 Step 1
				Local $loc = GUICtrlRead($GUI_locationCombo[$n])
				If $n <> $GLB_curBot And GUICtrlRead($GUI_botRole[$n]) = "Fleet Miner" And ($loc = "station" Or $loc = "space" Or $loc = "belt") Then
					$GLB_stayInStation[$n] = -4
				EndIf
			Next
		EndIf

		; if input OK
		If ACT_Login() Then
			GUI_SetLocationAndState("info", "waiting")
			UTL_SetTimeout("waiting")
		Else
			WIN_ActivateWindow($WIN_titles[$GLB_curBot], "input in inactive window")
		EndIf
	ElseIf $state = "error" Then
		BOT_LogMessage("Login error! Waiting for " & GUICtrlRead($GUI_loginErrorDelayInput) & " min", 1)

		; check login errors amount
		$GUI_DATA_LoginErrors[$GLB_curBot] += 1
		If $GUI_DATA_LoginErrors[$GLB_curBot] >= GUICtrlRead($GUI_loginMaxErrorsInput) Then
			BOT_LogMessage("Login errors limit reached. Bot disabled", 1)
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			$GUI_DATA_LoginErrors[$GLB_curBot] = 0
			BOT_CloseWindow("Login errors limit reached")
		ElseIf GUICtrlRead($GUI_logoutAfterLoginErrorCheckbox) = $GUI_CHECKED Then
			BOT_CloseWindow("Login error")
		EndIf

		UTL_SetWaitTimestamp(GUICtrlRead($GUI_loginErrorDelayInput) * 60)
		GUI_SetLocationAndState("login", "free")
		Return False
	Else
		BOT_LogMessage("Unsupported state for login", 1)
		BOT_FixLocationAndState("login", $state)
	EndIf

	Return True
EndFunc   ;==>BOT_StateLogin

;check info state
Func BOT_StateInfo()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	If $state = "waiting" Then
		;ACT_MouseClick("left", 500, 100, 150, 25, 1, 5, 10)
		UTL_Wait(5, 5.5)

		If OCR_DetectMainMenu() Then
			GUI_SetLocationAndState("ingame", "waiting")
			GUI_SetLastActionTime()
			UTL_SetTimeout("waiting")
			$GUI_loadingCounter[$GLB_curBot] = 0
			$GUI_DATA_LoginErrors[$GLB_curBot] = 0
		Else
			Local $character = GUICtrlRead($GUI_character[$GLB_curBot])
			;enter directly due to Lenovo bug
			ACT_EnterGame($character)

			ACT_RandomMouseMoves()
			BOT_incrementLoadingCounter()
			BOT_CheckTimeout("waiting")
		EndIf
	Else
		BOT_LogMessage("Unsupported state for info", 1)
		BOT_FixLocationAndState("info", $state)
	EndIf
	Return True
EndFunc   ;==>BOT_StateInfo

;check ingame state
Func BOT_StateInGame()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	If $state = "waiting" Then
		; check is loaded
		If OCR_DetectMainMenu() Then
			UTL_Wait(2, 3)
			ACT_ActivatePAPTab()
			ACT_SwitchChatTab()
			;BOT_CheckSorting("pap")
			UTL_Wait(2, 3)
			If OCR_DetectUndockButton() Then
				; check for undock button
				GUI_SetLocationAndState("station", "free")
				;try to open cargo if closed
				If Not OCR_DetectInventoryWindow() Then
					ACT_OpenCargo()
					UTL_Wait(2, 3)
				EndIf
				ACT_InventoryActivateTopItem()

				; activate ore hold for miner
				If GUI_isRole("Belt Miner") Or GUI_isRole("Anomaly Miner") Then
					ACT_InventoryActivateItem(3)
				EndIf

				ACT_RandomMouseMoves(1, 500, 0, 1000, 500)

				;ACT_InventoryActivateItem($GLB_inventoryWindow_treeShipPosition)
				UTL_SetWaitTimestamp(10)
				UTL_SetTimeout("cargo")
			Else
				GUI_SetLocationAndState("ingame", "free")
				UTL_LogScreen("Logged in", "ingame")
				UTL_SetWaitTimestamp(20)
			EndIf
			GUI_SetLastActionTime()
			$GUI_loadingCounter[$GLB_curBot] = 0
			$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False
		Else
			BOT_incrementLoadingCounter()
		EndIf
		BOT_CheckTimeout("waiting")
	ElseIf $state = "free" Then
		If OCR_DetectMainMenu() Then
			Local $loc = "space", $stt = "free"

			ACT_SetView()

			;try to open cargo if closed
			If Not OCR_DetectInventoryWindow() Then
				ACT_OpenCargo()
				UTL_Wait(2, 3)
			EndIf

			; activate ore hold for miner
			If GUI_isRole("Belt Miner") Then
				ACT_InventoryActivateItem(3)
				UTL_Wait(1, 2)
			EndIf

			; set destination for Courier role
			If GUI_isRole("Courier") Then
				Local $cargo = BOT_CheckCargo()
				BOT_LogMessage("Check destination", 1)
				If $cargo = 0 Then
					Local $PAP_bookmarkStationState = OCR_getPNPItemType(GUI_BookmarkGetPosition("station"))
					If $PAP_bookmarkStationState <> "destination" Then
						BOT_LogMessage("Recover base", 1)
						ACT_SetDestination(GUI_BookmarkGetPosition("station"))
					EndIf
				Else
					Local $PAP_bookmarkDestinationState = OCR_getPNPItemType(GUI_BookmarkGetPosition("destination"))
					If $PAP_bookmarkDestinationState <> "destination" Then
						BOT_LogMessage("Recover destination", 1)
						ACT_SetDestination(GUI_BookmarkGetPosition("destination"))
					EndIf
				EndIf
				UTL_Wait(1, 2)
			EndIf

			;check for asteroid in asteroids tab
			ACT_SwitchTab("asteroids")
			If OCR_CheckAsteroidPresent() <> False Then
				$loc = "belt"
				If GUI_isHunter() Then
					ACT_SwitchTab("npc")
					If OCR_CheckNPCPresent() <> False Then
						$stt = "npc"
					EndIf
				Else
					If GUI_getSecurityStatus() = "Low" Then
						GUICtrlSetData($GUI_dronesOnReturn[$GLB_curBot], "Spot")
					Else
						$stt = "drones"
						GUICtrlSetData($GUI_dronesOnReturn[$GLB_curBot], "Station")
					EndIf
				EndIf
			Else
				If GUI_getSecurityStatus() = "Low" Then
					ACT_SwitchTab("npc")
					If GUI_isHunter() And OCR_CheckNPCPresent() <> False Then
						$loc = "belt"
						$stt = "npc"
					Else
						Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
						If $POS = "Station" Or $POS = "None" Then
							Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
							If $huntPlace = "Anomaly" Then
								$loc = "anomaly"
							Else
								ACT_WarpTo("belts", 1)
								$loc = "belt"
							EndIf

						ElseIf $POS = "Station and POS" Or $POS = "POS" Then
							ACT_WarpTo("pos", 1, True)
							$loc = "pos"
						EndIf
						UTL_SetWaitTimestamp(20)
						$stt = "free"
					EndIf
				Else
					$loc = "space"
				EndIf
			EndIf

			;collect loosed drones if need
			If GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED Then
				ACT_SwitchTab("drones")
				If OCR_CheckDronePresent() <> False Then
					$stt = "dronesReturn"
					GUICtrlSetData($GUI_dronesOnReturn[$GLB_curBot], "Station")
					UTL_SetTimeout("drones")
				EndIf
			EndIf

			GUI_SetLocationAndState($loc, $stt)

			$GUI_loadingCounter[$GLB_curBot] = 0
		Else
			BOT_incrementLoadingCounter()
		EndIf
	Else
		BOT_LogMessage("Unsupported state for ingame", 1)
		BOT_FixLocationAndState("ingame", $state)
	EndIf

	Return True
EndFunc   ;==>BOT_StateInGame

;check station state
Func BOT_StateStation()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	Local $cargo = BOT_CheckCargo()

	If $GLB_stayInStation[$GLB_curBot] >= 0 Then
		BOT_CheckLocal()
	EndIf

	If GUI_isFleetCommander() Then
		Local $oreCargo = OCR_CalculateOreCargo()
	EndIf

	If $state = "free" Then
		If GUI_isRole("Anomaly Miner") Then
			AnomalyMiner("station", "free")
			Return True
		ElseIf GUI_isRole("Courier") Then
			Courier("station", "free")
			Return True
		ElseIf GUI_isRole("Hunter") Then
			Hunter("station", "free")
			Return True
		ElseIf GUI_isRole("Watcher") Then
			Watcher("station", "free")
			Return True
		EndIf

		BOT_checkInventory()

		; if cargo bar not loaded wait and check cargo again
		If $cargo = 0 Then
			ACT_StackAll("cargo")
			ACT_RandomMouseMoves(1, 500, 0, 1000, 500)
			UTL_Wait(2, 3)
			$cargo = BOT_CheckCargo()
		EndIf

		; hide inventory filters panel
		;BOT_CheckInventoryFilters()

		;if miner reset skiped containers
		If GUI_isMiner() Or GUI_isTransporter() Then
			GUICtrlSetData($GUI_skipedContainers[$GLB_curBot], "0")
		EndIf

		If Not BOT_checkAlarm("station") Then
			Return True
		EndIf

		If GUI_isFleetCommander() Then
			ACT_ActivateStationPanel()
			ACT_OpenFitting()
			UTL_Wait(2, 3)
			ACT_OpenShipCorpHangarInStation()
			ACT_OpenFitting()
			UTL_Wait(1, 2)
			Local $corpHangarCargo = OCR_CalculateCorpHangarCargo()
		EndIf

		If GUI_isFleetCommander() And ($cargo > 0 Or $oreCargo > 0 Or $corpHangarCargo > 0) Then
			BOT_LogMessage("C,O,CH: " & $cargo & ", " & $oreCargo & ", " & $corpHangarCargo, 1)
			Local $unloadTo = GUICtrlRead($GUI_UnloadToCombo[$GLB_curBot])
			If $unloadTo = "Items" Then
				BOT_LogMessage("Fleet commander could unload only into CorpHangar! Bot disabled", 1)
				GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			ElseIf $unloadTo = "CorpHangar" Then
				ACT_SortByName("cargo")
				ACT_SortByName("items")
				ACT_OpenCorpHangar()
				;TODO open ore hold

				ACT_OpenFitting()
				UTL_Wait(2, 3)
				ACT_OpenShipCorpHangarInStation()
				ACT_OpenFitting()
				ACT_ActivateCorpHangarTab(1, $GLB_fleetCommanderCorpHangarWindow)

				ACT_SortByName("fleetCommCorpHangar")
				If $cargo > 0 Then
					ACT_MoveAllCargoToCorpHangar()
				EndIf
				If $oreCargo > 0 Then
					ACT_MoveAllOreCargoToCorpHangar()
				EndIf

				If $corpHangarCargo > 0 Then
					ACT_MoveAllShipCorpHangarCargoToCorpHangar()
				EndIf
				UTL_Wait(2, 3)
			EndIf
		ElseIf Not GUI_isFleetCommander() And $cargo > 0 Then
			Station_unloadCargo("ore")
			UTL_Wait(2, 2.5)
		Else
			; repair all if drones used
			If GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED And GUICtrlRead($GUI_repairDrones[$GLB_curBot]) = $GUI_CHECKED Then
				Station_repairDrones()
			EndIf

			Station_undock()
		EndIf

		GUI_SetLastActionTime()

		BOT_CheckTimeout("station")
	ElseIf $state = "delay" Then
		If GUI_isRole("Watcher") Then
			Watcher("station", "delay")
			Return True
		EndIf
		UTL_SetTimeout("station")
		GUI_SetLocationAndState("station", "free")
	ElseIf $state = "warping" Then
		BOT_CheckWarp("station")
	ElseIf $state = "warpWaiting" Then
		BOT_CheckWarpWait("station")
	ElseIf $state = "waiting" Then
		Local $undock = OCR_DetectUndockButton()
		If $undock Then
			BOT_LogMessage("Station dock detected")
			GUI_SetLocationAndState("station", "free")
			UTL_SetTimeout("waiting", True)
			UTL_SetTimeout("station")
			UTL_Wait(2, 3)
		Else
			BOT_LogMessage("Waiting for station dock")
			BOT_CheckTimeout("waiting")
		EndIf
	ElseIf $state = "closeAndWait" Then
		; if no enemies in local
		If BOT_CheckLocal() Then
			GUI_SetLocationAndState("station", "free")
		Else
			BOT_CloseWindow("Enemy found, station logout")
			Local $wait = GUICtrlRead($GUI_enemyTimeoutInput)
			If $wait < 0 Then
				$wait = GUICtrlRead($GUI_enemyTimeoutInput)
			EndIf
			UTL_SetWaitTimestamp($wait * 60 + Round(Random(-1, 1)))
			GUI_SetLocationAndState("closed", "delay")

			; reset anomalies
			If GUICtrlRead($GUI_huntingPlace[$GLB_curBot]) = "Anomaly" Then
				GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], 1)
			EndIf
		EndIf
	Else
		BOT_LogMessage("Unsupported state for station", 1)
		BOT_FixLocationAndState("station", $state)
	EndIf
EndFunc   ;==>BOT_StateStation

;check space state
Func BOT_StateSpace()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])

	;if cargo empty and we are in space
	If $state = "free" Then
		If GUI_isRole("Anomaly Miner") Then
			AnomalyMiner("space", "free")
			Return True
		ElseIf GUI_isRole("Courier") Then
			Courier("space", "free")
			Return True
		ElseIf GUI_isRole("Hunter") Then
			Hunter("space", "free")
			Return True
		ElseIf GUI_isRole("Watcher") Then
			Watcher("space", "free")
			Return True
		EndIf

		;if enemy was not found in station, but appeared after undock
		If $GLB_stayInStation[$GLB_curBot] <> -5 And $GLB_stayInStation[$GLB_curBot] <> -6 Then
			BOT_CheckLocal()
		EndIf

		Local $cargo = BOT_CheckCargo()
		If $cargo < 5 And $GLB_stayInStation[$GLB_curBot] = 0 And $GLB_forcedUnload[$GLB_curBot] = 0 Then
			; warp to belt or anomaly
			Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])

			; fly to fleet commander
			If GUI_isFleetMiner() And GUI_getFleetCommBookmark() Then
				BOT_LogMessage("Warping to Fleet commander", 1)
				$curBookmark = GUI_getFleetCommBookmark()
				;ElseIf GUI_isRole("Belt Miner") Then
				;	$curBookmark = BOT_GetNextBookmark()
				GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $curBookmark)
			EndIf

			; warp to belt or anomaly
			Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
			Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
			If $huntPlace = "Belt" Then
				ACT_WarpTo("belts", $curBookmark)
			ElseIf $huntPlace = "Anomaly" Then
				ACT_WarpTo("anomaly", $curBookmark)
			Else
				;TODO unknown hunt place
			EndIf
		Else
			ACT_ActivatePAPTab()
			ACT_DockToStation()
		EndIf
	ElseIf $state = "warping" Then
		BOT_CheckWarp("belt")
	ElseIf $state = "warpWaiting" Then
		BOT_CheckWarpWait("space")
	ElseIf $state = "waiting" Then
		If OCR_DetectMainMenu() And Not OCR_DetectUndockButton() Then
			BOT_LogMessage("Space detected")
			UTL_SetTimeout("station", True)
			ACT_SetView()
			GUI_SetLocationAndState("space", "free")
			UTL_SetTimeout("waiting", True)
		Else
			BOT_CheckTimeout("waiting")
		EndIf
	ElseIf $state = "flying" Then
		If GUI_isRole("Courier") Then
			Courier("space", "flying")
		EndIf
	Else
		BOT_LogMessage("Unsupported state for space", 1)
		BOT_FixLocationAndState("space", $state)
	EndIf
EndFunc   ;==>BOT_StateSpace

;check space state
Func BOT_StateSpot()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])

	;if cargo empty and we are in spot
	If $state = "free" Then
		If GUI_isRole("Anomaly Miner") Then
			AnomalyMiner("spot", "free")
			Return True
		ElseIf GUI_isRole("Hunter") Then
			Hunter("spot", "free")
			Return True
		ElseIf GUI_isRole("Watcher") Then
			Watcher("spot", "free")
			Return True
		EndIf

		Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])

		If $GLB_stayInStation[$GLB_curBot] = 0 Then
			BOT_CheckLocal()
		EndIf

		If $GLB_stayInStation[$GLB_curBot] <> 0 Then
			If $POS = "Station" Then
				ACT_DockToStation(True)
			ElseIf $POS = "Station and POS" Or $POS = "POS" Then
				ACT_WarpTo("pos")
			ElseIf $POS = "None" Then
				BOT_checkAlarm("spot")
			EndIf
			Return False
		EndIf

		Local $cargo = BOT_CheckCargo()

		If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
			If $POS = "Station" Then
				ACT_DockToStation(True)
			ElseIf $POS = "Station and POS" Or $POS = "POS" Then
				ACT_WarpTo("pos")
			ElseIf $POS = "None" Then
				$GLB_forcedUnload[$GLB_curBot] = 0
				GUI_SetLocationAndState("spot", "unloading")
			EndIf
		Else
			; warp to belt or anomaly
			Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
			Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
			If $huntPlace = "Belt" Then
				ACT_WarpTo("belts", $curBookmark)
			ElseIf $huntPlace = "Anomaly" Then
				GUI_SetLocationAndState("anomaly", "next")
			Else
				;TODO unknown hunt place
			EndIf
		EndIf
	ElseIf $state = "warping" Then
		BOT_CheckWarp("spot")
	ElseIf $state = "warpWaiting" Then
		BOT_CheckWarpWait("spot")
	ElseIf $state = "delay" Then
		If GUI_isRole("Watcher") Then
			Watcher("spot", "delay")
			Return True
		EndIf
	ElseIf $state = "ammo" Then
		If GUI_isRole("Hunter") Then
			Hunter("spot", "ammo")
			Return True
		EndIf
	ElseIf $state = "unloading" Then
		ACT_SwitchTab("containers")

		Local $posContainer = OCR_CheckContainerPresent()

		If $posContainer <> False Then
			ACT_ClickOverviewObject($posContainer[2])
			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($posContainer[2]))
			If $distance < 2500 Then
				ACT_OpenContainer($posContainer)
				UTL_Wait(2, 3)

				Local $leaveFirstItem = (GUICtrlRead($GUI_leaveOneItemInCargoCheckbox[$GLB_curBot]) = $GUI_CHECKED)

				If $leaveFirstItem = True Then
					$leaveFirstItem = 1
				Else
					$leaveFirstItem = 0
				EndIf

				ACT_InventoryActivateTopItem()
				UTL_Wait(1, 2)
				ACT_InventoryMoveItems("shipCargo", "container", True, $leaveFirstItem)
				UTL_Wait(2, 3)

				GUI_SetLocationAndState("spot", "free")
			Else
				ACT_SI_ObjectApproach("container")
				BOT_LogMessage("Container too far away - " & $distance & " m", 1)
			EndIf
		Else
			BOT_LogMessage("Spot storage not found", 1)
			UTL_LogScreen("Spot storage not found", "pos")
			GUI_SetLocationAndState("spot", "noStorage")
		EndIf
	ElseIf $state = "scan" Then
		; open scanner
		ACT_OpenScanner()
		UTL_Wait(1, 2)
		; scan
		ACT_LaunghScanner()
		GUI_SetLocationAndState("spot", "scanned")
		UTL_SetWaitTimestamp($GLB_ScanWaitTime)
	ElseIf $state = "scanned" Then
		ACT_WarpToScannerItem(GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
		UTL_Wait(1, 2)
		; close scanner
		ACT_CloseScanner()
	ElseIf $state = "noStorage" Then
		BOT_CloseWindow("Spot storage not found, logout")
		GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
	Else
		BOT_LogMessage("Unsupported state for spot", 1)
		BOT_FixLocationAndState("spot", $state)
	EndIf
EndFunc   ;==>BOT_StateSpot

;check POS state
Func BOT_StatePOS()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	Local $cargo = BOT_CheckCargo()
	Local $unloadTo = GUICtrlRead($GUI_UnloadToCombo[$GLB_curBot])

	If $state = "free" Then
		If GUI_isRole("Hunter") Then
			Hunter("pos", "free")
			Return True
		ElseIf GUI_isRole("Watcher") Then
			Watcher("pos", "free")
			Return True
		EndIf

		If $GLB_stayInStation[$GLB_curBot] >= 0 Then
			BOT_CheckLocal()
		EndIf

		; hide inventory filters panel
		;BOT_CheckInventoryFilters()

		If Not BOT_checkAlarm("pos") Then
			Return True
		ElseIf $GLB_forcedUnload[$GLB_curBot] = 1 Then
			BOT_LogMessage("Forced unload", 1)
			UTL_LogScreen("Forced unload", "pos")
			GUI_SetLocationAndState("pos", "unloading")
			$GLB_forcedUnload[$GLB_curBot] = 0
		ElseIf $cargo > GUICtrlRead($GUI_fullCargo[$GLB_curBot]) And $unloadTo = "POS" Then
			GUI_SetLocationAndState("pos", "unloading")
		Else
			BOT_WarpTo("Spot")
		EndIf
	ElseIf $state = "ammo" Then
		If GUI_isRole("Hunter") Then
			Hunter("pos", "ammo")
			Return True
		EndIf
	ElseIf $state = "unloading" Then
		ACT_SwitchTab("containers")

		Local $posCorpHangar = OCR_CheckCorpHangarPresent()

		If $posCorpHangar <> False Then
			ACT_ClickOverviewObject($posCorpHangar[2])
			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($posCorpHangar[2]))
			If $distance < 2500 Then
				ACT_OpenContainer($posCorpHangar, False, True)
				UTL_Wait(2, 3)

				Local $leaveFirstItem = (GUICtrlRead($GUI_leaveOneItemInCargoCheckbox[$GLB_curBot]) = $GUI_CHECKED)

				If $leaveFirstItem = True Then
					$leaveFirstItem = 1
				Else
					$leaveFirstItem = 0
				EndIf

				;ACT_InventoryOpenInSeparateWindow(3)
				;UTL_Wait(2, 3)
				ACT_InventoryActivateTopItem()
				UTL_Wait(1, 2)

				If $cargo = 100 And $leaveFirstItem Then
					UTL_LogScreen("Cargo is too full", "cargo")
					ACT_InventoryMoveItems("shipCargo", "corpHangar", True, False)
				Else
					ACT_InventoryMoveItems("shipCargo", "corpHangar", True, $leaveFirstItem)
				EndIf

				UTL_Wait(2, 3)
				ACT_CloseCorpHangar()

				GUI_SetLocationAndState("pos", "skip")
			Else
				ACT_SI_ObjectApproach("container")
				BOT_LogMessage("POS coprorate hangar too far away - " & $distance & " m", 1)
			EndIf
		Else
			BOT_LogMessage("POS storage not found", 1)
			UTL_LogScreen("POS storage not found", "pos")
			GUI_SetLocationAndState("pos", "noStorage")
		EndIf
	ElseIf $state = "warping" Then
		BOT_CheckWarp("pos")
	ElseIf $state = "warpWaiting" Then
		BOT_CheckWarpWait("pos")
	ElseIf $state = "delay" Then
		If GUI_isRole("Watcher") Then
			Watcher("pos", "delay")
			Return True
		EndIf
		GUI_SetLocationAndState("pos", "free")
	ElseIf $state = "closeAndWait" Then
		; if no enemies in local
		If BOT_CheckLocal() Then
			GUI_SetLocationAndState("pos", "free")
		Else
			BOT_CloseWindow("Enemy found, POS logout")
			Local $wait = GUICtrlRead($GUI_enemyTimeoutInput)
			If $wait < 0 Then
				$wait = GUICtrlRead($GUI_enemyTimeoutInput)
			EndIf
			UTL_SetWaitTimestamp($wait * 60 + Round(Random(-1, 1)))
			GUI_SetLocationAndState("closed", "delay")

			; reset anomalies
			If GUICtrlRead($GUI_huntingPlace[$GLB_curBot]) = "Anomaly" Then
				GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], 1)
			EndIf
		EndIf
	ElseIf $state = "noStorage" Then
		BOT_CloseWindow("POS storage not found, logout")
		GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
	ElseIf $state = "skip" Then
		; skip hanging places
		GUI_SetLocationAndState("pos", "free")
	Else
		BOT_LogMessage("Unsupported state for pos", 1)
		BOT_FixLocationAndState("pos", $state)
	EndIf
EndFunc   ;==>BOT_StatePOS

;check belt state
Func BOT_StateBelt()
	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	Local $fullCargo = GUICtrlRead($GUI_fullCargo[$GLB_curBot])
	Local $container, $cargoContainer, $fullCargoContainer
	Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
	Local $lockDistance = GUICtrlRead($GUI_lockDistance[$GLB_curBot])

	If $GLB_stayInStation[$GLB_curBot] >= 0 Then
		If BOT_CheckLocal() = False And GUICtrlRead($GUI_systemPOS[$GLB_curBot]) = "None" Then
			Return
		EndIf
	EndIf

	; force back to station
	If $state <> "warpWaiting" And $state <> "warping" And $state <> "drones" Then
		If $GLB_stayInStation[$GLB_curBot] > 0 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Need pause. Go to spot from belt", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Need pause. Go to station from belt", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -2 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Downtime. Go to spot from belt", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Downtime. Go to station from belt", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -2.1 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Scheduled stop. Go to spot from belt", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Scheduled stop. Go to station from belt", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -4 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Fleet commander offline. Go to spot from belt", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Fleet commander offline. Go to station from belt", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -5 Or $GLB_stayInStation[$GLB_curBot] = -6 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Enemy found. Go to spot from belt", 1)
				Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
				If $POS = "None" Then
					; warp to first spot with container
					ACT_WarpTo("spot", 1)
				Else
					BOT_WarpTo("Spot")
				EndIf
			Else
				BOT_LogMessage("Enemy found. Go to station from belt", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] < -6 And $GLB_stayInStation[$GLB_curBot] > -11 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("License error " & $GLB_stayInStation[$GLB_curBot] & ". Go to spot from belt", 1)
				Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
				If $POS = "None" Then
					; warp to first spot with container
					ACT_WarpTo("spot", 1)
				Else
					BOT_WarpTo("Spot")
				EndIf
			Else
				BOT_LogMessage("License error. Go to station from belt", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		EndIf
	EndIf

	;we need to unload cargo
	If $state = "unloading" Then
		If GUI_isRole("Belt Miner") Then
			BeltMiner("belt", "unloading")
			Return True
		EndIf

		Local $cargo = BOT_CheckCargo()
		; if window closed on cargo timeout
		If $cargo = -1 Then
			Return False
		EndIf

		If GUI_isMiner() Then
			If $cargo >= $fullCargo Then
				Local $openCargoTries = 0
				If Not OCR_DetectContainerWindow() Then
					While Not OCR_DetectContainerWindow()
						If $openCargoTries >= 3 Then
							BOT_CloseWindow("Hang during container open!")
							Return False
						EndIf

						ACT_SwitchTab("containers")
						$container = OCR_CheckContainerPresent()
						If $container <> False Then
							ACT_ClickOverviewObject($container, True)
							ACT_SI_ObjectApproach("container")

							ACT_OpenContainer($container)
							UTL_Wait(2, 3)
						EndIf
						$openCargoTries += 1
					WEnd
				EndIf

				$fullCargoContainer = GUICtrlRead($GUI_fullContainerCargo[$GLB_curBot])
				$cargoContainer = BOT_GetContainerCargo()

				If $cargoContainer > $fullCargoContainer Then
					Local $skipedContainers = GUICtrlRead($GUI_skipedContainers[$GLB_curBot]) + 1
					Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
					GUICtrlSetData($GUI_skipedContainers[$GLB_curBot], $skipedContainers)

					If $skipedContainers < $maxBookmark Then
						BOT_LogMessage("Container is full. Skiping it", 1)
						GUI_SetLocationAndState("belt", "next")
					Else
						BOT_LogMessage("All containers are skiped", 1)
						BOT_WarpTo("Station")
					EndIf
				Else
					ACT_SortByName("cargo")
					If $cargoContainer >= 85 Then
						ACT_MoveAllCargoToContainer(False)
					Else
						ACT_MoveAllCargoToContainer()
					EndIf
					;UTL_Wait(1.5, 2)
					;Local $newContainerCargo = BOT_GetContainerCargo()

					; check if cargo not changed
					;If $newContainerCargo = $cargoContainer And $cargoContainer <> 100 Then
					;	BOT_CloseWindow("Unload to container doesn't work")
					;	Return False
					;EndIf

					GUICtrlSetData($GUI_skipedContainers[$GLB_curBot], "0")
					GUI_SetLocationAndState("belt", "mining")
				EndIf
			Else
				GUI_SetLocationAndState("belt", "free")
			EndIf
		ElseIf GUI_isTransporter() Then
			BOT_WarpTo("Station")
		ElseIf GUI_isFleetCommander() Then
			GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], BOT_GetNextBookmark())
			BOT_WarpTo("Station")
		ElseIf GUI_isFleetMiner() Then
			ACT_SwitchTab("default")
			Local $commandShip = OCR_CheckFleetOrcaPresent()
			If $commandShip <> False Then
				ACT_ClickOverviewObject($commandShip[2])
				ACT_SI_ObjectOrbit("fleetCommander")

				; if corp hangar present
				If Not OCR_DetectShipCorpHangarWindow() Then
					;Local $distDetector = TOCR_GetOverviewObjectDistance($commandShip[2], "fleet", "selected")
					Local $distDetector = Int(EVEOCR_GetOverviewObjectDistance($commandShip[2]))
					If $distDetector = False Then
						Local $distance = 20000
					Else
						Local $distance = Int($distDetector)
					EndIf

					BOT_LogMessage("Distance to fleet commander: " & $distance & " m", 1)
					If $distance > 10000 Then
						BOT_LogMessage("Keep flying to fleet commander", 1)
						Return True
					EndIf

					ACT_OpenFleetCommCorpHangar($commandShip[0], $commandShip[1])
					UTL_Wait(1, 2)
					ACT_ActivateCorpHangarTab(1, $GLB_shipCorpHangarWindow)
				EndIf

				Local $commandShipCorpHangarCargo = OCR_CalculateShipCorpHangarCargo()
				If $commandShipCorpHangarCargo < GUI_getFleetCommFulCargo() Then
					BOT_LogMessage("Unloading to Fleet commander", 1)
					ACT_SortByName("cargo")
					If $commandShipCorpHangarCargo >= 85 Then
						BOT_LogMessage("Fleet commander is near full! Unloading one item", 1)
						ACT_MoveAllCargoToShipCorpHangar(False)
					Else
						ACT_MoveAllCargoToShipCorpHangar()
					EndIf

					ACT_SwitchTab("lensedAsteroids")
					Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

					If $asteroidsAmount > 0 Then
						BOT_ActivateMining($asteroidsAmount)
					Else
						ACT_SwitchTab("asteroids")
						$asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

						If $asteroidsAmount > 0 Then
							BOT_ActivateMining($asteroidsAmount)
						EndIf
					EndIf
					GUI_SetLocationAndState("belt", "mining")
				Else
					UTL_LogScreen("Fleet commander has full(" & $commandShipCorpHangarCargo & "%) corphangar! Unloading to station")
					BOT_LogMessage("Fleet commander has full(" & $commandShipCorpHangarCargo & "%) corphangar! Unloading to station", 1)
					BOT_WarpTo("Station")
				EndIf
			Else
				UTL_LogScreen("Fleet commander not found! Unloading to station")
				BOT_LogMessage("Fleet commander not found! Unloading to station", 1)
				BOT_WarpTo("Station")
			EndIf
		ElseIf GUI_isRole("Hunter") Or GUI_isRole("Marauder") Then
			If GUI_getSecurityStatus() = "Low" Then
				Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
				If $POS = "None" Then
					; warp to first spot with container
					ACT_WarpTo("spot", 1)
				Else
					BOT_WarpTo("Spot")
				EndIf
			Else
				BOT_WarpTo("Station")
			EndIf
		EndIf
	ElseIf $state = "free" Then
		If GUI_isRole("Belt Miner") Then
			BeltMiner("belt", "free")
			Return True
		EndIf

		If GUI_isRole("Hunter") Then
			Hunter("belt", "free")
			Return True
		EndIf

		Local $cargo = BOT_CheckCargo()
		; if window closed on cargo timeout
		If $cargo = -1 Then
			Return False
		EndIf

		;do not act if NPC found
		If GUI_isRole("Marauder") Or GUI_getSecurityStatus() = "Low" Then
			ACT_SwitchTab("npc")
			Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
			If $NPCcounter <> False And $NPCcounter > 1 Then
				Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
				If $maxBookmark = 1 Then
					BOT_LogMessage("NPC found. Run away from the belt", 1)
					$GLB_stayInStation[$GLB_curBot] = 60 * 3
					BOT_WarpTo("Spot")
				Else
					BOT_LogMessage("NPC found. Changing belt", 1)
					GUI_SetLocationAndState("belt", "next")
				EndIf
				Return
			EndIf
		EndIf

		If Space_launchDrones() = False Then
			Return False
		EndIf

		ACT_SetView()

		; if allowed to attack NPC and guns present
		If GUICtrlRead($GUI_attackNPCCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetBotGunsAmount() > 0 Then
			; if no ammo in cargo
			If GUI_isRole("Hunter") And $cargo < 10 Then
				BOT_LogMessage("Too low ammo", 1)
				If GUI_getSecurityStatus() = "Low" Then
					Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
					If $POS = "None" Then
						; warp to first spot with container
						ACT_WarpTo("spot", 1)
					Else
						BOT_WarpTo("Spot")
					EndIf
				Else
					ACT_DockToStation(True)
				EndIf
				Return
			EndIf

			;try to find NPC
			ACT_SwitchTab("npc")
			BOT_CheckSorting("overview", "icon")

			Local $NPC = BOT_CheckNPC()

			If $NPC <> False Then
				UTL_LogScreen("NPC found", "npc")
				BOT_LogMessage("NPC found", 1)
				SPEECH_Notify("overviewNPCFound")

				Local $distance = Int(EVEOCR_GetOverviewObjectDistance($NPC[2]))
				BOT_LogMessage("Distance to NPC at arrival: " & $distance & " m", 1)
				If $distance > GUICtrlRead($GUI_lockDistance[$GLB_curBot]) * 1000 Then
					BOT_LogMessage("NPC too far away at arrival(limit " & GUICtrlRead($GUI_lockDistance[$GLB_curBot]) & " km)", 1)
					$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False
					GUI_SetLocationAndState("belt", "next")
					Return
				EndIf

				ACT_ReactivateGuns()

				If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
					ACT_ActivateModule("middle", "targetPainter")
				EndIf

				ACT_ClickOverviewObject($NPC[2])
				UTL_SetWaitTimestamp(UTL_CalcLockTime($NPC[3]))
				ACT_RandomMouseMoves(1, 50, 0, 700, 500)

				GUI_SetLocationAndState("belt", "npc")

				If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "shield"))  Then
					ACT_ActivateModule("middle", "shield")
				EndIf

				GUI_SetLastActionTime()
				Return True
			Else
				BOT_LogMessage("Suitable NPC not found", 1)
				If GUI_isHunter() Then
					$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = False
					If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
						GUI_SetLocationAndState("belt", "next")
						Return
					EndIf
				EndIf
			EndIf
		EndIf

		; if allowed to loot wreks
		If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED Then
			;try to find Wrek
			ACT_SwitchTab("npc")
			BOT_CheckSorting("overview", "distance")
			Local $overviewSize = False
			If GUI_isFleetCommander() Then
				$overviewSize = 3
			EndIf

			Local $wreckType = "any"
			Local $isFaction = False
			If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
				$wreckType = "own"
			EndIf
			If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
				$isFaction = True
			EndIf

			Local $wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)

			If $wreck <> False Then
				BOT_LogMessage("Wreck found", 1)
				If Not BOT_CheckSorting("overview") Then
					$wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)
					;if wreck disapeared
					If $wreck = False Then
						BOT_LogMessage("Wreck disappeared", 1)
						Return
					EndIf
				EndIf
				Local $distance = Int(EVEOCR_GetOverviewObjectDistance($wreck[2]))
				BOT_LogMessage("Distance to wreck: " & $distance & " m", 1)
				If GUI_isFleetCommander() Then
					; ignore wrecks on start
				ElseIf Not GUI_isRole("Hunter") And Not GUI_isRole("Marauder") And $distance < 20000 Then
					ACT_ActivateModule("high", "tractor")
					ACT_ClickOverviewObject($wreck[2])
					ACT_RandomMouseMoves()
					UTL_SetTimeout("tractoring")
					GUI_SetLocationAndState("belt", "wreckTractoring")
					Return True
				ElseIf GUI_isRole("Marauder") Then
					If $distance > 150000 Then
						ACT_WarpToOverviewObject($wreck[2])
						GUI_SetLocationAndState("space", "warping")
						Return
					ElseIf $distance < 20000 Then
						ACT_ActivateModule("high", "tractor")
					EndIf
					ACT_ClickOverviewObject($wreck[2])
					ACT_SI_ObjectApproach("wreck")
					GUI_SetLocationAndState("belt", "wreck")
					UTL_SetWaitTimestamp(5)
					Return True
				Else
					BOT_LogMessage("Wreck too far away", 1)
				EndIf
			Else
				BOT_LogMessage("No wrecks in belt", 1)
				If GUI_isRole("Marauder") Then
					GUI_SetLocationAndState("belt", "next")
					Return True
				EndIf
			EndIf
		EndIf

		;if role miner only - open container
		If GUI_isMiner() Then
			ACT_StopEngine()
			ACT_SwitchTab("containers")
			$container = OCR_CheckContainerPresent()
			If $container <> False Then
				BOT_CheckSorting("overview")
				ACT_ClickOverviewObject($container, True)
				ACT_SI_ObjectApproach("container")
				GUI_SetLocationAndState("belt", "container")
				UTL_SetWaitTimestamp(10)
			Else
				BOT_LogMessage("Container not found", 1)
				UTL_LogScreen("Container not found")
				GUI_SetLocationAndState("belt", "next")
			EndIf
		ElseIf GUI_isTransporter() Then
			ACT_StopEngine()

			;check container
			ACT_SwitchTab("containers")
			Local $container = OCR_CheckContainerPresent()
			If $container <> False Then
				BOT_CheckSorting("overview")
				ACT_ObjectApproach($container)
				UTL_SetWaitTimestamp(10)
				GUI_SetLocationAndState("belt", "container")
			Else
				BOT_LogMessage("Container not found", 1)
				GUI_SetLocationAndState("belt", "next")
			EndIf
		ElseIf GUI_isFleetCommander() Then
			; if fleet commander check fleet state
			ACT_StopEngine()

			ACT_SwitchTab("asteroids")
			BOT_CheckSorting("overview")
			;Local $distDetector = TOCR_GetOverviewObjectDistance()
			Local $distDetector = Int(EVEOCR_GetOverviewObjectDistance())
			If $distDetector <> False And Int($distDetector) > 15000 Then
				BOT_LogMessage("Asteroids too far away changing belt", 1)
				UTL_LogScreen("Asteroids too far away changing belt", "faraway")
				GUI_SetLocationAndState("belt", "next")
				Return True
			EndIf

			ACT_OpenFleet()
			UTL_Wait(4, 5)

			; if fleet not created
			If OCR_DetectFleetCreation() Then
				BOT_LogMessage("Creating fleet", 1)
				ACT_CreateFleet()
				UTL_Wait(4, 5)
			Else
				BOT_LogMessage("Fleet already created", 1)
			EndIf

			If BOT_InviteAllToFleet() Then
				BOT_CheckAllBotsForFleet()
			EndIf

			ACT_ActivateModule("high", "gang")

			GUI_SetLocationAndState("belt", "commanding")
		ElseIf GUI_isFleetMiner() Then
			ACT_SwitchTab("default")
			Local $commandShip = OCR_CheckFleetOrcaPresent()
			If $commandShip <> False Then
				BOT_CheckSorting("overview")
				BOT_LogMessage("Fleet commander found! Joining", 1)
				ACT_ClickOverviewObject($commandShip[2])
				ACT_SI_ObjectOrbit("fleetCommander")
				GUI_SetLocationAndState("belt", "joinCommander")
				UTL_SetWaitTimestamp(30)
			Else
				BOT_LogMessage("Fleet commander not found! Simple mining", 1)
				ACT_SwitchTab("lensedAsteroids")
				BOT_CheckSorting("overview")
				Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

				If $asteroidsAmount > 1 Then
					BOT_ActivateMining($asteroidsAmount)
				Else
					ACT_SwitchTab("asteroids")
					$asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

					If $asteroidsAmount > 0 Then
						BOT_ActivateMining($asteroidsAmount)
					Else
						; switch state if nothing found
						GUI_SetLocationAndState("belt", "mining")
					EndIf
				EndIf
				ACT_ClickOverviewObject()
				ACT_SI_ObjectOrbit("asteroid")
			EndIf
		EndIf
	ElseIf $state = "joinCommander" Then
		Local $commandShip = OCR_CheckFleetOrcaPresent()
		If $commandShip <> False Then
			ACT_ClickOverviewObject($commandShip[2])
			ACT_RandomMouseMoves(1, 0, 0, 512, 760)
			;Local $distDetector = TOCR_GetOverviewObjectDistance($commandShip[2], "fleet", "selected")
			Local $distDetector = Int(EVEOCR_GetOverviewObjectDistance($commandShip[2]))
			If $distDetector = False Then
				Local $distance = 20000
			Else
				Local $distance = Int($distDetector)
			EndIf

			BOT_LogMessage("Distance to fleet commander: " & $distance & " m", 1)
			If $distance > 10000 Then
				BOT_LogMessage("Keep flying to fleet commander", 1)
				Return True
			EndIf
		EndIf

		ACT_SwitchTab("lensedAsteroids")
		Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

		If $asteroidsAmount > 1 Then
			BOT_ActivateMining($asteroidsAmount)
		Else
			ACT_SwitchTab("asteroids")
			$asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)
			If $asteroidsAmount > 0 Then
				BOT_ActivateMining($asteroidsAmount)
			Else
				; switch state if nothing found
				GUI_SetLocationAndState("belt", "mining")
			EndIf
		EndIf
	ElseIf $state = "commanding" Then
		Local $cargo = BOT_CheckCargo()
		; if window closed on cargo timeout
		If $cargo = -1 Then
			Return False
		EndIf

		If Not OCR_DetectFleetCommCorpHangarWindow() Or Not OCR_DetectFleetCommOreWindow() Then
			ACT_OpenOrcaCargos()
			ACT_ActivateCorpHangarTab(1, $GLB_fleetCommanderCorpHangarWindow)
		EndIf

		Local $oreCargo = OCR_CalculateOreCargo()
		Local $corpHangarCargo = OCR_CalculateCorpHangarCargo()

		If $corpHangarCargo >= $fullCargo - 10 And $oreCargo >= $fullCargo And $cargo >= $fullCargo Then
			GUI_SetLocationAndState("belt", "unloading")
			Return True
		ElseIf $corpHangarCargo > 0 And $oreCargo <= $fullCargo Then
			ACT_SortByName("fleetCommCorpHangar")
			If $oreCargo >= 85 Then
				BOT_LogMessage("Ore hold is near full! Unloading one item", 1)
				ACT_MoveAllCorpHangarCargoToOreHold(False)
			Else
				ACT_MoveAllCorpHangarCargoToOreHold()
			EndIf
		ElseIf $corpHangarCargo > 0 And $oreCargo >= $fullCargo And $cargo <= $fullCargo Then
			ACT_SortByName("fleetCommCorpHangar")
			If $cargo >= 85 Then
				BOT_LogMessage("Cargo is near full! Unloading one item", 1)
				ACT_MoveAllCorpHangarCargoToCargo(False)
			Else
				ACT_MoveAllCorpHangarCargoToCargo()
			EndIf
		EndIf

		Local $newCargo = BOT_CheckCargo()
		Local $newOreCargo = OCR_CalculateOreCargo()
		Local $newCorpHangarCargo = OCR_CalculateCorpHangarCargo()
		BOT_LogMessage("Cargo: " & $newCargo & "%", 1)
		BOT_LogMessage("Cargo ore hold: " & $newOreCargo & "%", 1)
		BOT_LogMessage("Cargo corp hangar: " & $newCorpHangarCargo & "%", 1)
		; update caro timeout if need
		If $newOreCargo <> $oreCargo Or $newCorpHangarCargo <> $GUI_GLB_FleetCommCorpHangarValue Or $corpHangarCargo <> $newCorpHangarCargo Then
			UTL_SetTimeout("cargo")
			$GUI_GLB_FleetCommCorpHangarValue = $newCorpHangarCargo

			If BOT_InviteAllToFleet() Then
				BOT_CheckAllBotsForFleet()
			EndIf
		EndIf

		If Round(Random(0, 9)) >= 6 Then
			BOT_LogMessage("Random fleet check", 1)
			If BOT_InviteAllToFleet() Then
				BOT_CheckAllBotsForFleet()
			EndIf

			; check wrecks
			If GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED Then
				If $newCargo < 99 Then
					GUI_SetLocationAndState("belt", "wreck")
				Else
					BOT_LogMessage("Cargo is full, no place for wrecks", 1)
				EndIf
			EndIf
		EndIf

		; check asteroids
		ACT_SwitchTab("asteroids")
		Local $asteroid = OCR_CheckAsteroidPresent()
		If $asteroid <> False Then
			BOT_LogMessage("Flying to asteroids", 1)
			ACT_ClickOverviewObject()
			ACT_SI_ObjectApproach("asteroid")
		Else
			UTL_LogScreen("Asteroids not found going to next belt")
			BOT_LogMessage("Asteroids not found going to next belt", 1)
			GUI_SetLocationAndState("belt", "next")
		EndIf
	ElseIf $state = "mining" Then
		If GUI_isRole("Belt Miner") Then
			BeltMiner("belt", "mining")
			Return True
		EndIf

		Local $cargo = BOT_CheckCargo()
		; if window closed on cargo timeout
		If $cargo = -1 Then
			Return False
		EndIf

		;if cargo is full
		If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
			BOT_LogMessage("Cargo is full", 1)
			GUI_SetLocationAndState("belt", "unloading")
			STA_SetIntervalTimestamp("mining_end")
			STA_FinalizeInterval("mining")
			Return True
		EndIf

		;do not mine if NPC found
		If GUI_getSecurityStatus() = "Low" And Not GUI_isHunter() Then
			ACT_SwitchTab("npc")
			Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
			If $NPCcounter <> False And $NPCcounter > 1 Then
				Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
				If $maxBookmark = 1 Then
					BOT_LogMessage("NPC found. Run away from the belt", 1)
					$GLB_stayInStation[$GLB_curBot] = 60 * 3
					BOT_WarpTo("Spot")
				Else
					BOT_LogMessage("NPC found. Changing belt", 1)
					GUI_SetLocationAndState("belt", "next")
				EndIf
				Return
			EndIf
		EndIf

		If Not Space_checkMinersReload() Then
			$cargo = BOT_CheckCargo()
		EndIf

		;if mining interrupted
		If Not BOT_CheckMining() Then
			BOT_LogMessage("Mining interrupted", 1)
			;ACT_SwitchTab("asteroids")
			;ACT_ClickOverviewObject()
			;If Not BOT_IsDisconnected() Then
			If GUI_isMiner() Then
				ACT_SwitchTab("asteroids")
				BOT_CheckSorting("overview")
				; try to mine next asteroid
				If $GUI_miningAsteroidNumber[$GLB_curBot] >= $GLB_miningTryLimit Then
					BOT_LogMessage("Mined try limit(" & $GLB_miningTryLimit & ") reached. Going to next bookmark", 1)
					GUI_SetLocationAndState("belt", "next")
				ElseIf EVEOCR_getAsteroidsInRange($lockDistance) > 0 Then
					$GUI_miningAsteroidNumber[$GLB_curBot] += 1
					BOT_LogMessage("Mining try #" & $GUI_miningAsteroidNumber[$GLB_curBot], 1)
					If OCR_IsContainerLock1Present() Then
						ACT_RemoveLock1ByMenu()
					Else
						ACT_UnlockActiveObject()
					EndIf
					BOT_ActivateMining(EVEOCR_getAsteroidsInRange($lockDistance))
					;reinit container
					ACT_SwitchTab("containers")
					$container = OCR_CheckContainerPresent()
					If $container <> False Then
						ACT_ClickOverviewObject($container, True)
						ACT_SI_ObjectApproach("container")
						If Not OCR_DetectContainerWindow() Then
							ACT_OpenContainer($container)
						EndIf
					EndIf

					;if cargo is full
					If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
						BOT_LogMessage("Cargo is full", 1)
						GUI_SetLocationAndState("belt", "unloading")
						STA_SetIntervalTimestamp("mining_end")
						STA_FinalizeInterval("mining")
						Return True
					EndIf
				Else
					UTL_LogScreen("Mined all in bookmark " & GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
					BOT_LogMessage("Mined all in bookmark " & GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]), 1)
					GUI_SetLocationAndState("belt", "next")
				EndIf
			ElseIf GUI_isFleetMiner() Then
				ACT_SwitchTab("default")
				Local $commandShip = OCR_CheckFleetOrcaPresent()
				If $commandShip <> False Then
					BOT_CheckSorting("overview")
					BOT_LogMessage("Fleet commander found! Re-joining", 1)
					ACT_ClickOverviewObject($commandShip[2])
					; if corp hangar present
					If Not OCR_DetectShipCorpHangarWindow() Then
						ACT_OpenFleetCommCorpHangar($commandShip[0], $commandShip[1])
						UTL_Wait(1, 2)
						ACT_ActivateCorpHangarTab(1, $GLB_shipCorpHangarWindow)
					EndIf
					ACT_SI_ObjectOrbit("fleetCommander")

					ACT_SwitchTab("lensedAsteroids")
					Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

					If $asteroidsAmount > 1 Then
						BOT_ActivateMining($asteroidsAmount)
					Else
						ACT_SwitchTab("asteroids")
						$asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)
						If $asteroidsAmount > 0 Then
							BOT_ActivateMining($asteroidsAmount)
						EndIf
					EndIf
				Else
					ACT_SwitchTab("lensedAsteroids")
					BOT_CheckSorting("overview")
					Local $asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)

					If $asteroidsAmount > 1 Then
						BOT_ActivateMining($asteroidsAmount)
					Else
						ACT_SwitchTab("asteroids")
						$asteroidsAmount = EVEOCR_getAsteroidsInRange($lockDistance)
						If $asteroidsAmount < 5 Then
							ACT_ClickOverviewObject()
							ACT_SI_ObjectOrbit("asteroid")
						Else
							ACT_StopEngine()
							ACT_UnlockActiveObject()
						EndIf

						BOT_ActivateMining($asteroidsAmount)
					EndIf
				EndIf
				Return True
			EndIf
			;EndIf
			Return True
		EndIf

		Local $activateOneOnly = False
		If GUI_getSecurityStatus() = "Low" Then
			$activateOneOnly = True
		EndIf

		ACT_ReactivateMiners($activateOneOnly)
		;if cargo is full
		If $cargo >= GUICtrlRead($GUI_fullCargo[$GLB_curBot]) Then
			BOT_LogMessage("Cargo is full", 1)
			GUI_SetLocationAndState("belt", "unloading")
			STA_SetIntervalTimestamp("mining_end")
			STA_FinalizeInterval("mining")
			Return True
		EndIf

		BOT_LogMessage("Mining in process", 1)
	ElseIf $state = "warping" Then
		BOT_CheckWarp("space")
	ElseIf $state = "warpWaiting" Then
		BOT_CheckWarpWait("belt")
	ElseIf $state = "next" Then
		; goto next bookmark
		Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
		Local $nextBookmark = BOT_GetNextBookmark()

		If $maxBookmark = 1 Then
			BOT_LogMessage("No next bookmark. Stay in current", 1)
			If GUI_isHunter() Then
				;aproach bookmark
				ACT_WarpTo("belts", 1, True)
				GUI_SetLocationAndState("belt", "npcWaiting")
			Else
				GUI_SetLocationAndState("belt", "free")
			EndIf
			; TODO send belt miner to station and stay here
		ElseIf $nextBookmark = -1 Then
			BOT_LogMessage("Stay in current bookmark", 1)
			If GUI_isMiner() Or GUI_isTransporter() Then
				GUI_SetLocationAndState("belt", "container")
			ElseIf GUI_isHunter() Then
				GUI_SetLocationAndState("belt", "npcWaiting")
			Else
				GUI_SetLocationAndState("belt", "free")
			EndIf
		ElseIf GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED Then
			GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $nextBookmark)
			If $nextBookmark = $maxBookmark Then $GLB_allBeltsDone[$GLB_curBot]+= 1
			BOT_WarpTo("Next")
		Else
			GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $nextBookmark)
			If $nextBookmark = $maxBookmark Then $GLB_allBeltsDone[$GLB_curBot]+= 1
			ACT_WarpTo("belts", $nextBookmark)
		EndIf
	ElseIf $state = "container" Then
		Local $cargo = BOT_CheckCargo()
		; if window closed on cargo timeout
		If $cargo = -1 Then
			Return False
		EndIf

		If Not GUI_isTransporter() Or $GUI_GLB_containers[GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]) - 1] > 0 Then
			ACT_SwitchTab("containers")
			$container = OCR_CheckContainerPresent()
			If $container <> False Then
				ACT_ClickOverviewObject($container, True)
				ACT_SI_ObjectApproach("container")
				If Not OCR_DetectContainerWindow() Then
					ACT_OpenContainer($container)
					UTL_Wait(2, 3)
				EndIf
				BOT_GetContainerCargo()
			Else
				GUI_SetLocationAndState("belt", "next")
				Return True
			EndIf
		EndIf

		If GUI_isTransporter() Then
			; unload container if not empty
			$cargoContainer = BOT_GetContainerCargo()
			If $cargoContainer > 0 Then
				ACT_SortByName("container")
				ACT_MoveAllCargoFromContainer()
				UTL_Wait(1, 2)
				BOT_GetContainerCargo()
			EndIf

			; unload if full
			$cargo = BOT_CheckCargo()
			If $cargo >= $fullCargo Then
				GUI_SetLocationAndState("belt", "unloading")
			Else
				GUI_SetLocationAndState("belt", "next")
			EndIf
		ElseIf GUI_isMiner() Then
			ACT_SwitchTab("asteroids")
			UTL_Wait(0.5, 1)
			BOT_ActivateMining(EVEOCR_getAsteroidsInRange($lockDistance))
			$GUI_miningAsteroidNumber[$GLB_curBot] = 1

			; unload if full
			$cargo = BOT_CheckCargo()
			If $cargo >= $fullCargo Then
				GUI_SetLocationAndState("belt", "unloading")
			EndIf
		EndIf
	ElseIf $state = "npcWaiting" Then
		If GUI_isRole("Hunter") Then
			Hunter("belt", "npcWaiting")
			Return True
		EndIf
	ElseIf $state = "npc" Then
		If GUI_isRole("Hunter") Then
			Hunter("belt", "npc")
			Return True
		EndIf
	ElseIf $state = "wreckTractoring" Then
		Local $cargo = BOT_CheckCargo()
		; if window closed on cargo timeout
		If $cargo = -1 Then
			Return False
		EndIf

		Local $overviewSize = False

		;do not salvage if NPC found
		If GUI_isRole("Marauder") Or (GUI_getSecurityStatus() = "Low" And Not GUI_isRole("Hunter")) Then
			ACT_SwitchTab("npc")
			Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
			If $NPCcounter <> False And $NPCcounter > 1 Then
				Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
				If $maxBookmark = 1 Then
					BOT_LogMessage("NPC found. Run away from the belt", 1)
					$GLB_stayInStation[$GLB_curBot] = 60 * 3
					BOT_WarpTo("Spot")
				Else
					BOT_LogMessage("NPC found. Changing belt", 1)
					GUI_SetLocationAndState("belt", "next")
				EndIf
				Return
			EndIf
		EndIf


		If GUI_isFleetCommander() Then
			Local $oreCargo = OCR_CalculateOreCargo()
			Local $corpHangarCargo = OCR_CalculateCorpHangarCargo()
			If $corpHangarCargo >= $fullCargo And $oreCargo >= $fullCargo And $cargo >= $fullCargo Then
				GUI_SetLocationAndState("belt", "unloading")
				Return True
			ElseIf $corpHangarCargo > 0 Then
				#cs
					If $oreCargo < $fullCargo Then
					BOT_LogMessage("Unloading during wreck tractoring", 1)
					ACT_SortByName("fleetCommCorpHangar")
					If $oreCargo >= 85 Then
					BOT_LogMessage("Ore hold is near full! Unloading one item", 1)
					ACT_MoveAllCorpHangarCargoToOreHold(False)
					Else
					ACT_MoveAllCorpHangarCargoToOreHold()
					EndIf
					Else
				#ce
				If $cargo < $fullCargo Then
					BOT_LogMessage("Unloading during wreck tractoring", 1)
					ACT_SortByName("fleetCommCorpHangar")
					If $cargo >= 85 Then
						BOT_LogMessage("Cargo is near full! Unloading one item", 1)
						ACT_MoveAllCorpHangarCargoToCargo(False)
					Else
						ACT_MoveAllCorpHangarCargoToCargo()
					EndIf
				EndIf
			EndIf
			; check asteroids
			ACT_SwitchTab("asteroids")
			Local $asteroid = OCR_CheckAsteroidPresent()
			If $asteroid <> False Then
				BOT_LogMessage("Flying to asteroids", 1)
				ACT_ClickOverviewObject()
				ACT_SI_ObjectApproach("asteroid")
			Else
				UTL_LogScreen("Asteroids not found going to next belt")
				BOT_LogMessage("Asteroids not found going to next belt", 1)
				GUI_SetLocationAndState("belt", "next")
			EndIf
			$overviewSize = 3
		EndIf

		ACT_SwitchTab("npc")
		BOT_CheckSorting("overview")

		Local $wreckType = "any"
		Local $isFaction = False
		If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
			$wreckType = "own"
		EndIf
		If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
			$isFaction = True
		EndIf

		Local $wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)
		If $wreck <> False Then
			ACT_ClickOverviewObject($wreck[2])
			ACT_RandomMouseMoves(1, 0, 0, 512, 760)
			Local $distDetector = EVEOCR_GetOverviewObjectDistance($wreck[2])

			;If $distDetector = False Then
			;	Local $distance = 20000
			;Else
			Local $distance = Int($distDetector)
			;EndIf

			BOT_LogMessage("Distance to wreck: " & $distance & " m", 1)

			If $distance < 2500 Then
				ACT_StopEngine()
				;deactivate afterburner
				If OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
					ACT_ActivateModule("middle", "afterburner")
				EndIf

				SPEECH_Notify("overviewLoot")
				BOT_LogMessage("Loot wreck " & $wreck[2], 1)

				;deactivate tractoring
				ACT_ActivateModule("high", "tractor")

				ACT_OpenWreck()
				UTL_Wait(3, 4)
				UTL_LogScreen("Loot wreck, before", "loot")
				ACT_LootAll()
				UTL_Wait(3, 4)

				; if cargo empty, wreck window not closed
				$cargo = BOT_CheckCargo()
				If $cargo = 0 Then
					ACT_InventoryActivateTopItem()
					GUI_SetLocationAndState("belt", "wreck")
					Return
				EndIf
				;UTL_LogScreen("Loot wreck, after", "loot")
				;ACT_CloseWrecks()

				$wreck = OCR_CheckWreckPresent($overviewSize)
				; check salvage
				If $wreck <> False And StringInStr($wreck[3], "empty") > 0 Then
					; salvage
					If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
						If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
							ACT_ActivateModule("high", "salvager")
							ACT_ClickOverviewObject($wreck[2])
						EndIf
					EndIf
				ElseIf GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
					If OCR_IsWreckLock1Present() Then
						ACT_RemoveLock1ByMenu()
					Else
						ACT_UnlockActiveObject()
					EndIf
				EndIf

				; force hunter faction unload
				If GUI_isRole("Hunter") And GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
					$GLB_forcedUnload[$GLB_curBot] = 1
				EndIf

				GUI_SetLocationAndState("belt", "wreck")
				UTL_SetTimeout("tractoring", True)
				Return True
			EndIf
		Else
			BOT_LogMessage("Keep wreck tractoring", 1)
		EndIf
		; if tractoring not active
		If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
			BOT_LogMessage("Tractoring interrupted. Reseting state", 1)
			GUI_SetLocationAndState("belt", "wreck")
			Return False
		EndIf
		If Not UTL_CheckTimeout("tractoring") Then
			BOT_LogMessage("Tractoring timeout. Going to next belt", 1)
			GUI_SetLocationAndState("belt", "next")
			Return False
		EndIf
	ElseIf $state = "wreck" Then
		If GUI_isRole("Hunter") Then
			Hunter("belt", "wreck")
			Return True
		EndIf

		;do not loot if NPC found
		If GUI_isRole("Marauder") Or GUI_getSecurityStatus() = "Low" Then
			ACT_SwitchTab("npc")
			Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
			If $NPCcounter <> False And $NPCcounter > 1 Then
				Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
				If $maxBookmark = 1 Then
					BOT_LogMessage("NPC found. Run away from the belt", 1)
					$GLB_stayInStation[$GLB_curBot] = 60 * 3
					BOT_WarpTo("Spot")
				Else
					BOT_LogMessage("NPC found. Changing belt", 1)
					GUI_SetLocationAndState("belt", "next")
				EndIf
				Return
			EndIf
		EndIf

		; wait for salvage
		If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
			If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
				BOT_LogMessage("Waiting during salvaging", 1)
				Return
			EndIf
		EndIf

		; check cargo
		If BOT_CheckCargo() > $fullCargo Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
			GUI_SetLocationAndState("belt", "unloading")
			Return
		EndIf

		Local $overviewSize = False
		If GUI_isFleetCommander() Then
			; check asteroids
			ACT_SwitchTab("asteroids")
			Local $asteroid = OCR_CheckAsteroidPresent()
			If $asteroid <> False Then
				BOT_LogMessage("Flying to asteroids", 1)
				ACT_ClickOverviewObject()
				ACT_SI_ObjectApproach("asteroid")
			Else
				UTL_LogScreen("Asteroids not found going to next belt")
				BOT_LogMessage("Asteroids not found going to next belt", 1)
				GUI_SetLocationAndState("belt", "next")
			EndIf

			$overviewSize = 3
		EndIf
		ACT_SwitchTab("npc")

		Local $wreckType = "any"
		Local $isFaction = False
		If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
			$wreckType = "own"
		EndIf
		If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
			$isFaction = True
		EndIf

		Local $wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)

		If $wreck <> False Then
			If Not BOT_CheckSorting("overview") Then
				$wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)
				;if wreck disapeared
				If $wreck = False Then
					BOT_LogMessage("Wreck disappeared", 1)
					Return
				EndIf
			EndIf

			If OCR_IsWreckLock1Present() Then
				ACT_RemoveLock1ByMenu()
			EndIf

			ACT_RandomMouseMoves(1, 0, 0, 512, 760)
			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($wreck[2]))

			BOT_LogMessage("Distance to wreck: " & $distance & " m", 1)
			If (Not GUI_isRole("Marauder") And $distance <= 19000) Or (GUI_isFleetCommander() And $distance <= 59000) Then
				If $distance < 20000 Then
					ACT_ActivateModule("high", "tractor")
				EndIf
				ACT_ClickOverviewObject($wreck[2])
				ACT_RandomMouseMoves()
				UTL_SetTimeout("tractoring")
				GUI_SetLocationAndState("belt", "wreckTractoring")
			ElseIf GUI_isRole("Marauder") Then
				If $distance > 150000 Then
					ACT_WarpToOverviewObject($wreck[2])
					GUI_SetLocationAndState("space", "warping")
					Return
				ElseIf $distance < 20000 Then
					If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
						ACT_ActivateModule("high", "tractor")
					EndIf
				EndIf

				ACT_ClickOverviewObject($wreck[2])
				ACT_SI_ObjectApproach("wreck")
				ACT_RandomMouseMoves(1, 0, 0, 512, 760)

				; if wreck was opened
				If $wreck[3] = "empty.used" Or $wreck[3] = "empty.ushared" Then
					; check and activate salvage
					If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
						If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
							ACT_ActivateModule("high", "salvager")
							ACT_ClickOverviewObject($wreck[2])
							Return
						EndIf
					EndIf
				Else
					If $distance < 2500 Then
						BOT_LogMessage("Loot wreck " & $wreck[2] & " at start", 1)
						ACT_OpenWreck()
						UTL_Wait(3, 4)
						UTL_LogScreen("Loot wreck, before", "loot")
						ACT_LootAll()
						UTL_Wait(3, 4)

						; if cargo empty, wreck window not closed
						If BOT_CheckCargo() = 0 Then
							ACT_InventoryActivateTopItem()
							GUI_SetLocationAndState("belt", "wreck")
							Return
						EndIf
						;UTL_LogScreen("Loot wreck, after", "loot")

						;deactivate tractor
						If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
							ACT_ActivateModule("high", "tractor")
						EndIf

						; check and activate salvage
						If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
							If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
								ACT_ActivateModule("high", "salvager")
								ACT_ClickOverviewObject($wreck[2])
							EndIf
						EndIf

						; force faction unload
						If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
							$GLB_forcedUnload[$GLB_curBot] = 1
						EndIf

						Return
					EndIf

					;activate afterburner
					If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
						ACT_ActivateModule("middle", "afterburner")
					EndIf
				EndIf

				UTL_SetTimeout("tractoring")
				GUI_SetLocationAndState("belt", "wreckTractoring")
				UTL_SetWaitTimestamp(5)
			Else
				BOT_LogMessage("Next wreck too far away", 1)
				GUI_SetLocationAndState("belt", "free")
			EndIf
		Else
			BOT_LogMessage("No more wrecks", 1)
			If GUI_isFleetCommander() Then
				GUI_SetLocationAndState("belt", "commanding")
			Else
				GUI_SetLocationAndState("belt", "free")
			EndIf
			UTL_SetTimeout("cargo")
		EndIf
	ElseIf $state = "scan" Then
		;depricated
		GUI_SetLocationAndState("belt", "next")
		; close scanner
		; ACT_CloseScanner()
	ElseIf $state = "drones" Then
		UTL_SetTimeout("drones", True)
		Local $postAction = GUICtrlRead($GUI_dronesOnReturn[$GLB_curBot])
		BOT_LogMessage("Drones returned, going to " & $postAction, 1)
		If $postAction = "Station" Then
			ACT_WarpTo("station")
		ElseIf $postAction = "Anomaly" Then
			ACT_WarpTo("anomaly")
		ElseIf $postAction = "Spot" Then
			ACT_WarpTo("spot")
		ElseIf $postAction = "POS" Then
			ACT_WarpTo("pos")
		ElseIf $postAction = "Next" Then
			Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
			Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
			If $huntPlace = "Belt" Then
				ACT_WarpTo("belts", $curBookmark)
			ElseIf $huntPlace = "Anomaly" Then
				ACT_WarpTo("anomaly", $curBookmark)
			EndIf
		EndIf
	ElseIf $state = "dronesReturn" Then
		If GUI_isRole("Belt Miner") Then
			BeltMiner("belt", "dronesReturn")
			Return True
		EndIf
		ACT_SwitchTab("drones")
		Local $drone = OCR_CheckDronePresent()
		If $drone <> False Then
			ACT_ClickOverviewObject()
			UTL_Wait(0.5, 1)
			ACT_SI_ObjectApproach("drone")
			ACT_ReturnCurrentDrone()
			BOT_LogMessage("Waiting for drones", 1)
		Else
			GUI_SetLocationAndState("belt", "drones")
		EndIf
		BOT_CheckTimeout("drones")
		;ElseIf $state = "asteroid" Then
		;	If Not OCR_WrapIsActive() Then
		;		ACT_LockNearestObject()
		;		ACT_NearestAsteroidOrbit()
		;		ACT_ActivateMining()
		;	EndIf
	ElseIf $state = "flying" Then
		If GUI_isRole("Belt Miner") Then
			BeltMiner("belt", "flying")
			Return True
		EndIf
	Else
		BOT_LogMessage("Unsupported state for belt", 1)
		BOT_FixLocationAndState("belt", $state)
	EndIf
EndFunc   ;==>BOT_StateBelt

;check anomaly state
Func BOT_StateAnomaly()
	If $GLB_stayInStation[$GLB_curBot] <> -5 Then
		BOT_CheckLocal()
	EndIf

	Local $state = GUICtrlRead($GUI_stateCombo[$GLB_curBot])
	Local $cargo = BOT_CheckCargo()
	Local $fullCargo = GUICtrlRead($GUI_fullCargo[$GLB_curBot])

	; force back to station if maintenance time
	If $state <> "warpWaiting" And $state <> "warping" And $state <> "drones" Then
		If $GLB_stayInStation[$GLB_curBot] <> 0 And $state = "scanned" Then
			; close scanner
			ACT_CloseScanner()
		EndIf

		If $GLB_stayInStation[$GLB_curBot] > 0 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Need pause. Go to spot from anomaly", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Need pause. Go to station from anomaly", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -2 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Downtime. Go to spot from anomaly", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Downtime. Go to station from anomaly", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -2.1 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Scheduled stop. Go to spot from anomaly", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Scheduled stop. Go to station from anomaly", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -4 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Fleet commander offline. Go to spot from anomaly", 1)
				BOT_WarpTo("Spot")
			Else
				BOT_LogMessage("Fleet commander offline. Go to station from anomaly", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		ElseIf $GLB_stayInStation[$GLB_curBot] = -5 Or $GLB_stayInStation[$GLB_curBot] = -6 Then
			If GUI_getSecurityStatus() = "Low" Then
				BOT_LogMessage("Enemy found. Go to spot from anomaly", 1)
				Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
				If $POS = "None" Then
					; warp to first spot with container
					ACT_WarpTo("spot", 1)
				Else
					BOT_WarpTo("Spot")
				EndIf
			Else
				BOT_LogMessage("Enemy found. Go to station from anomaly", 1)
				BOT_WarpTo("Station")
			EndIf
			Return True
		EndIf
	EndIf

	If $state = "free" Then
		If GUI_isRole("Anomaly Miner") Then
			AnomalyMiner("anomaly", "free")
			Return True
		EndIf

		If GUI_isRole("Hunter") Then
			Hunter("anomaly", "free")
			Return True
		EndIf

		;try to find NPC
		ACT_SwitchTab("npc")
		UTL_Wait(1, 2)

		BOT_CheckSorting("overview", "icon")

		Local $NPC = OCR_GetNPC("tower", True)

		If GUI_isRole("Marauder") And $NPC <> False Then
			GUI_SetLocationAndState("anomaly", "next")
			Return True
		EndIf
	ElseIf $state = "unloading" Then
		; deactivate all miners
		If OCR_isActiveHighSlot() Then
			ACT_ActivateModule("high", "miner")
		EndIf

		If GUI_getSecurityStatus() = "Low" Then
			Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
			If $POS = "None" Then
				; warp to first spot with container
				ACT_WarpTo("spot", 1)
			Else
				BOT_WarpTo("Spot")
			EndIf
		Else
			BOT_WarpTo("Station")
		EndIf
	ElseIf $state = "npc" Then
		If GUI_isRole("Hunter") Then
			Hunter("anomaly", "npc")
			Return True
		EndIf
	ElseIf $state = "wreck" Then
		;do not loot if NPC found
		If GUI_getSecurityStatus() = "Low" And Not GUI_isRole("Hunter") Then
			ACT_SwitchTab("npc")
			Local $NPCcounter = OCR_CheckNPCPresent(False, "any", True)
			If $NPCcounter <> False And $NPCcounter > 1 Then
				Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
				If $maxBookmark = 1 Then
					BOT_LogMessage("NPC found. Run away from the anomaly", 1)
					$GLB_stayInStation[$GLB_curBot] = 60 * 3
					BOT_WarpTo("Spot")
				Else
					BOT_LogMessage("NPC found. Changing anomaly", 1)
					GUI_SetLocationAndState("anomaly", "next")
				EndIf
				Return
			EndIf
		EndIf

		; wait for salvage
		If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
			If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
				BOT_LogMessage("Waiting during salvaging", 1)
				Return
			EndIf
		EndIf

		; check cargo
		If BOT_CheckCargo() > $fullCargo Or $GLB_forcedUnload[$GLB_curBot] = 1 Then
			GUI_SetLocationAndState("anomaly", "unloading")
			Return
		EndIf

		; if new npc arrived, stop looting and destroy them
		Local $NPC = BOT_CheckNPC()
		If GUI_isRole("Hunter") And $NPC <> False Then
			SPEECH_Notify("overviewNPCFound")
			UTL_LogScreen("New NPC arrived to anomaly during wreck utilization", "npc")
			GUI_SetLocationAndState("anomaly", "npc")
			If OCR_IsWreckLock1Present() Then
				ACT_RemoveLock1ByMenu()
			EndIf
			Return
		EndIf

		Local $overviewSize = False
		Local $wreckType = "any"
		Local $isFaction = False
		If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
			$wreckType = "own"
		EndIf
		If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
			$isFaction = True
		EndIf

		Local $wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)

		If $wreck <> False Then
			If Not BOT_CheckSorting("overview") Then
				$wreck = OCR_CheckWreckPresent($overviewSize, $wreckType, $isFaction)
				;if wreck disapeared
				If $wreck = False Then
					BOT_LogMessage("Wreck disappeared", 1)
					Return
				EndIf
			EndIf

			If OCR_IsWreckLock1Present() Then
				ACT_RemoveLock1ByMenu()
			EndIf

			ACT_RandomMouseMoves(1, 0, 0, 512, 760)
			Local $distance = Int(EVEOCR_GetOverviewObjectDistance($wreck[2]))

			BOT_LogMessage("Distance to wreck: " & $distance & " m", 1)
			If GUI_isRole("Hunter") Or GUI_isRole("Marauder") Then
				If $distance > 150000 Then
					ACT_WarpToOverviewObject($wreck[2])
					GUI_SetLocationAndState("space", "warping")
					Return
				ElseIf $distance < 20000 Then
					If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
						ACT_ActivateModule("high", "tractor")
					EndIf
				EndIf

				ACT_ClickOverviewObject($wreck[2])
				ACT_SI_ObjectApproach("wreck")

				; if wreck was opened
				If $wreck[3] = "empty.used" Or $wreck[3] = "empty.ushared" Then
					; check and activate salvage
					If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED And GUI_GetSlotPosition("high", "salvager") <> False Then
						If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "salvager")) Then
							ACT_ActivateModule("high", "salvager")
							ACT_ClickOverviewObject($wreck[2])
							Return
						EndIf
					EndIf
				Else
					If $distance < 2500 Then
						BOT_LogMessage("Loot wreck " & $wreck[2] & " at start", 1)
						ACT_OpenWreck()
						UTL_Wait(3, 4)
						UTL_LogScreen("Loot wreck, before", "loot")
						ACT_LootAll()
						UTL_Wait(3, 4)
						;UTL_LogScreen("Loot wreck, after", "loot")

						;deactivate
						If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
							ACT_ActivateModule("high", "tractor")
						EndIf
						; force faction unload
						If GUICtrlRead($GUI_lootOnlyFaction[$GLB_curBot]) = $GUI_CHECKED Then
							$GLB_forcedUnload[$GLB_curBot] = 1
						EndIf

						Return
					EndIf

					;activate afterburner
					If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "afterburner")) Then
						ACT_ActivateModule("middle", "afterburner")
					EndIf
				EndIf

				UTL_SetTimeout("tractoring")
				GUI_SetLocationAndState("anomaly", "wreckTractoring")
				UTL_SetWaitTimestamp(5)
			Else
				BOT_LogMessage("Next wreck too far away", 1)
				GUI_SetLocationAndState("anomaly", "free")
			EndIf
		Else
			BOT_LogMessage("No more wrecks", 1)
			If GUI_isHunter() Then
				GUI_SetLocationAndState("anomaly", "next")
			Else
				GUI_SetLocationAndState("anomaly", "free")
			EndIf
			UTL_SetTimeout("cargo")
		EndIf
	ElseIf $state = "wreckTractoring" Then
		ACT_SwitchTab("npc")
		Local $wreck = OCR_CheckWreckPresent()
		If $wreck <> False Then
			ACT_ClickOverviewObject($wreck[2])
			ACT_RandomMouseMoves(1, 0, 0, 512, 760)

			Local $distDetector = Int(EVEOCR_GetOverviewObjectDistance($wreck[2]))
			If $distDetector = False Then
				Local $distance = 20000
			Else
				Local $distance = Int($distDetector)
			EndIf

			BOT_LogMessage("Distance to wreck in anomaly: " & $distance & " m", 1)

			If $distance < 2500 Then
				BOT_LogMessage("Loot anomaly wreck " & $wreck[2], 1)

				ACT_OpenWreck()
				UTL_Wait(3, 4)
				UTL_LogScreen("Loot wreck, before", "loot")
				ACT_LootAll()
				UTL_Wait(3, 4)
				;UTL_LogScreen("Loot wreck, after", "loot")

				;deactivate
				If OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
					ACT_ActivateModule("high", "tractor")
				EndIf

				; check salvage
				If GUICtrlRead($GUI_salvageWrecksCheckbox[$GLB_curBot]) = $GUI_UNCHECKED Then
					If OCR_IsWreckLock1Present() Then
						ACT_RemoveLock1ByMenu()
					Else
						ACT_UnlockActiveObject()
					EndIf
				EndIf

				GUI_SetLocationAndState("anomaly", "wreck")
				UTL_SetTimeout("tractoring", True)
				Return True
			EndIf
		Else
			BOT_LogMessage("Keep anomaly wreck tractoring", 1)
		EndIf

		; if tractoring not active
		If Not OCR_isActiveHighSlot(GUI_GetSlotPosition("high", "tractor")) Then
			BOT_LogMessage("Tractoring interrupted. Reseting anomaly state", 1)
			GUI_SetLocationAndState("anomaly", "wreck")
			Return False
		EndIf

		If Not UTL_CheckTimeout("tractoring") Then
			BOT_LogMessage("Tractoring timeout. Going to next anomaly from anomaly", 1)
			GUI_SetLocationAndState("anomaly", "next")
			Return False
		EndIf
	ElseIf $state = "warping" Then
		BOT_CheckWarp("anomaly")
	ElseIf $state = "warpWaiting" Then
		BOT_CheckWarpWait("anomaly")
	ElseIf $state = "next" Then
		If GUI_isRole("Anomaly Miner") Then
			AnomalyMiner("anomaly", "next")
			Return True
		EndIf

		; goto next bookmark
		Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
		Local $nextBookmark = BOT_GetNextBookmark()

		If $maxBookmark = 1 Then
			BOT_LogMessage("No next anomaly. Stay in current", 1)
			If GUI_isHunter() Then
				;aproach bookmark
				ACT_WarpTo("anomaly", 1, True)
				GUI_SetLocationAndState("anomaly", "npcWaiting")
			Else
				GUI_SetLocationAndState("anomaly", "free")
			EndIf
		ElseIf $nextBookmark = -1 Then
			BOT_LogMessage("Stay in current anomaly", 1)
			If GUI_isHunter() Then
				GUI_SetLocationAndState("anomaly", "npcWaiting")
			Else
				GUI_SetLocationAndState("anomaly", "free")
			EndIf
		ElseIf GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED Then
			GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $nextBookmark)
			BOT_WarpTo("Next")
		Else
			GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], $nextBookmark)
			If $nextBookmark = 1 Then
				Local $delay = GUICtrlRead($GUI_anomaliesDelay[$GLB_curBot])
				If $delay > 0 Then
					$GLB_stayInStation[$GLB_curBot] = $delay*60
					GUI_SetLocationAndState("anomaly", "free")
				Else
					GUI_SetLocationAndState("anomaly", "scan")
				EndIf
			Else
				GUI_SetLocationAndState("anomaly", "scan")
			EndIf
		EndIf
	ElseIf $state = "scan" Then
		; open scanner
		ACT_OpenScanner()
		UTL_Wait(1, 2)
		; scan
		ACT_LaunghScanner()
		GUI_SetLocationAndState("anomaly", "scanned")
		UTL_SetWaitTimestamp($GLB_ScanWaitTime)
	ElseIf $state = "scanned" Then
		ACT_WarpToScannerItem(GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
		UTL_Wait(1, 2)
		; close scanner
		ACT_CloseScanner()
	ElseIf $state = "drones" Then
		UTL_SetTimeout("drones", True)
		Local $postAction = GUICtrlRead($GUI_dronesOnReturn[$GLB_curBot])
		BOT_LogMessage("Drones returned, going to " & $postAction, 1)
		If $postAction = "Station" Then
			ACT_WarpTo("station")
		ElseIf $postAction = "Anomaly" Then
			ACT_WarpTo("anomaly")
		ElseIf $postAction = "Spot" Then
			ACT_WarpTo("spot")
		ElseIf $postAction = "POS" Then
			ACT_WarpTo("pos")
		ElseIf $postAction = "Next" Then
			Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
			Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
			If $huntPlace = "Belt" Then
				ACT_WarpTo("belts", $curBookmark)
			ElseIf $huntPlace = "Anomaly" Then
				ACT_WarpTo("anomaly", $curBookmark)
			EndIf
		EndIf
	ElseIf $state = "mining" Then
		If GUI_isRole("Anomaly Miner") Then
			AnomalyMiner("anomaly", "mining")
			Return True
		EndIf
	ElseIf $state = "flying" Then
		If GUI_isRole("Anomaly Miner") Then
			BeltMiner("anomaly", "flying")
			Return True
		EndIf
	Else
		BOT_LogMessage("Unsupported state for anomaly", 1)
		BOT_FixLocationAndState("anomaly", $state)
	EndIf
EndFunc   ;==>BOT_StateAnomaly

; check is suitable NPC found
Func BOT_CheckNPC()
	Local $NPC = False
	Local $respawn = GUICtrlRead($GUI_forceNPCrespawn[$GLB_curBot])

	If $respawn = "No" Or $GUI_killAllNPCinCurrentBelt[$GLB_curBot] Then
		BOT_LogMessage("BOT_CheckNPC: Kill smallest NPC. " & $respawn & "," & $GUI_killAllNPCinCurrentBelt[$GLB_curBot], 1)
		$NPC = OCR_CheckNPCPresent(False, "smallest")
	ElseIf OCR_isShipScrambled() Then
		If Not $GUI_killAllNPCinCurrentBelt[$GLB_curBot] Then
			UTL_LogScreen("Scrambling respawn", "scramble")
			$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = True
		EndIf
		BOT_LogMessage("BOT_CheckNPC: Kill scrambling respawn.", 1)
		$NPC = OCR_CheckNPCPresent(False, "smallest")
	ElseIf OCR_CheckNPCPresent(False, "any", False, True) Then
		If Not $GUI_killAllNPCinCurrentBelt[$GLB_curBot] Then
			UTL_LogScreen("Faction respawn", "faction npc")
			$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = True
		EndIf
		BOT_LogMessage("BOT_CheckNPC: Kill faction respawn.", 1)
		$NPC = OCR_CheckNPCPresent(False, "smallest")
	ElseIf $respawn <> "No" Then
		Local $findtype
		If $respawn = "Battleships" Then
			$findtype = "big"
		Else
			$findtype = "medium"
		EndIf

		Local $amount = OCR_CheckNPCPresent(False, "any", True)
		Local $amountOfType = OCR_CheckNPCPresent(False, $findtype, True)
		Local $ship = OCR_GetNPC($findtype, True)

		BOT_LogMessage("BOT_CheckNPC: " & $amountOfType & " big ships, all " & $amount, 1)

		; if all cruisers destroyed, check for battleships
		If $ship = False And $respawn = "Cruisers" Then
			$ship = OCR_GetNPC("big", True)
		EndIf

		Local $destroyAll = False
		Local $loot = (GUICtrlRead($GUI_lootWrecksCheckbox[$GLB_curBot]) = $GUI_CHECKED)
		If $amountOfType = 0 Then
			If (OCR_CheckWreckPresent(False, "any", False) = False And Not $loot) Or $amount > 3 Then
				BOT_LogMessage("BOT_CheckNPC: no big ship respawn", 1)
				$destroyAll = True
			EndIf
		ElseIf $amountOfType < GUICtrlRead($GUI_respawnAmount[$GLB_curBot]) Then
			If OCR_CheckWreckPresent(False, "any", False) = False And Not $loot Then
				BOT_LogMessage("BOT_CheckNPC: too small big ship respawn", 1)
				$destroyAll = True
			Else
				BOT_LogMessage("BOT_CheckNPC: Kill suitable big ship respawned NPC", 1)
				If $ship <> False Then $NPC = $ship
			EndIf
		ElseIf $ship <> False Then
			BOT_LogMessage("BOT_CheckNPC: Kill big ship respawned NPC", 1)
			$NPC = $ship
		EndIf

		If $destroyAll Then
			BOT_LogMessage("BOT_CheckNPC: Destroy all NPC respawn", 1)
			$GUI_killAllNPCinCurrentBelt[$GLB_curBot] = True
			$NPC = OCR_CheckNPCPresent(False, "smallest")
		EndIf
	EndIf

	Return $NPC
EndFunc

; check alarm value
Func BOT_checkAlarm($location)
	Switch $GLB_stayInStation[$GLB_curBot]
		Case 1 To 1000000000 ; to infinity
			; wait in location if needed
			BOT_LogMessage("Stay in " & $location, 1)
			UTL_LogScreen("Stay in " & $location, $location)
			GUI_SetLocationAndState($location, "delay")
			UTL_SetWaitTimestamp($GLB_stayInStation[$GLB_curBot])
			;if delay more than 1 hour, close client winfow
			If $GLB_stayInStation[$GLB_curBot] >= 60*60 Then
				BOT_CloseWindow("Delay too long. " & $GLB_stayInStation[$GLB_curBot] & " minutes")
				GUI_SetLocationAndState("closed", "delay")
			EndIf

			$GLB_stayInStation[$GLB_curBot] = 0

			UTL_CheckResetTimeouts()
			Return False
		Case -1
			; stay in location and disable account if needed
			BOT_LogMessage("Stay in " & $location & ". Bot disabled", 1)
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			BOT_CloseWindow("Bot disabled")
			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return False
		Case -2
			; stay in location and close if downtime
			BOT_LogMessage("Stay in " & $location & ". Downtime", 1)
			BOT_CloseWindow("downtime")
			UTL_SetWaitTimestamp(UTL_CalcScheduleTimeLeft(GUICtrlRead($GUI_downtime)))
			GUI_SetLocationAndState("closed", "delay")
			$GLB_stayInStation[$GLB_curBot] = 0
			GUI_initContainers()

			; reset anomalies
			If GUICtrlRead($GUI_huntingPlace[$GLB_curBot]) = "Anomaly" Then
				GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], 1)
			EndIf

			Return False
		Case -2.1
			; stay in location and close if scheduled stop
			BOT_LogMessage("Stay in " & $location & ". Scheduled stop", 1)
			BOT_CloseWindow("Scheduled stop")
			UTL_SetWaitTimestamp(UTL_CalcScheduleTimeLeft(GUICtrlRead($GUI_botSchedule[$GLB_curBot])))
			GUI_SetLocationAndState("closed", "delay")
			$GLB_stayInStation[$GLB_curBot] = 0
			GUI_initContainers()

			; reset anomalies
			If GUICtrlRead($GUI_huntingPlace[$GLB_curBot]) = "Anomaly" Then
				GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], 1)
			EndIf

			Return False
		Case -3
			; armor damaged
			; TODO recover armor repair
			;If GUI_getSecurityStatus() = "High" Then
				; repair if needed
			;	BOT_LogMessage("Repair armor in station", 1)
			;	ACT_RepairAllInStation()
			;Else
				BOT_LogMessage("Armor damaged. Stay in " & $location & ". Bot disabled", 1)
				BOT_CloseWindow("Armor damaged. Stay in " & $location & ". Bot disabled")
				GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			;EndIf
			$GLB_stayInStation[$GLB_curBot] = 0
			Return False
		Case -4
			; fleet commander offline
			BOT_LogMessage("Fleet commander offline. Close window in " & $location & ".", 1)
			BOT_CloseWindow("Fleet commander offline")
			$GLB_stayInStation[$GLB_curBot] = 0
			Return False
		Case -5
			; enemy found
			BOT_LogMessage("Enemy found. Waiting in " & $location & ".", 1)
			UTL_LogScreen("Enemy found. Waiting in " & $location & "", $location)

			If $location = "spot" Then
				UTL_SetWaitTimestamp(GUICtrlRead($GUI_enemyTimeoutInput) * 60)
				BOT_CloseWindow("Enemy found. Logoff on safe spot")
			Else
				; change anomaly after enemy arrival
				If GUICtrlRead($GUI_huntingPlace[$GLB_curBot]) = "Anomaly" Then
					GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], BOT_GetNextBookmark())
				EndIf

				If GUICtrlRead($GUI_EnemyLogoutCheckbox) = $GUI_CHECKED Then
					UTL_SetWaitTimestamp(GUICtrlRead($GUI_enemyWaitBeforeLogoutInput) * 60)
					GUI_SetLocationAndState($location, "closeAndWait")
				Else
					UTL_SetWaitTimestamp(GUICtrlRead($GUI_enemyTimeoutInput) * 60)
				EndIf
			EndIf

			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return False
		Case -6
			; local overloaded
			BOT_LogMessage("Local overloaded. Waiting in " & $location & ".", 1)
			UTL_LogScreen("Local overloaded. Waiting in " & $location & "", $location)

			If $location = "spot" Then
				BOT_CloseWindow("Enemy found. Logoff on safe spot")
			EndIf

			UTL_SetWaitTimestamp(10 * 60)
			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return False
		Case -7
			; session expired
			BOT_LogMessage("License session expired, " & $location & " logoff. Bot disabled", 1)
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			BOT_CloseWindow("Session expired")
			GUI_SetLocationAndState("closed", "free")
			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return False
		Case -8
			; license expired
			BOT_LogMessage("License expired, " & $location & " logoff. Bot disabled", 1)
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			BOT_CloseWindow("License expired")
			GUI_SetLocationAndState("closed", "free")
			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return False
		Case -10 To -9
			; license server error
			BOT_LogMessage("License server error, " & $location & " logoff. " & $LIC_licensingMessage & " Bot disabled", 1)
			GUICtrlSetState($GUI_enableBot[$GLB_curBot], $GUI_UNCHECKED)
			BOT_CloseWindow("License server error. " & $LIC_licensingMessage)
			$LIC_licensingMessage = ""
			$GLB_stayInStation[$GLB_curBot] = 0
			UTL_CheckResetTimeouts()
			Return False
	EndSwitch

	Return True
EndFunc

;check for inventory window
Func BOT_checkInventory()
	If Not OCR_DetectInventoryWindow() Then
		ACT_RandomMouseMoves(1, 50, 0, 700, 500)
		UTL_Wait(1, 2)
		If Not OCR_DetectInventoryWindow() Then
			WIN_ActivateWindow($WIN_titles[$GLB_curBot])
			UTL_Wait(2, 3)
			ACT_OpenCargo()
			UTL_Wait(2, 3)
			If Not OCR_DetectInventoryWindow() Then
				ACT_OpenCargo()
				UTL_Wait(2, 3)
				If Not OCR_DetectInventoryWindow() Then
					BOT_LogMessage("Inventory window not found. Disabling bot", 1)
					$GLB_stayInStation[$GLB_curBot] = -1
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc

;invite all to fleet
Func BOT_InviteAllToFleet()
	Local $invited = False
	; check fleet invitations
	ACT_SwitchChatTab("local")
	ACT_SwitchChatTab("corp")

	; scan corp chat and invite all to fleet
	For $i = 0 To 7 Step 1
		If OCR_ChatUserInCorp($i + 1) Then
			BOT_LogMessage("Invite user " & ($i + 1) & " to fleet", 1)
			ACT_InviteToFleet($i + 1)
			$invited = True
			$GLB_allowFleetJoin += 1
		ElseIf OCR_ChatUserInFleet($i + 1) Then
			BOT_LogMessage("User " & ($i + 1) & " already in fleet", 1)
			ContinueLoop
		Else
			BOT_LogMessage("User " & ($i + 1) & " has unknown state", 1)
		EndIf
	Next

	Return $invited
EndFunc   ;==>BOT_InviteAllToFleet

;check local
Func BOT_CheckLocal()
	;if monitoring not needed
	If Not GUI_localMonitoringAllowed() Then
		Return True
	EndIf

	Local $maxAmountOfUsers = GUICtrlRead($GUI_localChatMaxAmountOfUsers[$GLB_curBot])
	Local $localChatIconSize = GUICtrlRead($GUI_localChatIconSize[$GLB_curBot])

	ACT_SwitchChatTab("local")

	; highsec monitoring
	If GUI_getSecurityStatus() = "High" Then
		; scan chat
		For $i = 0 To $maxAmountOfUsers Step 1
			If OCR_ChatUserPresent($i + 1, $localChatIconSize) Then
				Local $usertype = OCR_ChatUserType($i + 1, $localChatIconSize)

				If $usertype[1] = "terrible" Then
					BOT_LogMessage("Enemy found in chat. Position #" & ($i + 1), 1)
					UTL_LogScreen("Enemy found in chat. Position #" & ($i + 1), "enemy")
					SPEECH_Notify("localEnemyFound")

					BOT_SetAlertToGroup(-5, GUICtrlRead($GUI_groupID[$GLB_curBot]))
					Return False
				EndIf
			EndIf
		Next
	Else
	; lowsec monitoring
		Local $amountOfFriends = 1
		Local $neutralsAllowed = True
		Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])

		; scan chat
		For $i = 0 To $maxAmountOfUsers Step 1
			If OCR_ChatUserPresent($i + 1, $localChatIconSize) Then
				Local $usertype = OCR_ChatUserType($i + 1, $localChatIconSize)
				If $POS = "None" And ((Not $neutralsAllowed) Or $amountOfFriends > 1) And $usertype[1] <> "corporation" Then
					If $usertype[0] = "friend" Then
						BOT_CloseWindow("Non-corporation user in local")
						UTL_SetWaitTimestamp(30 * 30 + Round(Random(-5, 5)))
					Else
						BOT_CloseWindow("Enemy found in local")
						UTL_SetWaitTimestamp(30 * 60 + Round(Random(-5, 5)))
					EndIf
					Return False
				ElseIf $usertype[0] = "friend" Then
					$amountOfFriends += 1
				Else
					; skip yourself
					If $neutralsAllowed Then
						$neutralsAllowed = False
						ContinueLoop
					EndIf

					BOT_LogMessage("Enemy found in chat. Position #" & ($i + 1), 1)
					UTL_LogScreen("Enemy found in chat. Position #" & ($i + 1), "enemy")
					SPEECH_Notify("localEnemyFound")

					BOT_SetAlertToGroup(-5, GUICtrlRead($GUI_groupID[$GLB_curBot]))
					Return False
				EndIf
			Else
				If $i = 0 Then
					$amountOfFriends = 0
				EndIf
				ExitLoop
			EndIf
		Next

		;trace local changes
		If $NET_LocalUsers[Int(GUICtrlRead($GUI_groupID[$GLB_curBot]))] <> $amountOfFriends Then
			BOT_LogMessage("Local changed. " & $amountOfFriends & " users now", 1)
			UTL_LogScreen("Local changed. " & $amountOfFriends & " users now", "local")
			SPEECH_Notify("localNewUser")
			$NET_LocalUsers[GUICtrlRead($GUI_groupID[$GLB_curBot])] = $amountOfFriends
		EndIf

		If $amountOfFriends = $maxAmountOfUsers Then
			BOT_LogMessage("Too many users in local", 1)
			UTL_LogScreen("Too many users in local", "local")
			SPEECH_Notify("localTooManyUsers")

			BOT_SetAlertToGroup(-6, GUICtrlRead($GUI_groupID[$GLB_curBot]))
		ElseIf $amountOfFriends = 0 Then
			BOT_LogMessage("No users in local. Wrong local tweak.", 1)
			UTL_LogScreen("No users in local. Wrong local tweak.", "local")
			;For $n = 0 To $GLB_numOfBots - 1 Step 1
			;	$GLB_stayInStation[$n] = -6
			;Next
		EndIf
	EndIf

	Return True
EndFunc   ;==>BOT_CheckLocal

; set alert to all accounts in group
Func BOT_SetAlertToGroup($alert, $group)
	BOT_LogMessage("Set alert '" & GUI_getAlarmText($alert) & "' to group " & $group, 1)
	For $n = 0 To $GLB_numOfBots - 1 Step 1
		If $group = GUICtrlRead($GUI_groupID[$n]) Then
			$GLB_stayInStation[$n] = $alert
		EndIf
	Next
EndFunc

;check all bots and accept fleets
Func BOT_CheckAllBotsForFleet()
	For $i = 0 To $GLB_numOfBots - 1 Step 1
		WIN_ActivateWindow($WIN_titles[$i])
		UTL_Wait(0.5, 0.7)

		;if join fleet window if opened
		If OCR_DetectJoinFleetWindow() Then
			UTL_Wait(1, 2)
			BOT_LogMessage("Fleet proposition detected. Accepting by fleet commander", 1)
			UTL_LogScreen("Fleet proposition detected. Accepting by fleet commander")

			MouseClick("left", $GLB_click_JFW_yes[0], $GLB_click_JFW_yes[1], 1, 5)
			UTL_Wait(0.5, 0.7)
			Send("{ENTER}")
		EndIf
	Next

	WIN_ActivateWindow($WIN_titles[$GLB_curBot])
EndFunc   ;==>BOT_CheckAllBotsForFleet

; check is mining active
Func BOT_CheckMining()
	Local $slots = GUI_GetSlotPosition("high", "miner", True)
	If Not $slots[0] Then
		Return False
	EndIf

	For $s = 1 To UBound($slots) - 1 Step 1
		If $slots[$s] And Not OCR_isActiveHighSlot($s) Then
			;BOT_LogMessage("DEBUG FALSE: " & $s & "," & $slots[$s], 1)
			Return False
		EndIf
		;BOT_LogMessage("DEBUG TRUE: " & $s & "," & $slots[$s], 1)
	Next
	Return True
EndFunc

;check selected item window
Func BOT_CheckSIWindow()
	If Not OCR_isSelectedItemWindowClosed() Then
		ACT_SIWindowMaximize()
		BOT_LogMessage("Selected Item window reopened", 1)
	EndIf
EndFunc   ;==>BOT_CheckSIWindow

; not used in Retribution 1.0.5
#cs
;hide inventory filters panel
Func BOT_CheckInventoryFilters()
	; check twice, filter has a bug with hiding
	If OCR_DetectInventoryFilters() Then
		ACT_InventoryHideFilters($GLB_inventoryWindow_filtersIndicator[1])
		UTL_Wait(1, 1.5)
		If OCR_DetectInventoryFilters() Then
			ACT_InventoryHideFilters($GLB_inventoryWindow_filtersIndicator[1])
		EndIf
	ElseIf OCR_DetectInventoryFilters2() Then
		ACT_InventoryHideFilters($GLB_inventoryWindow_filtersIndicator2[1])
		UTL_Wait(1, 1.5)
		If OCR_DetectInventoryFilters2() Then
			ACT_InventoryHideFilters($GLB_inventoryWindow_filtersIndicator2[1])
		EndIf
	EndIf
EndFunc   ;==>BOT_CheckInventoryFilters
#ce

;get container cargo
Func BOT_GetContainerCargo()
	Local $cargo = OCR_CalculateContainerCargo()
	$GUI_GLB_containers[GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]) - 1] = $cargo
	GUICtrlSetData($GUI_containerCargo[$GLB_curBot], $cargo)
	BOT_LogMessage("Container " & GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]) & " cargo: " & $cargo & "%", 1)
	Return $cargo
EndFunc   ;==>BOT_GetContainerCargo

;activate mining
Func BOT_ActivateMining($asteroidsAmount, $location = "belt")
	;if allready mining
	If BOT_CheckMining() Then
		GUI_SetLocationAndState($location, "mining")
		Return True
	EndIf

	If OCR_IsFleetCommLock1Present() Then
		UTL_LogScreen("Fleet commander lock found")
		BOT_LogMessage("Fleet commander lock found", 1)
		ACT_RemoveLock1ByMenu(True)
	EndIf

	If Not GUI_isFleetMiner() Then
		ACT_SwitchTab("asteroids")
	EndIf

	Local $asteroid = OCR_CheckAsteroidPresent()
	If $asteroid <> False Then
		If OCR_IsAsteroidUnlockPresent() Then
			ACT_UnlockActiveObject()
		EndIf

		;Local $lowerLockBoundary = 2
		;Local $upperLockBoundary = 7
		If $asteroidsAmount = 0 Then
			GUI_SetLocationAndState($location, "next")
			Return False
		;ElseIf $asteroidsAmount < $upperLockBoundary Then
		;	$lowerLockBoundary = 2
		;	$upperLockBoundary = $asteroidsAmount
		EndIf

		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + 0*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)
		Local $x2 = $GLB_ObjectSearch[0]
		Local $y2 = $GLB_ObjectSearch[1] + 1*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)

		Local $actionDistance = GUICtrlRead($GUI_actionDistance[$GLB_curBot])

		If GUICtrlRead($GUI_mineAtOnce[$GLB_curBot]) = 1 Then
			ACT_ActivateMining()
			ACT_ClickOverviewObject()
		ElseIf GUICtrlRead($GUI_mineAtOnce[$GLB_curBot]) = 2 Then
			Local $slotPerAsteroid = GUI_GetBotMinersAmount() / 2
			If $slotPerAsteroid < 1 Then
				If Not OCR_isObjectLocked($x1, $y1) Then
					ACT_ActivateMining(1, GUI_GetBotMinersAmount())
					ACT_ClickOverviewObject()
				EndIf
			ElseIf $slotPerAsteroid >= 1 And $slotPerAsteroid < 2 Then
				If Not OCR_isObjectLocked($x1, $y1) Then
					ACT_ClickOverviewObject()
					ACT_SI_ObjectLock("asteroid")
				EndIf

				If Not OCR_isObjectLocked($x2, $y2) And EVEOCR_GetOverviewObjectDistance(2) < $actionDistance*1000 Then
					ACT_ClickOverviewObject(2)
					ACT_SI_ObjectLock("asteroid")
				EndIf

				Local $lockTime = UTL_CalcLockTime()/1000
				UTL_Wait($lockTime, $lockTime + 1)

				ACT_ActivateLockedTarget(1)
				ACT_ActivateMining(1, 1)
				ACT_ActivateLockedTarget(2)
				ACT_ActivateMining(2, GUI_GetBotMinersAmount())
				ACT_ClickOverviewObject()
			ElseIf $slotPerAsteroid >= 2 Then
				;TODO
				ACT_ActivateMining(1, 2)
				ACT_ClickOverviewObject(1)
				ACT_ActivateMining(3, GUI_GetBotMinersAmount())
				ACT_ClickOverviewObject(2)
			EndIf
#cs
		ElseIf GUICtrlRead($GUI_mineAtOnce[$GLB_curBot]) = 3 Then
			Local $slotPerAsteroid = GUI_GetBotMinersAmount() / 3
			If $slotPerAsteroid < 1 Then
				ACT_ActivateMining()
				ACT_ClickOverviewObject()
			ElseIf $slotPerAsteroid >= 1 And $slotPerAsteroid < 2 Then
				;first asteroid
				Local $ast1 = 1
				If Not OCR_isObjectLocked($GLB_ObjectSearch[0], $GLB_ObjectSearch[1] + ($ast1 - 1) * ($GLB_ObjectSearchIconSize + $GLB_ObjectSearchDividerSize)) Then
					ACT_ClickOverviewObject($ast1)
					ACT_SI_ObjectLock("asteroid")
					UTL_Wait(2, 3)
				Else
					BOT_LogMessage("Asteroid " & $ast1 & " already locked", 1)
				EndIf

				;second asteroid
				Local $ast2 = 1
				If $asteroidsAmount > 2 Then
					$ast2 = Round(Random($lowerLockBoundary, $upperLockBoundary))
				EndIf

				If Not OCR_isObjectLocked($GLB_ObjectSearch[0], $GLB_ObjectSearch[1] + ($ast2 - 1) * ($GLB_ObjectSearchIconSize + $GLB_ObjectSearchDividerSize)) Then
					ACT_ClickOverviewObject($ast2)
					ACT_SI_ObjectLock("asteroid")
					UTL_Wait(2, 3)
				Else
					BOT_LogMessage("Asteroid " & $ast2 & " already locked", 1)
				EndIf

				;third asteroid
				Local $ast3 = 1
				If $asteroidsAmount > 2 Then
					$ast3 = $ast2
					While $ast3 = $ast2
						$ast3 = Round(Random($lowerLockBoundary, $upperLockBoundary))
					WEnd
				EndIf

				If Not OCR_isObjectLocked($GLB_ObjectSearch[0], $GLB_ObjectSearch[1] + ($ast3 - 1) * ($GLB_ObjectSearchIconSize + $GLB_ObjectSearchDividerSize)) Then
					ACT_ClickOverviewObject($ast3)
					ACT_SI_ObjectLock("asteroid")
					UTL_Wait(4, 5)
				Else
					BOT_LogMessage("Asteroid " & $ast3 & " already locked", 1)
				EndIf

				ACT_ActivateLockedTarget(1)
				ACT_ActivateMining(1, 1)

				ACT_ActivateLockedTarget(2)
				ACT_ActivateMining(2, 2)

				If GUI_getSecurityStatus() = "High" Then
					ACT_ActivateLockedTarget(3)
					ACT_ActivateMining(3, GUI_GetBotMinersAmount())
				EndIf
				; for bug with unlock
				ACT_ClickOverviewObject()
			ElseIf $slotPerAsteroid >= 2 Then
				;TODO
				ACT_ActivateMining(1, 2)
				ACT_ClickOverviewObject(1)
				ACT_ActivateMining(3, 4)
				ACT_ClickOverviewObject(2)
				ACT_ActivateMining(5, GUI_GetBotMinersAmount())
				ACT_ClickOverviewObject(3)
			EndIf
#ce
		EndIf

		GUI_SetLocationAndState($location, "mining")
		$GUI_minersReloadTS[$GLB_curBot] = _TimeGetStamp()
		UTL_SetWaitTimestamp(UTL_CalcLockTime())
		STA_SetIntervalTimestamp("mining_start")
		UTL_SetTimeout("cargo")
		Return True
	Else
		; redundant code, need check
		BOT_LogMessage("Asteroids not found", 1)
		UTL_LogScreen("Asteroids not found")
		If GUICtrlRead($GUI_bookmarkMax[$GLB_curBot]) = 1 Then
			Space_backToBase()
		Else
			GUI_SetLocationAndState($location, "next")
		EndIf
		Return False
	EndIf
EndFunc   ;==>BOT_ActivateMining

;check bot damage
Func BOT_CheckDamage($location, $state)
	Local $isNeedBackOnDamage = GUICtrlRead($GUI_runOnDamageCheckbox[$GLB_curBot]) = $GUI_CHECKED
	Local $isAllNeedBackOnDamage = GUICtrlRead($GUI_allBackOnOneDamageCheckbox) = $GUI_CHECKED
	Local $isUseShield = GUICtrlRead($GUI_useShieldsCheckbox[$GLB_curBot]) = $GUI_CHECKED
	Local $shield = -1
	Local $armorDamaged = False
	Local $activeFor = 0

	If $location = "station" Or $state = "warping" Then
		Return False
	EndIf

	If $GLB_stayInStation[$GLB_curBot] <> 0 Then
		Return False
	EndIf

	; check back on damage if needed
	If $isNeedBackOnDamage Or $isAllNeedBackOnDamage Then
		Local $repairLevel = 0
		$armorDamaged = OCR_DetectArmorDamage()
		$shield = OCR_DetectShieldDamage()
		GUICtrlSetData($GUI_shieldCurrent[$GLB_curBot], $shield)
		If $armorDamaged Then
			BOT_LogMessage("Shield status: " & $shield & "%", 1)
			UTL_LogScreen("Ship armor damaged", "damage")
			BOT_LogMessage("Ship armor damaged", 1)
			$repairLevel = 3
		ElseIf $shield <= GUICtrlRead($GUI_shieldCritical[$GLB_curBot]) Then
			BOT_LogMessage("Shield status: " & $shield & "%", 1)
			UTL_LogScreen("Ship damaged", "damage")
			BOT_LogMessage("Ship damaged", 1)

			; report NPC damage
			NET_ReportNPC(GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]), True)
			If GUI_speechAllowed() Then SPEECH_Say(GUICtrlRead($GUI_login[$GLB_curBot]), "Корабль поврежден в белте " & NET_GetNPCbelt() & ". Требуется зачистка белта.")

			$repairLevel = 1
		ElseIf $location = "station" And OCR_DetectCapsuleStation() Then
			BOT_LogMessage("Try mouse move to fix capsule detection", 1)
			ACT_RandomMouseMoves(1, 300, 0, 300, 500)
			If OCR_DetectCapsuleStation() Then
				UTL_LogScreen("Ship destroyed. Evacuation capsule detected in " & $location, "damage")
				BOT_LogMessage("Ship destroyed. Evacuation capsule detected in " & $location, 1)
				$repairLevel = 2
			Else
				BOT_LogMessage("False capsule detection in " & $location, 1)
			EndIf
		ElseIf ($location = "space" Or $location = "belt" Or $location = "anomaly") And OCR_DetectCapsuleSpace() Then
			BOT_LogMessage("Try mouse move to fix capsule detection", 1)
			ACT_RandomMouseMoves(1, 300, 0, 300, 500)
			If OCR_DetectCapsuleSpace() Then
				UTL_LogScreen("Ship destroyed. Evacuation capsule detected in " & $location, "damage")
				BOT_LogMessage("Ship destroyed. Evacuation capsule detected in " & $location, 1)
				$repairLevel = 2
			Else
				BOT_LogMessage("False capsule detection in " & $location, 1)
			EndIf
		EndIf

		If $repairLevel > 0 Then
			If $repairLevel = 1 Then
				If GUI_isHunter() Or GUI_isRole("Marauder") Then
					Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
					If $POS = "None" Or $POS = "POS" Then
						$GLB_stayInStation[$GLB_curBot] = 5 * 60 ; wait on POS 5 min
					Else
						$GLB_stayInStation[$GLB_curBot] = 1
					EndIf
				Else
					$GLB_stayInStation[$GLB_curBot] = GUICtrlRead($GUI_allBackOnOneDamageInput) * 60
				EndIf
				;TODO change belt
			ElseIf $repairLevel = 2 Then
				$GLB_stayInStation[$GLB_curBot] = -1
			ElseIf $repairLevel = 3 Then
				$GLB_stayInStation[$GLB_curBot] = -3
			EndIf

			If Not OCR_DetectUndockButton() And Not GUI_isRole("Courier") Then
				If GUI_getSecurityStatus() = "Low" Then
					BOT_WarpTo("Spot")
				Else
					BOT_WarpTo("Station")
				EndIf
			EndIf
			; for all
			If $isAllNeedBackOnDamage Then
				For $n = 0 To $GLB_numOfBots - 1 Step 1
					If $n <> $GLB_curBot Then
						$GLB_stayInStation[$n] = GUICtrlRead($GUI_allBackOnOneDamageInput) * 60
					EndIf
				Next
			EndIf
			Return True
		EndIf
	EndIf

	;if all need to dock
	If $GLB_stayInStation[$GLB_curBot] > 0 Then
		If OCR_DetectMainMenu() Then
			UTL_LogScreen("One of ships damaged", "damage")
			Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
			If GUI_getSecurityStatus() = "Low" And $POS = "POS" Then
				If $location <> "pos" Then
					BOT_WarpTo("POS")
				EndIf
				BOT_LogMessage("One of ships damaged. Aproaching POS", 1)
			Else
				BOT_LogMessage("One of ships damaged. Aproaching station", 1)
				If Not OCR_DetectUndockButton() Then
					ACT_SwitchTab("asteroids")
					If OCR_CheckAsteroidPresent() <> False Then
						BOT_WarpTo("Station")
					Else
						ACT_DockToStation()
					EndIf
				EndIf
			EndIf
		Else
			;TODO process loading
		EndIf
		Return True
	EndIf

	; actiate shield if needed
	If $isUseShield Then
		If $shield = -1 Then
			$shield = OCR_DetectShieldDamage()
		EndIf

		GUICtrlSetData($GUI_shieldCurrent[$GLB_curBot], $shield)

		If $GUI_shieldActivatedTS[$GLB_curBot] <> 0 Then
			$activeFor = Round((_TimeGetStamp() - $GUI_shieldActivatedTS[$GLB_curBot]) / 60)
		EndIf

		If $shield <= GUICtrlRead($GUI_shieldActivateOn[$GLB_curBot]) Then
			;BOT_LogMessage("BOT_CheckDamage: 0 - " & $shield, 1)
			Local $shieldSlots = GUI_GetSlotPosition("middle", "shield", True)
			;BOT_LogMessage("BOT_CheckDamage: 1 - " & UBound($shieldSlots), 1)
			;BOT_LogMessage("BOT_CheckDamage: 2 - " & $shieldSlots[0], 1)
			If $shieldSlots[0] Then
				;BOT_LogMessage("BOT_CheckDamage: 2.1", 1)
				For $i = 1 To UBound($shieldSlots) - 1 Step 1
					;BOT_LogMessage("BOT_CheckDamage: 3 - " & $i, 1)
					If Not OCR_isActiveMiddleSlot($shieldSlots[$i]) Then
						;BOT_LogMessage("BOT_CheckDamage: 4 - " & $i, 1)
						ACT_ActivateModule("middle", $shieldSlots[$i])
						;BOT_LogMessage("BOT_CheckDamage: 5 - " & $i, 1)
						$GUI_shieldActivatedTS[$GLB_curBot] = _TimeGetStamp()
						BOT_LogMessage("Shield status: " & $shield & "%, activating shield " & $i, 1)
					EndIf
				Next
			EndIf
		ElseIf (($shield = 100 And GUICtrlRead($GUI_shieldActivateOn[$GLB_curBot]) <> 100) Or $activeFor >= GUICtrlRead($GUI_shieldMaxActiveTime[$GLB_curBot])) And OCR_CheckShield() Then
			If $shield = 100 Then
				BOT_LogMessage("Shield status: " & $shield & "%, deactivating shield on repair", 1)
			Else
				BOT_LogMessage("Shield status: " & $shield & "%, deactivating shield on timeout", 1)
			EndIf
			$GUI_shieldActivatedTS[$GLB_curBot] = 0
			;TODO separate method for deactivation
			ACT_ActivateModule("middle", "shield")
		EndIf
	EndIf

	; activate damage control if exists
	Local $damageControl = GUI_GetSlotPosition("low", "damageControl")
	If $damageControl <> False And Not OCR_isActiveLowSlot($damageControl) Then
		ACT_ActivateModule("low", "damageControl")
	EndIf

	Return False
EndFunc   ;==>BOT_CheckDamage

;warp to
Func BOT_WarpTo($postAction = "Station")
	; reset cargo timeout
	UTL_SetTimeout("cargo", True)

	;return drones
	If GUICtrlRead($GUI_useDrones[$GLB_curBot]) = $GUI_CHECKED Then
		ACT_ReturnDrones()
		BOT_LogMessage("Try to return drones")

		If GUICtrlRead($GUI_waitDrones[$GLB_curBot]) = $GUI_CHECKED Then
			GUICtrlSetData($GUI_dronesOnReturn[$GLB_curBot], $postAction)

			Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
			If $huntPlace = "Belt" Then
				GUI_SetLocationAndState("belt", "drones")
			ElseIf $huntPlace = "Anomaly" Then
				GUI_SetLocationAndState("anomaly", "drones")
			EndIf

			UTL_SetWaitTimestamp(7)
			Return
		EndIf
	EndIf

	;BOT_CheckSorting("pap")

	ACT_ActivatePAPTab()

	If $postAction = "Station" Then
		ACT_WarpTo("station")
	ElseIf $postAction = "Anomaly" Then
		ACT_WarpTo("anomaly")
	ElseIf $postAction = "Spot" Then
		ACT_WarpTo("spot")
	ElseIf $postAction = "POS" Then
		ACT_WarpTo("pos")
	ElseIf $postAction = "Next" Then
		Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
		If $huntPlace = "Belt" Then
			ACT_WarpTo("belts", GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
		ElseIf $huntPlace = "Anomaly" Then
			; open scanner
			ACT_OpenScanner()
			UTL_Wait(1, 2)
			ACT_WarpToScannerItem(GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
			; close scanner
			ACT_CloseScanner()
		EndIf
	EndIf
EndFunc   ;==>BOT_WarpTo

;identify next bookmark
Func BOT_GetNextBookmark()
	Local $contLowLevel = 30
	Local $contHightLevel = 70
	Local $curBookmark = GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
	Local $maxBookmark = GUICtrlRead($GUI_bookmarkMax[$GLB_curBot])
	Local $nextBookmark = $curBookmark + 1
	Local $falseNextBookmark = $curBookmark + 2
	Local $falsePrevBookmark = $curBookmark - 2

	If $nextBookmark > $maxBookmark Then
		$nextBookmark = 1
	EndIf

	If GUI_isTransporter() Then
		$nextBookmark = -1

		Local $nextFound = False
		; look for next empty after current
		For $bookmark = $curBookmark - 1 To $maxBookmark - 1 Step 1
			If $GUI_GLB_containers[$bookmark] > $contLowLevel And $bookmark + 1 <> $curBookmark And $bookmark + 1 <> $falseNextBookmark And $bookmark + 1 <> $falsePrevBookmark Then
				BOT_LogMessage("Bookmark: go to next full container, current=" & ($curBookmark) & ", next=" & ($bookmark + 1), 1)
				$nextBookmark = $bookmark + 1
				$nextFound = True
				ExitLoop
			EndIf
		Next

		If Not $nextFound Then
			For $bookmark = 0 To $curBookmark - 1 Step 1
				If $GUI_GLB_containers[$bookmark] > $contLowLevel And $bookmark + 1 <> $curBookmark And $bookmark + 1 <> $falseNextBookmark And $bookmark + 1 <> $falsePrevBookmark Then
					BOT_LogMessage("Bookmark: go to prev full container, current=" & ($curBookmark) & ", next=" & ($bookmark + 1), 1)
					$nextBookmark = $bookmark + 1
					$nextFound = True
					ExitLoop
				EndIf
			Next
		EndIf

		; if not found go to next Miner
		If Not $nextFound Then
			For $bookmark = 0 To $maxBookmark - 1 Step 1
				If GUI_isMinerPresentInBookmark($bookmark + 1) And $bookmark + 1 <> $curBookmark And $bookmark + 1 <> $falseNextBookmark And $bookmark + 1 <> $falsePrevBookmark Then
					BOT_LogMessage("Bookmark: go to Miner, current=" & ($curBookmark) & ", next=" & ($bookmark + 1), 1)
					$nextBookmark = $bookmark + 1
					ExitLoop
				EndIf
			Next
		EndIf
	ElseIf GUI_isMiner() Then
		Local $nextFound = False
		; look for next empty after current
		For $bookmark = $curBookmark - 1 To $maxBookmark - 1 Step 1
			If $GUI_GLB_containers[$bookmark] < $contHightLevel And $bookmark + 1 <> $curBookmark And $GUI_GLB_containerAsteroids[$bookmark] > 0 And $bookmark + 1 <> $falseNextBookmark And $bookmark + 1 <> $falsePrevBookmark Then
				BOT_LogMessage("Bookmark current=" & ($curBookmark) & ", next=" & ($bookmark + 1), 1)
				$nextBookmark = $bookmark + 1
				$nextFound = True
				ExitLoop
			EndIf
		Next

		If Not $nextFound Then
			For $bookmark = 0 To $curBookmark - 1 Step 1
				If $GUI_GLB_containers[$bookmark] < $contHightLevel And $bookmark + 1 <> $curBookmark And $GUI_GLB_containerAsteroids[$bookmark] > 0 And $bookmark + 1 <> $falseNextBookmark And $bookmark + 1 <> $falsePrevBookmark Then
					BOT_LogMessage("Bookmark current=" & ($curBookmark) & ", next=" & ($bookmark + 1), 1)
					$nextBookmark = $bookmark + 1
					ExitLoop
				EndIf
			Next
		EndIf
	ElseIf GUI_isFleetMiner() Then
		If GUI_getFleetCommBookmark() <> $curBookmark Then
			$nextBookmark = GUI_getFleetCommBookmark()
		Else
			$nextBookmark = GUI_getFleetCommBookmark() + 1
			If $nextBookmark > $maxBookmark Then
				$nextBookmark = 1
				If $nextBookmark = $curBookmark Then
					$nextBookmark = -1
				EndIf
			EndIf
		EndIf
	ElseIf GUI_isHunter() Then
		;skip bookmark if another hunter is there
		For $i = 0 To $GLB_numOfBots - 1 Step 1
			If $i = $GLB_curBot Then
				ContinueLoop
			EndIf

			If GUICtrlRead($GUI_groupID[$GLB_curBot]) = GUICtrlRead($GUI_groupID[$i]) And GUICtrlRead($GUI_bokmarkCurrent[$i]) = $nextBookmark Then
				$nextBookmark += 1
				ExitLoop
			EndIf
		Next

		If $nextBookmark > $maxBookmark Then
			$nextBookmark = 1
		EndIf

		; skip low anomalies
		Local $anomaliesList = GUICtrlRead($GUI_anomaliesList[$GLB_curBot])
		Local $huntPlace = GUICtrlRead($GUI_huntingPlace[$GLB_curBot])
		If $huntPlace = "Anomaly" And $anomaliesList <> "" And Not BOT_isAnomalyInList($nextBookmark) Then
			Do
				GUICtrlSetData($GUI_bokmarkCurrent, $nextBookmark)
				$nextBookmark = $nextBookmark + 1
				If $nextBookmark > $maxBookmark Then
					$nextBookmark = 1
				EndIf
			Until BOT_isAnomalyInList($nextBookmark)
		EndIf
	EndIf

	BOT_LogMessage("Next bookmark " & $nextBookmark, 1)

	Return $nextBookmark
EndFunc   ;==>BOT_GetNextBookmark

; is anomaly in allowed list
Func BOT_isAnomalyInList($bookmark)
	Local $arrayAnomaliesList = _StringExplode(GUICtrlRead($GUI_anomaliesList[$GLB_curBot]), ",")
	For $i = 0 To UBound($arrayAnomaliesList) - 1 Step 1
		If $arrayAnomaliesList[$i] = $bookmark Then
			Return True
		EndIf
	Next
	Return False
EndFunc

;check warp wait
Func BOT_CheckWarpWait($destination)
	;detect warp start
	If Not $GUI_warpDetected[$GLB_curBot] Then
		If OCR_WrapIsActive() Then
			$GUI_warpDetected[$GLB_curBot] = True
			UTL_SetTimeout("warp")
			GUI_SetLocationAndState($destination, "warping")
			UTL_SetTimeout("waiting", True)
			$GUI_timeoutWarpWaiting = 0
			$GUI_timeoutWarpWaitingTry = 0
		Else
			Local $now = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
			Local $diff = $now - $GUI_timeoutWarpWaiting

			BOT_LogMessage("BOT_CheckWarpWait: " & $diff & ", " & _StringFormatTime("%c", $now) & " - " & _StringFormatTime("%c", $GUI_timeoutWarpWaiting))

			Local $oldTimestamp = $GUI_timeoutWarpWaiting

			If ($diff > 9 And $GUI_timeoutWarpWaitingTry = 0) Or ($diff > 19 And $GUI_timeoutWarpWaitingTry = 1) Or ($diff > 29 And $GUI_timeoutWarpWaitingTry = 2) Then
				;if ship scrambled
				If OCR_isShipScrambled() Then
					BOT_LogMessage("BOT_CheckWarpWait: ship scrambled", 1)
					UTL_LogScreen("ship scrambled", "ship scrambled")
					ACT_SwitchTab("npc")
					Local $NPC = OCR_CheckNPCPresent()
					If GUI_GetBotGunsAmount() > 0 And $NPC <> False Then
						BOT_CheckSorting("overview", "icon")
						$NPC = OCR_CheckNPCPresent(False, "smallest")
						If $NPC <> False Then
							UTL_LogScreen("Possible scrambling NPC found", "npc")
							BOT_LogMessage("BOT_CheckWarpWait: Possible scrambling NPC found", 1)
							;If GUI_speechAllowed() Then SPEECH_Say(GUICtrlRead($GUI_login[$GLB_curBot]),"Возможно таклящее NPC в белте " & $curBookmark & ".")

							ACT_ReactivateGuns() ; wrecks too far avay if start to shoot immedeately
							If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "targetPainter")) Then
								ACT_ActivateModule("middle", "targetPainter")
							EndIf
							ACT_ClickOverviewObject($NPC[2])

							If Not OCR_isActiveMiddleSlot(GUI_GetSlotPosition("middle", "shield"))  Then
								ACT_ActivateModule("middle", "shield")
							EndIf

							GUI_SetLastActionTime()
						EndIf
						Return False
					ElseIf GUI_GetBotGunsAmount() > 0 Then
						ACT_SwitchTab("default")
						UTL_LogScreen("ship scrambled by enemy", "ship scrambled")
						;TODO destroy scrambling enemy ship
					Else
						UTL_LogScreen("unknown scrambler", "ship scrambled")
					EndIf
				; try to change belt if nothing helps
				ElseIf $destination = "space" And $diff > 29 And $GUI_timeoutWarpWaitingTry = 2 Then
					UTL_LogScreen("Warp not started in belt " & GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]) & ", changing belt", "belt change")
					BOT_LogMessage("Warp not started in belt " & GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]) & ", changing belt", 1)
					GUICtrlSetData($GUI_bokmarkCurrent[$GLB_curBot], BOT_GetNextBookmark())
				EndIf

				BOT_LogMessage("BOT_CheckWarpWait: try to warp again #" & ($GUI_timeoutWarpWaitingTry + 1), 1)
				;if PAP window closed
				If Not OCR_DetectPAPWindow() Then
					ACT_OpenPAPWindow()
				EndIf
				ACT_ActivatePAPTab()

				If $destination = "station" Or $destination = "belt" Then
					ACT_WarpTo("station")
				ElseIf $destination = "anomaly" Then
					; open scanner
					ACT_OpenScanner()
					UTL_Wait(1, 2)
					ACT_WarpToScannerItem(GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
					; close scanner
					ACT_CloseScanner()
				ElseIf $destination = "spot" Then
					ACT_WarpTo("spot")
				ElseIf $destination = "pos" Then
					ACT_WarpTo("pos")
				ElseIf $destination = "space" Then
					ACT_WarpTo("belts", GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot]))
				EndIf

				$GUI_timeoutWarpWaitingTry += 1
				$GUI_timeoutWarpWaiting = $oldTimestamp

				UTL_Wait(1, 2)
			EndIf

			If $GUI_timeoutWarpWaiting <> 0 And $diff > $GUI_timeoutWarpWaitingDefault Then
				Local $msg = $destination & " warp waiting timeout"
				If $destination = "space" Then
					$msg &= ", bookmark " & GUICtrlRead($GUI_bokmarkCurrent[$GLB_curBot])
				EndIf
				BOT_CloseWindow($msg)
				UTL_SetTimeout("waiting", True)
				$GUI_timeoutWarpWaiting = 0
				$GUI_timeoutWarpWaitingTry = 0
				Return False
			EndIf
			BOT_CheckTimeout("waiting")
		EndIf
	EndIf
EndFunc   ;==>BOT_CheckWarpWait

;check warp
Func BOT_CheckWarp($destination)
	; check false warp end
	Local $firstCheck = OCR_WrapIsActive()
	UTL_Wait(0.5, 1)

	If Not $firstCheck And Not OCR_WrapIsActive() Then
		BOT_LogMessage("Warp end", 1)
		GUI_SetLocationAndState($destination, "free")
		UTL_SetTimeout("warp", True)
		If $destination = "station" Then
			GUI_SetLocationAndState("station", "waiting")
			;UTL_SetWaitTimestamp(25)
		Else
			UTL_Wait(1.5, 2)
		EndIf
	Else
		BOT_LogMessage("Warp active")
		BOT_CheckTimeout("warp")
	EndIf
EndFunc   ;==>BOT_CheckWarp

;depricate
;activate shield
Func BOT_ActivateShields()
	$GUI_shieldActivatedTS[$GLB_curBot] = _TimeGetStamp()
	ACT_ActivateModule("middle", "shield")
EndFunc   ;==>BOT_ActivateShields

;close window
Func BOT_CloseWindow($reason = "unknown")
	UTL_LogScreen("Closing window: " & $reason)
	BOT_LogMessage("Closing window: " & $reason, 1)
	WIN_CloseWindow()
	GUI_SetLocationAndState("closed", "free")
	UTL_CheckResetTimeouts()
EndFunc   ;==>BOT_CloseWindow

;check timeout
Func BOT_CheckTimeout($type)
	If $type <> "drones" And Not UTL_CheckTimeout($type) Then
		BOT_CloseWindow($type & " timeout")
		BOT_LogMessage("Closed on " & $type & " timeout", 1)
		Return False
	ElseIf $type = "drones" And Not UTL_CheckTimeout($type) Then
		GUI_SetLocationAndState("belt", "free")
	EndIf
	Return True
EndFunc   ;==>BOT_CheckTimeout

;unhandled error processing
Func BOT_UnhandledError()
	BOT_FinalizeStop()
	BOT_LogMessage("Closing windows on unhandled error")
	For $b = 0 To $GLB_numOfBots - 1 Step 1
		$GLB_curBot = $b
		WIN_CloseWindow()
		GUI_SetLocationAndState("closed", "free")
	Next
	BOT_Start()
EndFunc   ;==>BOT_UnhandledError

;check location and state
Func BOT_CheckLocationAndState($location, $state)
	; ignore waiting and warping states
	If $state = "waiting" Or $state = "warping" Then
		Return True
	EndIf

	Local $needFix = False
	If $location = "login" Then
		If $state = "free" And Not OCR_DetectLogin() Then $needFix = True
		;ElseIf $location = "info" Then
		;If Not OCR_DetectInfo() Then $needFix = True
	ElseIf $location = "station" Then
		If $state = "free" And Not OCR_DetectUndockButton() Then $needFix = True
	ElseIf $location = "space" Then
		If OCR_DetectUndockButton() Then $needFix = True
	ElseIf $location = "belt" Then
		If OCR_DetectUndockButton() Then $needFix = True
	EndIf

	If $needFix Then
		BOT_FixLocationAndState($location, $state)
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>BOT_CheckLocationAndState

;fix location and state
Func BOT_FixLocationAndState($location, $state)
	BOT_LogMessage("Fixing location, please wait ...", 1)

	Local $winExists = WinExists($WIN_titles[$GLB_curBot])
	Local $login = OCR_DetectLogin()
	Local $info = OCR_DetectInfo()
	Local $undock = False
	Local $warp = False
	Local $mining = False
	Local $base = False
	Local $asteroid = False

	If $winExists And Not $login And Not $info Then
		$undock = OCR_DetectUndockButton()
		If Not $undock Then
			$warp = OCR_WrapIsActive()

			If Not GUI_isTransporter() Then
				$mining = BOT_CheckMining()
			EndIf

			ACT_SwitchTab("default")
			UTL_Wait(1, 2)
			$base = OCR_CheckAsteroidPresent()
			ACT_SwitchTab("asteroids")
			UTL_Wait(1, 2)
			$asteroid = OCR_CheckAsteroidPresent()
		EndIf
	EndIf

	;check location
	If Not $winExists Then
		GUI_SetLocationAndState("closed", "free", "LOCATION FIXED from " & $location)
	ElseIf $login And $location <> "login" Then
		GUI_SetLocationAndState("login", "free", "LOCATION FIXED from " & $location)
		UTL_LogScreen("LOCATION FIXED from " & $location, "fixes")
	ElseIf $info And $location <> "info" Then
		GUI_SetLocationAndState("info", "waiting", "LOCATION FIXED from " & $location)
		UTL_LogScreen("LOCATION FIXED from " & $location, "fixes")
	ElseIf $undock And $location <> "station" Then
		GUI_SetLocationAndState("station", "free", "LOCATION FIXED from " & $location)
		UTL_LogScreen("LOCATION FIXED from " & $location, "fixes")
	ElseIf $asteroid <> False And $location <> "belt" Then
		GUI_SetLocationAndState("belt", "free", "LOCATION FIXED from " & $location)
		UTL_LogScreen("LOCATION FIXED from " & $location, "fixes")
	ElseIf $base <> False And Not $undock And $location <> "space" Then
		GUI_SetLocationAndState("space", "free", "LOCATION FIXED from " & $location)
		UTL_LogScreen("LOCATION FIXED from " & $location, "fixes")
	EndIf

	$location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
	;check state
	If $location = "belt" And $state <> "mining" And $mining Then
		GUI_SetLocationAndState("belt", "mining", "STATE FIXED from " & $state)
		UTL_LogScreen("STATE FIXED from " & $state, "fixes")
	ElseIf $state <> "warping" And $warp Then
		GUI_SetLocationAndState($location, "warping", "STATE FIXED from " & $state)
		UTL_LogScreen("STATE FIXED from " & $state, "fixes")
	EndIf

	BOT_LogMessage("Location fixed", 1)
	Return True
EndFunc   ;==>BOT_FixLocationAndState

;check disconnect
Func BOT_IsDisconnected()
	Local $close = False
	;if server not responding
	If Not BOT_PingServer(GUICtrlRead($GUI_EVEServerInput)) Then
		BOT_LogMessage("Server not responding", 1)
		$close = True
		;TODO check time for drive activation
		#cs
			ElseIf Not OCR_DetectUndockButton() Then
			;check commands in client
			BOT_LogMessage("Checking client commands", 1)
			ACT_GoOnMaxSpeed()
			UTL_Wait(7, 8)
			If Not OCR_EngineIsActive() Then
			BOT_LogMessage("Client not responding to commands", 1)
			$close = True
			Else
			ACT_StopEngine()
			EndIF
		#ce
	EndIf

	If $close Then
		BOT_CloseWindow("disconnected")
		UTL_SetWaitTimestamp(1 * 60)
		Return True
	EndIf

	BOT_LogMessage("Client connection OK", 1)
	Return False
EndFunc   ;==>BOT_IsDisconnected

;ping server
Func BOT_PingServer($server)
	Local $ping = 0
	BOT_LogMessage("Checking server ping: " & $server, 1)
	For $p = 0 To 5 Step 1
		If Ping($server, GUICtrlRead($GUI_EVEServerTimeoutInput)) <> 0 Then
			$ping += 1
		EndIf
	Next

	If $ping = 0 Then
		Return False
	EndIf

	Return True
EndFunc   ;==>BOT_PingServer

;check informational windows
Func BOT_CheckInfoWindows()
	Local $location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])

	;close info window if opened
	If OCR_DetectInfoWindow() Then
		BOT_LogMessage("Informational window detected", 1)
		UTL_LogScreen("Informational window detected", "info")

		If $location = "login" Then
			; removed depricated code
		ElseIf $location = "info" Then
			If OCR_DetectLogin() Then
				GUI_SetLocationAndState("login", "error")
			Else
				;if info enter game error, wait
				UTL_SetWaitTimestamp(1 * 60)
			EndIf

			If $location <> "login" Then
				Send("{ENTER}")
			EndIf
			Return False
		EndIf
		ACT_CloseInfoWindow()
	ElseIf OCR_DetectConnectioLostWindow() Then
		BOT_LogMessage("Connection lost window detected", 1)
		UTL_LogScreen("Connection lost window detected", "info")
		UTL_Wait(0.5, 1)
		WIN_CloseWindow($WIN_titles[$GLB_curBot])
		GUI_SetLocationAndState("closed", "free")
		Return False
	EndIf

	Return True
EndFunc   ;==>BOT_CheckInfoWindows

;check client update window
Func BOT_CheckClientUpdateWindow()
	;close window if opened
	If OCR_DetectClientUpdateWindow() Then
		BOT_LogMessage("Client update window detected{" & $GLB_curBot & "}. Closing. Disabling all accounts", 1)
		BOT_LogMessage("Client update window detected{" & $GLB_curBot & "}. Closing. Disabling all accounts", 2)
		For $b = 0 To $GLB_numOfBots - 1 Step 1
			GUICtrlSetState($GUI_enableBot[$b], $GUI_UNCHECKED)
			GUI_SetLocationAndState("closed", "free", "", $b)
		Next
		BOT_CloseWindow("Client update window detected")
		WIN_CloseAllWindows() ; close all other windows
		EMAIL_Notify("clientUpdateNeeded")
		;ACT_CloseClientUpdateWindow()
		Return False
	EndIf

	Return True
EndFunc   ;==>BOT_CheckClientUpdateWindow

;check client enable to connect message
Func BOT_CheckClientNeedUpdate()
	If OCR_DetectClientUnableToConnectMessage() Then
		BOT_LogMessage("Unable to connect message detected{" & $GLB_curBot & "}. Closing. Disabling all accounts", 1)
		BOT_LogMessage("Unable to connect message detected{" & $GLB_curBot & "}. Closing. Disabling all accounts", 2)
		For $b = 0 To $GLB_numOfBots - 1 Step 1
			GUICtrlSetState($GUI_enableBot[$b], $GUI_UNCHECKED)
			GUI_SetLocationAndState("closed", "free", "", $b)
		Next
		BOT_CloseWindow("Client needs update")
		WIN_CloseAllWindows() ; close all other windows
		EMAIL_Notify("clientUpdateNeeded")
		UTL_ShowToolTip("EVE Harvester: EVE client needs update!", 10)
		Return False
	EndIf

	Return True
EndFunc   ;==>BOT_CheckClientNeedUpdate

;check sorting
Func BOT_CheckSorting($type = "overview", $column = "distance", $order = "asc")
	If $type = "overview" And (($order = "asc" And Not OCR_checkOverviewSorting($column)) Or ($order = "desc" And OCR_checkOverviewSorting($column))) Then
		BOT_LogMessage("Wrong sorting detected - " & $column, 1)

		BOT_LogMessage("Try mouse move to fix", 1)
		ACT_RandomMouseMoves(1, 50, 0, 300, 500)
		If ($order = "asc" And Not OCR_checkOverviewSorting($column)) Or ($order = "desc" And OCR_checkOverviewSorting($column)) Then
			;UTL_LogScreen("Wrong sorting detected, click on column - " & $column, "sorting") ; a lot of screens for hunter
			BOT_LogMessage("Wrong sorting detected, click on column - " & $column, 1)
			ACT_ClickOverviewSorting($column)
			Return False
		Else
			BOT_LogMessage("Sorting OK", 1)
		EndIf
	ElseIf $type = "pap" And (($order = "asc" And Not OCR_checkPAPSorting()) Or ($order = "desc" And OCR_checkPAPSorting())) Then
		ACT_RandomMouseMoves()
		If (($order = "asc" And Not OCR_checkPAPSorting()) Or ($order = "desc" And OCR_checkPAPSorting())) Then
			ACT_ClickPAPSorting()
			UTL_LogScreen("Wrong sorting detected - PAP", "sorting")
			Return False
		Else
			BOT_LogMessage("False wrong sorting detected - PAP", 1)
		EndIf
	EndIf

	ACT_RandomMouseMoves()

	Return True
EndFunc   ;==>BOT_CheckSorting

;check scanner
Func BOT_CheckScanner()
	; open scanner
	ACT_OpenScanner()
	ACT_LaunghScanner()
	UTL_SetWaitTimestamp($GLB_ScanWaitTime)
	GUI_SetLocationAndState("belt", "scanning")
EndFunc   ;==>BOT_CheckScanner

;do coordinates transformations
Func BOT_UpdateCoordinates()
	;TODO check needs
	GLB_CalculateWindowsCoordinates()
EndFunc   ;==>BOT_UpdateCoordinates

;check join fleet window
Func BOT_CheckJoinFleetWindow()
	;if join fleet window if opened
	If OCR_DetectJoinFleetWindow() Then
		Local $allowFlet = GUICtrlRead($GUI_acceptUnknownFleet[$GLB_curBot])
		If $allowFlet = "Yes" Or ($allowFlet = "SameBotOnly" And $GLB_allowFleetJoin > 0) Then
			BOT_LogMessage("Fleet proposition detected. Accepting", 1)
			UTL_LogScreen("Fleet proposition detected. Accepting")
			ACT_AcceptFleet()
			$GLB_allowFleetJoin -= 1
		Else
			BOT_LogMessage("Fleet proposition detected. Rejecting", 1)
			UTL_LogScreen("Fleet proposition detected. Rejecting")
			ACT_RejectFleet()
		EndIf
	EndIf
EndFunc   ;==>BOT_CheckJoinFleetWindow

;check chat invitation window
Func BOT_CheckChatInvitationWindow()
	;if join fleet window if opened
	If OCR_DetectChatInviteWindow() Then
		Local $allowChat = False
		If $allowChat Then
			BOT_LogMessage("Chat invitation detected. Accepting", 1)
			UTL_LogScreen("Chat invitation detected. Accepting")
			ACT_AcceptChat()
		Else
			BOT_LogMessage("Chat invitation detected. Rejecting", 1)
			UTL_LogScreen("Chat invitation detected. Rejecting")
			ACT_RejectChat()
		EndIf
	EndIf
EndFunc   ;==>BOT_CheckChatInvitationWindow

;increment loading indicator
Func BOT_incrementLoadingCounter()
	BOT_LogMessage("Loading")
	$GUI_loadingCounter[$GLB_curBot] = $GUI_loadingCounter[$GLB_curBot] + 1

	;if loading hangs
	If $GUI_loadingCounter[$GLB_curBot] >= $GLB_loadingCounterLimit Then
		BOT_CloseWindow("client hang")
		BOT_LogMessage("Client loadings limit reached: " & $GUI_loadingCounter[$GLB_curBot] & " from " & $GLB_loadingCounterLimit, 1)
		$GUI_loadingCounter[$GLB_curBot] = 0
	Else
		; close window if connection lost
		Local $location = GUICtrlRead($GUI_locationCombo[$GLB_curBot])
		If $location <> "login" Then
			Send("{ENTER}")
		EndIf
	EndIf
EndFunc   ;==>BOT_incrementLoadingCounter

;check main menu
Func BOT_CheckMainMenu()
	Local $mainMenu = OCR_DetectMainMenu()

	;if no menu - loading in process
	If Not $mainMenu Then
		BOT_incrementLoadingCounter()
		Return False
	Else
		$GUI_loadingCounter[$GLB_curBot] = 0
		Return True
	EndIf
EndFunc   ;==>BOT_CheckMainMenu

;check cargo
Func BOT_CheckCargo()
	Local $cargo = OCR_CalculateInventoryCargo()

	;log cargo changes
	If $cargo <> GUICtrlRead($GUI_cargo[$GLB_curBot]) Then
		GUICtrlSetData($GUI_cargo[$GLB_curBot], $cargo)
		UTL_SetTimeout("cargo")
		BOT_LogMessage("Ship cargo: " & $cargo & "%", 1)
	EndIf

	If Not UTL_CheckTimeout("cargo") Then
		BOT_CloseWindow("Cargo timeout")
		$cargo = -1
	EndIf

	Return $cargo
EndFunc   ;==>BOT_CheckCargo

;старт работы бота
Func BOT_Start()
	If GUI_GetEnabledSteamAmounts() > 1 Then
		BOT_LogMessage("Only one account could be used with enabled Steam option", 2)
		Return False
	EndIf

	GUICtrlSetData($GUI_startButton, "Press" & @CRLF & "'PAUSE'" & @CRLF & "to stop")
	GUICtrlSetOnEvent($GUI_startButton, "BOT_Stopping")
	GUICtrlSetState($GUI_startButton, $GUI_DISABLE)

	For $botid = 0 To $GLB_numOfBots - 1 Step 1
		GUI_SetLastActionTime($botid)

		; reset timeouts to avoid window closing after manual stop/start
		UTL_SetTimeout("waiting", True, $botid)
		UTL_SetTimeout("warp", True, $botid)
		UTL_SetTimeout("cargo", True, $botid)
		UTL_SetTimeout("drones", True, $botid)
		UTL_SetTimeout("station", True, $botid)
		UTL_SetTimeout("tractoring", True, $botid)

		GUICtrlSetState($GUI_buttonSetHWND[$botid], $GUI_DISABLE)
	Next

	GUICtrlSetState($GUI_eveSelectPath, $GUI_DISABLE)
	GUICtrlSetState($GUI_eveSelectButton, $GUI_DISABLE)

	GUICtrlSetState($GUI_menuConf_Save, $GUI_DISABLE)
	GUICtrlSetState($GUI_menuConf_Load, $GUI_DISABLE)

	; set license state
	If LIC_isLicenseInputed() Then
		If Not $LIC_cryptKeyUpdated Then
			LIC_GetCryptKey()
		EndIf
		LIC_CheckLicense()
	Else
		LIC_setStandardLicense()
	EndIf

	$GLB_isRunning = True
	BOT_LogMessage("Start bot", 2)
EndFunc   ;==>BOT_Start

;останавливаем работу бота
Func BOT_Stopping()
	$GLB_isRunning = False
	$GLB_isStopping = True
	GUICtrlSetData($GUI_startButton, "Wait...")
	GUICtrlSetState($GUI_startButton, $GUI_DISABLE)
EndFunc

;окончательная остановка работы бота
Func BOT_FinalizeStop()
	GUICtrlSetData($GUI_startButton, "Start")
	GUICtrlSetOnEvent($GUI_startButton, "BOT_Start")
	GUICtrlSetState($GUI_startButton, $GUI_ENABLE)

	For $botid = 0 To $GLB_numOfBots - 1 Step 1
		GUICtrlSetState($GUI_buttonSetHWND[$botid], $GUI_ENABLE)
	Next

	GUICtrlSetState($GUI_eveSelectPath, $GUI_ENABLE)
	GUICtrlSetState($GUI_eveSelectButton, $GUI_ENABLE)

	GUICtrlSetState($GUI_menuConf_Save, $GUI_ENABLE)
	GUICtrlSetState($GUI_menuConf_Load, $GUI_ENABLE)

	$GLB_isStopping = False
	BOT_LogMessage("Stop bot", 2)
EndFunc   ;==>BOT_Stop

; log message
Func BOT_LogMessage($Text, $level = 0)
	UTL_LogMessage($Text, $level)
	UTL_Wait(0.05, 0.1)
EndFunc   ;==>BOT_LogMessage