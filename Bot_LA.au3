;log analyzer

#include <GUIConstants.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include <Array.au3>
#include <String.au3>

#include "UnixTime.au3"

Opt("GUIOnEventMode", 1) ;enable onEvent functions
Opt("PixelCoordMode", 2) ;Отсчет координат пикселей от левого верхнего угла клиентской части окна
Opt("MouseCoordMode", 2) ;Отсчет координат мыши от левого верхнего угла клиентской части окна
Opt("MustDeclareVars", 1) ;Форсируем задачу переменных. То есть после задания этой опции перед тем как нам использовать какую-либо переменную нам надо обозначить ее.
Opt("SendKeyDelay", 100)

Global $LA_mainWindow
Global $LA_selectButton
Global $LA_logInput

Global $LA_WorkTime[2]
Global $LA_StationCorpHangarUnloadsData[1]
Global $LA_StationItemsUnloadsData[1]
Global $LA_WindowClose[1]
Global $LA_MinersReloads[1]
Global $LA_MiningInterrupted[1]
Global $LA_BeltChangesForced[1]
Global $LA_InfoWindows[1]
Global $LA_FleetsAccepted[1]
Global $LA_FleetsRejected[1]
Global $LA_LocationFixes[1]
Global $LA_ShipDamaged[1]
Global $LA_ShipArmorDamaged[1]
Global $LA_ShipDestroyed[1]
Global $LA_LoginErrors[1]
Global $LA_InternetConnectionNotFound[1]
Global $LA_FleetCommNotFound[1]
Global $LA_ContainerNotFound[1]
Global $LA_AsteroidsNotFound[1]
Global $LA_ManualStops[1]

LA_CreateGUI()	

While 1
	; loop
WEnd

Func LA_CreateGUI()	
	$LA_mainWindow = GuiCreate("Log analyzer", 500, 400, 0, 0)
	
	$LA_logInput = GuiCtrlCreateEdit("", 5, 30, 490, 365, BitOR($ES_READONLY, $ES_AUTOVSCROLL))		
	
	$LA_selectButton = GUICtrlCreateButton ("Select log file", 5, 5, 490, 25)	
	GUICtrlSetOnEvent($LA_selectButton, "LA_OpenLogFile")
	GUICtrlSetTip($LA_selectButton, "Select log file")	
		
	GUISetOnEvent($GUI_EVENT_CLOSE, "LA_Close")

	GuiSetState()
EndFunc

Func LA_Close()
	GUIDelete()
	Exit 0
EndFunc

Func LA_OpenLogFile()	
	Local $filepath = FileOpenDialog("Select log file", @ScriptDir, "TXT file (*.txt)", 1)

	If @error Then
		Return False
	EndIf		
	
	LA_ClearData()
	
	LA_AddRecord ("Log analysis started. Please wait.")	
	
	LA_ReadLogFile($filepath)
	LA_ShowStatistics()
EndFunc

