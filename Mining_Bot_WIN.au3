Global $WIN_monitor[4]

;activate window
Func WIN_ActivateWindow($title, $msg = "")
	If WinExists($title) Then
		If WinActive($title) Then
			Return True
		EndIf

		If $msg <> "" Then
			$msg = ", " & $msg
		EndIf

		WinActivate($title)

		While Not WinActive($title)
			WinActivate($title)
			BOT_LogMessage("Waiting for window activation: " & $title & $msg, 2)
			UTL_Wait(0.1, 0.2)
			If Not WinExists($title) Then
				Return False
			EndIf
		WEnd

		BOT_LogMessage("Activated window: " & $title & $msg, 2)
		Return True
	Else
		Return False
	EndIf
EndFunc

;minimize window
Func WIN_MinimizeWindow($title)
	If WinExists($title) And $title <> "" Then
		WinSetState ($title, "", @SW_MINIMIZE)
		BOT_LogMessage("Window minimize : " & $title, 2)
	EndIf
EndFunc

;restore window
Func WIN_RestoreWindow($title)
	If WinExists($title) Then
		WinSetState ($title, "", @SW_RESTORE)
		BOT_LogMessage("Window restore : " & $title & ", waiting 3 sec", 2)
		UTL_Wait(2, 3)
	EndIf
EndFunc

;resize window
Func WIN_ResizeWindow($title, $x, $y)
	If WinExists($title) Then
		WinMove($title, "", Default, Default, $x, $y)
		BOT_LogMessage("Window resized to " & $x & ":" & $y & ", waiting 3 sec")
		UTL_Wait(2, 3)
	EndIf
EndFunc

;get window size
Func WIN_GetWindowSize($title)
	If WinExists($title) Then
		Return WinGetClientSize($title)
	EndIf

	Return False
EndFunc

;try open window
Func WIN_TryOpenWindow()
	Local $PathEVE = GUICtrlRead($GUI_eveSelectPath)
	Local $WorkdirEVE = StringReplace($PathEVE, "\ExeFile.exe", "")
	BOT_LogMessage("Loading EVE: " & $PathEVE, 1)
	Run($PathEVE, $WorkdirEVE);/noBreakpadUpload
	Return True
EndFunc

;try open steam window
Func WIN_TryOpenSteamWindow()
	Local $steamAddress = "steam://rungameid/8500"
	BOT_LogMessage("Loading Steam EVE: " & $steamAddress, 1)
	ShellExecute($steamAddress)
EndFunc

;check open window
Func WIN_CheckOpenWindow($type = "")
	Local $winExecuted = False

	$winExecuted = WIN_FindNewEVEWindow()

	If $winExecuted <> False Then
		WIN_ActivateWindow($winExecuted)
		$WIN_titles[$GLB_curBot] = $winExecuted
		GUICtrlSetData($GUI_windowHWND[$GLB_curBot], $winExecuted)
	Else
		BOT_LogMessage("Waiting for new " & $type & "window ...", 1)
		Return False
	EndIf

	BOT_LogMessage("Loading OK!", 1)
	Return True
EndFunc

;find new EVE window
Func WIN_FindNewEVEWindow()
	Local $windows = WinList($initTitleEVE)
	Local $notFound = True

	For $i = 1 to $windows[0][0]
		$notFound = True
		For $j = 0 to $GLB_numOfBots - 1 Step 1
			; windows that have a title and in list
			If $windows[$i][0] <> "" AND $WIN_titles[$j] = $windows[$i][1] Then
				;BOT_LogMessage("Exists window found! HWND=" & $windows[$i][1], 1)
				$notFound = False
			EndIf
		Next

		If $notFound = True Then
			BOT_LogMessage("New EVE window found! HWND=" & $windows[$i][1], 1)
			Return $windows[$i][1]
		EndIf
	Next

	BOT_LogMessage("New EVE window not found!")
	Return False
EndFunc

;close unused windows
Func WIN_CloseUnusedWindows()
	For $b = 0 To $GLB_numOfBots - 1 Step 1
		; if disabled skip it
		If GUICtrlRead($GUI_enableBot[$b]) = $GUI_UNCHECKED Then
			ContinueLoop
		EndIf
		; if not all windows set
		If $WIN_titles[$b] = -1 Or Not WinExists($WIN_titles[$b]) Then
			Return False
		EndIf
	Next

	Local $windows = WinList($initTitleEVE)
	Local $found = False
	For $i = 1 to $windows[0][0]
		$found = False

		For $j = 0 To UBound($WIN_titles) - 1 Step 1
			If $windows[$i][1] = $WIN_titles[$j] Then
				$found = True
			EndIF
		Next

		If Not $found Then
			WinKill($windows[$i][1])
			BOT_LogMessage("Closed redundant window = " & $windows[$i][1], 2)
		EndIf
	Next
