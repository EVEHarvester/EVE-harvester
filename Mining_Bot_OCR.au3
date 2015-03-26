Global $OCR_freezeChecksum = 0

;detect main menu
Func OCR_DetectMainMenu()
	PixelSearch($GLB_mainMenu[0], $GLB_mainMenu[1], $GLB_mainMenu[2], $GLB_mainMenu[3], $GLB_mainMenu[4], $GLB_mainMenu[5])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;detect undock button
Func OCR_DetectUndockButton()
	BOT_LogMessage("OCR_DetectUndockButton: " & Hex(PixelGetColor($GLB_undockButton[0], $GLB_undockButton[1]),6))
	PixelSearch($GLB_undockButton[0], $GLB_undockButton[1], $GLB_undockButton[0], $GLB_undockButton[1], $GLB_undockButton[2], $GLB_undockButton[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;calculate cargo in inventory in %
Func OCR_CalculateInventoryCargo()
	Local $cargoIndicator = $GLB_inventoryWindow_cargoIndicator
	Local $cargoBarWidth = $cargoIndicator[2]

	; if empty cargo
	PixelSearch($cargoIndicator[0], $cargoIndicator[1], $cargoIndicator[0], $cargoIndicator[1], $cargoIndicator[3], $cargoIndicator[4])
	If @error Then
		;BOT_LogMessage("OCR_CalculateInventoryCargo: EMPTY CARGO", 1)
		Return 0
	EndIf

	; if full cargo
	PixelSearch($cargoIndicator[0] + $cargoBarWidth, $cargoIndicator[1], $cargoIndicator[0] + $cargoBarWidth, $cargoIndicator[1], $cargoIndicator[3], $cargoIndicator[4])
	If Not @error Then
		;BOT_LogMessage("OCR_CalculateInventoryCargo: FULL CARGO", 1)
		Return 100
	EndIf

	Local $mixedCargo = -1
	Local $oneTenth = Round($cargoBarWidth/10)
	Local $oneHundredth = Round($cargoBarWidth/100)
	Local $cargoTenth = 9*$oneTenth
	Local $cargoHundredth = 9*$oneHundredth

	For $i = 1 To 9 Step 1
		Local $curTenth = $i*$oneTenth
		;BOT_LogMessage("OCR_CalculateInventoryCargo: ONE-TENTH = " & $oneTenth & ", curI=" & $i & ", curTenth=" & $curTenth & ", x=" &($cargoIndicator[0] + $curTenth)& ", color=" & Hex(PixelGetColor($cargoIndicator[0] + $curTenth, $cargoIndicator[1]),6), 1)
		PixelSearch($cargoIndicator[0] + $curTenth, $cargoIndicator[1], $cargoIndicator[0] + $curTenth, $cargoIndicator[1], $cargoIndicator[3], $cargoIndicator[4])
		If @error Then
			$cargoTenth = $curTenth - $oneTenth
			ExitLoop
		EndIf
	Next

	For $j = 0 To 9 Step 1
		Local $curHundredth = $j*$oneHundredth
		Local $x = $cargoIndicator[0] + $cargoTenth + $curHundredth
		;BOT_LogMessage("OCR_CalculateInventoryCargo: number = " & $j & ", x=" & $x & ", mixedCargo=" & $mixedCargo, 1)
		PixelSearch($x, $cargoIndicator[1], $x, $cargoIndicator[1], $cargoIndicator[3], $cargoIndicator[4])
		If @error Then
			$cargoHundredth = $curHundredth - $oneHundredth
			;BOT_LogMessage("OCR_CalculateInventoryCargo: cargoHundredth = " & $cargoHundredth, 1)
			ExitLoop
		EndIf
	Next

	$mixedCargo = Round((($cargoTenth + $cargoHundredth)*100)/($cargoBarWidth))
	;BOT_LogMessage("OCR_CalculateInventoryCargo: mixedCargo = " & $mixedCargo, 1)

	Return $mixedCargo
EndFunc

;calculate ore cargo in ship in %
Func OCR_CalculateOreCargo()
	Local $cargoBarWidth = $GLB_oreHoldBar[2] - $GLB_oreHoldBar[0]

	For $i = 0 To $cargoBarWidth Step 1
		;MouseMove($GLB_cargoBar[0] + $i, $GLB_cargoBar[1])
		PixelSearch($GLB_oreHoldBar[0] + $i, $GLB_oreHoldBar[1], $GLB_oreHoldBar[0] + $i, $GLB_oreHoldBar[3], $GLB_oreHoldBar[4], $GLB_oreHoldBar[5])
		If @error Then
			Return Round($i*100/$cargoBarWidth)
		EndIf
	Next

	Return 100
EndFunc

;calculate corp hangar cargo in ship in %
Func OCR_CalculateCorpHangarCargo()
	Local $cargoBarWidth = $GLB_fleetCommanderCorpHangarBar[2] - $GLB_fleetCommanderCorpHangarBar[0]

	For $i = 0 To $cargoBarWidth Step 1
		;MouseMove($GLB_cargoBar[0] + $i, $GLB_cargoBar[1])
		PixelSearch($GLB_fleetCommanderCorpHangarBar[0] + $i, $GLB_fleetCommanderCorpHangarBar[1], $GLB_fleetCommanderCorpHangarBar[0] + $i, $GLB_fleetCommanderCorpHangarBar[3], $GLB_fleetCommanderCorpHangarBar[4], $GLB_fleetCommanderCorpHangarBar[5])
		If @error Then
			Return Round($i*100/$cargoBarWidth)
		EndIf
	Next

	Return 100
EndFunc

;calculate ship corp hangar cargo in ship in %
Func OCR_CalculateShipCorpHangarCargo()
	Local $cargoBarWidth = $GLB_shipCorpHangarBar[2] - $GLB_shipCorpHangarBar[0]

	For $i = 0 To $cargoBarWidth Step 1
		;MouseMove($GLB_cargoBar[0] + $i, $GLB_cargoBar[1])
		PixelSearch($GLB_shipCorpHangarBar[0] + $i, $GLB_shipCorpHangarBar[1], $GLB_shipCorpHangarBar[0] + $i, $GLB_shipCorpHangarBar[3], $GLB_shipCorpHangarBar[4], $GLB_shipCorpHangarBar[5])
		If @error Then
			Return Round($i*100/$cargoBarWidth)
		EndIf
	Next

	Return 100
EndFunc


;calculate cargo in container in %
Func OCR_CalculateContainerCargo()
	Local $cargoBarWidth = $GLB_containerBar[2] - $GLB_containerBar[0]

	For $i = 0 To $cargoBarWidth Step 1
		;MouseMove($GLB_containerBar[0] + $i, $GLB_containerBar[1])
		PixelSearch($GLB_containerBar[0] + $i, $GLB_containerBar[1], $GLB_containerBar[0] + $i, $GLB_containerBar[3], $GLB_containerBar[4], $GLB_containerBar[5])
		If @error Then
			Return Round($i*100/$cargoBarWidth)
		EndIf
	Next

	Return 100
EndFunc

;is asteroid present in overview window tab
Func OCR_CheckAsteroidPresent()
	;Local $overviewActiveAreaHeight = $GLB_overviewWindow[3] - $GLB_ObjectSearch[1]

	Local $x1 = $GLB_ObjectSearch[0]
	Local $y1 = $GLB_ObjectSearch[1]
	Local $x2 = $x1 + 190
	Local $y2 = $y1 + 14

	;MouseMove( $x1 , $y1, 50)
	;MouseMove( $x1 , $y2, 50)
	;MouseMove( $x2 , $y2, 50)
	;MouseMove( $x2 , $y1, 50)

	;look for asteroid
	PixelSearch($x1, $y1, $x2, $y2, $GLB_AsteroidTextColor, 50)
	If Not @error Then
		Local $returnObj[2] = [$x1, $y1]
		Return $returnObj
	EndIf

	PixelSearch($x1, $y1, $x2, $y2, $GLB_AsteroidTextColor2, 50)
	If Not @error Then
		Local $returnObj[2] = [$x1, $y1]
		Return $returnObj
	EndIf

	Return False
EndFunc

;is container present in overview window tab
Func OCR_CheckContainerPresent()
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1]
		Local $x2 = $GLB_ObjectSearch[0]
		Local $y2 = $y1 + $GLB_ObjectSearchIconSize

		;look for container
		PixelSearch($x1, $y1, $x2, $y2, $GLB_ContainerColor, 25)
		If Not @error Then
			Local $returnObj[3] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1]
			;MouseMove( $x1, $y1)
			Return $returnObj
		EndIf
	Next

	Return False
EndFunc

;is pos corp hangar present in overview window tab
Func OCR_CheckCorpHangarPresent()
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x = $GLB_ObjectSearch[0] + $GLB_OverviewCorpHangar[0]
		Local $y = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize) + $GLB_OverviewCorpHangar[1]

		;look for corp hangar
		PixelSearch($x, $y, $x, $y, $GLB_OverviewCorpHangar[2], $GLB_OverviewCorpHangar[3])
		If Not @error Then
			Local $returnObj[3] = [$x - $GLB_OverviewCorpHangar[0], $y + $GLB_ObjectSearchIconSize/2 - $GLB_OverviewCorpHangar[1], $i + 1]
			;MouseMove($x1, $y1)
			Return $returnObj
		EndIf
	Next

	Return False
EndFunc

