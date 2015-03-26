; containers state
Global $GUI_GLB_containers[100]
Global $GUI_GLB_containerAsteroids[100]

; fleet commander corp hangar value
Global $GUI_GLB_FleetCommCorpHangarValue = 0

Global $GUI_waitingStartTS[1]
Global $GUI_warpStartTS[1]
Global $GUI_cargoStartTS[1]
Global $GUI_dronesStartTS[1]
Global $GUI_stationStartTS[1]
Global $GUI_tractoringStartTS[1]

Global $GUI_warpDetected[1]
Global $GUI_DATA_LoginErrors[1]

;mining statistics
;Global $GUI_statMining[1]
Global $GUI_miningAsteroidNumber[1]

Global $GUI_currentConfigFile = "-1"
#cs
;START FROM HERE
#ce
;set state and location
Func GUI_SetLocationAndState($location, $state, $msg = "", $botid = $GLB_curBot)
	GUICtrlSetData($GUI_locationCombo[$botid], $location)
	GUICtrlSetData($GUI_stateCombo[$botid], $state)

	If $msg <> "" Then
		$msg = " [ " & $msg & " ]"
	EndIf

	BOT_LogMessage("State changed to: " & $location & " -> " & $state & $msg, 1)
EndFunc

; init containers
Func GUI_initContainers()
	For $i = 0 To UBound($GUI_GLB_containerAsteroids) - 1 Step 1
		$GUI_GLB_containerAsteroids[$i] = 15
		$GUI_GLB_containers[$i] = 0
	Next
EndFunc

;set last action time
Func GUI_SetLastActionTime($bot = "", $timestamp = "")
	If $bot = "" Then
		$bot = $GLB_curBot
	EndIf

	If $timestamp = "" Then
		$timestamp = _TimeGetStamp()
	EndIf

	$GUI_lastActionTS[$bot] = $timestamp
EndFunc

;create GUI
Func GUI_CreateGUI()
	GUI_CreateMainWindowGUI()
	GUI_CreateSettingsWindowGUI()
	GUI_CreateOCRWindowGUI()
	GUI_CreateAccountWindow()
	GUI_CreateAboutWindowGUI()
EndFunc

Func GUI_launghLA()
	Run(@ScriptDir & "/Bot_LA.exe", @ScriptDir)
EndFunc

Func GUI_launghSF()
	 Run(@ScriptDir & "/Bot_SF.exe", @ScriptDir)
 EndFunc

Func GUI_launghHC()
	 Local $run = MsgBox(1, "Warning", "Health checker will close all bot windows. Continue?")
	 If $run = 1 Then
		Run(@ScriptDir & "/Bot_HEALTH_CHECKER.exe " & $GUI_currentConfigFile, @ScriptDir)
	 EndIf
EndFunc

;select eve executable
Func GUI_SelectEVEExe()
	Local $filepath = FileOpenDialog("Select EVE executable", @WindowsDir, "Executable (*.exe)", 1, "ExeFile.exe")

	If @error And GUICtrlRead($GUI_eveSelectPath) = "" Then
		MsgBox(4096,"","No File chosen, new windows will not be opened!")
	Else
		GUICtrlSetData($GUI_eveSelectPath, $filepath)
	EndIf
EndFunc

;check bot enabled
Func GUI_CheckBotEnable()
	$GLB_curBot = _GUICtrlListBox_GetCaretIndex($GUI_usersList)
	Local $enabled = GUICtrlRead($GUI_enableBot[$GLB_curBot]) = $GUI_CHECKED

	If $enabled Then
		BOT_LogMessage("Bot enabled", 1)
	Else
		BOT_LogMessage("Bot disabled", 1)
	EndIf
EndFunc

;get slot position
Func GUI_GetSlotPosition($level = "high", $type = "gun", $all = False)
	Local $slots
	If $level = "high" Then
		$slots = $GUI_slotHigh
	ElseIf $level = "middle" Then
		$slots = $GUI_slotMiddle
	ElseIf $level = "low" Then
		$slots = $GUI_slotLow
	EndIf

	Local $slotsAll[1] = [False]
	For $s = 0 To 7 Step 1
		If GUICtrlRead($slots[$GLB_curBot][$s]) = $type Then
			If $all Then
				_ArrayAdd($slotsAll, $s + 1)
				$slotsAll[0] = True
			Else
				Return $s + 1
			EndIf
		EndIf
	Next

	If $all Then
		Return $slotsAll
	EndIf

	Return False