Func LA_ClearData()
	For $i = 1 To UBound($LA_StationCorpHangarUnloadsData) - 1 Step 1
		_ArrayDelete($LA_StationCorpHangarUnloadsData, $i)
	Next

	For $i = 1 To UBound($LA_StationItemsUnloadsData) - 1 Step 1
		_ArrayDelete($LA_StationItemsUnloadsData, $i)
	Next	
	
	For $i = 1 To UBound($LA_WindowClose) - 1 Step 1
		_ArrayDelete($LA_WindowClose, $i)
	Next
	
	For $i = 1 To UBound($LA_MinersReloads) - 1 Step 1
		_ArrayDelete($LA_MinersReloads, $i)
	Next
	
	For $i = 1 To UBound($LA_MiningInterrupted) - 1 Step 1
		_ArrayDelete($LA_MiningInterrupted, $i)
	Next
	
	For $i = 1 To UBound($LA_BeltChangesForced) - 1 Step 1
		_ArrayDelete($LA_BeltChangesForced, $i)
	Next
	
	For $i = 1 To UBound($LA_InfoWindows) - 1 Step 1
		_ArrayDelete($LA_InfoWindows, $i)
	Next
	
	For $i = 1 To UBound($LA_FleetsAccepted) - 1 Step 1
		_ArrayDelete($LA_FleetsAccepted, $i)
	Next
	
	For $i = 1 To UBound($LA_FleetsRejected) - 1 Step 1
		_ArrayDelete($LA_FleetsRejected, $i)
	Next
	
	For $i = 1 To UBound($LA_LocationFixes) - 1 Step 1
		_ArrayDelete($LA_LocationFixes, $i)
	Next
	
	For $i = 1 To UBound($LA_ShipDamaged) - 1 Step 1
		_ArrayDelete($LA_ShipDamaged, $i)
	Next
	
	For $i = 1 To UBound($LA_ShipArmorDamaged) - 1 Step 1
		_ArrayDelete($LA_ShipArmorDamaged, $i)
	Next
	
	For $i = 1 To UBound($LA_ShipDestroyed) - 1 Step 1
		_ArrayDelete($LA_ShipDestroyed, $i)
	Next
	
	For $i = 1 To UBound($LA_LoginErrors) - 1 Step 1
		_ArrayDelete($LA_LoginErrors, $i)
	Next
	
	For $i = 1 To UBound($LA_InternetConnectionNotFound) - 1 Step 1
		_ArrayDelete($LA_InternetConnectionNotFound, $i)
	Next
	
	For $i = 1 To UBound($LA_FleetCommNotFound) - 1 Step 1
		_ArrayDelete($LA_FleetCommNotFound, $i)
	Next
	
	For $i = 1 To UBound($LA_ContainerNotFound) - 1 Step 1
		_ArrayDelete($LA_ContainerNotFound, $i)
	Next
	
	For $i = 1 To UBound($LA_AsteroidsNotFound) - 1 Step 1
		_ArrayDelete($LA_AsteroidsNotFound, $i)
	Next
	
	For $i = 1 To UBound($LA_ManualStops) - 1 Step 1
		_ArrayDelete($LA_ManualStops, $i)
	Next		
	
	GUICtrlSetData($LA_logInput, "", 1)
EndFunc

Func LA_ReadLogFile($filename)
	Local $file = FileOpen($filename, 0)

	; Check if file opened for reading OK
	If $file = -1 Then
		MsgBox(0, "", "Unable to open file: " & $filename)
		Return 0
	EndIf
	
	;Local $fileMain = FileOpen($filenameMain, 0)

	Local $lineCounter = 0
	Local $prevLine
	; Read in lines of text until the EOF is reached
	While 1
		Local $line = FileReadLine($file)
		If @error = -1 Then ExitLoop
			
		If StringInStr($line, "Unloading cargo to Corp Hangar") Then
			LA_PutRecordIntoData($line, $LA_StationCorpHangarUnloadsData, 300)
		ElseIf StringInStr($line, "Unloading cargo to Items") Then
			LA_PutRecordIntoData($line, $LA_StationItemsUnloadsData, 300)
		ElseIf StringInStr($line, "Closing window:") Then
			LA_PutRecordIntoData($line, $LA_WindowClose, 0)
		ElseIf StringInStr($line, "Miners reloading") Then
			LA_PutRecordIntoData($line, $LA_MinersReloads, 0)
		ElseIf StringInStr($line, "Mining interrupted") Then
			LA_PutRecordIntoData($line, $LA_MiningInterrupted, 0)
		ElseIf StringInStr($line, "State changed to: belt -> next") Then
			LA_PutRecordIntoData($line, $LA_BeltChangesForced, 0)
		ElseIf StringInStr($line, "Informational window detected") Then
			LA_PutRecordIntoData($line, $LA_InfoWindows, 0)
		ElseIf StringInStr($line, "Fleet proposition detected. Accepting") Then
			LA_PutRecordIntoData($line, $LA_FleetsAccepted, 0)
		ElseIf StringInStr($line, "Fleet proposition detected. Rejecting") Then
			LA_PutRecordIntoData($line, $LA_FleetsRejected, 0)
		ElseIf StringInStr($line, "Fixing location, please wait") Then
			LA_PutRecordIntoData($line, $LA_LocationFixes, 0)
		ElseIf StringInStr($line, "Ship damaged") Then
			LA_PutRecordIntoData($line, $LA_ShipDamaged, 0)
		ElseIf StringInStr($line, "Ship armor damaged") Then
			LA_PutRecordIntoData($line, $LA_ShipArmorDamaged, 0)
		ElseIf StringInStr($line, "Ship destroyed. Evacuation capsule detected") Then
			LA_PutRecordIntoData($line, $LA_ShipDestroyed, 0)
		ElseIf StringInStr($line, "Login error!") Then
			LA_PutRecordIntoData($line, $LA_LoginErrors, 0)
		ElseIf StringInStr($line, "Internet connection not found!") Then
			LA_PutRecordIntoData($line, $LA_InternetConnectionNotFound, 0)
		ElseIf StringInStr($line, "Fleet commander not found!") Then
			LA_PutRecordIntoData($line, $LA_FleetCommNotFound, 0)
		ElseIf StringInStr($line, "Container not found") Then
			LA_PutRecordIntoData($line, $LA_ContainerNotFound, 0)
		ElseIf StringInStr($line, "Asteroid not found") Or StringInStr($line, "Asteroids not found") Then
			LA_PutRecordIntoData($line, $LA_AsteroidsNotFound, 0)
		ElseIf StringInStr($line, "Stop bot") Then
			LA_PutRecordIntoData($line, $LA_ManualStops, 0)
		EndIf
		
		If $lineCounter = 0 Then
			$LA_WorkTime[0] = LA_RecordIntoTimestamp($line)
		EndIf
		$prevLine = $line
		$lineCounter+= 1
	Wend
	
	$LA_WorkTime[1] = LA_RecordIntoTimestamp($prevLine)
	
	;_ArrayDisplay($LA_CorpHangarUnloadsData)