EndFunc

;close window
Func WIN_CloseWindow($title = False)
	If $title = False Then
		$title = $WIN_titles[$GLB_curBot]
	EndIf
	If WinExists($WIN_titles[$GLB_curBot]) Then
		WinKill($title)
		$WIN_titles[$GLB_curBot] = -1
	EndIf
EndFunc

; close all windows
Func WIN_CloseAllWindows()
	For $a = 0 To $GLB_numOfBots - 1 Step 1
		If WinExists($WIN_titles[$a]) Then
			WinKill($WIN_titles[$a])
			$WIN_titles[$a] = -1
		EndIf
	Next
EndFunc

;set window position
Func WIN_PositionWindow()
	If WinExists($WIN_titles[$GLB_curBot]) Then
		Local $winSize = WIN_GetWindowSize($WIN_titles[$GLB_curBot])
		If $winSize = False Then
			Return False
		EndIf

		Local $x = $WIN_monitor[0] + $WIN_monitor[2] - $winSize[0] - 1*$GLB_curBot - 15
		Local $y = 1*$GLB_curBot
		WinMove($WIN_titles[$GLB_curBot], "", $x, $y)
		BOT_LogMessage("Window moved to " & $x & ":" & $y)
	EndIf
EndFunc

;organize bot windows
Func WIN_OrganizeBotWindows($location)
	If $location <> "closed" Then
		Local $prevWindow = $GLB_curBot - 1
		If $GLB_curBot = 0 Then
			$prevWindow = $GLB_numOfBots - 1
		EndIf

		; if client closed
		If Not WinExists($WIN_titles[$GLB_curBot]) Then
			Local $newWindow = WIN_FindNewEVEWindow()
			If $newWindow <> False Then
				$WIN_titles[$GLB_curBot] = $newWindow
				GUI_SetLocationAndState("login", "free")
				WIN_PositionWindow()
			Else
				GUI_SetLocationAndState("closed", "free")
			EndIf
		EndIf

		If UTL_GetNumOfEnabledBots() > 1 Then
			WIN_MinimizeWindow($WIN_titles[$prevWindow])
			WIN_RestoreWindow($WIN_titles[$GLB_curBot])
		EndIf
		WIN_ActivateWindow($WIN_titles[$GLB_curBot])
	EndIf
EndFunc

Func WIN_GetActiveWindow()
	Local $window[2]
	Local $winlist
	$winlist = WinList($initTitleEVE)
	For $i = 1 to $winlist[0][0]
		If $winlist[$i][0] <> "" Then
			$window[0] = $winlist[$i][0]
			$window[1] = $winlist[$i][1]
			ExitLoop
		EndIf
	Next
	Return $window
EndFunc

Func WIN_ChangeWindowTitle($window, $newTitle)
	WinSetTitle($window, "", $newTitle)
EndFunc


;Global Const $MONITOR_DEFAULTTONULL     = 0x00000000
;Global Const $MONITOR_DEFAULTTOPRIMARY  = 0x00000001
;Global Const $MONITOR_DEFAULTTONEAREST  = 0x00000002
Global Const $CCHDEVICENAME             = 32
Global Const $MONITORINFOF_PRIMARY      = 0x00000001

Func WIN_GetMonitorCoordinates($useMonitor = 1)
	Local $_GetMonitors = _EnumDisplayMonitors()

	For $i = 1 to $_GetMonitors[0][0]
		Local $arMonitorInfos[4]
		If $useMonitor = $i Then
			Local $objReturn[4] = [$_GetMonitors[$i][1], $_GetMonitors[$i][2], ($_GetMonitors[$i][3] - $_GetMonitors[$i][1]), ($_GetMonitors[$i][4] - $_GetMonitors[$i][2])]; x, y, w ,h
			Return $objReturn

			;MsgBox(64, "", "Monitor Handle: "& $_GetMonitors[$i][0] &@CRLF& "Left: "& $_GetMonitors[$i][1] &@CRLF& "Top: "& $_GetMonitors[$i][2] &@CRLF& "Right: "& $_GetMonitors[$i][3] &@CRLF& "Bottom: "& $_GetMonitors[$i][4])
			If _GetMonitorInfo($_GetMonitors[$i][0], $arMonitorInfos) Then _
				Msgbox(0, "Monitor-Infos", "Rect-Monitor" & @Tab & ": " & $arMonitorInfos[0] & @LF & _
                            "Rect-Workarea" & @Tab & ": " & $arMonitorInfos[1] & @LF & _
                            "PrimaryMonitor?" & @Tab & ": " & $arMonitorInfos[2] & @LF & _
                            "Devicename" & @Tab & ": " & $arMonitorInfos[3])

		EndIf
	Next
