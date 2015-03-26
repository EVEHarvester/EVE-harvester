Global $NET_PROTOCOL = "http"
Global $NET_SERVER = "eveharvester.com"
Global $NET_SERVER_API = "/api/"
Global $NET_MAC = False
Global $NET_updateTS = 0
Global $NET_NPCinBelt[30]
Global $NET_NPCinBeltGroup[30]
Global $NET_LocalUsers[30]
Global $NET_maxUploadFileSize = 500000 ;500000 = 1Mb
Global $NET_fileUploading = False
Global $NET_lastResponse = Null

; remote parameters
Global $NET_lastRemoteCmdCheckTime = 0
Global $NET_remoteCmdCheckInterval
Global $NET_remoteCmdCheckGeneralInterval = 2*60 ; 2 minutes
Global $NET_remoteCmdCheckIntensiveInterval = 3 ; 3 seconds
Global $NET_lastRemoteCmdReceiveTime = 0
Global $NET_lastRemoteCmdIdleInterval = 10*60; 10 minutes

Func NET_InitData()
	; set all npc in belts to false
	For $i = 0 To UBound($NET_NPCinBelt) - 1 Step 1
		$NET_NPCinBelt[$i] = False
	Next

	; set all group id locals to 1
	For $i = 0 To UBound($NET_LocalUsers) - 1 Step 1
		$NET_LocalUsers[$i] = 1
	Next

	$NET_MAC = NET_getMacAddress()
EndFunc

Func NET_ReportNPC($belt, $isPresent)
	$NET_NPCinBelt[$belt - 1] = $isPresent
	$NET_NPCinBeltGroup[$belt - 1] = $GUI_groupID[$GLB_curBot]

	#cs
	Local $JSON_params = _JSONEncode( _
		_JSONObject( _
			'u','belt', _
			'id', $belt - 1, _
			'val', $isPresent _
		) _
	)
	#ce

	;NET_Request($JSON_params, "set")
EndFunc

Func NET_GetNPCbelt($group = 0)
	For $i = 0 To UBound($NET_NPCinBelt) - 1 Step 1
		If $NET_NPCinBelt[$i] And $NET_NPCinBeltGroup[$i] = $GUI_groupID[$group] Then
			Return ($i + 1)
		EndIf
	Next
	Return False
EndFunc

Func NET_Request($sendData, $type = "POST")
	Local $varName = "i"
	If $sendData = 'connect' Then
		$varName = "c"
	EndIf
	Local $postData = $varName & "=" & _Base64Encode(_rijndaelCipher($LIC_cryptKey, $sendData), False) & "&v=" & UTL_GetScriptVersion(True)

	; COM objects replaces pluses on spaces in request
	; prevent this action
	$postData = StringReplace($postData, "+", "plus")

	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

	$oHTTP.Open($type, $NET_PROTOCOL & "://" & $NET_SERVER & $NET_SERVER_API)
	If (@error) Then
		BOT_LogMessage("NET_Request: Open request failed", 2)
		Return False
	EndIf

	Local $timeout = GUICtrlRead($GUI_NetworkTimeoutInput)*1000
	$oHTTP.setTimeouts($timeout, $timeout, $timeout, $timeout)
	;$oHTTP.SetRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
	;$oHTTP.SetRequestHeader("Accept-Language", "ru")
	;$oHTTP.SetRequestHeader("Referer", $NET_URL)
	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oHTTP.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)")
	;$oHTTP.SetRequestHeader("Host",$Host)
	$oHTTP.SetRequestHeader("Proxy-Connection", "Keep-alive")
	$oHTTP.Send($postData)
	If (@error) Then
		BOT_LogMessage("NET_Request: Send request failed", 2)
		Return False
	EndIf
	$oHTTP.WaitForResponse

	Local $decodedResponse = BinaryToString(_rijndaelInvCipher($LIC_cryptKey, _HexToString($oHTTP.ResponseText)))

	$NET_lastResponse = $oHTTP.ResponseText

	;BOT_LogMessage("sendData=" & $sendData, 1)
	;BOT_LogMessage("postData=" & $postData, 1)
	;BOT_LogMessage("response=" & $oHTTP.ResponseText, 1)
	;BOT_LogMessage("decodedResponse=" & $decodedResponse, 1)

	return StringSplit($decodedResponse, "&")
