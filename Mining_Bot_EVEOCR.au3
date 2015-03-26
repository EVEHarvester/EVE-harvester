Global $EVEOCR_brightnessDiff = 20
Global $EVEOCR_brightnessEtalon
Global $EVEOCR_Bitmap
Global $EVEOCR_GDIImage

Global $EVEOCR_OVERVIEW_X1_DIFF = 60
Global $EVEOCR_OVERVIEW_Y1_DIFF = 70

Func EVEOCR_GetOverviewObjectDistance($position = 1, $debug = False)
	Local $x1 = $GLB_overviewWindow[0] + $EVEOCR_OVERVIEW_X1_DIFF
	Local $y1 = $GLB_overviewWindow[1] + $EVEOCR_OVERVIEW_Y1_DIFF + ($GLB_ObjectSearchIconSize + $GLB_ObjectSearchDividerSize)*($position - 1)
	Local $x2 = $x1 + 40
	Local $y2 = $y1 + 9
	Local $imgSize[2] = [$x2 - $x1, $y2 - $y1]

	;$debug = True
	;BOT_LogMessage("EVEOCR_GetOverviewObjectDistance: coord="&$x1&":"&$y1&", "&$x2&":"&$y2&", "&$imgSize[0]&"x"&$imgSize[1])

	Local $borders = UTL_GetWindowBorders()

	$x1+= $borders[0]
	$y1+= $borders[1]
	$x2+= $borders[0]
	$y2+= $borders[1]

	_GDIPlus_Startup()
	If $debug Then
		;test
		_ScreenCapture_CaptureWnd(@ScriptDir & "/log/eveocr" & $position & ".bmp", $WIN_titles[$GLB_curBot], $x1, $y1, $x2, $y2, False)
		;end test
	EndIf
	$EVEOCR_Bitmap = _ScreenCapture_CaptureWnd("", $WIN_titles[$GLB_curBot], $x1, $y1, $x2, $y2, False)
	$EVEOCR_GDIImage = _GDIPlus_BitmapCreateFromHBITMAP($EVEOCR_Bitmap)

	$EVEOCR_brightnessEtalon = EVEOCR_getPixelBrightness($imgSize[0] - 1, 0)
	BOT_LogMessage("EVEOCR_GetOverviewObjectDistance: EVEOCR_brightnessEtalon="&$EVEOCR_brightnessEtalon)
	Local $digitsPointer[2]
	local $distMultiplier = 1000000
	local $number = ""

	; distance type
	; check m
	If EVEOCR_isBright($imgSize[0] - 6, $imgSize[1] - 2) And EVEOCR_isBright($imgSize[0], $imgSize[1] - 2) Then
		; check k
		If EVEOCR_isBright($imgSize[0] - 11, $imgSize[1] - 1) And EVEOCR_isBright($imgSize[0] - 11, $imgSize[1] - 9) Then
			BOT_LogMessage("EVEOCR_GetOverviewObjectDistance: km")
			$digitsPointer[0] = $imgSize[0] - 19
			$digitsPointer[1] = $imgSize[1] - 9
			$distMultiplier = 1000
		Else
			$digitsPointer[0] = $imgSize[0] - 14
			$digitsPointer[1] = $imgSize[1]	- 9
			BOT_LogMessage("EVEOCR_GetOverviewObjectDistance: m")
			$distMultiplier = 1
		EndIf
	Else
		BOT_LogMessage("EVEOCR_GetOverviewObjectDistance: AU")
		Return $distMultiplier
	EndIf

	;check 3 digits
	For $i = 0 To 3 Step 1
		Local $digitStart[2] = [$digitsPointer[0] - $i*6, $digitsPointer[1]]
		; skip separator
		If $i = 3 Then
			$digitStart[0] = $digitStart[0] - 3
		EndIf

		Local $digit = EVEOCR_checkDigit($digitStart)
		If $digit = False Then
			;BOT_LogMessage("EVEOCR_GetOverviewObjectDistance: Exit")
			ExitLoop
		Else
			$number = $digit & $number
		EndIf
	Next

    _GDIPlus_ImageDispose($EVEOCR_GDIImage)
    _WinAPI_DeleteObject($EVEOCR_Bitmap)
    _GDIPlus_Shutdown()

	If $number = "0000" Then
		$number = 22222
	EndIf

	BOT_LogMessage("EVEOCR: distance to object - " & ($number*$distMultiplier) & " m", 1)
	Return $number*$distMultiplier
EndFunc

Func EVEOCR_BitmapGetPixel($iX, $iY)
     Local $tArgb, $pArgb, $aRet
     $tArgb = DllStructCreate("dword Argb")
     $pArgb = DllStructGetPtr($tArgb)
     $aRet = DllCall($__g_hGDIPDll, "int", "GdipBitmapGetPixel", "hwnd", $EVEOCR_GDIImage, "int", $iX, "int", $iY, "ptr", $pArgb)
	 ;BOT_LogMessage("EVEOCR_BitmapGetPixel: " & $iX & " : " & $iY & ", c="& "0x" & Hex(DllStructGetData($tArgb, "Argb")))
     Return "0x" & Hex(DllStructGetData($tArgb, "Argb"))
 EndFunc

