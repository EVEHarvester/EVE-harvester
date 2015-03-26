Global $UTL_logDir = "\log\" & _StringFormatTime("%d.%m.%y %H-%M-%S", _TimeGetStamp())
Global $UTL_accountLogDirName = "log-account"

Global $UTL_generalLastTimestamp4Diff = False
Global $UTL_process1LastTimestamp4Diff = False

Global $UTL_lastLogRecord[1][2] ; last log record for account

;wait random time, params in seconds
Func UTL_Wait($min = 0.5, $max = 1)
    Sleep(Random($min*1000, $max*1000))
EndFunc

;create directories
Func UTL_CreateDirectories()
	DirCreate (@ScriptDir & $UTL_logDir)
EndFunc

;create log file
Func UTL_CreateLog($botNumber = "")
	BOT_LogMessage("UTL_CreateLog: bn=" & $botNumber, 2)
	If $botNumber = "" Then
		Local $filename = @ScriptDir & $UTL_logDir & "\" & $GLB_logFileName & "-global." & $GLB_logFileExtension
		BOT_LogMessage("UTL_CreateLog: global log file=" & $filename, 2)
	ElseIf $GLB_numOfBots > 0 Then
		Local $accountDir = $UTL_accountLogDirName & "-" & $botNumber
		If DirGetSize(@ScriptDir & $UTL_logDir & "\" & $accountDir & "\") = -1 Then
			If DirCreate (@ScriptDir & $UTL_logDir & "\" & $accountDir & "\") = 0 Then
				BOT_LogMessage("Log not created. Couldn't create directory "& $accountDir & ".", 2)
				Return False
			EndIf
		EndIf
		Local $filename = @ScriptDir & $UTL_logDir & "\" & $accountDir & "\" & $GLB_logFileName & "-" & $botNumber & "." & $GLB_logFileExtension
		BOT_LogMessage("UTL_CreateLog: account file=" & $filename, 2)
	EndIf

	If Not _FileCreate($filename) Then
		BOT_LogMessage("UTL_CreateLog: Log creation error " & $filename & ", error:" & @error, 2)
	Else
		BOT_LogMessage("UTL_CreateLog: Log created " & $filename, 2)
	EndIf
EndFunc

;write to log file
Func UTL_WriteToLog($text, $level = 0)
	If $level < 2 And $GLB_numOfBots > 0 Then ; bot log
		; filter dublicates and redundant messages
		If $text = $UTL_lastLogRecord[$GLB_curBot][0] Then
			Return False
		ElseIf StringInStr($text, "Need wait for") And StringInStr($UTL_lastLogRecord[$GLB_curBot][1], "Need wait for") Then
			Return False
		EndIf

		If Not _FileWriteLog(@ScriptDir & $UTL_logDir & "\" & $UTL_accountLogDirName & "-" & ($GLB_curBot + 1) & "\" & $GLB_logFileName & "-" &  ($GLB_curBot + 1) & "." & $GLB_logFileExtension, $text) Then
			BOT_LogMessage("Log record add error, error:" & @error & ", level:" & $level & ", text:" & $text, 2)
		EndIf

		$UTL_lastLogRecord[$GLB_curBot][1] = $UTL_lastLogRecord[$GLB_curBot][0]
		$UTL_lastLogRecord[$GLB_curBot][0] = $text
	ElseIf $level = 2 Then ; app log
		If Not _FileWriteLog(@ScriptDir & $UTL_logDir & "\" & $GLB_logFileName & "-global." & $GLB_logFileExtension, $text) Then
			BOT_LogMessage("Log record add error, error:" & @error & ", level:" & $level & ", text:" & $text, 2)
		EndIf
	EndIf

	Return True
EndFunc

; log message to gui and file
Func UTL_LogMessage($Text, $level = 0)
	Local $addText = @HOUR & ":" & @MIN & ":" & @SEC & " - " & $Text
	If $level = 1 Then
		Local $positionCurrentBot = StringLen(GUICtrlRead($GUI_currentLogInput))
		_GUICtrlEdit_SetSel($GUI_currentLogInput, $positionCurrentBot, $positionCurrentBot)
		GUICtrlSetData($GUI_currentLogInput, @CRLF & $addText, 1)

		If GUICtrlRead($GUI_useTooltipLog) = $GUI_CHECKED Then
			ToolTip($addText, $WIN_monitor[0] + 2, $WIN_monitor[1] + 2)
		EndIf
	EndIf

	UTL_WriteToLog($Text, $level)
	UTL_Wait(0.05, 0.1)
EndFunc   ;==>UTL_LogMessage

; show tooltip
Func UTL_ShowToolTip($text, $waitTime)
	Local $aPos = WinGetPos($GUI_mainWindow)
	Local $x = $aPos[0] + 10
	Local $y = $aPos[1] + $aPos[3] + 10

	ToolTip($text, $x, $y)
	Sleep($waitTime*1000) ; Sleep to give tooltip time to display
	UTL_HideToolTip()
EndFunc

; hide tooltip
Func UTL_HideToolTip()
	ToolTip("")
EndFunc

Func UTL_GetWindowBorders()
	If Not WinExists($WIN_titles[$GLB_curBot]) Then
		BOT_LogMessage("UTL_GetWindowBorders: can't get window borders, return [0,0]", 1)
		Local $returnObj[2] = [0, 0]
		Return $returnObj
	EndIf

	Local $wincoord = WinGetPos($WIN_titles[$GLB_curBot])
	#cs
		Returns a 4-element array containing the following information:
		$array[0] = X position
		$array[1] = Y position
		$array[2] = Width
		$array[3] = Height
	#ce

	Local $winClientSize = WinGetClientSize($WIN_titles[$GLB_curBot])
	#cs
		Returns a 2-element array containing the following information:
		$array[0] = Width of window's client area
		$array[1] = Height of window's client area
	#ce

	Local $border = ($wincoord[2] - $winClientSize[0]) / 2 ;dX
	Local $hTitle = $wincoord[3] - $winClientSize[1] - $border ;dY

	Local $returnObj[2] = [$border, $hTitle]
	Return $returnObj
EndFunc

;log screen
Func UTL_LogScreen($message, $group = "")
	Local $winSize = WinGetClientSize($WIN_titles[$GLB_curBot])
	If @error Then
		BOT_LogMessage("Screen not captured. Couldn't get window size.")
		Return False
	EndIf

	Local $targetDir = @ScriptDir & $UTL_logDir & "\" & $UTL_accountLogDirName & "-" & ($GLB_curBot + 1) & "\"

	If $group <> "" Then
		$targetDir = $targetDir & $group & "\"
		If DirGetSize($targetDir) = -1 Then
			If DirCreate ($targetDir) = 0 Then
				BOT_LogMessage("Screen not captured. Couldn't create directory.")
				Return False
			EndIf
		EndIf
	EndIf

	Local $filename = $targetDir & "screen-" & $GLB_logFileName & "-" & ($GLB_curBot + 1) & "." & _StringFormatTime("%d.%m.%y %H-%M-%S", _TimeGetStamp()) & ".jpg"
	Local $borders = UTL_GetWindowBorders()
	Local $x1 = $borders[0]
	Local $y1 = $borders[1]
	Local $x2 = $winSize[0] + $borders[0]
	Local $y2 = $winSize[1] + $borders[1]

	; Initialize GDI+ library
    If Not _GDIPlus_Startup () Then
		BOT_LogMessage("Screen not captured. GDI+ not initialized.")
		Return False
	EndIf

    ; Capture full screen
    Local $hBitmap1 = _ScreenCapture_CaptureWnd("", $WIN_titles[$GLB_curBot], $x1, $y1, $x2, $y2, True)
    Local $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP ($hBitmap1)

	If $hImage1 = 0 Then
		BOT_LogMessage("Screen not captured. GDI+ bitmap not created.")
		_GDIPlus_ShutDown ()
		Return False
	EndIf

    ; Draw in image
    Local $hGraphics = _GDIPlus_ImageGetGraphicsContext ($hImage1)
	Local $hBrush = _GDIPlus_BrushCreateSolid (0xFF2EB200)
    Local $hFormat = _GDIPlus_StringFormatCreate ()
    Local $hFamily = _GDIPlus_FontFamilyCreate ("Tahoma")
    Local $hFont = _GDIPlus_FontCreate ($hFamily, 12, 1)
    Local $tLayout = _GDIPlus_RectFCreate (10, 30, 0, 0)
    Local $aInfo = _GDIPlus_GraphicsMeasureString ($hGraphics, $message, $hFont, $tLayout, $hFormat)

    _GDIPlus_GraphicsDrawStringEx ($hGraphics, $message, $hFont, $aInfo[0], $hFormat, $hBrush)

    If Not _GDIPlus_ImageSaveToFile ($hImage1, $filename) Then
		BOT_LogMessage("Screen not captured. Couldn't save image.")
		_GDIPlus_FontDispose ($hFont)
		_GDIPlus_FontFamilyDispose ($hFamily)
		_GDIPlus_StringFormatDispose ($hFormat)
		_GDIPlus_BrushDispose ($hBrush)
		_GDIPlus_GraphicsDispose ($hGraphics)

		_GDIPlus_ImageDispose ($hImage1)
		_WinAPI_DeleteObject ($hBitmap1)

		_GDIPlus_ShutDown ()
		Return False
	EndIf

    ; Clean up resources
	_GDIPlus_FontDispose ($hFont)
    _GDIPlus_FontFamilyDispose ($hFamily)
    _GDIPlus_StringFormatDispose ($hFormat)
    _GDIPlus_BrushDispose ($hBrush)
    _GDIPlus_GraphicsDispose ($hGraphics)

    _GDIPlus_ImageDispose ($hImage1)

    _WinAPI_DeleteObject ($hBitmap1)

    ; Shut down GDI+ library
    _GDIPlus_ShutDown ()

	BOT_LogMessage("Screen captured to " & $filename & ", " & $winSize[0] &":"& $winSize[1])
EndFunc

;scheduled timestamps
Func UTL_GetScheduledTimestamps($schedules)
	If $schedules = "" Or $schedules = $GLB_notFoundRecord Then
		Local $returnObj[2] = [0,0]
		Return $returnObj
	EndIf

	Local $intervals = StringSplit($schedules, ',', 2)
	Local $returnObj[UBound($intervals)][2]

	Local $mStartHour
	Local $mStartMinute
	Local $mEndHour
	Local $mEndMinute

	For $i = 0 To UBound($intervals) - 1 Step 1
		Local $intervalData = StringSplit($intervals[$i], '-', 2)
		Local $intervalStart = StringSplit($intervalData[0], ':', 2)
		Local $intervalEnd = StringSplit($intervalData[1], ':', 2)
		$mStartHour = $intervalStart[0]
		$mStartMinute = $intervalStart[1]
		$mEndHour = $intervalEnd[0]
		$mEndMinute = $intervalEnd[1]
		$returnObj[$i][0] = _TimeMakeStamp(0, Int($mStartMinute), Int($mStartHour), Int(@MDAY), Int(@MON), @YEAR)
		$returnObj[$i][1] = _TimeMakeStamp(0, Int($mEndMinute), Int($mEndHour), Int(@MDAY), Int(@MON), @YEAR)
	Next

	;_ArrayDisplay($returnObj)
	Return $returnObj
EndFunc

;check for downtime
Func UTL_CheckDowntime()
	Local $curTS = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
	Local $sTS = UTL_GetScheduledTimestamps(GUICtrlRead($GUI_downtime))

	For $i = 0 To UBound($sTS) - 1 Step 1
		Local $startTS = $sTS[$i][0]
		Local $endTS = $sTS[$i][1]

		;Local $NOW = _StringFormatTime("%H-%M-%S", $curTS)
		;Local $START = _StringFormatTime("%H-%M-%S", $startTS)
		;Local $END = _StringFormatTime("%H-%M-%S", $endTS)
		;BOT_LogMessage("MT: " & $NOW & " - ("&$START&"<->"&$END&")", 1)
		If $curTS > $startTS And $curTS < $endTS Then
			Return True
		EndIf
	Next

	Return False
EndFunc

;generate schedule
Func UTL_GenerateSchedule($workHours = 14, $workMinutes = 0)
	Local $newSchedule = ""
	Local $waitMinutes = (24 - $workHours)*60 - $workMinutes

	Local $downtimeMinutes = 0
	Local $downtimeIntervals = StringSplit(GUICtrlRead($GUI_downtime), ',', 2)
	Local $downtimeObj[UBound($downtimeIntervals)][2]

	For $i = 0 To UBound($downtimeIntervals) - 1 Step 1
		Local $intervalData = StringSplit($downtimeIntervals[$i], '-', 2)
		Local $intervalStart = StringSplit($intervalData[0], ':', 2)
		Local $intervalEnd = StringSplit($intervalData[1], ':', 2)
		Local $mStartHour = $intervalStart[0]
		Local $mStartMinute = $intervalStart[1]
		Local $mEndHour = $intervalEnd[0]
		Local $mEndMinute = $intervalEnd[1]
		$downtimeObj[$i][0] = Int($mStartHour)*60 + Int($mStartMinute)
		$downtimeObj[$i][1] = Int($mEndHour)*60 + Int($mEndMinute)
		$downtimeMinutes+= ($mEndHour - $mStartHour)*60 + ($mEndMinute - $mStartMinute) ;Example -> 12:30-14:15 = (14 - 12)*60 + (15 - 30) = 105
	Next

	$waitMinutes-= $downtimeMinutes

	;BOT_LogMessage("UTL_GenerateSchedule: waitMinutes=" & $waitMinutes & ", downtimeMinutes=" & $downtimeMinutes, 1)

	If $waitMinutes <= 0 Then
		BOT_LogMessage("UTL_GenerateSchedule: no time to schedule", 1)
		Return $newSchedule
	EndIf

	;BOT_LogMessage("UTL_GenerateSchedule: shedule " & $waitMinutes & " minutes", 1)

	Local $stopsAmount = Random(1, 3, 1)
	Local $stopsObj[$stopsAmount][2]
	Local $stopSize = Round($waitMinutes/$stopsAmount)

	;BOT_LogMessage("UTL_GenerateSchedule: stopsAmount= " & $stopsAmount & ", stopSize=" & $stopSize, 1)

	; generate intervals
	Do
		Local $stopSizeShift = Random(1, Floor($stopSize/Random(2, 10, 1)), 1)
		Local $stopSizeCurrent

		If $stopsAmount >= 1 Then
			$stopSizeCurrent = $stopSize
			If $stopsAmount = 2 Then
				$stopSizeCurrent+= $stopSizeShift
			EndIf

			$stopsObj[0][0] = Random(0, 23 - (Floor(($stopSizeCurrent)/60) + 1), 1)*60 + Random(0, 59, 1) ;minute start
			$stopsObj[0][1] = $stopsObj[0][0] + $stopSizeCurrent ; minute end
		EndIf

		If $stopsAmount >= 2 Then
			$stopSizeCurrent = $stopSize
			If $stopsAmount = 2 Or $stopsAmount = 3 Then
				$stopSizeCurrent-= $stopSizeShift
			EndIf
			$stopsObj[1][0] = Random(0, 23 - (Floor(($stopSizeCurrent)/60) + 1), 1)*60 + Random(0, 59, 1) ;minute start
			$stopsObj[1][1] = $stopsObj[1][0] + $stopSizeCurrent ; minute end
		EndIf

		If $stopsAmount >= 3 Then
			$stopSizeCurrent = $stopSize
			If $stopsAmount = 3 Then
				$stopSizeCurrent+= $stopSizeShift
			EndIf
			$stopsObj[2][0] = Random(0, 23 - (Floor(($stopSizeCurrent)/60) + 1), 1)*60 + Random(0, 59, 1) ;minute start
			$stopsObj[2][1] = $stopsObj[2][0] + $stopSizeCurrent ; minute end
		EndIf
		;BOT_LogMessage("UTL_GenerateSchedule: temp shedule generated", 1)
	Until Not UTL_isIntersectedIntervals($stopsObj, $downtimeObj)

	; create shedule string
	For $i = 0 To UBound($stopsObj) - 1 Step 1
		Local $sHour = Floor($stopsObj[$i][0]/60)
		Local $sMinute = $stopsObj[$i][0] - $sHour*60
		Local $eHour = Floor($stopsObj[$i][1]/60)
		Local $eMinute = $stopsObj[$i][1] - $eHour*60

		If $sHour < 10 Then $sHour = "0" & $sHour
		If $sMinute < 10 Then $sMinute = "0" & $sMinute
		If $eHour < 10 Then $eHour = "0" & $eHour
		If $eMinute < 10 Then $eMinute = "0" & $eMinute

		$newSchedule = $newSchedule & $sHour & ":" & $sMinute & "-" & $eHour & ":" & $eMinute

		If $i <> UBound($stopsObj) - 1 Then
			$newSchedule = $newSchedule & ","
		EndIf
		;BOT_LogMessage("UTL_GenerateSchedule: shedule interval" & ($i+1) & "=" & ($stopsObj[$i][1] - $stopsObj[$i][0]), 1)
	Next

	BOT_LogMessage("UTL_GenerateSchedule: newSchedule=" & $newSchedule, 1)
	Return $newSchedule
EndFunc

Func UTL_isIntersectedIntervals($intervals, $intervalsAdditional)
	;check self intersection
	For $i = 0 To UBound($intervals) - 1 Step 1
		For $j = 0 To UBound($intervals) - 1 Step 1
			If $i <> $j And (($intervals[$i][0] > $intervals[$j][0] And $intervals[$i][0] < $intervals[$j][1]) Or ($intervals[$i][1] > $intervals[$j][0] And $intervals[$i][1] < $intervals[$j][1])) Then
				;BOT_LogMessage("UTL_GenerateSchedule: self intersected", 1)
				Return True
			EndIf
		Next
	Next

	;check additional intersection
	For $i = 0 To UBound($intervals) - 1 Step 1
		For $j = 0 To UBound($intervalsAdditional) - 1 Step 1
			If ($intervals[$i][0] > $intervalsAdditional[$j][0] And $intervals[$i][0] < $intervalsAdditional[$j][1]) Or ($intervals[$i][1] > $intervalsAdditional[$j][0] And $intervals[$i][1] < $intervalsAdditional[$j][1]) Then
				;BOT_LogMessage("UTL_GenerateSchedule: additional intersected", 1)
				Return True
			EndIf
		Next
	Next

	Return False
EndFunc

;check schedule
Func UTL_CheckSchedule()
	Local $curTS = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)
	Local $sTS = UTL_GetScheduledTimestamps(GUICtrlRead($GUI_botSchedule[$GLB_curBot]))

	For $i = 0 To UBound($sTS) - 1 Step 1
		Local $startTS = $sTS[$i][0]
		Local $endTS = $sTS[$i][1]

		;Local $NOW = _StringFormatTime("%H-%M-%S", $curTS)
		;Local $START = _StringFormatTime("%H-%M-%S", $startTS)
		;Local $END = _StringFormatTime("%H-%M-%S", $endTS)
		;BOT_LogMessage("MT: " & $NOW & " - ("&$START&"<->"&$END&")", 1)
		If $curTS > $startTS And $curTS < $endTS Then
			Return True
		EndIf
	Next

	Return False
EndFunc

;calc schedule time left
Func UTL_CalcScheduleTimeLeft($schedule)
	Local $sTS = UTL_GetScheduledTimestamps($schedule)

	For $i = 0 To UBound($sTS) - 1 Step 1
		Local $startTS = $sTS[$i][0]
		Local $endTS = $sTS[$i][1]
		Local $curTS = _TimeMakeStamp(Int(@SEC), Int(@MIN), Int(@HOUR), Int(@MDAY), Int(@MON), @YEAR)

		If $curTS > $startTS And $curTS < $endTS Then
			Return ($endTS - $curTS)
		EndIf
	Next
EndFunc

;set wait timestamp
Func UTL_SetWaitTimestamp($seconds = 5)
	$GLB_needWait[$GLB_curBot] = _TimeGetStamp() + $seconds
	BOT_LogMessage("Waiting timestamp set to " & _StringFormatTime("%c", $GLB_needWait[$GLB_curBot]))
EndFunc

;reset wait timestamp
Func UTL_ResetWaitTimestamp()
	$GLB_needWait[$GLB_curBot] = 0
	BOT_LogMessage("Waiting timestamp reseted")
EndFunc

;check wait timestamp
Func UTL_CheckWaitTimestamp()
	Local $now = _TimeGetStamp()
	If $GLB_needWait[$GLB_curBot] <> 0 And Int($now) < Int($GLB_needWait[$GLB_curBot]) Then
		Local $wait = Int($GLB_needWait[$GLB_curBot]) - Int($now)
		Local $waitText = ""
		Local $waitHour = Floor($wait/(60*60))
		Local $waitMin = Floor(($wait - $waitHour*60*60)/60)
		Local $waitSec = Floor(($wait - $waitHour*60*60 - $waitMin*60))
		If $waitHour > 0 Then
			$waitText&= $waitHour & " hr(s) "
		EndIf
		If $waitMin > 0 Then
			$waitText&= $waitMin & " min(s) "
		EndIf
		If $waitSec > 0 Then
			$waitText&= $waitSec & " sec(s)"
		EndIf
		BOT_LogMessage("Need wait for " & $waitText, 1)
		Return False
	ElseIf $GLB_needWait[$GLB_curBot] <> 0 And Int($now) >= Int($GLB_needWait[$GLB_curBot]) Then
		UTL_ResetWaitTimestamp()
	Else
		Return True
	EndIf
EndFunc

; set timeout
Func UTL_SetTimeout($type, $reset = False, $botid = $GLB_curBot)
	Local $new = 0
	Local $tsData

	If Not $reset Then
		$new = _TimeGetStamp()
	EndIf

	If $type = "waiting" Then
		$GUI_waitingStartTS[$botid] = $new
		$tsData = $GUI_timeoutWaiting[$botid]
	ElseIf $type = "warp" Then
		$GUI_warpStartTS[$botid] = $new
		$tsData = $GUI_timeoutWarp[$botid]
	ElseIf $type = "cargo" Then
		$GUI_cargoStartTS[$botid] = $new
		$tsData = $GUI_timeoutCargo[$botid]
	ElseIf $type = "drones" Then
		$GUI_dronesStartTS[$botid] = $new
		$tsData = $GUI_timeoutDrones[$botid]
	ElseIf $type = "station" Then
		$GUI_stationStartTS[$botid] = $new
		$tsData = $GUI_timeoutStation[$botid]
	ElseIf $type = "tractoring" Then
		$GUI_tractoringStartTS[$botid] = $new
		$tsData = $GUI_timeoutTractoring[$botid]
	EndIf

	; update on reset
	If $reset Then
		GUICtrlSetData($tsData, "0")
	EndIf

	BOT_LogMessage("Timeout set: "& $type & " -> " & $new)
EndFunc

;check timeout
Func UTL_CheckTimeout($type)
	Local $start, $timeout, $current
	Local $now = _TimeGetStamp()
	Local $tsData

	If $type = "waiting" Then
		$start = $GUI_waitingStartTS[$GLB_curBot]
		$timeout = GUICtrlRead($GUI_timeoutWaitingDefault[$GLB_curBot])
	ElseIf $type = "warp" Then
		$start = $GUI_warpStartTS[$GLB_curBot]
		$timeout = GUICtrlRead($GUI_timeoutWarpDefault[$GLB_curBot])
	ElseIf $type = "cargo" Then
		$start = $GUI_cargoStartTS[$GLB_curBot]
		$timeout = GUICtrlRead($GUI_timeoutCargoDefault[$GLB_curBot])
	ElseIf $type = "drones" Then
		$start = $GUI_dronesStartTS[$GLB_curBot]
		$timeout = GUICtrlRead($GUI_timeoutDronesDefault[$GLB_curBot])
	ElseIf $type = "station" Then
		$start = $GUI_stationStartTS[$GLB_curBot]
		$timeout = GUICtrlRead($GUI_timeoutStationDefault[$GLB_curBot])
	ElseIf $type = "tractoring" Then
		$start = $GUI_tractoringStartTS[$GLB_curBot]
		$timeout = GUICtrlRead($GUI_timeoutTractoringDefault[$GLB_curBot])
	EndIf

	; if timeout start not set
	If $start = 0 Then
		Return True
	EndIf

	If $type = "waiting" Then
		$tsData = $GUI_timeoutWaiting[$GLB_curBot]
	ElseIf $type = "warp" Then
		$tsData = $GUI_timeoutWarp[$GLB_curBot]
	ElseIf $type = "cargo" Then
		$tsData = $GUI_timeoutCargo[$GLB_curBot]
	ElseIf $type = "drones" Then
		$tsData = $GUI_timeoutDrones[$GLB_curBot]
	ElseIf $type = "station" Then
		$tsData = $GUI_timeoutStation[$GLB_curBot]
	ElseIf $type = "tractoring" Then
		$tsData = $GUI_timeoutTractoring[$GLB_curBot]
	EndIf

	$current = Round(($now - $start)/60, 2)
	If $current >= $timeout Then
		BOT_LogMessage("Timeout reached: " & $current & ">" & $timeout)
		GUICtrlSetData($tsData, "0")
		UTL_SetTimeout($type, True)
		Return False
	Else
		BOT_LogMessage("Timeout : " & $type & "=" & $current, 1)
		GUICtrlSetData($tsData, $current)
		Return True
	EndIf
EndFunc

;reset all timeouts
Func UTL_CheckResetTimeouts()
	UTL_SetTimeout("waiting", True)
	UTL_SetTimeout("cargo", True)
	UTL_SetTimeout("station", True)
	UTL_SetTimeout("warp", True)
	UTL_SetTimeout("drones", True)
	UTL_SetTimeout("tractoring", True)
EndFunc

;capture part of screen
Func UTL_ScreenCapture($type, $x1, $y1, $x2, $y2, $withCursor = False)
	Local $borders = UTL_GetWindowBorders()
	$x1+= $borders[0]
	$y1+= $borders[1]
	$x2+= $borders[0]
	$y2+= $borders[1]
	_ScreenCapture_CaptureWnd(@ScriptDir & "/ocr/" & $type & "/bot" & ($GLB_curBot + 1) & ".bmp", $WIN_titles[$GLB_curBot], $x1, $y1, $x2, $y2, $withCursor)
EndFunc

;get number of enabled bots
Func UTL_GetNumOfEnabledBots()
	Local $num = 0
	For $e = 0 To $GLB_numOfBots - 1 Step 1
		If GUICtrlRead($GUI_enableBot[$e]) = $GUI_CHECKED Then
			$num+= 1
		EndIf
	Next
	Return $num
EndFunc

;replace symbols
Func UTL_ReplaceSymbols($string, $sSet, $sub)
	For $e = 0 To StringLen($sSet) - 1 Step 1
		$string = StringReplace($string, StringMid($sSet, $e+1, 1), $sub)
	Next
	Return $string
EndFunc

;check team viewer window
Func UTL_CheckTeamViewerWindow()
	Local $tv_title = 'Спонсируемый сеанс'
	If WinExists($tv_title) Then
		Local $control = '[Instance:1; ClassNN:Button4]'
		ControlFocus($tv_title, "", $control)
		ControlClick($tv_title, "", $control)
	EndIf
EndFunc

;check CCP exeFile error window
Func UTL_CheckCCPexeFileErrorWindow()
	Local $error_title = 'CCP exeFile'
	If WinExists($error_title) Then
		WinKill($error_title)
	EndIf
EndFunc

;TODO depricate
Func UTL_ColorInBounds($pMColor, $pTColor, $pVariation)
	Local $lMCBlue = _ColorGetBlue($pMColor)
	Local $lMCGreen = _ColorGetGreen($pMColor)
	Local $lMCRed = _ColorGetRed($pMColor)

	Local $lTCBlue = _ColorGetBlue($pTColor)
	Local $lTCGreen = _ColorGetGreen($pTColor)
	Local $lTCRed = _ColorGetRed($pTColor)

	Local $a = Abs($lMCBlue - $lTCBlue)
	Local $b = Abs($lMCGreen - $lTCGreen)
	Local $c = Abs($lMCRed - $lTCRed)

	;MsgBox(64, "msg", "a="&$a&", b="&$b&", c="&$c)

	If ( ( $a <= $pVariation ) AND ( $b <= $pVariation ) AND ( $c <= $pVariation ) ) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;calculate lock time
Func UTL_CalcLockTime($type = "small")
	Local $scanResolution = GUICtrlRead($GUI_scanResolution[$GLB_curBot])
	Local $signature

	Switch $type
		Case "small", 1
			$signature = $GLB_avgSigFrigate
		Case "medium", 2, 4
			$signature = $GLB_avgSigCruiser
		Case "big", 3
			$signature = $GLB_avgSigBattleship
	EndSwitch

	;Text equation:
	;   T = (40000/X)/(asinh(Y)^2)
	;Where:
	;    X = scan resolution of your ship
	;    Y = sig radius of the target
	;    T = the time to lock.

	Local $lockTime = Round((40000/$scanResolution)/(ASinH($signature)^2))
	BOT_LogMessage("UTL_CalcLockTime: type=" & $type & ", time=" & $lockTime, 1)

	Return $lockTime
EndFunc

; get script version
Func UTL_GetScriptVersion($stripDots = False)
	Local $version
    If @Compiled Then
        $version = FileGetVersion(@AutoItExe)
    Else
        $version = IniRead(@ScriptFullPath, "ScriptVersion", "#AutoIt3Wrapper_Res_Fileversion", "0.0.0.0")
    EndIf

	If $stripDots Then
		$version = StringReplace($version, ".", "")
	EndIf

	Return $version
EndFunc

;check timestamp difference
Func UTL_CheckTimestampDiff($level = "general", $msg = "")
	Return True
	Local $now = _TimeGetStamp()
	Local $old = 0

	If $level = "general" Then
		$old = $UTL_generalLastTimestamp4Diff
		$UTL_generalLastTimestamp4Diff = $now
	ElseIf $level = "process1" Then
		$old = $UTL_process1LastTimestamp4Diff
		$UTL_process1LastTimestamp4Diff = $now
	EndIf

	If $old = False Then
		$old = $now
	EndIf

	Local $diff = $now - $old

	BOT_LogMessage("UTL_CheckTimestampDiff:" & $level & ": " & $msg & " - " & $diff, 2)
	Return $diff
EndFunc

;check timestamp difference
Func UTL_launchCommandUtil($cmd, $params)
	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)
	Run(@ScriptDir & '\utils\command\CommandUtil.exe "' & $LIC_cryptKey & '" "' & $login & '" "' & $password & '" "' & $cmd & '" "' & $params & '"', "", @SW_HIDE)
EndFunc