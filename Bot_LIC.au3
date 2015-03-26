Global $LIC_cryptKey = "qWeAtauaopaaasDf"
Global $LIC_cryptKeyUpdated = False

Global $LIC_isStandard = True
Global $LIC_expiration = False

Global $LIC_sessionCheckTS = 0 ; timestamp
Global $LIC_sessionCheckPeriod = 60 ; 60 min

Global $LIC_licensingMessage = ""

; check is user entered license data
Func LIC_isLicenseInputed()
	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)

	If $login = "yourServerLogin" Or $login = "" Or $password = "yourServerPassword" Or $password = "" Then
		Return False
	Else
		Return True
	EndIf
EndFunc

; check crypt key
Func LIC_GetCryptKey()
	Local $request = 'connect'
	Local $responseArr = NET_Request($request)

	If $responseArr = False Then
		BOT_LogMessage("LIC_SK: connection error", 2)
		Return False
	EndIf

	Local $err = NET_GetResponseKey($responseArr, "error")
	Local $key = NET_GetResponseKey($responseArr, "key")

	If $err <> False Then
		BOT_LogMessage("LIC_SK: server error")
		LIC_onServerError($err)
	ElseIf StringLen($key) = 16 Then
		$LIC_cryptKey = $key
		$LIC_cryptKeyUpdated = True

		;BOT_LogMessage("LIC_SK: new key = " & $key, 2)
	Else
		BOT_LogMessage("LIC_SK: server strange response", 2)
		LIC_onServerError($responseArr[1], False)
	EndIf
EndFunc

; check license
Func LIC_CheckLicense()
	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)
	Local $request = '{"login":"' & $login & '","password":"' & $password & '","method":"license","mac":"' & $NET_MAC & '"}'
	Local $responseArr = NET_Request($request)

	If $responseArr = False Then
		BOT_LogMessage("LIC_CL: connection error", 2)
		Return False
	EndIf

	Local $err = NET_GetResponseKey($responseArr, "error")
	Local $license = NET_GetResponseKey($responseArr, "license")
	Local $expiration = NET_GetResponseKey($responseArr, "expiration")

	If $err <> False Then
		BOT_LogMessage("LIC_CL: server error", 2)
		LIC_onServerError($err)
	ElseIf $license <> False Then
		If $license = "full" Then
			LIC_setPremiumLicense($expiration)
		Else
			LIC_setStandardLicense()
		EndIf
	Else
		BOT_LogMessage("LIC_CL: server strange response", 2)
		LIC_onServerError($responseArr[1], False)
	EndIf
EndFunc

; set standard license
Func LIC_setStandardLicense()
	$LIC_isStandard = True
	$LIC_expiration = False

	GUICtrlSetData($GUI_currentLicStatusInput, "STANDARD")
	GUICtrlSetBkColor($GUI_currentLicStatusInput, 0xff0000)
	GUICtrlSetData($GUI_currentLicExpirationInput, "NEVER")

	BOT_LogMessage("LIC_SSL: standard license.", 2)
EndFunc

; set premium license
Func LIC_setPremiumLicense($expiration)
	$LIC_isStandard = False
	$LIC_expiration = $expiration

	GUICtrlSetData($GUI_currentLicStatusInput, "PREMIUM")
	GUICtrlSetBkColor($GUI_currentLicStatusInput, 0x00ff00)
	GUICtrlSetData($GUI_currentLicExpirationInput, $LIC_expiration)

	BOT_LogMessage("LIC_SSL: premium license. " & $expiration, 2)
EndFunc

; check session
Func LIC_CheckSession()
	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)

	Local $request = '{"login":"' & $login & '","password":"' & $password & '","method":"session","mac":"' & $NET_MAC & '"}'
	Local $responseArr = NET_Request($request)

	If $responseArr = False Then
		BOT_LogMessage("LIC_US: connection error", 2)
		Return False
	EndIf

	Local $err = NET_GetResponseKey($responseArr, "error")
	Local $session = NET_GetResponseKey($responseArr, "session")
	Local $license = NET_GetResponseKey($responseArr, "ucl")

	If $err <> False Then
		BOT_LogMessage("LIC_US: server error", 2)
		LIC_onServerError($err)
	ElseIf $session <> False Then
		If $session = "extend" Then
			$LIC_sessionCheckTS = _TimeMakeStamp(0, @MIN, @HOUR, @MDAY, @MON, @YEAR)
			BOT_LogMessage("LIC_US: session extended", 2)
		ElseIf $session = "terminate" Then
			For $n = 0 To $GLB_numOfBots - 1 Step 1
				$GLB_stayInStation[$n] = -7
				BOT_LogMessage("Set instructions for bot " & $n & ". Session termination", 2)
			Next
			BOT_LogMessage("LIC_US: session termination", 2)
		EndIf

		; recheck license if license type changed
		If ($license = "demo" And $LIC_isStandard = False) Or ($license = "full" And $LIC_isStandard = True) Then
			BOT_LogMessage("LIC_US: license changed", 2)
			LIC_CheckLicense()
		EndIf
	Else
		BOT_LogMessage("LIC_US: server strange response", 2)
		LIC_onServerError($responseArr[1], False)
	EndIf
EndFunc

; is session need update
Func LIC_SessionNeedUpdate()
	Local $now = _TimeMakeStamp(0, @MIN, @HOUR, @MDAY, @MON, @YEAR)
	Local $border = $LIC_sessionCheckTS + $LIC_sessionCheckPeriod*60
	If $now > $border Then
		Return True
	Else
		Return False
	EndIf
EndFunc

; server error actions
Func LIC_onServerError($err, $managable = True)
	Local $errCode
	Local $message
	If $managable Then
		$errCode = -9
		If $err = "user" Then
			$message = "Wrong username"
			$LIC_licensingMessage = "Wrong license data!"
		ElseIf $err = "password" Then
			$message = "Wrong password"
			$LIC_licensingMessage = "Wrong license data!"
		ElseIf $err = "version" Then
			$message = "Wrong version " & UTL_GetScriptVersion(True)
			$LIC_licensingMessage = "New version available!"
			UTL_ShowToolTip("EVE Harvester: New version available!", 10)
		ElseIf $err = "method" Then
			$message = "Wrong request"
		Else
			$message = "Unknown error"
		EndIf
	Else
		$errCode = -10
		$message = "Unmanaged error. [" & $NET_lastResponse & "]"
	EndIf

	; is errors manageble process it
	If $errCode <> -10 Then
		For $n = 0 To $GLB_numOfBots - 1 Step 1
			$GLB_stayInStation[$n] = $errCode
			BOT_LogMessage("Set instructions for bot " & $n & ". Server error", 2)
		Next
	EndIf

	BOT_LogMessage("LIC_OSE: " & $message & " [" & $err & "]", 2)
EndFunc