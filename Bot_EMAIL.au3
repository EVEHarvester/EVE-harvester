; speech notification
Func EMAIL_Notify($event)
	If GUICtrlRead($GUI_useEmailNotifications) = $GUI_UNCHECKED Then
		Return False
	ElseIf $LIC_isStandard Then
		BOT_LogMessage("Email notifications not included in STANDARD license", 1)
		BOT_LogMessage("Please purchase PREMIUM license to access this feature", 1)
		Return False
	EndIf

	Switch $event
		Case "clientUpdateNeeded"
			If (GUICtrlRead($GUI_sendEmailOnUpdateNeeded) = $GUI_CHECKED) Then EMAIL_Send(GUICtrlRead($GUI_textEmailOnUpdateNeeded))
		case Else
			BOT_LogMessage("Unknown email notification - " & $event, 2)
	EndSwitch
EndFunc

; send email
Func EMAIL_Send($text)
	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)

	Local $sendData = '{"login":"' & $login & '","password":"' & $password & '","method":"email","data":"' & $text & '"}'
	Local $responseArr = NET_Request($sendData)
	BOT_LogMessage("Email notification - '" & $text & "' sent [" & $responseArr[1] & "]", 1)
EndFunc