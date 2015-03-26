; local chat users
Global $GLB_localChatMaxUsersAmountBig = 12
Global $GLB_localChatMaxUsersAmountSmall = 26

;chat window
Global $GLB_LSCWindow[2]

Global $GLB_LSCWDefaultLocation[2] = [33, 141]

Global $GLB_LSCW_LocalTab[4]
Global $GLB_LSCW_CorpTab[4]

Global $GLB_LSCW_Members[2]
Global $GLB_LSCW_MembersHeight = 37
Global $GLB_LSCW_MembersStatus[2]

Global $GLB_LSCW_MembersSmall[2]
Global $GLB_LSCW_MembersHeightSmall = 18
Global $GLB_LSCW_MembersStatusSmall[2]

Global $GLB_LSCW_MembersText[2] = [0xC0C0C0, 30]

Global $GLB_LSCW_MemberColorCorp = 0x217D18
Global $GLB_LSCW_MemberColorFleet = 0x7B24B5
Global $GLB_LSCW_MemberColorAlliance = 0x08287B
Global $GLB_LSCW_MemberColorMilitia = 0x42086B
Global $GLB_LSCW_MemberColorExellent = 0x08287B
Global $GLB_LSCW_MemberColorGood = 0x3169C6

Global $GLB_LSCW_MemberColorTerribleStandings = 0x9C0808

; update ocr data from GUI
Func DATA_UpdateChatOCR()
	Local $OCRChatX = GUICtrlRead($GUI_OCRChatX)
	Local $OCRChatY = GUICtrlRead($GUI_OCRChatY)

	Dim $GLB_LSCWindow[2] = [$OCRChatX, $OCRChatY]
	Dim $GLB_LSCW_LocalTab[4] = [$GLB_LSCWindow[0] + 25, $GLB_LSCWindow[1] + 10, 5, 1]
	Dim $GLB_LSCW_CorpTab[4] = [$GLB_LSCWindow[0] + 70, $GLB_LSCWindow[1] + 10, 2, 2]

	Dim $GLB_LSCW_Members[2] = [$GLB_LSCWindow[0] + 150, $GLB_LSCWindow[1] + 42]
	Dim $GLB_LSCW_MembersStatus[2] = [$GLB_LSCWindow[0] + 236, 19]; x, dY

	Dim $GLB_LSCW_MembersSmall[2] = [$GLB_LSCWindow[0] + 51, $GLB_LSCWindow[1] + 44]
	Dim $GLB_LSCW_MembersStatusSmall[2] = [7, 7]; dX, dY
EndFunc