EndFunc

Func LA_RecordIntoTimestamp($logRecord)	
	Local $logData = _StringExplode($logRecord, " : ")
	Local $logDateTime = _StringExplode($logData[0], " ")
	Local $logDate = _StringExplode($logDateTime[0], "-")
	Local $logTime = _StringExplode($logDateTime[1], ":")
	
	Return _TimeMakeStamp($logTime[2], $logTime[1], $logTime[0], $logDate[2], $logDate[1], $logDate[0])
EndFunc

Func LA_TimestampIntoFormat($timestampDiff, $format)
	Local $days = Floor($timestampDiff/(60*60*24))
	Local $hrs = Floor(($timestampDiff - $days*60*60*24)/(60*60))
	Local $mins = Floor(($timestampDiff - $hrs*60*60 - $days*60*60*24)/60)
	Local $secs = $timestampDiff - $hrs*60*60 - $mins*60 - $days*60*60*24

	$format = StringReplace ($format, "DD", $days, 0, 1)
	$format = StringReplace ($format, "hh", $hrs, 0, 1)
	$format = StringReplace ($format, "mm", $mins, 0, 1)
	$format = StringReplace ($format, "ss", $secs, 0, 1)
	
	Return $format
EndFunc

Func LA_PutRecordIntoData($logRecord, ByRef $data, $timeLimit)		
	Local $index = UBound($data) - 1
	Local $recordTimestamp = LA_RecordIntoTimestamp($logRecord)
	
	If $index = 0 Or $recordTimestamp - $data[$index - 1] > $timeLimit Then
		;_DebugOut ("_DebugReport: " & $index & ", " & $logRecord & " = " & $recordTimestamp)

		_ArrayInsert($data, $index)
		$data[$index] = $recordTimestamp
	Else
		;skip
	EndIf
EndFunc

