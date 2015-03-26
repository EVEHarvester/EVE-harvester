Func TEST()
	;Local $a = OCR_GetScannerAnomaliesList()
	;_ArrayDisplay($a)
	;WIN_ActivateWindow($WIN_titles[$GLB_curBot])
	;ACT_SetDestination(2)
	;BOT_LogMessage("OCR_countLockedObjects: " & OCR_countLockedObjects(), 1)

	;UTL_GenerateSchedule(15, 0)

	;ACT_StackAll("stationHangar")

	;TEST_ActiveModules()

	;TEST_fileUpload("c:\Users\User\Desktop\bot\log\31.03.14 20-59-28_log1_Krotokot.jpg")

	;TEST_remoteCmd()

	;TEST_decodeText()

	;UTL_ShowToolTip("EVE Harvester: new")

	;TEST_capsule()

	;TEST_shield()

	;TEST_cargo()

	;TEST_email()

	;TEST_Overview(1)

	;TEST_overLocks()

	;TEST_Inventory(0)

	;TEST_Overview(0)

	Return False
EndFunc

Func TEST_Local()
	BOT_CheckLocal()
EndFunc

; test overview
Func TEST_Overview($index)
	If $index = False Then
		$index = _GUICtrlListBox_GetCaretIndex($GUI_usersList)
		If $index = -1 Then
			MsgBox(64, "TEST_Overview", "Select account first.")
			Return False
		ElseIf Not WIN_ActivateWindow($WIN_titles[$GLB_curBot]) Then
			MsgBox(64, "TEST_Overview", "EVE window not found. Set window in account first.")
			Return False
		EndIf
	EndIf

	Local $distance

	$distance = Int(EVEOCR_GetOverviewObjectDistance(1, true))
	If $distance = 22222 Or $distance = 1000000 Then
		$distance = "NOT FOUND"
	Else
		$distance = $distance & "m"
	EndIf

	#cs
	Local $X1_OLD = $EVEOCR_OVERVIEW_X1_DIFF
	Local $Y1_OLD = $EVEOCR_OVERVIEW_Y1_DIFF

	For $dx = -3 To 3 Step 1
		For $dy = -3 To 3 Step 1
			$EVEOCR_OVERVIEW_X1 = $X1_OLD + $dx
			$EVEOCR_OVERVIEW_Y1 = $Y1_OLD + $dy
			$distance = Int(EVEOCR_GetOverviewObjectDistance(1))
			If $distance = 22222 Or $distance = 1000000 Then
				$distance = "NOT DETECTED"
			EndIf
			BOT_LogMessage("TEST_Distance: [X="&$dx&",Y="&$dy&"]: " & $distance, 1)
		Next
	Next

	$EVEOCR_OVERVIEW_X1 = $X1_OLD
	$EVEOCR_OVERVIEW_Y1 = $Y1_OLD
	#ce

	BOT_LogMessage("TEST_Overview: near object distance " & $distance, 1)
EndFunc

; test inventory
Func TEST_Inventory($index)
	If $index = False Then
		$index = _GUICtrlListBox_GetCaretIndex($GUI_usersList)
		If $index = -1 Then
			MsgBox(64, "TEST_Inventory", "Select account first.")
			Return False
		ElseIf Not WIN_ActivateWindow($WIN_titles[$GLB_curBot]) Then
			MsgBox(64, "TEST_Inventory", "EVE window not found. Set window in account first.")
			Return False
		EndIf
	EndIf

	Local $window = OCR_DetectInventoryWindow()
	Local $cargo
	If $window <> False Then
		BOT_LogMessage("TEST_Inventory: Inventory window found", 1)
		$cargo = OCR_CalculateInventoryCargo()
		BOT_LogMessage("TEST_Inventory: Inventory cargo = " & $cargo & "%", 1)
	Else
		BOT_LogMessage("TEST_Inventory: Inventory window NOT FOUND", 1)
	EndIf