Func EVEOCR_TrimColor($TargetTrim)
;cs TrimarkColor - Comment Start
;Исползуется для получения из цвета в формате RGB значение яркости пикселя. Возвращает значение от 0 до 255.
;Скорость:
;Функция выполняется за ~0.06-0.10 мс.
;(с) Archy26 :)
;#ce TrimarkColor - Comment End
	Local $a, $a_fin
	$a = Hex($TargetTrim, 6)
	$a_fin = (Dec(StringTrimRight($a, 4)) + Dec(StringTrimLeft(StringTrimRight($a, 2), 2)) + Dec(StringTrimLeft($a, 4)))/3
	$TargetTrim = Round($a_fin, 0)
	Return $TargetTrim
EndFunc

Func EVEOCR_getPixelBrightness($x, $y)
	Return EVEOCR_TrimColor(EVEOCR_BitmapGetPixel($x, $y))
EndFunc

Func EVEOCR_isBright($x, $y)
	If EVEOCR_getPixelBrightness($x, $y) - $EVEOCR_brightnessEtalon > $EVEOCR_brightnessDiff Then
		;BOT_LogMessage("EVEOCR_isBright: bright " & $x & " : " & $y & ", b="& EVEOCR_getPixelBrightness($x, $y))
		Return True
	Else
		;BOT_LogMessage("EVEOCR_isBright: not bright " & $x & " : " & $y & ", b="& EVEOCR_getPixelBrightness($x, $y))
		Return False
	EndIf
EndFunc

; depricated in crusible 1.2
Func EVEOCR_isDark($x, $y)
	If EVEOCR_getPixelBrightness($x, $y) - $EVEOCR_brightnessEtalon < -1*$EVEOCR_brightnessDiff Then
		;BOT_LogMessage("EVEOCR_isDark: dark " & $x & " : " & $y & ", b="& EVEOCR_getPixelBrightness($x, $y))
		Return True
	Else
		;BOT_LogMessage("EVEOCR_isDark: not dark " & $x & " : " & $y & ", b="& EVEOCR_getPixelBrightness($x, $y))
		Return False
	EndIf
EndFunc

Func EVEOCR_checkDigit($digitStart)
	Local $number = False

	If EVEOCR_isBright($digitStart[0] - 4, $digitStart[1] + 3) Then
		;5 6 8 9 0
		If EVEOCR_isBright($digitStart[0] - 2, $digitStart[1] + 4) Then
			;5 8 0
			If EVEOCR_isBright($digitStart[0], $digitStart[1] + 2) Then
				;8 0
				If EVEOCR_isBright($digitStart[0] - 1, $digitStart[1] + 2) Then
					;0
					$number = "0"
				ElseIf EVEOCR_isBright($digitStart[0] - 3, $digitStart[1] + 4) Then
					;8
					$number = "8"
				EndIf
			ElseIf EVEOCR_isBright($digitStart[0] - 4, $digitStart[1]) Then
				;5
				$number = "5"
			EndIf
		Else
			; 6 9
			If EVEOCR_isBright($digitStart[0] - 2, $digitStart[1] + 3) Then
				;6
				$number = "6"
			ElseIf EVEOCR_isBright($digitStart[0], $digitStart[1] + 2) Then
				;9
				$number = "9"
			EndIf
		EndIf
	Else
		;1 2 3 4 7
		If EVEOCR_isBright($digitStart[0] - 2, $digitStart[1] + 8) Then
			;1 2 3
			If EVEOCR_isBright($digitStart[0] - 2, $digitStart[1] + 2) Then
				;1
				$number = "1"
			ElseIf EVEOCR_isBright($digitStart[0] - 1, $digitStart[1] + 6) Then
				;3
				$number = "3"
			ElseIf EVEOCR_isBright($digitStart[0] - 4, $digitStart[1] + 8) Then
				;2
				$number = "2"
			EndIf
		Else
			; 4 7
			If EVEOCR_isBright($digitStart[0] - 4, $digitStart[1]) Then
				;7
				$number = "7"
			ElseIf EVEOCR_isBright($digitStart[0] - 1, $digitStart[1] + 8) Then
				;4
				$number = "4"
			EndIf
		EndIf
	EndIf

	BOT_LogMessage("EVEOCR_checkDigit: number="&$number)
	Return $number
EndFunc

; get asteroids in range
Func EVEOCR_getAsteroidsInRange($range, $limit = "unlimited")
	Local $num = 0
	While EVEOCR_GetOverviewObjectDistance($num + 1) < $range*1000
		$num+= 1
		If $limit = $num Then
			ExitLoop
		EndIf
	WEnd
	BOT_LogMessage("EVEOCR: Asteroids closer " & $range & "km = " & $num & "(limit:" & $limit & ")", 1)
	Return $num
EndFunc