EndFunc

Func NET_GetResponseKey($data, $keyName)
	If IsArray($data) Then
		For $i = 1 To $data[0] Step 1
			If StringInStr($data[$i], $keyName & "=") <> 0 Then
				Local $pair = StringSplit($data[$i], "=")
				Return $pair[2]
			EndIf
		Next
	EndIf
	Return False
EndFunc

; get network adapters properties
Func NET_NetAdapters($sHostName = "localhost")
    Local $objItem, $objWMIService = ObjGet( "winmgmts:\\"& $sHostName &"\root\CIMV2")
    Local $sQuery = 'SELECT Index, Caption, MACAddress, IPAddress FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True'
    Local $colItems = $objWMIService.ExecQuery($sQuery, "WQL", 0x30)
    If IsObj($colItems) Then
        Local $aRes[1][3], $i=0
        For $colItem In $colItems
            ReDim $aRes[$i+1][3]
            $aRes[$i][0] = $colItem.Caption
            $aRes[$i][1] = $colItem.IPAddress(0)
            $aRes[$i][2] = $colItem.MACAddress
            $i+=1
        Next
        Return $aRes
    EndIf
    Return SetError(1)
EndFunc  ;==> NET_NetAdapters

; get adapter MAC-adrdess
Func NET_getMacAddress($adapter = 0)
	Local $adapters = NET_NetAdapters()
	Return $adapters[$adapter][2]
EndFunc  ;==> NET_NetAdapters

; open URL in user default browser
Func NET_OpenUrlInBrowser($url, $protocol = "http")
	Local $fullURL = $protocol & "://" & $url
	ShellExecute($fullURL)
EndFunc

; check remote commands interval
Func NET_remoteCmdIntervalCheck($now)
	If ($now - $NET_lastRemoteCmdReceiveTime) < $NET_lastRemoteCmdIdleInterval Then
		BOT_LogMessage("NET_remoteCmdIntervalCheck: change check interval to intensive", 2)
		$NET_remoteCmdCheckInterval = $NET_remoteCmdCheckIntensiveInterval
	Else
		BOT_LogMessage("NET_remoteCmdIntervalCheck: change check interval to general", 2)
		$NET_remoteCmdCheckInterval = $NET_remoteCmdCheckGeneralInterval
	EndIf

	Local $diff = $now - $NET_lastRemoteCmdCheckTime
	If $diff < $NET_remoteCmdCheckInterval Then
		BOT_LogMessage("NET_remoteCmdCheck: waiting for " & ($NET_remoteCmdCheckInterval - $diff) & " seconds", 2)
		Return False
	EndIf

	Return True
EndFunc