EndFunc

; test chat
Func TEST_Chat($index)
	If $index = False Then
		$index = _GUICtrlListBox_GetCaretIndex($GUI_usersList)
		If $index = -1 Then
			MsgBox(64, "TEST_Chat", "Select account first.")
			Return False
		ElseIf Not WIN_ActivateWindow($WIN_titles[$GLB_curBot]) Then
			MsgBox(64, "TEST_Chat", "EVE window not found. Set window in account first.")
			Return False
		EndIf
	EndIf

	Local $maxAmountOfUsers = GUICtrlRead($GUI_localChatMaxAmountOfUsers[$index])
	Local $localChatIconSize = GUICtrlRead($GUI_localChatIconSize[$index])

	BOT_LogMessage("TEST_Chat: Settings: maxAmountOfUsers=" & $maxAmountOfUsers & ", localChatIconSize=" & $localChatIconSize, 1)

	; scan chat
	Local $amountOfFoundUsers = 0
	For $i = 0 To $maxAmountOfUsers Step 1
		If OCR_ChatUserPresent($i + 1, $localChatIconSize) Then
			Local $usertype = OCR_ChatUserType($i + 1, $localChatIconSize)
			BOT_LogMessage("TEST_Chat: User found, type=" & $usertype[0] & "-" & $usertype[1], 1)
			$amountOfFoundUsers = $amountOfFoundUsers + 1
		Else
			ExitLoop
		EndIf
	Next

	If $amountOfFoundUsers > 0 Then
		BOT_LogMessage("TEST_Chat: " & $amountOfFoundUsers & " found in chat", 1)
	Else
		BOT_LogMessage("TEST_Chat: Chat users NOT FOUND", 1)
	EndIf
EndFunc

; test GUI layouts
Func TEST_AllGUI()
	BOT_LogMessage("TEST_AllGUI: STARTED", 1)
	Local $amount = _GUICtrlListBox_GetCount($GUI_usersList)
	Local $index = _GUICtrlListBox_GetCaretIndex($GUI_usersList)

	If $amount = 0 Then
		MsgBox(64, "TEST_AllGUI", "Add account first")
		Return False
	ElseIf $index = -1 Then
		MsgBox(64, "TEST_AllGUI", "Select account first")
		Return False
	ElseIf Not WIN_ActivateWindow($WIN_titles[$GLB_curBot]) Then
		MsgBox(64, "TEST_AllGUI", "EVE window not found. Set window in account first")
		Return False
	EndIf

	;cargo
	TEST_Inventory($index)
	;local
	TEST_Chat($index)
	;overview
	TEST_Overview($index)
	;modules
	;pap
	BOT_LogMessage("TEST_AllGUI: FINISHED", 1)
EndFunc

; test image encoders
Func TEST_imageEncoders()
	BOT_LogMessage("TESTimageEncoders: STARTED", 1)
	_GDIPlus_Startup ()
	Local $enc = _GDIPlus_Encoders()
	_ArrayDisplay($enc)

	Local $sFileName = @ScriptDir & $UTL_logDir & "\" & _StringFormatTime("%d.%m.%y %H-%M-%S", _TimeGetStamp()) & "_log" & ($GLB_curBot + 1) & "_LOGIN.jpg"
	Local $sExt = __GDIPlus_ExtractFileExt($sFileName)
	Local $sCLSID = _GDIPlus_EncodersGetCLSID($sExt)

	_GDIPlus_ShutDown ()

	BOT_LogMessage("TESTimageEncoders: " & $sExt & "," & $sCLSID, 1)

	BOT_LogMessage("TESTimageEncoders: FINISHED", 1)
EndFunc

Func TEST_switch()
	Local $value = -10
	Switch $value
		Case -10 To -9
			MsgBox(64,"ok","ok")
	EndSwitch
EndFunc

Func TEST_SteamLaunch()
	ShellExecute("steam://rungameid/8500")
