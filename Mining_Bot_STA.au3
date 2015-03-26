Global $STA_lastCargoUnload[1]
Global $STA_lastUndock[1]

;mining
Global $STA_lastMinings[1]
Global $STA_lastMiningStart[1]
Global $STA_lastMiningEnd[1]

Global $STA_lastWarpStart[1]
Global $STA_lastWarpEnd[1]
Global $STA_waitTime[1]
Global $STA_damages[1]
Global $STA_clientHangs[1]

; init bot data arrays
Func STA_InitBotData($botid)
	_ArrayInsert($STA_lastCargoUnload, $botid)
	_ArrayInsert($STA_lastUndock, $botid)
	_ArrayInsert($STA_lastMinings, $botid)
	_ArrayInsert($STA_lastMiningStart, $botid)
	_ArrayInsert($STA_lastMiningEnd, $botid)
	_ArrayInsert($STA_lastWarpStart, $botid)
	_ArrayInsert($STA_lastWarpEnd, $botid)
	_ArrayInsert($STA_waitTime, $botid)
	_ArrayInsert($STA_damages, $botid)
	_ArrayInsert($STA_clientHangs, $botid)

	$STA_lastCargoUnload[$botid] = 0
	$STA_lastUndock[$botid] = 0
	$STA_lastMinings[$botid] = 0
	$STA_lastMiningStart[$botid] = 0
	$STA_lastWarpStart[$botid] = 0
	$STA_lastMiningEnd[$botid] = 0
	$STA_lastWarpStart[$botid] = 0
	$STA_lastWarpEnd[$botid] = 0
	$STA_waitTime[$botid] = 0
	$STA_damages[$botid] = 0
	$STA_clientHangs[$botid] = 0
EndFunc

; deinit bot data arrays
Func STA_DeinitBotData($botid)
	_ArrayDelete($STA_lastCargoUnload, $botid)
	_ArrayDelete($STA_lastUndock, $botid)
	_ArrayDelete($STA_lastMinings, $botid)
	_ArrayDelete($STA_lastMiningStart, $botid)
	_ArrayDelete($STA_lastMiningEnd, $botid)
	_ArrayDelete($STA_lastWarpStart, $botid)
	_ArrayDelete($STA_lastWarpEnd, $botid)
	_ArrayDelete($STA_waitTime, $botid)
	_ArrayDelete($STA_damages, $botid)
	_ArrayDelete($STA_clientHangs, $botid)
EndFunc

; set statistics interval
Func STA_SetIntervalTimestamp($type)
	If $type = "mining_start" Then
		$STA_lastMiningStart[$GLB_curBot] = _TimeGetStamp()
	ElseIf $type = "mining_end" Then
		$STA_lastMiningEnd[$GLB_curBot] = _TimeGetStamp()
	EndIf
EndFunc

; finalize statistics interval
Func STA_FinalizeInterval($type)
	Local $value

	If $type = "mining" And $STA_lastMiningStart[$GLB_curBot] <> 0 And $STA_lastMiningEnd[$GLB_curBot] <> 0 Then
		;$value = GUICtrlRead($GUI_statMining[$GLB_curBot]) + Round(($STA_lastMiningEnd[$GLB_curBot] - $STA_lastMiningStart[$GLB_curBot])/60, 2)
		$STA_lastMinings[$GLB_curBot]+= 1

		;GUICtrlSetData($GUI_statMining[$GLB_curBot], Round($value/$STA_lastMinings[$GLB_curBot], 2))
		$STA_lastMiningStart[$GLB_curBot] = 0
		$STA_lastMiningEnd[$GLB_curBot] = 0
	Else
		;TODO other parameters
	EndIf
EndFunc

; log statistics
Func STA_LogStatistics()
	For $b = 0 To $GLB_numOfBots - 1 Step 1
		;LogMessage("Bot " & ($b + 1) & ": average mining time - " & GUICtrlRead($GUI_statMining[$b]) & " min", 2)
	Next
EndFunc