;is station corp hangar opened
Func OCR_CheckStationCorpHangarOpened()
	Local $x = $GLB_corpHangarWindow[0] + 20
	Local $y = $GLB_corpHangarWindow[1] + 40
	;look for corp hangar
	PixelSearch($x, $y, $x, $y, $GLB_corpHangarWindow[2], 10)
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;is NPC present in overview window tab
Func OCR_CheckNPCPresent($withLock = False, $type = "any", $countOnly = False, $hasFaction = False)
	Local $overviewItemsCapacity = $GLB_overviewContentItems
	Local $allNPC[$overviewItemsCapacity][5]
	Local $smallest = 4, $biggest = 0
	Local $smallestId = -1, $biggestId = -1
	Local $counter = 0
	Local $faction = False

	If $type = "small" Then
		$type = 1
	ElseIf $type = "medium" Then
		$type = 2
	ElseIf $type = "big" Then
		$type = 3
	EndIf

	For $i = 0 To $overviewItemsCapacity - 1 Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)
		Local $x2 = $GLB_ObjectSearch[0]
		Local $y2 = $y1 + $GLB_ObjectSearchIconSize

		;look for NPC
		PixelSearch($x1, $y1, $x2, $y2, $GLB_NPCColor, 10)

		If Not @error Then
			If $countOnly Then
				If $type = "any" Or $type = OCR_detectNPCSize($x1, $y1) Then
					$counter+= 1
				EndIf
				ContinueLoop
			EndIf

			If $hasFaction And OCR_isFaction($x1, $y1) Then
				$faction = True
				ExitLoop
			EndIf

			$allNPC[$i][0] = $x1
			$allNPC[$i][1] = $y1 + $GLB_ObjectSearchIconSize/2
			$allNPC[$i][2] = $i + 1
			$allNPC[$i][3] = OCR_detectNPCSize($x1, $y1)
			If $withLock Then
				$allNPC[$i][4] = OCR_isObjectLocked($x1, $y1)
			Else
				$allNPC[$i][4] = -1
			EndIf

			;MouseMove( $x1, $y1 + $GLB_ObjectSearchIconSize/2)
			If $type = "any" Then
				;check lock data
				If $withLock And Not $allNPC[$i][4] Then
					ContinueLoop
				EndIf
				;BOT_LogMessage("OCR_CheckNPCPresent1: " & $type & " npc - " & $i, 1)
				Local $retObj[5] = [$allNPC[$i][0], $allNPC[$i][1], $allNPC[$i][2], $allNPC[$i][3], $allNPC[$i][4]]
				Return $retObj
			ElseIf $type = $allNPC[$i][3] Then
				;BOT_LogMessage("OCR_CheckNPCPresent2: " & $type & " npc - " & $i, 1)
				Local $retObj[5] = [$allNPC[$i][0], $allNPC[$i][1], $allNPC[$i][2], $allNPC[$i][3], $allNPC[$i][4]]
				Return $retObj
			Else
				If $smallest > $allNPC[$i][3] Then
					$smallest = $allNPC[$i][3]
					$smallestId = $i
				ElseIf $biggest < $allNPC[$i][3] Then
					$biggest = $allNPC[$i][3]
					$biggestId = $i
				EndIf
			EndIf
		EndIf
	Next

	If $type = "smallest" And $smallestId <> -1 Then
		;BOT_LogMessage("OCR_CheckNPCPresent3: " & $type & " npc - " & $smallestId, 1)
		Local $retObj[5] = [$allNPC[$smallestId][0], $allNPC[$smallestId][1], $allNPC[$smallestId][2], $allNPC[$smallestId][3], $allNPC[$smallestId][4]]
		Return $retObj
	ElseIf $type = "biggest" And $biggestId <> -1 Then
		;BOT_LogMessage("OCR_CheckNPCPresent4: " & $type & " npc - " & $biggestId, 1)
		Local $retObj[5] = [$allNPC[$biggestId][0], $allNPC[$biggestId][1], $allNPC[$biggestId][2], $allNPC[$biggestId][3], $allNPC[$biggestId][4]]
		Return $retObj
	EndIf

	If $countOnly Then
		BOT_LogMessage("OCR_CheckNPCPresent5: " & $counter & " npc")
		Return $counter
	ElseIf $hasFaction Then
		BOT_LogMessage("OCR_CheckNPCPresent6: hasFaction = " & $hasFaction)
		Return $faction
	Else
		;BOT_LogMessage("OCR_CheckNPCPresent7: " & $type & " npc not found", 1)
		Return False
	EndIf
EndFunc

;get NPC
Func OCR_GetNPC($type = "any", $nearest = False)
	Local $overviewItemsCapacity = $GLB_overviewContentItems
	Local $allNPC[$overviewItemsCapacity][6]
	Local $smallest = 3, $biggest = 1
	Local $smallestId = -1, $biggestId = -1
	Local $counter = 0

	For $i = 0 To $overviewItemsCapacity - 1 Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)
		Local $x2 = $GLB_ObjectSearch[0]
		Local $y2 = $y1 + $GLB_ObjectSearchIconSize
		Local $color, $colorRange

		If $type <> "tower" Then
			$color = $GLB_NPCColor
			$colorRange = 10
		ElseIf $type = "tower" Then
			$color = $GLB_OverviewNPCTower[2]
			$colorRange = $GLB_OverviewNPCTower[3]
		EndIf

		;look for NPC
		PixelSearch($x1, $y1, $x2, $y2, $color, $colorRange)

		If Not @error Then
			$allNPC[$i][0] = $x1
			$allNPC[$i][1] = $y1 + $GLB_ObjectSearchIconSize/2
			$allNPC[$i][2] = $i + 1
			$allNPC[$i][3] = OCR_detectNPCSize($x1, $y1)
			$allNPC[$i][4] = -1
			If $nearest And (($type = "small" And $allNPC[$i][3] = 1) Or ($type = "medium" And $allNPC[$i][3] = 2) Or ($type = "big" And $allNPC[$i][3] = 3) Or ($type = "tower" And $allNPC[$i][3] = 4)) Then
				$allNPC[$i][5] = Int(EVEOCR_GetOverviewObjectDistance($i + 1))
			Else
				$allNPC[$i][5] = 0
			EndIf
		EndIf

		;BOT_LogMessage("OCR_GetNPC: i=" & $i & ", size=" & $allNPC[$i][3], 1)
	Next

	Local $NPC[6] = [-1, -1, -1, 3, -1, 100000]

	; find needed NPC
	For $i = 0 To UBound($allNPC) - 1 Step 1
		If (($type = "small" And $allNPC[$i][3] = 1) Or ($type = "medium" And $allNPC[$i][3] = 2) Or ($type = "big" And $allNPC[$i][3] = 3) Or ($type = "tower" And $allNPC[$i][3] = 4) Or ($type = "smallest" And $allNPC[$i][3] <= $NPC[3]) Or ($type = "biggest" And $allNPC[$i][3] >= $NPC[3])) And $allNPC[$i][5] < $NPC[5] Then
			$NPC[0] = $allNPC[$i][0]
			$NPC[1] = $allNPC[$i][1]
			$NPC[2] = $allNPC[$i][2]
			$NPC[3] = $allNPC[$i][3]
			$NPC[4] = $allNPC[$i][4]
			$NPC[5] = $allNPC[$i][5]
		EndIf
	Next

	If $NPC[0] <> -1 Then
		Return $NPC
	Else
		Return False
	EndIf
EndFunc

;detect NPC size
Func OCR_detectNPCSize($x, $y)
	Local $x_check, $y_check
	$x_check = $x + $GLB_OverviewNPCBig[0]
	$y_check = $y + $GLB_OverviewNPCBig[1]
	PixelSearch($x_check , $y_check, $x_check, $y_check, $GLB_NPCColor, 10)
	If Not @error Then
		;BOT_LogMessage("OCR_detectNPCSize: big ["&$x&":"&$y&"]", 1)
		Return 3
	EndIf

	$x_check = $x + $GLB_OverviewNPCMedium[0]
	$y_check = $y + $GLB_OverviewNPCMedium[1]
	PixelSearch($x_check , $y_check, $x_check, $y_check, $GLB_NPCColor, 10)
	If Not @error Then
		;BOT_LogMessage("OCR_detectNPCSize: medium ["&$x&":"&$y&"]", 1)
		Return 2
	EndIf

	$x_check = $x + $GLB_OverviewNPCSmall[0]
	$y_check = $y + $GLB_OverviewNPCSmall[1]
	PixelSearch($x_check , $y_check, $x_check, $y_check, $GLB_NPCColor, 10)
	If Not @error Then
		;BOT_LogMessage("OCR_detectNPCSize: small ["&$x&":"&$y&"]", 1)
		Return 1
	EndIf

	$x_check = $x + $GLB_OverviewNPCTower[0]
	$y_check = $y + $GLB_OverviewNPCTower[1]
	PixelSearch($x_check , $y_check, $x_check, $y_check, $GLB_OverviewNPCTower[2], $GLB_OverviewNPCTower[3])
	If Not @error Then
		;BOT_LogMessage("OCR_detectNPCSize: tower ["&$x&":"&$y&"]", 1)
		Return 4
	EndIf

	;BOT_LogMessage("OCR_detectNPCSize: unknown NPC type ["&$x&":"&$y&"]", 1)
EndFunc

;is object locked in overview
;wrecks and asteroids only
Func OCR_isObjectLocked($x, $y)
	;lock data
	Local $x1 = $x + $GLB_OverviewObjectLocked[0]
	Local $y1 = $y + $GLB_OverviewObjectLocked[1]
	PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewObjectLocked[4], $GLB_OverviewObjectLocked[7])
	If Not @error Then
		$x1 = $x + $GLB_OverviewObjectLocked[2]
		$y1 = $y + $GLB_OverviewObjectLocked[3]
		PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewObjectLocked[4], $GLB_OverviewObjectLocked[7])
		If Not @error Then
			;BOT_LogMessage("OCR_isObjectLocked: general lock found["&$x1&":"&$y1&"]", 1)
			Return True
		EndIf
	EndIf

	$x1 = $x + $GLB_OverviewObjectLocked[0]
	$y1 = $y + $GLB_OverviewObjectLocked[1]
	PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewObjectLocked[5], $GLB_OverviewObjectLocked[7])
	If Not @error Then
		$x1 = $x + $GLB_OverviewObjectLocked[2]
		$y1 = $y + $GLB_OverviewObjectLocked[3]
		PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewObjectLocked[5], $GLB_OverviewObjectLocked[7])
		If Not @error Then
			;BOT_LogMessage("OCR_isObjectLocked: deselected lock found["&$x1&":"&$y1&"]", 1)
			Return True
		EndIf
	EndIf

	$x1 = $x + $GLB_OverviewObjectLocked[0]
	$y1 = $y + $GLB_OverviewObjectLocked[1]
	PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewObjectLocked[6], $GLB_OverviewObjectLocked[7])
	If Not @error Then
		$x1 = $x + $GLB_OverviewObjectLocked[2]
		$y1 = $y + $GLB_OverviewObjectLocked[3]
		PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewObjectLocked[6], $GLB_OverviewObjectLocked[7])
		If Not @error Then
			;BOT_LogMessage("OCR_isObjectLocked: selected lock found["&$x1&":"&$y1&"]", 1)
			Return True
		EndIf
	EndIf

	;BOT_LogMessage("OCR_isObjectLocked: lock not found["&$x1&":"&$y1&"]", 1)
	Return False
EndFunc

;is object locked in overview
;wrecks and asteroids only
Func OCR_countLockedObjects()
	Local $amount = 0
	;Local $overviewActiveAreaHeight = $GLB_overviewWindow[3] - $GLB_ObjectSearch[1]
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)

		If OCR_isObjectLocked($x1, $y1) Then
			$amount+= 1
		EndIf
	Next
	Return $amount
EndFunc