EndFunc

Func TEST_PAP_ItemType()
	For $i = 1 To 5 Step 1
		BOT_LogMessage("TEST_PAP_ItemType: " & $i & " - " & OCR_getPNPItemType($i), 1)
	Next
EndFunc

Func TEST_Overview_Destination()
	OCR_CheckDestinationPresent()
EndFunc

Func TEST_ActiveModules()
	BOT_LogMessage("TEST_ActiveModules: started", 1)
	For $i = 1 To 5 Step 1
		If OCR_isActiveHighSlot($i) Then
			BOT_LogMessage("TEST_ActiveModules: high" & $i & " - is active", 1)
		EndIf
		If OCR_isActiveMiddleSlot($i) Then
			BOT_LogMessage("TEST_ActiveModules: middle" & $i & " - is active", 1)
		EndIf
		If OCR_isActiveLowSlot($i) Then
			BOT_LogMessage("TEST_ActiveModules: low" & $i & " - is active", 1)
		EndIf
	Next
	BOT_LogMessage("TEST_ActiveModules: finished", 1)
EndFunc

Func TEST_fileUpload($filePath)
	BOT_LogMessage("TEST_fileUpload: " & $filePath)
	NET_sendFile($filePath)
EndFunc

Func TEST_remoteCmd()
	GUICtrlSetData($GUI_licenseLogin, "creator77")
	GUICtrlSetData($GUI_licensePassword, "creator77")
	NET_remoteCmdCheck()

	BOT_LogMessage("TEST_remoteCmd: end of test")
	UTL_Wait(5, 10)
EndFunc

Func TEST_decodeText()
	Local $text = '/-¶mƒP»9M"€¥|¦ÆÅZoŒ—|¾³IùÌë›*ùQ^(WþV›ÕR ¿œÑÝsvÇCÉÛ¦¨¸žFýÝ¨´‰H˜gó3†WªA–Éó8p¿²å»,ö¤ÓMN„ä+~ƒql¼‚²àô¤€ÄqÔj”+†bÞº¹FN3¿`2ÐÂ»kÑòò5(­›¨¦_›’¤‹ÔZñ+ê!h­}ÿùqœfã3·FZèBÂT©ÃñÈe‚˜Ló™vze°FÇï¨„,>Ó˜@H]_¦šzD/sýþÕaÓ4>©à:2u›Rt¡¤1ü6²ä†)'
	;Local $decoded = BinaryToString(_rijndaelInvCipher("qwert!uiop[]asdf", $text))
	Local $decoded = _rijndaelInvCipher("qwert!uiop[]asdf", $text)

	BOT_LogMessage("TEST_decodeText: decoded=" & $decoded)
EndFunc

Func TEST_capsule()
	Local $capsuleSpace = OCR_DetectCapsuleSpace()
	Local $capsuleStation = OCR_DetectCapsuleStation()

	BOT_LogMessage("TEST_capsule: capsuleSpace=" & $capsuleSpace, 1)
	BOT_LogMessage("TEST_capsule: capsuleStation=" & $capsuleStation, 1)
EndFunc

Func TEST_shield()
	Local $shield = OCR_DetectShieldDamage()

	BOT_LogMessage("TEST_shield: shield=" & $shield, 1)
EndFunc

Func TEST_cargo()
	Local $cargo = OCR_CalculateInventoryCargo()

	BOT_LogMessage("TEST_cargo: cargo=" & $cargo, 1)
EndFunc

Func TEST_email()
	EMAIL_Send("clientUpdateNeeded")

	BOT_LogMessage("TEST_email", 1)
EndFunc

Func TEST_overLocks()
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)

		If Not OCR_isObjectLocked($x1, $y1) Then
			BOT_LogMessage("TEST_overLocks: "&$i&" not locked", 1)
		Else
			BOT_LogMessage("TEST_overLocks: "&$i&" locked", 1)
		EndIf
	Next
EndFunc