EndFunc

;==================================================================================================
; Function Name:   _EnumDisplayMonitors()
; Description::    Load monitor positions
; Parameter(s):    n/a
; Return Value(s): 2D Array of Monitors
;                       [0][0] = Number of Monitors
;                       [i][0] = HMONITOR handle of this monitor.
;                       [i][1] = Left Position of Monitor
;                       [i][2] = Top Position of Monitor
;                       [i][3] = Right Position of Monitor
;                       [i][4] = Bottom Position of Monitor
; Note:            [0][1..4] are set to Left,Top,Right,Bottom of entire screen
;                  hMonitor is returned in [i][0], but no longer used by these routines.
;                  Also sets $__MonitorList global variable (for other subs to use)
; Author(s):       xrxca (autoit@forums.xrx.ca)
;==================================================================================================
Func _EnumDisplayMonitors()
    Global $__MonitorList[1][5]
    $__MonitorList[0][0] = 0
    Local $handle = DllCallbackRegister("_MonitorEnumProc", "int", "hwnd;hwnd;ptr;lparam")
    DllCall("user32.dll", "int", "EnumDisplayMonitors", "hwnd", 0, "ptr", 0, "ptr", DllCallbackGetPtr($handle), "lparam", 0)
    DllCallbackFree($handle)
    Local $i = 0
    For $i = 1 To $__MonitorList[0][0]
        If $__MonitorList[$i][1] < $__MonitorList[0][1] Then $__MonitorList[0][1] = $__MonitorList[$i][1]
        If $__MonitorList[$i][2] < $__MonitorList[0][2] Then $__MonitorList[0][2] = $__MonitorList[$i][2]
        If $__MonitorList[$i][3] > $__MonitorList[0][3] Then $__MonitorList[0][3] = $__MonitorList[$i][3]
        If $__MonitorList[$i][4] > $__MonitorList[0][4] Then $__MonitorList[0][4] = $__MonitorList[$i][4]
    Next
    Return $__MonitorList
EndFunc   ;==>_EnumDisplayMonitors

Func _GetMonitorInfo($hMonitor, ByRef $arMonitorInfos)
    Local $stMONITORINFOEX = DllStructCreate("dword;int[4];int[4];dword;char[" & $CCHDEVICENAME & "]")
    DllStructSetData($stMONITORINFOEX, 1, DllStructGetSize($stMONITORINFOEX))

    Local $nResult = DllCall("user32.dll", "int", "GetMonitorInfo", "hwnd", $hMonitor, "ptr", DllStructGetPtr($stMONITORINFOEX))
    If $nResult[0] = 1 Then
        $arMonitorInfos[0] = DllStructGetData($stMONITORINFOEX, 2, 1) & ";" & _
            DllStructGetData($stMONITORINFOEX, 2, 2) & ";" & _
            DllStructGetData($stMONITORINFOEX, 2, 3) & ";" & _
            DllStructGetData($stMONITORINFOEX, 2, 4)
        $arMonitorInfos[1] = DllStructGetData($stMONITORINFOEX, 3, 1) & ";" & _
            DllStructGetData($stMONITORINFOEX, 3, 2) & ";" & _
            DllStructGetData($stMONITORINFOEX, 3, 3) & ";" & _
            DllStructGetData($stMONITORINFOEX, 3, 4)
        $arMonitorInfos[2] = DllStructGetData($stMONITORINFOEX, 4)
        $arMonitorInfos[3] = DllStructGetData($stMONITORINFOEX, 5)
    EndIf

    Return $nResult[0]
EndFunc   ;==>_GetMonitorInfo

;==================================================================================================
; Function Name:   _MonitorEnumProc($hMonitor, $hDC, $lRect, $lParam)
; Description::    Enum Callback Function for EnumDisplayMonitors in _GetMonitors
; Author(s):       xrxca (autoit@forums.xrx.ca)
;==================================================================================================
Func _MonitorEnumProc($hMonitor, $hDC, $lRect, $lParam)
    Local $Rect = DllStructCreate("int left;int top;int right;int bottom", $lRect)
    $__MonitorList[0][0] += 1
    ReDim $__MonitorList[$__MonitorList[0][0] + 1][5]
    $__MonitorList[$__MonitorList[0][0]][0] = $hMonitor
    $__MonitorList[$__MonitorList[0][0]][1] = DllStructGetData($Rect, "left")
    $__MonitorList[$__MonitorList[0][0]][2] = DllStructGetData($Rect, "top")
    $__MonitorList[$__MonitorList[0][0]][3] = DllStructGetData($Rect, "right")
    $__MonitorList[$__MonitorList[0][0]][4] = DllStructGetData($Rect, "bottom")
    Return 1
EndFunc   ;==>_MonitorEnumProc