Func LA_ShowStatistics()
	Local $sum = 0
	Local $count = 0
	Local $avr = 0
	Local $min = 1000000
	Local $max = 0
	Local $days = 0
	Local $hrs = 0
	Local $mins = 0
	Local $secs = 0
	Local $tail = ""
	
	; work time
	Local $workTime = $LA_WorkTime[1] - $LA_WorkTime[0]	
	LA_AddRecord ("Work time: " & LA_TimestampIntoFormat($workTime, "DD days hh:mm:ss"))
	
	; station corporate hangar unload statistics
	For $i = 1 To UBound($LA_StationCorpHangarUnloadsData) - 2 Step 1
		Local $diff = $LA_StationCorpHangarUnloadsData[$i] - $LA_StationCorpHangarUnloadsData[$i - 1]
		$sum+= $diff
		$count+= 1
		If $min > $diff Then $min = $diff
		If $max < $diff Then $max = $diff
	Next
	
	$avr = Round($sum/$count)
	
	If $count > 0 Then
		$tail = ", duration - average = " & LA_TimestampIntoFormat($avr, "hh:mm:ss") & ", minimum = " & LA_TimestampIntoFormat($min, "hh:mm:ss") & ", maximum = " & LA_TimestampIntoFormat($max, "hh:mm:ss")
	EndIf
	LA_AddRecord ("Unloaded to station corporate hangar: " & $count & " times" & $tail)
	
	$sum = 0
	$count = 0
	$avr = 0
	$min = 1000000
	$max = 0
	; station items unload statistics
	For $i = 1 To UBound($LA_StationItemsUnloadsData) - 2 Step 1
		Local $diff = $LA_StationItemsUnloadsData[$i] - $LA_StationItemsUnloadsData[$i - 1]
		$sum+= $diff
		$count+= 1
		If $min > $diff Then $min = $diff
		If $max < $diff Then $max = $diff
	Next
	
	$avr = Round($sum/$count)
	If $count > 0 Then
		$tail = ", duration - average = " & LA_TimestampIntoFormat($avr, "hh:mm:ss") & ", minimum = " & LA_TimestampIntoFormat($min, "hh:mm:ss") & ", maximum = " & LA_TimestampIntoFormat($max, "hh:mm:ss")
	EndIf

	LA_AddRecord ("Unloaded to station items: " & $count & " times" & $tail)
	
	; window close statistics
	LA_AddRecord ("Window close: " & UBound($LA_WindowClose) - 1 & " times")
	
	; miner reloads statistics
	LA_AddRecord ("Miners reloaded: " & UBound($LA_MinersReloads) - 1 & " times")
		
	; mining interrupted statistics
	LA_AddRecord ("Mining interrupted: " & UBound($LA_MiningInterrupted) - 1 & " times")	
	
	; belts changed statistics
	LA_AddRecord ("Forced belts changes: " & UBound($LA_BeltChangesForced) - 1 & " times")	
	
	; info windows statistics
	LA_AddRecord ("Informational windows detected: " & UBound($LA_InfoWindows) - 1 & " times")
	
	; fleets statistics
	LA_AddRecord ("Fleets accepted: " & UBound($LA_FleetsAccepted) - 1 & " times")	
	LA_AddRecord ("Fleets rejected: " & UBound($LA_FleetsRejected) - 1 & " times")
	
	LA_AddRecord ("Location fixed: " & UBound($LA_LocationFixes) - 1 & " times")
	
	; damage statistics
	LA_AddRecord ("Ship shield critically damaged: " & UBound($LA_ShipDamaged) - 1 & " times")	
	LA_AddRecord ("Ship armor damaged: " & UBound($LA_ShipArmorDamaged) - 1 & " times")
	LA_AddRecord ("Ship destroyed: " & UBound($LA_ShipDestroyed) - 1 & " times")
	
	; login statistics
	LA_AddRecord ("Login errors: " & UBound($LA_LoginErrors) - 1)	
	
	; internet connection statistics
	LA_AddRecord ("Internet connection not found: " & UBound($LA_InternetConnectionNotFound) - 1 & " times")
	
	; fleet commander not found statistics
	LA_AddRecord ("Fleet commander not found: " & UBound($LA_FleetCommNotFound) - 1 & " times")
	
	; container not found statistics
	LA_AddRecord ("Container not found: " & UBound($LA_ContainerNotFound) - 1 & " times")
	
	; asteroids not found statistics
	LA_AddRecord ("Asteroids not found: " & UBound($LA_AsteroidsNotFound) - 1 & " times")
	
	; manual stops statistics
	LA_AddRecord ("Manual stops: " & UBound($LA_ManualStops) - 1 & " times")
	
	LA_AddRecord ("Log analysis completed")
EndFunc

Func LA_AddRecord($addText)
	local $positionCurrent = StringLen(GUICtrlRead($LA_logInput))		
	_GUICtrlEdit_SetSel($LA_logInput, $positionCurrent, $positionCurrent)
	GUICtrlSetData($LA_logInput, @CRLF & $addText, 1)
EndFunc