;is wreck present in overview window tab
Func OCR_CheckWreckPresent($items = False, $type = "any", $isFaction = False)
	;Local $overviewActiveAreaHeight = $GLB_overviewWindow[3] - $GLB_ObjectSearch[1]
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	If $items <> False Then
		$overviewItemsCapacity = $items
	EndIf

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize) + 9

		;look for own Wreck
		If $type = "any" Or $type = "own" Then
			PixelSearch($x1, $y1, $x1, $y1, $GLB_OwnWreckColor, 25)
			If Not @error And (Not $isFaction Or OCR_isFaction($x1, $y1 - 9)) Then
				Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "own"]
				BOT_LogMessage("Own wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				Return $returnObj
			EndIf
		EndIf

		;look for used Wreck
		If $type = "any" Or $type = "used" Then
			PixelSearch($x1, $y1, $x1, $y1, $GLB_UsedWreckColor, 25)
			If Not @error And (Not $isFaction Or OCR_isFaction($x1, $y1 - 9)) Then
				PixelSearch($x1, $y1 + 1, $x1, $y1 + 1, $GLB_UsedWreckColor, 5)
				If Not @error Then
					Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "used"]
					BOT_LogMessage("Used wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				Else
					Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "empty.used"]
					BOT_LogMessage("Empty used wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				EndIf

				Return $returnObj
			EndIf
		EndIf

		;look for shared Wreck
		If $type = "any" Or $type = "shared" Then
			PixelSearch($x1, $y1, $x1, $y1, $GLB_SharedWreckColor, 25)
			If Not @error  And (Not $isFaction Or OCR_isFaction($x1, $y1 - 9)) Then
				Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "shared"]
				BOT_LogMessage("Shared wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				Return $returnObj
			EndIf
		EndIf

		;look for used shared Wreck
		If $type = "any" Or $type = "ushared" Then
			PixelSearch($x1, $y1, $x1, $y1, $GLB_SharedUsedWreckColor, 25)
			If Not @error And (Not $isFaction Or OCR_isFaction($x1, $y1 - 9)) Then
				PixelSearch($x1, $y1 + 1, $x1, $y1 + 1, $GLB_SharedUsedWreckColor, 5)
				If Not @error Then
					Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "ushared"]
					BOT_LogMessage("Shared used wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				Else
					Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "empty.ushared"]
					BOT_LogMessage("Empty shared used wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				EndIf

				;Local $returnObj[4] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1, "ushared"]
				;BOT_LogMessage("Shared used wreck: " & Hex(PixelGetColor($x1, $y1),6) & "["&$x1&":"&$y1&"]")
				Return $returnObj
			EndIf
		EndIf
	Next
	Return False
EndFunc

;is faction
Func OCR_isFaction($x, $y)
	Local $color
	Local $NPCtype = GUICtrlRead($GUI_factionType[$GLB_curBot])
	Local $pixelColor
	Local $pixelColorRange

	If $NPCtype = "Angels" Then
		$x+= $GLB_OverviewDomination[0]
		$y+= $GLB_OverviewDomination[1]
		$pixelColor = $GLB_OverviewDomination[2]
		$pixelColorRange = $GLB_OverviewDomination[3]
	ElseIf $NPCtype = "Drones" Then
		$x+= $GLB_OverviewSentient[0]
		$y+= $GLB_OverviewSentient[1]
		$pixelColor = $GLB_OverviewSentient[2]
		$pixelColorRange = $GLB_OverviewSentient[3]
	ElseIf $NPCtype = "Guristas" Then
		$x+= $GLB_OverviewDread[0]
		$y+= $GLB_OverviewDread[1]
		$pixelColor = $GLB_OverviewDread[2]
		$pixelColorRange = $GLB_OverviewDread[3]
	ElseIf $NPCtype = "Serpentis" Then
		$x+= $GLB_OverviewShadow[0]
		$y+= $GLB_OverviewShadow[1]
		$pixelColor = $GLB_OverviewShadow[2]
		$pixelColorRange = $GLB_OverviewShadow[3]
	EndIf

	$color = Hex(PixelGetColor($x, $y),6)
	PixelSearch($x, $y, $x, $y, $pixelColor, $pixelColorRange)
	If Not @error Then
		;MouseMove( $x, $y + $GLB_ObjectSearchIconSize/2)
		BOT_LogMessage("OCR_isFaction: faction["&$x&":"&$y&"]-" & $color, 1)
		Return true
	EndIf

	;BOT_LogMessage("OCR_isFaction: not faction["&$x&":"&$y&"]-" & $color, 1)
	Return False
EndFunc

;is drone present in overview window tab
Func OCR_CheckDronePresent()
	;Local $overviewActiveAreaHeight = $GLB_overviewWindow[3] - $GLB_ObjectSearch[1]
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)
		Local $x2 = $GLB_ObjectSearch[0]
		Local $y2 = $y1 + $GLB_ObjectSearchIconSize

		;look for own drone
		PixelSearch($x1, $y1, $x2, $y2, $GLB_DronColor[0], $GLB_DronColor[1])
		If Not @error Then
			Local $returnObj[3] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2]
			;MouseMove( $x1, $y1 + $GLB_ObjectSearchIconSize/2)
			Return $returnObj
		EndIf
	Next
	Return False
EndFunc

;is destination object present in overview window tab
Func OCR_CheckDestinationPresent()
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0] + $GLB_OverviewDestination[0]
		Local $y1 = $GLB_ObjectSearch[1] + $GLB_OverviewDestination[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)
		;Local $x2 = $GLB_ObjectSearch[0]
		;Local $y2 = $y1 + $GLB_ObjectSearchIconSize

		;BOT_LogMessage("OCR_CheckDestinationPresent: " & $i & " - [" & $x1 & ":" & $y1 & "," & Hex(PixelGetColor($x1, $y1),6) & "]", 1)

		;look for destination
		PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewDestination[2], $GLB_OverviewDestination[3])
		If Not @error Then
			Local $returnObj[3] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1]
			;MouseMove( $x1, $y1 + $GLB_ObjectSearchIconSize/2)
			Return $returnObj
		EndIf
	Next
	Return False
EndFunc

;is gate object present in overview window tab
Func OCR_CheckGatePresent($position = "all")
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		If $position = "all" Or $position = ($i+1) Then
			Local $x1 = $GLB_ObjectSearch[0] + $GLB_OverviewGate[0]
			Local $y1 = $GLB_ObjectSearch[1] + $GLB_OverviewGate[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)

			;BOT_LogMessage("OCR_CheckGatePresent: " & $i & " - [" & $x1 & ":" & $y1 & "," & Hex(PixelGetColor($x1, $y1),6) & "]", 1)

			;look for destination
			PixelSearch($x1, $y1, $x1, $y1, $GLB_OverviewGate[2], $GLB_OverviewGate[3])
			If Not @error Then
				Local $returnObj[3] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1]
				;MouseMove( $x1, $y1 + $GLB_ObjectSearchIconSize/2)
				Return $returnObj
			EndIf
		EndIf
	Next
	Return False
EndFunc

;is fleet orca present in overview window tab
Func OCR_CheckFleetOrcaPresent()
	;Local $overviewActiveAreaHeight = $GLB_overviewWindow[3] - $GLB_ObjectSearch[1]
	Local $overviewItemsCapacity = $GLB_overviewContentItems

	For $i = 0 To $overviewItemsCapacity Step 1
		Local $x1 = $GLB_ObjectSearch[0]
		Local $y1 = $GLB_ObjectSearch[1] + $i*($GLB_ObjectSearchIconSize+$GLB_ObjectSearchDividerSize)
		Local $x2 = $GLB_ObjectSearch[0]
		Local $y2 = $y1 + $GLB_ObjectSearchIconSize

		;MouseMove($x1, $y1)
		;look for fleet ship
		PixelSearch($x1, $y1, $x2, $y2, $GLB_FleetColor[0], $GLB_FleetColor[1])
		If Not @error Then
			Local $returnObj[3] = [$x1, $y1 + $GLB_ObjectSearchIconSize/2, $i + 1]
			Return $returnObj
		EndIf
	Next
	Return False
EndFunc

