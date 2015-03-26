; speech notification
Func SPEECH_Notify($event)
	If Not GUI_speechAllowed() Then
		Return False
	EndIf

	Local $login = GUICtrlRead($GUI_login[$GLB_curBot])

	Switch $event
		Case "localEnemyFound"
			If (GUICtrlRead($GUI_useSpeechOnEnemy) = $GUI_CHECKED) Then SPEECH_Say($login, GUICtrlRead($GUI_textSpeechOnEnemy))
		Case "localTooManyUsers"
			If (GUICtrlRead($GUI_useSpeechTooManyUsers) = $GUI_CHECKED) Then SPEECH_Say($login, GUICtrlRead($GUI_textSpeechTooManyUsers))
		Case "localNewUser"
			If (GUICtrlRead($GUI_useSpeechOnNewUser) = $GUI_CHECKED) Then SPEECH_Say($login, GUICtrlRead($GUI_textSpeechOnNewUser))
		Case "overviewNPCFound"
			If (GUICtrlRead($GUI_useSpeechOnNPCFound) = $GUI_CHECKED) Then SPEECH_Say($login, GUICtrlRead($GUI_textSpeechOnNPCFound))
		Case "overviewLoot"
			If (GUICtrlRead($GUI_useSpeechOnLoot) = $GUI_CHECKED) Then SPEECH_Say($login, GUICtrlRead($GUI_textSpeechOnLoot))
		Case "damage"
			If (GUICtrlRead($GUI_useSpeechOnDamage) = $GUI_CHECKED) Then SPEECH_Say($login, GUICtrlRead($GUI_textSpeechOnDamage))
	EndSwitch
EndFunc

; say text
Func SPEECH_Say($from, $text)
	Local $message = $from & "." & $text & "."
	Run(@ScriptDir & '/utils/speech/speak.bat "' & $message & '"', @ScriptDir & '/utils/speech', @SW_MINIMIZE)
EndFunc