EndFunc

;get bot miners amount
Func GUI_GetBotMinersAmount()
	Local $amount = 0
	For $s = 0 To 7 Step 1
		If GUICtrlRead($GUI_slotHigh[$GLB_curBot][$s]) = "miner" Then
			$amount+= 1
		EndIf
	Next
	Return $amount
EndFunc

;get bot tractors amount
Func GUI_GetBotTractorsAmount()
	Local $amount = 0
	For $s = 0 To 7 Step 1
		If GUICtrlRead($GUI_slotHigh[$GLB_curBot][$s]) = "tractor" Then
			$amount+= 1
		EndIf
	Next
	Return $amount
EndFunc

;get bot guns amount
Func GUI_GetBotGunsAmount()
	Local $amount = 0
	For $s = 0 To 7 Step 1
		If GUICtrlRead($GUI_slotHigh[$GLB_curBot][$s]) = "gun" Then
			$amount+= 1
		EndIf
	Next
	Return $amount
EndFunc

;get enabled steam accounts amount
Func GUI_GetEnabledSteamAmounts()
	Local $amount = 0
	For $s = 0 To $GLB_numOfBots - 1 Step 1
		If GUICtrlRead($GUI_enableBot[$s]) = $GUI_CHECKED And GUICtrlRead($GUI_isSteam[$s]) = $GUI_CHECKED Then
			$amount+= 1
		EndIf
	Next
	Return $amount
EndFunc

;get accounts amount of location and state
Func GUI_GetAccountsAmount($location, $state)
	Local $amount = 0
	For $s = 0 To $GLB_numOfBots - 1 Step 1
		If GUICtrlRead($GUI_locationCombo[$s]) = $location And GUICtrlRead($GUI_stateCombo[$s]) = $state Then
			$amount+= 1
		EndIf
	Next
	Return $amount
EndFunc

;get role
Func GUI_getRole()
	Return GUICtrlRead($GUI_botRole[$GLB_curBot])
EndFunc

;depricate separate roles check
Func GUI_isRole($roleName)
	Return GUI_getRole() = $roleName
EndFunc

;is bot miner
Func GUI_isMiner()
	Return GUICtrlRead($GUI_botRole[$GLB_curBot]) = "Miner"
EndFunc

;is bot transporter
Func GUI_isTransporter()
	Return GUICtrlRead($GUI_botRole[$GLB_curBot]) = "Transporter"
EndFunc

;is bot hunter
Func GUI_isHunter()
	Return GUICtrlRead($GUI_botRole[$GLB_curBot]) = "Hunter"
EndFunc

;is bot fleet miner
Func GUI_isFleetMiner()
	Return GUICtrlRead($GUI_botRole[$GLB_curBot]) = "Fleet Miner"
EndFunc

;is bot fleet commander
Func GUI_isFleetCommander()
	Return GUICtrlRead($GUI_botRole[$GLB_curBot]) = "Fleet Commander"
EndFunc

;is Miner present in bookmark
Func GUI_isMinerPresentInBookmark($num)
	For $b = 0 To $GLB_numOfBots - 1 Step 1
		If GUICtrlRead($GUI_enableBot[$b]) = $GUI_CHECKED And GUICtrlRead($GUI_botRole[$b]) = "Miner" And GUICtrlRead($GUI_bokmarkCurrent[$b]) = $num Then
			Return True
		EndIf
	Next
	Return False
EndFunc

;get fleet commander bookmark
Func GUI_getFleetCommBookmark()
	For $b = 0 To $GLB_numOfBots - 1 Step 1
		If GUICtrlRead($GUI_enableBot[$b]) = $GUI_CHECKED And GUICtrlRead($GUI_botRole[$b]) = "Fleet Commander" Then
			Return GUICtrlRead($GUI_bokmarkCurrent[$b])
		EndIf
	Next
	Return False