;neen password input
Func OCR_ContainerNeedPassword()
	PixelSearch($GLB_ContainerLoginPixel[0], $GLB_ContainerLoginPixel[1], $GLB_ContainerLoginPixel[0], $GLB_ContainerLoginPixel[1], $GLB_ContainerLoginPixel[2], $GLB_ContainerLoginPixel[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;check warp
Func OCR_WrapIsActive($times = 2)
	Local $active

	For $w = 0 To $times - 1 Step 1
		$active = True
;BOT_LogMessage("OCR_WrapIsActive: 1 - " & Hex(PixelGetColor($GLB_warpState1[0], $GLB_warpState1[1]),6), 1)
		PixelSearch($GLB_warpState1[0], $GLB_warpState1[1], $GLB_warpState1[0], $GLB_warpState1[1], $GLB_warpState1[2], $GLB_warpState1[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
;BOT_LogMessage("OCR_WrapIsActive: 2 - " & Hex(PixelGetColor($GLB_warpState2[0], $GLB_warpState2[1]),6), 1)
		PixelSearch($GLB_warpState2[0], $GLB_warpState2[1], $GLB_warpState2[0], $GLB_warpState2[1], $GLB_warpState2[2], $GLB_warpState2[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
;BOT_LogMessage("OCR_WrapIsActive: 3 - " & Hex(PixelGetColor($GLB_warpState3[0], $GLB_warpState3[1]),6), 1)
		PixelSearch($GLB_warpState3[0], $GLB_warpState3[1], $GLB_warpState3[0], $GLB_warpState3[1], $GLB_warpState3[2], $GLB_warpState3[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		#cs
		PixelSearch($GLB_warpState4[0], $GLB_warpState4[1], $GLB_warpState4[0], $GLB_warpState4[1], $GLB_warpState4[2], $GLB_warpState4[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		PixelSearch($GLB_warpState5[0], $GLB_warpState5[1], $GLB_warpState5[0], $GLB_warpState5[1], $GLB_warpState5[2], $GLB_warpState5[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		#ce
	Next

	Return $active
EndFunc

;check jumping
Func OCR_JumpIsActive($times = 2)
	Local $active

	For $w = 0 To $times - 1 Step 1
		$active = True

		PixelSearch($GLB_jumpState1[0], $GLB_jumpState1[1], $GLB_jumpState1[0], $GLB_jumpState1[1], $GLB_jumpState1[2], $GLB_jumpState1[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		PixelSearch($GLB_jumpState2[0], $GLB_jumpState2[1], $GLB_jumpState2[0], $GLB_jumpState2[1], $GLB_jumpState2[2], $GLB_jumpState2[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		PixelSearch($GLB_jumpState3[0], $GLB_jumpState3[1], $GLB_jumpState3[0], $GLB_jumpState3[1], $GLB_jumpState3[2], $GLB_jumpState3[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
	Next

	Return $active
EndFunc

;check jumping initialization
Func OCR_DockJumpActivateGateIsActive($times = 2)
	Local $active

	For $w = 0 To $times - 1 Step 1
		$active = True

		PixelSearch($GLB_dockjumpactivateState1[0], $GLB_dockjumpactivateState1[1], $GLB_dockjumpactivateState1[0], $GLB_dockjumpactivateState1[1], $GLB_dockjumpactivateState1[2], $GLB_dockjumpactivateState1[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		PixelSearch($GLB_dockjumpactivateState2[0], $GLB_dockjumpactivateState2[1], $GLB_dockjumpactivateState2[0], $GLB_dockjumpactivateState2[1], $GLB_dockjumpactivateState2[2], $GLB_dockjumpactivateState2[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
		PixelSearch($GLB_dockjumpactivateState3[0], $GLB_dockjumpactivateState3[1], $GLB_dockjumpactivateState3[0], $GLB_dockjumpactivateState3[1], $GLB_dockjumpactivateState3[2], $GLB_dockjumpactivateState3[3])
		If @error Then
			$active = False
			ContinueLoop
		EndIf
	Next

	Return $active
EndFunc


;check engine state
Func OCR_EngineIsActive()
	PixelSearch($GLB_engineActive[0], $GLB_engineActive[1], $GLB_engineActive[0], $GLB_engineActive[1], $GLB_engineActive[2], $GLB_engineActive[3])
	If @error Then
		Return False
	EndIf

	Return True
EndFunc

;check PNP item type
Func OCR_getPNPItemType($number = 1)
	Local $x = $GLB_PAP_placesArea[0] + 50
	Local $y = $GLB_PAP_placesArea[1] + ($GLB_PAPItemSize + $GLB_PAPDividerSize)*($number - 1)
	Local $x2 = $x + 100
	Local $y2 = $y + $GLB_PAPItemSize

	;BOT_LogMessage("OCR_getPNPItemType: " & $number & " - [" & $x & ":" & $y & "," & $x2 & ":" & $y2 & "]", 1)

	Local $c = PixelSearch($x, $y, $x2, $y2, $GLB_PAPcurrentSysColor[0], $GLB_PAPcurrentSysColor[1])
	If Not @error Then
		;BOT_LogMessage("OCR_getPNPItemType: " & $number & " - [" & $c[0] & ":" & $c[1] & "," & Hex(PixelGetColor($c[0], $c[1]),6) & "]", 1)
		Return "current"
	Else
		Local $d = PixelSearch($x, $y, $x2, $y2, $GLB_PAPdestinationSysColor[0], $GLB_PAPdestinationSysColor[1])
		If Not @error Then
			;BOT_LogMessage("OCR_getPNPItemType: " & $number & " - [" & $d[0] & ":" & $d[1] & "," & Hex(PixelGetColor($d[0], $d[1]),6) & "]", 1)
			Return "destination"
		Else
			Return "unknown"
		EndIf
	EndIf
EndFunc

;check high slot by number
Func OCR_isActiveHighSlot($number = 1)
	Local $x = $GLB_activeHighSlot_Item1[0] + $GLB_slot_ItemShift*($number - 1)
	Local $y = $GLB_activeHighSlot_Item1[1]
	Local $color = $GLB_activeHighSlot_Item1[2]
	Local $colorRange = $GLB_activeHighSlot_Item1[3]

	Local $colorGet = Hex(PixelGetColor($x, $y), 6)
	BOT_LogMessage("OCR_isActiveHighSlot1:"&$number&" - ["&$x&":"&$y&"], "&$colorGet)

	PixelSearch($x, $y, $x, $y, $color, $colorRange)
	If Not @error Then
		Return True
	Else
		;$colorGet = Hex(PixelGetColor($x, $y), 6)
		;BOT_LogMessage("OCR_isActiveHighSlot2:"&$number&" - ["&$x&":"&$y&"], "&$colorGet)
		; check twice for shure
		PixelSearch($x, $y, $x, $y, $color, $colorRange)
		If Not @error Then
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc

;check middle slot by number
Func OCR_isActiveMiddleSlot($number = 1)
	Local $x = $GLB_activeShield_Item1[0] + $GLB_slot_ItemShift*($number - 1)
	Local $y = $GLB_activeShield_Item1[1]

	PixelSearch($x, $y, $x, $y, $GLB_activeShield_Item1[2], $GLB_activeShield_Item1[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;check low slot by number
Func OCR_isActiveLowSlot($number = 1)
	Local $x = $GLB_activeLowSlot1[0] + $GLB_slot_ItemShift*($number - 1)
	Local $y = $GLB_activeLowSlot1[1]

	PixelSearch($x, $y, $x, $y, $GLB_activeLowSlot1[2], $GLB_activeLowSlot1[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;count active miners
Func OCR_CountActiveMiners()
	Local $active = 0
	For $i = 0 To GUI_GetBotMinersAmount() - 1 Step 1
		Local $x = $GLB_activeHighSlot_Item1[0] + $GLB_slot_ItemShift*($i - 1)
		Local $y = $GLB_activeHighSlot_Item1[1]

		PixelSearch($x, $y, $x, $y, $GLB_activeHighSlot_Item1[2], $GLB_activeHighSlot_Item1[3])
		If Not @error Then
			$active+= 1
		EndIf

		;BOT_LogMessage("OCR_CountActiveMiners: i="&$i&",active="&$active)
	Next

	Return $active
EndFunc

;depricate
;check shield by number
Func OCR_CheckShield()
	Local $x = $GLB_activeShield_Item1[0]
	Local $y = $GLB_activeShield_Item1[1]

	PixelSearch($x, $y, $x, $y, $GLB_activeShield_Item1[2], $GLB_activeShield_Item1[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;check if shooting active for Gun
;depricated
#cs
Func OCR_CheckGun()
	PixelSearch($GLB_activeShooting1[0], $GLB_activeShooting1[1], $GLB_activeShooting1[0], $GLB_activeShooting1[1], $GLB_activeShooting1[2], $GLB_activeShooting1[3])
	If Not @error Then
		PixelSearch($GLB_activeShooting2[0], $GLB_activeShooting2[1], $GLB_activeShooting2[0], $GLB_activeShooting2[1], $GLB_activeShooting2[2], $GLB_activeShooting2[3])
		If Not @error Then
			Return True
		Else
			BOT_LogMessage("Shooting not active", 1)
			Return False
		EndIf
	Else
		BOT_LogMessage("Shooting not active", 1)
		Return False
	EndIf
EndFunc
#ce

;check ammo loaded
Func OCR_AmmoLoaded($slot = 1)
	Local $x = $GLB_activeHighSlot_Item1[0] + ($GLB_slot_ItemShift*($slot - 1)) + $GLB_ammoLoadedShift[0]
	Local $y = $GLB_activeHighSlot_Item1[1] + $GLB_ammoLoadedShift[1]

	PixelSearch($x, $y, $x, $y, $GLB_ammoLoadedShift[2], $GLB_ammoLoadedShift[3])
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;check shield damage
Func OCR_DetectShieldDamage()
	For $s = 19 To 0 Step -1
		PixelSearch($GLB_shieldIndicator[$s][0], $GLB_shieldIndicator[$s][1], $GLB_shieldIndicator[$s][0], $GLB_shieldIndicator[$s][1], $GLB_damageColor, $GLB_damageColorRange)
		If @error Then
			Return ($s + 1)*5
		EndIf
	Next

	Return 0
EndFunc

;check armor damage
Func OCR_DetectArmorDamage()
	PixelSearch($GLB_armorIndicator[0], $GLB_armorIndicator[1], $GLB_armorIndicator[0], $GLB_armorIndicator[1], $GLB_damageColor, $GLB_damageColorRange)
	If Not @error Then
		Return True
	EndIf
	Return False
EndFunc


;is shield active
;depricated
#cs
Func OCR_isShieldActive()
	;For $s = 10 To 0 Step -1
		PixelSearch($GLB_shieldActiveIndicator[0][0], $GLB_shieldActiveIndicator[0][1], $GLB_shieldActiveIndicator[0][0], $GLB_shieldActiveIndicator[0][1], $GLN_shieldActiveColor, $GLN_shieldActiveRange)
		If Not @error Then
			Return True
		EndIf
	;Next

	Return False
EndFunc
#ce

;detect active tab pixel
Func OCR_DetectActiveTabPixel($x, $y, $color, $dColor)
	PixelSearch($x, $y, $x, $y, $color, $dColor)
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;detect login pixels
Func OCR_DetectLogin()
	PixelSearch($GLB_login_pixel1[0], $GLB_login_pixel1[1], $GLB_login_pixel1[0], $GLB_login_pixel1[1], $GLB_login_pixel1[2], $GLB_login_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_login_pixel2[0], $GLB_login_pixel2[1], $GLB_login_pixel2[0], $GLB_login_pixel2[1], $GLB_login_pixel2[2], $GLB_login_pixel2[3])
		If Not @error Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunc

;detect login error pixels
Func OCR_DetectLoginError()
	PixelSearch($GLB_loginError_pixel1[0], $GLB_loginError_pixel1[1], $GLB_loginError_pixel1[2], $GLB_loginError_pixel1[3], $GLB_loginError_pixel1[4], $GLB_loginError_pixel1[5])
	If Not @error Then
		PixelSearch($GLB_loginError_pixel2[0], $GLB_loginError_pixel2[1], $GLB_loginError_pixel2[2], $GLB_loginError_pixel2[3], $GLB_loginError_pixel2[4], $GLB_loginError_pixel2[5])
		If Not @error Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunc

;detect info pixels
;depricated, used only in location fix
Func OCR_DetectInfo()
	Local $color = Hex(PixelGetColor($GLB_info_pixel1[0], $GLB_info_pixel1[1]),6)
	PixelSearch($GLB_info_pixel1[0], $GLB_info_pixel1[1], $GLB_info_pixel1[2], $GLB_info_pixel1[3], $GLB_info_pixel1[4], $GLB_info_pixel1[5])
	If Not @error Then
		BOT_LogMessage("OCR_DetectInfo: 1", 1)
		PixelSearch($GLB_info_pixel2[0], $GLB_info_pixel2[1], $GLB_info_pixel2[2], $GLB_info_pixel2[3], $GLB_info_pixel2[4], $GLB_info_pixel2[5])
		If Not @error Then
			BOT_LogMessage("OCR_DetectInfo: 2", 1)
			PixelSearch($GLB_info_pixel3[0], $GLB_info_pixel3[1], $GLB_info_pixel3[2], $GLB_info_pixel3[3], $GLB_info_pixel3[4], $GLB_info_pixel3[5])
			If Not @error Then
				BOT_LogMessage("OCR_DetectInfo: 3", 1)
				PixelSearch($GLB_info_pixel4[0], $GLB_info_pixel4[1], $GLB_info_pixel4[2], $GLB_info_pixel4[3], $GLB_info_pixel4[4], $GLB_info_pixel4[5])
				If Not @error Then
					BOT_LogMessage("OCR_DetectInfo: 4", 1)
					Return True
				EndIf
			EndIf
		EndIf
	Else
		BOT_LogMessage("OCR_DetectInfo: no info, color = " & $color, 1)
	EndIf
	Return False
EndFunc

;detect inventory window
Func OCR_DetectInventoryWindow()
	Local $detector = 0
	Local $pix1[4], $pix2[4]
	$pix1 = $GLB_inventoryWindowDetect1
	$pix2 = $GLB_inventoryWindowDetect2

	PixelSearch($pix1[0], $pix1[1], $pix1[0], $pix1[1], $pix1[2], $pix1[3])
	If Not @error Then
		$detector+= 1
		;BOT_LogMessage("OCR_DetectInventoryWindow: 1", 1)
	EndIf
	PixelSearch($pix2[0], $pix2[1], $pix2[0], $pix2[1], $pix2[2], $pix2[3])
	If Not @error Then
		$detector+= 1
		;BOT_LogMessage("OCR_DetectInventoryWindow: 2", 1)
	EndIf

	;BOT_LogMessage("OCR_DetectInventoryWindow: det=" & $detector & ", place=" & $place, 1)

	If $detector > 1 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

; not used in Retribution 1.0.5
#cs
;detect inventory window
Func OCR_DetectInventoryFilters()
	Local $pix = $GLB_inventoryWindow_filtersIndicator

	PixelSearch($pix[0], $pix[1], $pix[0], $pix[1], $pix[2], $pix[3])

	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;detect inventory window version 2
Func OCR_DetectInventoryFilters2()
	Local $pix = $GLB_inventoryWindow_filtersIndicator2

	PixelSearch($pix[0], $pix[1], $pix[0], $pix[1], $pix[2], $pix[3])

	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc
#ce

;detect container window
; depricated
Func OCR_DetectContainerWindow()
	Local $detector = 0
	PixelSearch($GLB_containerDetect1[0], $GLB_containerDetect1[1], $GLB_containerDetect1[0], $GLB_containerDetect1[1], $GLB_containerDetect1[2], $GLB_containerDetect1[3])
	If Not @error Then
		$detector+= 1
	EndIf
	PixelSearch($GLB_containerDetect2[0], $GLB_containerDetect2[1], $GLB_containerDetect2[0], $GLB_containerDetect2[1], $GLB_containerDetect2[2], $GLB_containerDetect2[3])
	If Not @error Then
		$detector+= 1
	EndIf

	If $detector = 2 Then
		;BOT_LogMessage("Container window opened", 1)
		Return True
	Else
		BOT_LogMessage("Container window not opened", 1)
		Return False
	EndIf
EndFunc

;detect ship corp hangar window
; depricated
Func OCR_DetectShipCorpHangarWindow()
	Local $detector = 0
	PixelSearch($GLB_SCHW_Detect1[0], $GLB_SCHW_Detect1[1], $GLB_SCHW_Detect1[0], $GLB_SCHW_Detect1[1], $GLB_SCHW_Detect1[2], $GLB_SCHW_Detect1[3])
	If Not @error Then
		$detector+= 1
	EndIf
	PixelSearch($GLB_SCHW_Detect2[0], $GLB_SCHW_Detect2[1], $GLB_SCHW_Detect2[0], $GLB_SCHW_Detect2[1], $GLB_SCHW_Detect2[2], $GLB_SCHW_Detect2[3])
	If Not @error Then
		$detector+= 1
	EndIf

	If $detector = 2 Then
		;BOT_LogMessage("Ship corp hangar window opened", 1)
		Return True
	Else
		BOT_LogMessage("Ship corp hangar window not opened", 1)
		Return False
	EndIf
EndFunc

;detect fleet comm corp hangar window
; depricated
Func OCR_DetectFleetCommCorpHangarWindow()
	Local $detector = 0
	PixelSearch($GLB_FCCHW_Detect1[0], $GLB_FCCHW_Detect1[1], $GLB_FCCHW_Detect1[0], $GLB_FCCHW_Detect1[1], $GLB_FCCHW_Detect1[2], $GLB_FCCHW_Detect1[3])
	If Not @error Then
		$detector+= 1
	EndIf
	PixelSearch($GLB_FCCHW_Detect2[0], $GLB_FCCHW_Detect2[1], $GLB_FCCHW_Detect2[0], $GLB_FCCHW_Detect2[1], $GLB_FCCHW_Detect2[2], $GLB_FCCHW_Detect2[3])
	If Not @error Then
		$detector+= 1
	EndIf

	If $detector = 2 Then
		;BOT_LogMessage("Fleet comm corp hangar window opened", 1)
		Return True
	Else
		BOT_LogMessage("Fleet comm corp hangar window not opened", 1)
		Return False
	EndIf
EndFunc

;detect fleet comm ore window
; depricated
Func OCR_DetectFleetCommOreWindow()
	Local $detector = 0
	PixelSearch($GLB_OHW_Detect1[0], $GLB_OHW_Detect1[1], $GLB_OHW_Detect1[0], $GLB_OHW_Detect1[1], $GLB_OHW_Detect1[2], $GLB_OHW_Detect1[3])
	If Not @error Then
		$detector+= 1
	EndIf
	PixelSearch($GLB_OHW_Detect2[0], $GLB_OHW_Detect2[1], $GLB_OHW_Detect2[0], $GLB_OHW_Detect2[1], $GLB_OHW_Detect2[2], $GLB_OHW_Detect2[3])
	If Not @error Then
		$detector+= 1
	EndIf

	If $detector = 2 Then
		;BOT_LogMessage("Fleet comm ore hold window opened", 1)
		Return True
	Else
		BOT_LogMessage("Fleet comm ore hold window not opened", 1)
		Return False
	EndIf
EndFunc


;detect asteroid unlock
Func OCR_IsAsteroidUnlockPresent()
	PixelSearch($GLB_SI_asteroidUnlock[0], $GLB_SI_asteroidUnlock[1], $GLB_SI_asteroidUnlock[2], $GLB_SI_asteroidUnlock[3], $GLB_SI_asteroidUnlock[4], $GLB_SI_asteroidUnlock[5])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;detect container unlock
Func OCR_IsContainerUnlockPresent()
	PixelSearch($GLB_SI_containerUnlock[0], $GLB_SI_containerUnlock[1], $GLB_SI_containerUnlock[0], $GLB_SI_containerUnlock[1], $GLB_SI_containerUnlock[2], $GLB_SI_containerUnlock[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;detect extended wreck unlock
Func OCR_IsWreckExtendedUnlockPresent()
	PixelSearch($GLB_SI_wreckExtendedUnlock[0], $GLB_SI_wreckExtendedUnlock[1], $GLB_SI_wreckExtendedUnlock[0], $GLB_SI_wreckExtendedUnlock[1], $GLB_SI_wreckExtendedUnlock[2], $GLB_SI_wreckExtendedUnlock[3])
	If Not @error Then
		;BOT_LogMessage("OCR_IsWreckExtendedUnlockPresent: found, " & Hex(PixelGetColor($GLB_SI_wreckExtendedUnlock[0], $GLB_SI_wreckExtendedUnlock[1]),6) & "["&$GLB_SI_wreckExtendedUnlock[0]&":"&$GLB_SI_wreckExtendedUnlock[1]&"]", 1)
		Return True
	Else
		;BOT_LogMessage("OCR_IsWreckExtendedUnlockPresent: not found, " & Hex(PixelGetColor($GLB_SI_wreckExtendedUnlock[0], $GLB_SI_wreckExtendedUnlock[1]),6) & "["&$GLB_SI_wreckExtendedUnlock[0]&":"&$GLB_SI_wreckExtendedUnlock[1]&"]", 1)
		Return False
	EndIf
EndFunc

;detect wreck lock1
Func OCR_IsWreckLock1Present()
	PixelSearch($GLB_wreckInLock1[0], $GLB_wreckInLock1[1], $GLB_wreckInLock1[0], $GLB_wreckInLock1[1], $GLB_wreckInLock1[2], $GLB_wreckInLock1[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc

;detect fleet commander lock1
Func OCR_IsFleetCommLock1Present()
	PixelSearch($GLB_fleetCommInLock1[0], $GLB_fleetCommInLock1[1], $GLB_fleetCommInLock1[0], $GLB_fleetCommInLock1[1], $GLB_fleetCommInLock1[2], $GLB_fleetCommInLock1[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc


;detect container lock1
Func OCR_IsContainerLock1Present()
	PixelSearch($GLB_wreckInLock1[0], $GLB_wreckInLock1[1], $GLB_wreckInLock1[0], $GLB_wreckInLock1[1], $GLB_wreckInLock1[2], $GLB_wreckInLock1[3])
	If Not @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc


;detect right click menu
Func OCR_DetectRightClickMenu($x, $y)
	;PixelSearch($x + $GLB_menu_rightClick[0], $y + $GLB_menu_rightClick[1], $x + $GLB_menu_rightClick[0], $y + $GLB_menu_rightClick[1], $GLB_menu_rightClick[4], $GLB_menu_rightClick[5])
	;If Not @error Then
		PixelSearch($x + $GLB_menu_rightClick[2], $GLB_menu_rightClick[3], $x + $GLB_menu_rightClick[2], $y + $GLB_menu_rightClick[3], $GLB_menu_rightClick[4], $GLB_menu_rightClick[5])
		If Not @error Then
			Return True
		EndIf
	;EndIf

	Return False
EndFunc

;detect info window pixels
Func OCR_DetectInfoWindow()
	PixelSearch($GLB_errorWindow_pixel1[0], $GLB_errorWindow_pixel1[1], $GLB_errorWindow_pixel1[0], $GLB_errorWindow_pixel1[0], $GLB_errorWindow_pixel1[2], $GLB_errorWindow_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_errorWindow_pixel2[0], $GLB_errorWindow_pixel2[1], $GLB_errorWindow_pixel2[0], $GLB_errorWindow_pixel2[1], $GLB_errorWindow_pixel2[2], $GLB_errorWindow_pixel2[3])
		If Not @error Then
			Return True
		EndIf
	EndIf

	Return False
EndFunc

;detect connection lost window pixels
Func OCR_DetectConnectioLostWindow()
	PixelSearch($GLB_shutdownWindow_pixel1[0], $GLB_shutdownWindow_pixel1[1], $GLB_shutdownWindow_pixel1[0], $GLB_shutdownWindow_pixel1[0], $GLB_shutdownWindow_pixel1[2], $GLB_shutdownWindow_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_shutdownWindow_pixel2[0], $GLB_shutdownWindow_pixel2[1], $GLB_shutdownWindow_pixel2[0], $GLB_shutdownWindow_pixel2[1], $GLB_shutdownWindow_pixel2[2], $GLB_shutdownWindow_pixel2[3])
		If Not @error Then
			Return True
		EndIf
	EndIf

	Return False
EndFunc

;detect join fleet window pixels
Func OCR_DetectJoinFleetWindow()
	PixelSearch($GLB_joinFleetWindow_pixel1[0], $GLB_joinFleetWindow_pixel1[1], $GLB_joinFleetWindow_pixel1[0], $GLB_joinFleetWindow_pixel1[1], $GLB_joinFleetWindow_pixel1[2], $GLB_joinFleetWindow_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_joinFleetWindow_pixel2[0], $GLB_joinFleetWindow_pixel2[1], $GLB_joinFleetWindow_pixel2[0], $GLB_joinFleetWindow_pixel2[1], $GLB_joinFleetWindow_pixel2[2], $GLB_joinFleetWindow_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_joinFleetWindow_pixel3[0], $GLB_joinFleetWindow_pixel3[1], $GLB_joinFleetWindow_pixel3[0], $GLB_joinFleetWindow_pixel3[1], $GLB_joinFleetWindow_pixel3[2], $GLB_joinFleetWindow_pixel3[3])
			If Not @error Then
				Return True
			EndIf
		EndIf
	EndIf

	Return False
EndFunc

;detect client update window pixels
Func OCR_DetectClientUpdateWindow()
	PixelSearch($GLB_clientUpdateWindow_pixel1[0], $GLB_clientUpdateWindow_pixel1[1], $GLB_clientUpdateWindow_pixel1[0], $GLB_clientUpdateWindow_pixel1[1], $GLB_clientUpdateWindow_pixel1[2], $GLB_clientUpdateWindow_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_clientUpdateWindow_pixel2[0], $GLB_clientUpdateWindow_pixel2[1], $GLB_clientUpdateWindow_pixel2[0], $GLB_clientUpdateWindow_pixel2[1], $GLB_clientUpdateWindow_pixel2[2], $GLB_clientUpdateWindow_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_clientUpdateWindow_pixel3[0], $GLB_clientUpdateWindow_pixel3[1], $GLB_clientUpdateWindow_pixel3[0], $GLB_clientUpdateWindow_pixel3[1], $GLB_clientUpdateWindow_pixel3[2], $GLB_clientUpdateWindow_pixel3[3])
			If Not @error Then
				Return True
			EndIf
		EndIf
	EndIf

	Return False
EndFunc

#cs depricated in Crius 1.0
;detect client ready to update window pixels
Func OCR_DetectClientReadyToUpdateWindow()
	PixelSearch($GLB_clientReadyToUpdateUpdateWindow_pixel1[0], $GLB_clientReadyToUpdateUpdateWindow_pixel1[1], $GLB_clientReadyToUpdateUpdateWindow_pixel1[0], $GLB_clientReadyToUpdateUpdateWindow_pixel1[1], $GLB_clientReadyToUpdateUpdateWindow_pixel1[2], $GLB_clientReadyToUpdateUpdateWindow_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_clientReadyToUpdateUpdateWindow_pixel2[0], $GLB_clientReadyToUpdateUpdateWindow_pixel2[1], $GLB_clientReadyToUpdateUpdateWindow_pixel2[0], $GLB_clientReadyToUpdateUpdateWindow_pixel2[1], $GLB_clientReadyToUpdateUpdateWindow_pixel2[2], $GLB_clientReadyToUpdateUpdateWindow_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_clientReadyToUpdateUpdateWindow_pixel3[0], $GLB_clientReadyToUpdateUpdateWindow_pixel3[1], $GLB_clientReadyToUpdateUpdateWindow_pixel3[0], $GLB_clientReadyToUpdateUpdateWindow_pixel3[1], $GLB_clientReadyToUpdateUpdateWindow_pixel3[2], $GLB_clientReadyToUpdateUpdateWindow_pixel3[3])
			If Not @error Then
				Return True
			EndIf
		EndIf
	EndIf

	Return False
EndFunc
#ce

;detect client unable to update message
Func OCR_DetectClientUnableToConnectMessage()
	PixelSearch($GLB_clientUnableToConnectMessage[0], $GLB_clientUnableToConnectMessage[1], $GLB_clientUnableToConnectMessage[2], $GLB_clientUnableToConnectMessage[3], $GLB_clientUnableToConnectMessage[4], $GLB_clientUnableToConnectMessage[5])
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;detect chat invite window pixels
Func OCR_DetectChatInviteWindow()
	PixelSearch($GLB_chatInviteWindow_pixel1[0], $GLB_chatInviteWindow_pixel1[1], $GLB_chatInviteWindow_pixel1[0], $GLB_chatInviteWindow_pixel1[1], $GLB_chatInviteWindow_pixel1[2], $GLB_chatInviteWindow_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_chatInviteWindow_pixel2[0], $GLB_chatInviteWindow_pixel2[1], $GLB_chatInviteWindow_pixel2[0], $GLB_chatInviteWindow_pixel2[1], $GLB_chatInviteWindow_pixel2[2], $GLB_chatInviteWindow_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_chatInviteWindow_pixel3[0], $GLB_chatInviteWindow_pixel3[1], $GLB_chatInviteWindow_pixel3[0], $GLB_chatInviteWindow_pixel3[1], $GLB_chatInviteWindow_pixel3[2], $GLB_chatInviteWindow_pixel3[3])
			If Not @error Then
				Return True
			EndIf
		EndIf
	EndIf

	Return False
EndFunc

;detect capsule pixels in space
Func OCR_DetectCapsuleSpace()
	PixelSearch($GLB_inventoryWindow_capsuleSpace_pixel1[0], $GLB_inventoryWindow_capsuleSpace_pixel1[1], $GLB_inventoryWindow_capsuleSpace_pixel1[0], $GLB_inventoryWindow_capsuleSpace_pixel1[1], $GLB_inventoryWindow_capsuleSpace_pixel1[2], $GLB_inventoryWindow_capsuleSpace_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_inventoryWindow_capsuleSpace_pixel2[0], $GLB_inventoryWindow_capsuleSpace_pixel2[1], $GLB_inventoryWindow_capsuleSpace_pixel2[0], $GLB_inventoryWindow_capsuleSpace_pixel2[1], $GLB_inventoryWindow_capsuleSpace_pixel2[2], $GLB_inventoryWindow_capsuleSpace_pixel2[3])
		If Not @error Then
			Return True
		EndIf
	EndIf

	Return False
EndFunc

;detect capsule pixels in station
Func OCR_DetectCapsuleStation()
	PixelSearch($GLB_inventoryWindow_capsuleStation_pixel1[0], $GLB_inventoryWindow_capsuleStation_pixel1[1], $GLB_inventoryWindow_capsuleStation_pixel1[0], $GLB_inventoryWindow_capsuleStation_pixel1[1], $GLB_inventoryWindow_capsuleStation_pixel1[2], $GLB_inventoryWindow_capsuleStation_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_inventoryWindow_capsuleStation_pixel2[0], $GLB_inventoryWindow_capsuleStation_pixel2[1], $GLB_inventoryWindow_capsuleStation_pixel2[0], $GLB_inventoryWindow_capsuleStation_pixel2[1], $GLB_inventoryWindow_capsuleStation_pixel2[2], $GLB_inventoryWindow_capsuleStation_pixel2[3])
		If Not @error Then
			Return True
		EndIf
	EndIf

	Return False
EndFunc

;detect paoples and places window
Func OCR_DetectPAPWindow()
	PixelSearch($GLB_PAPDetector[0], $GLB_PAPDetector[1], $GLB_PAPDetector[2], $GLB_PAPDetector[3], $GLB_PAPDetector[4], $GLB_PAPDetector[5])
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;detect join fleet window pixels
Func OCR_DetectFleetCreation()
	#cs
	PixelSearch($GLB_FW_createFleet_pixel1[0], $GLB_FW_createFleet_pixel1[1], $GLB_FW_createFleet_pixel1[0], $GLB_FW_createFleet_pixel1[1], $GLB_FW_createFleet_pixel1[2], $GLB_FW_createFleet_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_FW_createFleet_pixel2[0], $GLB_FW_createFleet_pixel2[1], $GLB_FW_createFleet_pixel2[0], $GLB_FW_createFleet_pixel2[1], $GLB_FW_createFleet_pixel2[2], $GLB_FW_createFleet_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_FW_createFleet_pixel3[0], $GLB_FW_createFleet_pixel3[1], $GLB_FW_createFleet_pixel3[0], $GLB_FW_createFleet_pixel3[1], $GLB_FW_createFleet_pixel3[2], $GLB_FW_createFleet_pixel3[3])
			If Not @error Then
				Return True
			EndIf
		EndIf
	EndIf
	#ce
	PixelSearch($GLB_FW_createFleet_pixel[0], $GLB_FW_createFleet_pixel[1], $GLB_FW_createFleet_pixel[2], $GLB_FW_createFleet_pixel[3], $GLB_FW_createFleet_pixel[4], $GLB_FW_createFleet_pixel[5])
	If @error Then
		Return True
	EndIf

	Return False
EndFunc

;is chat user in fleet
Func OCR_ChatUserInFleet($number)
	Local $x = $GLB_FCCW_CorpMembers[0] + $GLB_FCCW_CorpMemberStatus[0]
	Local $y = $GLB_FCCW_CorpMembers[1] + $GLB_FCCW_CorpMemberStatus[1] + ($number - 1)*$GLB_FCCW_CorpMemberHeight
	;MouseMove($x, $y)
	;UTL_Wait(2,3)
	PixelSearch($x, $y, $x, $y, $GLB_FCCW_CorpMemberStatus[3], $GLB_FCCW_CorpMemberStatus[4])
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;is chat user in corp
Func OCR_ChatUserInCorp($number)
	Local $x = $GLB_FCCW_CorpMembers[0] + $GLB_FCCW_CorpMemberStatus[0]
	Local $y = $GLB_FCCW_CorpMembers[1] + $GLB_FCCW_CorpMemberStatus[1] + ($number - 1)*$GLB_FCCW_CorpMemberHeight
	;MouseMove($x, $y)
	;UTL_Wait(2,3)
	PixelSearch($x, $y, $x, $y, $GLB_FCCW_CorpMemberStatus[2], $GLB_FCCW_CorpMemberStatus[4])
	If Not @error Then
		Return True
	EndIf

	Return False
EndFunc

;is chat user exists
Func OCR_ChatUserPresent($number, $size = "Big")
	If $size = "Big" Then
		Local $x = $GLB_LSCW_Members[0]
		Local $y = $GLB_LSCW_Members[1] + ($number - 1)*$GLB_LSCW_MembersHeight + $GLB_LSCW_MembersHeightSmall/2
	Else
		Local $x = $GLB_LSCW_MembersSmall[0]
		Local $y = $GLB_LSCW_MembersSmall[1] + ($number - 1)*$GLB_LSCW_MembersHeightSmall + $GLB_LSCW_MembersHeightSmall/2
	EndIf

	;BOT_LogMessage("OCR_ChatUserPresent: num=" &$number&","&$x&","&$y, 1)

	Local $dot = PixelSearch($x, $y, $x + 100, $y + 1, $GLB_LSCW_MembersText[0], $GLB_LSCW_MembersText[1])

	;MouseMove($x, $y)
	;UTL_Wait(2,3)

	If Not @error Then
		;Local $color = Hex(PixelGetColor($dot[0], $dot[1]), 6)
		BOT_LogMessage("OCR_ChatUserPresent: present")
		;BOT_LogMessage("OCR_ChatUserPresent: present, [" & $dot[0] & ":" & $dot[0] & "] = " & $color, 1)
		Return True
	EndIf

	BOT_LogMessage("OCR_ChatUserPresent: not present")
	Return False
EndFunc

;detect user type in chat
Func OCR_ChatUserType($number, $size = "Small")
	Local $foundPixel[2] = [-1, -1]
	If $size = "Big" Then
		Local $x = $GLB_LSCW_MembersStatus[0]
		Local $y = $GLB_LSCW_Members[1] + ($number - 1)*$GLB_LSCW_MembersHeight + $GLB_LSCW_MembersStatus[1]
		Local $x2 = $x + 1
		Local $y2 = $y + 1
	Else
		Local $x = $GLB_LSCW_MembersSmall[0]
		Local $y = $GLB_LSCW_MembersSmall[1] + ($number - 1)*$GLB_LSCW_MembersHeightSmall
		Local $x2 = $GLB_LSCW_MembersSmall[0] + $GLB_LSCW_MembersStatusSmall[0]
		Local $y2 = $GLB_LSCW_MembersSmall[1] + $GLB_LSCW_MembersStatusSmall[1] + ($number - 1)*$GLB_LSCW_MembersHeightSmall
	EndIf
	;MouseMove($x, $y)
	;UTL_Wait(2,3)

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorTerribleStandings, 25)
		If Not @error Then
			Local $retObject[2] = ["enemy", "terrible"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorCorp, 25)
		If Not @error Then
			Local $retObject[2] = ["friend", "corporation"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorFleet, 25)
		If Not @error Then
			Local $retObject[2] = ["friend", "fleet"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorAlliance, 25)
		If Not @error Then
			Local $retObject[2] = ["friend", "alliance"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorMilitia, 25)
		If Not @error Then
			Local $retObject[2] = ["friend", "militia"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorExellent, 25)
		If Not @error Then
			Local $retObject[2] = ["friend", "exellent"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		$foundPixel = PixelSearch($x, $y, $x2, $y2, $GLB_LSCW_MemberColorGood, 25)
		If Not @error Then
			Local $retObject[2] = ["friend", "good"]
		EndIf
	EndIf

	If Not IsDeclared("retObject") Then
		Dim $foundPixel[2] = [-1, -1]
		Local $retObject[2] = ["enemy", "unknown"]
	EndIf


	Local $color = Hex(PixelGetColor($foundPixel[0], $foundPixel[1]), 6)

	BOT_LogMessage("OCR_ChatUserType:"&$number&" = "&$retObject[0]&"-"&$retObject[1]&", ["&$foundPixel[0]&":"&$foundPixel[1]&"], "&$color)

	Return $retObject
EndFunc


;detect data loading pixels
Func OCR_DetectDataLoading()
	PixelSearch($GLB_dataLoading_pixel1[0], $GLB_dataLoading_pixel1[1], $GLB_dataLoading_pixel1[0], $GLB_dataLoading_pixel1[1], $GLB_dataLoading_pixel1[2], $GLB_dataLoading_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_dataLoading_pixel2[0], $GLB_dataLoading_pixel2[1], $GLB_dataLoading_pixel2[0], $GLB_dataLoading_pixel2[1], $GLB_dataLoading_pixel2[2], $GLB_dataLoading_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_dataLoading_pixel3[0], $GLB_dataLoading_pixel3[1], $GLB_dataLoading_pixel3[0], $GLB_dataLoading_pixel3[1], $GLB_dataLoading_pixel3[2], $GLB_dataLoading_pixel3[3])
			If Not @error Then
				PixelSearch($GLB_dataLoading_pixel4[0], $GLB_dataLoading_pixel4[1], $GLB_dataLoading_pixel4[0], $GLB_dataLoading_pixel4[1], $GLB_dataLoading_pixel4[2], $GLB_dataLoading_pixel4[3])
				If Not @error Then
					Return True
				EndIF
			EndIF
		EndIf
	EndIf

	PixelSearch($GLB_dataLoading2_pixel1[0], $GLB_dataLoading2_pixel1[1], $GLB_dataLoading2_pixel1[0], $GLB_dataLoading2_pixel1[1], $GLB_dataLoading2_pixel1[2], $GLB_dataLoading2_pixel1[3])
	If Not @error Then
		PixelSearch($GLB_dataLoading2_pixel2[0], $GLB_dataLoading2_pixel2[1], $GLB_dataLoading2_pixel2[0], $GLB_dataLoading2_pixel2[1], $GLB_dataLoading2_pixel2[2], $GLB_dataLoading2_pixel2[3])
		If Not @error Then
			PixelSearch($GLB_dataLoading2_pixel3[0], $GLB_dataLoading2_pixel3[1], $GLB_dataLoading2_pixel3[0], $GLB_dataLoading2_pixel3[1], $GLB_dataLoading2_pixel3[2], $GLB_dataLoading2_pixel3[3])
			If Not @error Then
				PixelSearch($GLB_dataLoading2_pixel4[0], $GLB_dataLoading2_pixel4[1], $GLB_dataLoading2_pixel4[0], $GLB_dataLoading2_pixel4[1], $GLB_dataLoading2_pixel4[2], $GLB_dataLoading2_pixel4[3])
				If Not @error Then
					Return True
				EndIF
			EndIF
		EndIf
	EndIf

	Return False
EndFunc

;detect first item in cargo
Func OCR_IsFirstItemInCargoPresent()
	Local $x = $GLB_cargoWindow[0] + 40
	Local $y = $GLB_cargoWindow[1] + 110
	PixelSearch($x, $y, $x, $y, $GLB_CW_bgColor[0], $GLB_CW_bgColor[1])
	If @error Then
		;BOT_LogMessage("OCR_IsFirstItemInCargoPresent: present", 1)
		Return True
	EndIf
	;BOT_LogMessage("OCR_IsFirstItemInCargoPresent: NOT present", 1)
	Return False
EndFunc

;detect first item in fleet comm corp hangar
Func OCR_IsFirstItemInFleetCommCorpHangarPresent()
	Local $x = $GLB_fleetCommanderCorpHangarWindow[0] + 40
	Local $y = $GLB_fleetCommanderCorpHangarWindow[1] + 150
	PixelSearch($x, $y, $x, $y, $GLB_CW_bgColor[0], $GLB_CW_bgColor[1])
	If @error Then
		;BOT_LogMessage("OCR_IsFirstItemInFleetCommCorpHangarPresent: present", 1)
		Return True
	EndIf
	;BOT_LogMessage("OCR_IsFirstItemInFleetCommCorpHangarPresent: NOT present", 1)
	Return False
EndFunc

;detect first item in container
Func OCR_IsFirstItemInContainerPresent()
	Local $x = $GLB_containerWindow[0] + 42
	Local $y = $GLB_containerWindow[1] + 112
	PixelSearch($x, $y, $x, $y, $GLB_CW_bgColor[0], $GLB_CW_bgColor[1])
	If @error Then
		;BOT_LogMessage("OCR_IsFirstItemInContainerPresent: present", 1)
		Return True
	EndIf
	;BOT_LogMessage("OCR_IsFirstItemInContainerPresent: NOT present", 1)
	Return False
EndFunc

;check freeze
Func OCR_isFreeze()
	Local $newChecksum = PixelChecksum( $GLB_freezeArea[0], $GLB_freezeArea[1], $GLB_freezeArea[0] + $GLB_freezeArea[2], $GLB_freezeArea[0] + $GLB_freezeArea[2], 1, $WIN_titles[$GLB_curBot], 1)
	If $OCR_freezeChecksum <> $newChecksum Then
		$OCR_freezeChecksum = $newChecksum
		Return False
	EndIf

	Return True
EndFunc

;check SI window
Func OCR_isSelectedItemWindowClosed()
	PixelSearch($GLB_SIWindowOpenDetector[0], $GLB_SIWindowOpenDetector[1], $GLB_SIWindowOpenDetector[0], $GLB_SIWindowOpenDetector[1], $GLB_SIWindowOpenDetector[2], $GLB_SIWindowOpenDetector[3])
	If Not @error Then
		;BOT_LogMessage("OCR_isSelectedItemWindowClosed: opened", 1)
		Return True
	EndIf

	BOT_LogMessage("OCR_isSelectedItemWindowClosed: NOT opened", 1)
	Return False
EndFunc

;check slots panel
Func OCR_isSlotsPanelOpened()
	PixelSearch($GLB_slotsOpenedPixel[0], $GLB_slotsOpenedPixel[1], $GLB_slotsOpenedPixel[0], $GLB_slotsOpenedPixel[1], $GLB_slotsOpenedPixel[2], $GLB_slotsOpenedPixel[3])
	If Not @error Then
		;BOT_LogMessage("OCR_isSlotsPanelOpened: opened", 1)
		Return True
	EndIf

	BOT_LogMessage("OCR_isSlotsPanelOpened: NOT opened", 1)
	Return False
EndFunc

;check is ship scrambled
Func OCR_isShipScrambled()
	Local $shift = 50
	PixelSearch($GLB_scramblingIndicator[0] - $shift, $GLB_scramblingIndicator[1], $GLB_scramblingIndicator[0] + $shift, $GLB_scramblingIndicator[1], $GLB_scramblingIndicator[2], $GLB_scramblingIndicator[3])
	If Not @error Then
		BOT_LogMessage("OCR_isShipScrambled: scrambled", 1)
		Return True
	EndIf

	;BOT_LogMessage("OCR_isShipScrambled: NOT scrambled", 1)
	Return False
EndFunc

;check is ship neutralized
Func OCR_isShipNeutralized()
	Local $shift = 50
	PixelSearch($GLB_neutralizingIndicator[0] - $shift, $GLB_neutralizingIndicator[1], $GLB_neutralizingIndicator[0] + $shift, $GLB_neutralizingIndicator[1], $GLB_neutralizingIndicator[2], $GLB_neutralizingIndicator[3])
	If Not @error Then
		BOT_LogMessage("OCR_isShipNeutralized: neutralized", 1)
		Return True
	EndIf

	;BOT_LogMessage("OCR_isShipNeutralized: NOT neutralized", 1)
	Return False
EndFunc

;check overview sorting
Func OCR_checkOverviewSorting($column = "distance")
	If $column = "icon" Then
		PixelSearch($GLB_sortingDetectorIcon[0], $GLB_sortingDetectorIcon[1], $GLB_sortingDetectorIcon[0], $GLB_sortingDetectorIcon[1], $GLB_sortingDetectorIcon[2], $GLB_sortingDetectorIcon[3])
	ElseIf $column = "distance" Then
		PixelSearch($GLB_sortingDetectorDistance[0], $GLB_sortingDetectorDistance[1], $GLB_sortingDetectorDistance[0], $GLB_sortingDetectorDistance[1], $GLB_sortingDetectorDistance[2], $GLB_sortingDetectorDistance[3])
	EndIf

	If Not @error Then
		;BOT_LogMessage("GLB_OverviewSortingDetector: OK", 1)
		Return True
	EndIf

	;BOT_LogMessage("OCR_checkOverviewSorting: WRONG=[" & $GLB_sortingDetectorDistance[0] & "," & $GLB_sortingDetectorDistance[1] & "]", 1)
	Return False
EndFunc

;check PAP sorting
Func OCR_checkPAPSorting()
	Local $x1 = $GLB_PAPsortingDetector[0]
	Local $y1 = $GLB_PAPsortingDetector[1]
	Local $x2 = $GLB_PAPsortingDetector2[0]
	Local $y2 = $GLB_PAPsortingDetector2[1]

	PixelSearch($x1, $y1, $x1, $y1, $GLB_PAPsortingDetector[2], $GLB_PAPsortingDetector[3])

	If Not @error Then
		PixelSearch($x2, $y2, $x2, $y2, $GLB_PAPsortingDetector2[2], $GLB_PAPsortingDetector2[3])
		If Not @error Then
			;BOT_LogMessage("GLB_PAPSortingDetector: OK", 1)
			Return True
		EndIf
	EndIf

	; if not detected check fix
	$x1 = $GLB_PAPsortingDetector[0] + $GLB_PAPsortingDetectorFix[0]
	$y1 = $GLB_PAPsortingDetector[1] + $GLB_PAPsortingDetectorFix[1]
	$x2 = $GLB_PAPsortingDetector2[0] + $GLB_PAPsortingDetectorFix[0]
	$y2 = $GLB_PAPsortingDetector2[1] + $GLB_PAPsortingDetectorFix[1]
	PixelSearch($x1, $y1, $x1, $y1, $GLB_PAPsortingDetector[2], $GLB_PAPsortingDetector[3])

	If Not @error Then
		PixelSearch($x2, $y2, $x2, $y2, $GLB_PAPsortingDetector2[2], $GLB_PAPsortingDetector2[3])
		If Not @error Then
			BOT_LogMessage("GLB_PAPSortingDetector: OK, PAP Window shifted, fix 1", 1)
			Return True
		EndIf
	EndIf

	; if not detected check fix
	$x1 = $GLB_PAPsortingDetector[0] + $GLB_PAPsortingDetectorFix2[0]
	$y1 = $GLB_PAPsortingDetector[1] + $GLB_PAPsortingDetectorFix2[1]
	$x2 = $GLB_PAPsortingDetector2[0] + $GLB_PAPsortingDetectorFix2[0]
	$y2 = $GLB_PAPsortingDetector2[1] + $GLB_PAPsortingDetectorFix2[1]
	PixelSearch($x1, $y1, $x1, $y1, $GLB_PAPsortingDetector[2], $GLB_PAPsortingDetector[3])

	If Not @error Then
		PixelSearch($x2, $y2, $x2, $y2, $GLB_PAPsortingDetector2[2], $GLB_PAPsortingDetector2[3])
		If Not @error Then
			BOT_LogMessage("GLB_PAPSortingDetector: OK, PAP Window shifted, fix 2", 1)
			Return True
		EndIf
	EndIf

	Local $color = Hex(PixelGetColor($GLB_PAPsortingDetector[0], $GLB_PAPsortingDetector[1]),6)

	BOT_LogMessage("GLB_PAPSortingDetector: WRONG=[" & $GLB_PAPsortingDetector[0] & "," & $GLB_PAPsortingDetector[1] & ",0x" & $color & "]", 1)
	Return False
EndFunc

;is anomaly present in scanner position
Func OCR_CheckScannerItem($position, $type, $subtype)
	BOT_LogMessage("OCR_CheckScannerItem 0", 1)
	Local $x, $y, $x_start, $y_start
	Local $i = $position - 1

	Local $color

	If $type = "ore" Then
		$x_start = $GLB_SW_scan_coloredResluts[0]
		$y_start = $GLB_SW_scan_coloredResluts[1]

		$x = $x_start + $GLB_SW_scan_coloredResluts_Ore_pixel1[0]
		$y = $y_start + $GLB_SW_scan_coloredResluts_Ore_pixel1[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
		$color = Hex(PixelGetColor($x, $y),6)
		;PixelSearch($x, $y, $x, $y, $GLB_SW_scan_coloredResluts_Ore_pixel1[2], $GLB_SW_scan_coloredResluts_Ore_pixel1[3])
		BOT_LogMessage("OCR_CheckScannerItem 0.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_Ore_pixel1[2],6), 1)
		;If Not @error Then
		If $color = Hex($GLB_SW_scan_coloredResluts_Ore_pixel1[2],6) Then
			;BOT_LogMessage("OCR_CheckScannerItem 1", 1)
			$x = $x_start + $GLB_SW_scan_coloredResluts_Ore_pixel2[0]
			$y = $y_start + $GLB_SW_scan_coloredResluts_Ore_pixel2[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
			$color = Hex(PixelGetColor($x, $y),6)
			;PixelSearch($x, $y, $x, $y, $GLB_SW_scan_coloredResluts_Ore_pixel2[2], $GLB_SW_scan_coloredResluts_Ore_pixel2[3])
			BOT_LogMessage("OCR_CheckScannerItem 1.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_Ore_pixel2[2],6), 1)
			;If Not @error Then
			If $color = Hex($GLB_SW_scan_coloredResluts_Ore_pixel2[2],6) Then
				;BOT_LogMessage("OCR_CheckScannerItem 2", 1)
				$x = $x_start + $GLB_SW_scan_coloredResluts_Ore_pixel3[0]
				$y = $y_start + $GLB_SW_scan_coloredResluts_Ore_pixel3[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
				$color = Hex(PixelGetColor($x, $y),6)
				;PixelSearch($x, $y, $x, $y, $GLB_SW_scan_coloredResluts_Ore_pixel3[2], $GLB_SW_scan_coloredResluts_Ore_pixel3[3])
				BOT_LogMessage("OCR_CheckScannerItem 2.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_Ore_pixel3[2],6), 1)
				;If Not @error Then
				If $color = Hex($GLB_SW_scan_coloredResluts_Ore_pixel3[2],6) Then
					;BOT_LogMessage("OCR_CheckScannerItem 3", 1)
					$x = $x_start + $GLB_SW_scan_coloredResluts_Ore_pixel4[0]
					$y = $y_start + $GLB_SW_scan_coloredResluts_Ore_pixel4[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
					$color = Hex(PixelGetColor($x, $y),6)
					;PixelSearch($x, $y, $x, $y, $GLB_SW_scan_coloredResluts_Ore_pixel4[2], $GLB_SW_scan_coloredResluts_Ore_pixel4[3])
					BOT_LogMessage("OCR_CheckScannerItem 3.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_Ore_pixel4[2],6), 1)
					;If Not @error Then
					If $color = Hex($GLB_SW_scan_coloredResluts_Ore_pixel4[2],6) Then
						Local $itemSubtype = OCR_CheckScannerItemSubtype($position, $type)
						BOT_LogMessage("OCR_CheckScannerItem 4: subtype = " & $itemSubtype, 1)
						If $subtype = "all" Or $itemSubtype = $subtype Then
							BOT_LogMessage("OCR_CheckScannerItem - OK, position = " & ($i + 1), 1)
							Return ($i + 1)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	Return False
EndFunc

;detect anomaly subtype
Func OCR_CheckScannerItemSubtype($position, $type)
	Local $x, $y, $x_start, $y_start
	Local $i = $position - 1

	Local $color

	If $type = "ore" Then
		$x_start = $GLB_SW_scan_coloredResluts[0]
		$y_start = $GLB_SW_scan_coloredResluts[1]

		; check if "Clear Icicle"
		$x = $x_start + $GLB_SW_scan_coloredResluts_ClearIcicle_pixel1[0]
		$y = $y_start + $GLB_SW_scan_coloredResluts_ClearIcicle_pixel1[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
		$color = Hex(PixelGetColor($x, $y),6)
		BOT_LogMessage("OCR_CheckScannerItemSybtype 0.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_ClearIcicle_pixel1[2],6), 1)
		If $color = Hex($GLB_SW_scan_coloredResluts_ClearIcicle_pixel1[2],6) Then
			$x = $x_start + $GLB_SW_scan_coloredResluts_ClearIcicle_pixel2[0]
			$y = $y_start + $GLB_SW_scan_coloredResluts_ClearIcicle_pixel2[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
			$color = Hex(PixelGetColor($x, $y),6)
			BOT_LogMessage("OCR_CheckScannerItemSybtype 1.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_ClearIcicle_pixel2[2],6), 1)
			If $color = Hex($GLB_SW_scan_coloredResluts_ClearIcicle_pixel2[2],6) Then
				$x = $x_start + $GLB_SW_scan_coloredResluts_ClearIcicle_pixel3[0]
				$y = $y_start + $GLB_SW_scan_coloredResluts_ClearIcicle_pixel3[1] + $i*($GLB_SW_scan_results_itemHeight+$GLB_SW_scan_results_delimiterHeight)
				$color = Hex(PixelGetColor($x, $y),6)
				BOT_LogMessage("OCR_CheckScannerItemSybtype 2.1:[" & $x & ";" & $y & "] - " & $color & "=" &Hex($GLB_SW_scan_coloredResluts_ClearIcicle_pixel3[2],6), 1)
				If $color = Hex($GLB_SW_scan_coloredResluts_ClearIcicle_pixel3[2],6) Then
					Return "ClearIcicle"
				EndIf
			EndIf
		EndIf
	EndIf

	Return "unknown"
EndFunc