; check remote commands
Func NET_remoteCmdCheck()
	BOT_LogMessage("NET_remoteCmdCheck: start", 2)

	Local $now = _TimeGetStamp()

	If Not NET_remoteCmdIntervalCheck($now) Then
		Return
	EndIf

	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)

	Local $sendData = '{"login":"' & $login & '","password":"' & $password & '","method":"remote-getRequest"}'
	Local $responseArr = NET_Request($sendData, "POST")

	Local $err = NET_GetResponseKey($responseArr, "error")
	Local $cmd = NET_GetResponseKey($responseArr, "cmd")
	Local $reqid = NET_GetResponseKey($responseArr, "reqid")

	If $err <> False Then
		BOT_LogMessage("NET_remoteCmdCheck: get request error - " & $err, 2)
	ElseIf $cmd = "no" Then
		BOT_LogMessage("NET_remoteCmdCheck: no commands", 2)
	ElseIf $cmd = False Then
		BOT_LogMessage("NET_remoteCmdCheck: API error", 2)
	Else
		BOT_LogMessage("NET_remoteCmdCheck: " & $cmd, 2)

		$NET_lastRemoteCmdReceiveTime = $now

		Local $params = NET_GetResponseKey($responseArr, "params")
		Local $responseData = ""
		If $cmd = "getState" Then
			$responseData&= "{"
			$responseData&= '"general":{'
			$responseData&= '"running":"' & $GLB_isRunning & '",'
			$responseData&= '"license":"' & $LIC_isStandard & '"'
			$responseData&= '},'

			$responseData&= '"accounts": ['
			For $a = 0 To $GLB_numOfBots - 1 Step 1
				$responseData&= '{'
				; name
				$responseData&= '"name":"' & GUICtrlRead($GUI_login[$a]) & '",'

				; role
				$responseData&= '"role":"' & GUICtrlRead($GUI_botRole[$a]) & '",'

				; location
				$responseData&= '"location":"' & GUICtrlRead($GUI_locationCombo[$a]) & '",'

				; state
				$responseData&= '"state":"' & GUICtrlRead($GUI_stateCombo[$a]) & '",'

				; alarm
				$responseData&= '"alarm":"' & GUI_getAlarmText($GLB_stayInStation[$a]) & '",'

				; schedule
				$responseData&= '"schedule":"' & GUICtrlRead($GUI_botSchedule[$a]) & '",'

				; enabled/disabled
				If GUICtrlRead($GUI_enableBot[$a]) = $GUI_CHECKED Then
					$responseData&= '"enabled":"true"'
				Else
					$responseData&= '"enabled":"false"'
				EndIf

				$responseData&= '}'

				If $a <> $GLB_numOfBots - 1 Then
					$responseData&= ','
				EndIf
			Next

			$responseData&= ']'
			$responseData&= '}'
		ElseIf $cmd = "start" Then
			BOT_Start()
			$responseData&= '{"running":"' & $GLB_isRunning & '"}'
		ElseIf $cmd = "stop" Then
			BOT_Stopping()
			If $params = "closewindows" Then
				While GUICtrlGetState($GUI_startButton) <> $GUI_ENABLE
					UTL_Wait(0.5, 1)
					BOT_LogMessage("NET_remoteCmdCheck: waiting for stop", 2)
				WEnd

				BOT_LogMessage("NET_remoteCmdCheck: closing all windows", 2)
				WIN_CloseAllWindows()
			EndIf
			$responseData&= '{"running":"' & $GLB_isRunning & '"}'
		Else
			BOT_LogMessage("NET_remoteCmdCheck: unknown command", 2)
		EndIf

		$sendData = '{"login":"' & $login & '","password":"' & $password & '","method":"remote-sendResponse", "reqid":"' & $reqid & '", "data":' & $responseData & '}'
		$responseArr = NET_Request($sendData, "POST")

		$err = NET_GetResponseKey($responseArr, "error")

		If $err <> False Then
			BOT_LogMessage("NET_remoteCmdCheck: response error - " & $err, 2)
		EndIf

	EndIf
	$NET_lastRemoteCmdCheckTime = $now
EndFunc

; send file to server
Func NET_sendFile($filePath)
	BOT_LogMessage("NET_sendFile: " & $filePath)
	Local $file = FileOpen($filePath, 16)
	Local $fileTypeName = StringRegExpReplace($filePath, '^.*\\', '')

    Local $fileData = FileRead($file, $NET_maxUploadFileSize)
    If @error Then BOT_LogMessage("Couldn't read file: " & $filePath, 1)

	Local $login = GUICtrlRead($GUI_licenseLogin)
	Local $password = GUICtrlRead($GUI_licensePassword)

	Local $sendData = '{"login":"' & $login & '","password":"' & $password & '","method":"file-upload", "name":"' & $fileTypeName & '", "data":"' & StringTrimLeft($fileData,2) & '"}'
	Local $responseArr = NET_Request($sendData, "POST")

	Local $err = NET_GetResponseKey($responseArr, "error")
	Local $link = NET_GetResponseKey($responseArr, "link")

	If $err <> False Then
		BOT_LogMessage("NET_sendFile: server error - " & $err)
	ElseIf $link <> False Then
		BOT_LogMessage("NET_sendFile: filelink - " & $link)
	EndIf
EndFunc