EndFunc

;get fleet commander full cargo value
Func GUI_getFleetCommFulCargo()
	For $b = 0 To $GLB_numOfBots - 1 Step 1
		If GUICtrlRead($GUI_enableBot[$b]) = $GUI_CHECKED And GUICtrlRead($GUI_botRole[$b]) = "Fleet Commander" Then
			Return GUICtrlRead($GUI_fullCargo[$b])
		EndIf
	Next
	Return False
EndFunc

;get bot security status
Func GUI_getSecurityStatus()
	Return GUICtrlRead($GUI_systemSecurity[$GLB_curBot])
EndFunc

;get POS status
Func GUI_getPOSStatus()
	Return GUICtrlRead($GUI_systemPOS[$GLB_curBot])
EndFunc

;is speech allowed
Func GUI_speechAllowed()
	Return (GUICtrlRead($GUI_useSpeechEngine) = $GUI_CHECKED)
EndFunc

;monitor local
Func GUI_localMonitoringAllowed()
	Return (GUICtrlRead($GUI_localChatMonitor[$GLB_curBot]) = $GUI_CHECKED)
EndFunc

; add bookmark
Func GUI_BookmarkAdd()
	Local $list = $GUI_BookmarksList[$GUI_lastOpenedUser]
	Local $newItem = GUICtrlRead($GUI_BookmarkItem[$GUI_lastOpenedUser])
	Local $positon = _GUICtrlListBox_GetCaretIndex($list)
	_GUICtrlListBox_InsertString($list, $newItem, $positon)
	_GUICtrlListBox_SetCurSel($list, $positon)
EndFunc

; remove bookmark
Func GUI_BookmarkRemove()
	Local $list = $GUI_BookmarksList[$GUI_lastOpenedUser]
	Local $positon = _GUICtrlListBox_GetCaretIndex($list)

	If _GUICtrlListBox_GetText($list, $positon) = "Belts" Then
		MsgBox(64, "Wrong action", "Belts couldn't be deleted!")
		Return
	EndIf

	_GUICtrlListBox_DeleteString($list, $positon)
	_GUICtrlListBox_SetCurSel($list, 0)
EndFunc

; get bookmark position
Func GUI_BookmarkGetPosition($type = "belts", $spotIndex = -1)
	Local $list = $GUI_BookmarksList[$GLB_curBot]
	Local $position = -1

	Switch StringLower($type)
		Case "station"
			$position = _GUICtrlListBox_FindString($list, $type)
		Case "pos"
			$position = _GUICtrlListBox_FindString($list, $type)
		Case "spot"
			Local $spots[1]
			Local $count = 0
			Local $currentPosition = -1
			For $s = 0 To _GUICtrlListBox_GetCount($list) - 1 Step 1
				$currentPosition = _GUICtrlListBox_FindInText($list, $type, $currentPosition)
				If $currentPosition <> -1 Then
					If $count = 0 Then
						$spots[0] = $currentPosition
					Else
						_ArrayInsert($spots, $count, $currentPosition)
					EndIf
					$count+= 1
				Else
					ExitLoop
				EndIf
			Next
			; first element is amount of unique records
			$spots = _ArrayUnique($spots)

			If $spotIndex = -1 Then
				$position = $spots[Random(1, $spots[0], 1)]
			ElseIf $spotIndex > $spots[0] - 1 Then
				MsgBox(64, "Error", "Spot not exist")
			Else
				$position = $spots[$spotIndex]
			EndIf
		Case "belts"
			$position = _GUICtrlListBox_FindString($list, $type)
		Case "destination"
			$position = _GUICtrlListBox_FindString($list, $type)
	EndSwitch

	If $position = -1 Then
		BOT_LogMessage("Bookmark " & $type & " NOT FOUND")
	Else
		; add shift 4 corporate bookmarks
		If GUICtrlRead($GUI_bookmarkType[$GLB_curBot]) = "Corporation" Then
			$position = $position + 1
		EndIf
		BOT_LogMessage("Bookmark " & $type & ", position=" & ($position + 1))
	EndIf

	Return ($position + 1)
EndFunc