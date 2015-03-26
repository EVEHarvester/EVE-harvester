#AutoIt3Wrapper_Outfile=Launcher.exe
#AutoIt3Wrapper_Icon=img/icon_launcher.ico

;health checker
#include <GUIConstants.au3>
#include <GuiEdit.au3>
#include <String.au3>

Opt("GUIOnEventMode", 1) ;enable onEvent functions
Opt("PixelCoordMode", 2) ;Отсчет координат пикселей от левого верхнего угла клиентской части окна
Opt("MouseCoordMode", 2) ;Отсчет координат мыши от левого верхнего угла клиентской части окна
Opt("MustDeclareVars", 1) ;Форсируем задачу переменных. То есть после задания этой опции перед тем как нам использовать какую-либо переменную нам надо обозначить ее.
Opt("SendKeyDelay", 100)

Global $HC_mainWindow
Global $HC_selectConfButton
Global $HC_goButton
Global $HC_confInput

Global $HC_selectBotButton
Global $HC_botInput

Global $HC_periodInput
Global $HC_killCheckbox
Global $HC_killInput

Global $HC_WindowTitle = "[TITLE:EVE; CLASS:triuiScreen]"

Global $HC_Running = False

Global $HC_botName = ""

HC_CreateGUI()
HC_CloseAllBotWindows()
HC_Stop()

While 1
	If $HC_Running Then
		; check health
		HC_CheckHealth()
		HC_CheckShutdown()
		Sleep(GUICtrlRead($HC_periodInput)*1000)
	EndIf
WEnd

Func HC_CreateGUI()
	$HC_mainWindow = GuiCreate("Launcher", 495, 80, 10, 10)

	$HC_confInput = GUICtrlCreateInput("", 160, 8, 275, 20)
	GUICtrlSetState($HC_confInput, $GUI_DISABLE)
	If $CmdLine[0] = 1 And $CmdLine[1] <> "-1" Then
		GUICtrlSetData($HC_confInput, $CmdLine[1])
	EndIf

	$HC_selectConfButton = GUICtrlCreateButton ("Select bot configuration", 5, 5, 150, 25)
	GUICtrlSetOnEvent($HC_selectConfButton, "HC_OpenConfigFile")
	GUICtrlSetTip($HC_selectConfButton, "Select configuration file")

	$HC_botInput = GUICtrlCreateInput("", 160, 33, 275, 20)
	GUICtrlSetState($HC_botInput, $GUI_DISABLE)
	$HC_selectBotButton = GUICtrlCreateButton ("Select bot file", 5, 30, 150, 25)
	GUICtrlSetOnEvent($HC_selectBotButton, "HC_OpenBotFile")
	GUICtrlSetTip($HC_selectBotButton, "Select bot file")

	$HC_killCheckbox = GUICtrlCreateCheckbox("shutdown application at ", 10, 58)
	$HC_killInput = GUICtrlCreateInput("13:00", 160, 58, 50, 20)

	GUICtrlCreateLabel("Check period(sec):", 285, 63)
	$HC_periodInput = GUICtrlCreateInput("30", 385, 58, 50, 20, $ES_NUMBER)

	$HC_goButton = GUICtrlCreateButton ("Run", 440, 5, 50, 70)

	GUISetOnEvent($GUI_EVENT_CLOSE, "HC_Close")

	GuiSetState()
EndFunc

Func HC_Close()
	GUIDelete()
	Exit 0
EndFunc

Func HC_OpenConfigFile()
	Local $filepath = FileOpenDialog("Select configuration file", @ScriptDir, "INI file (*.ini)", 1)

	If @error Then
		Return False
	EndIf

	GUICtrlSetData($HC_confInput, $filepath)
EndFunc

Func HC_OpenBotFile()
	Local $filepath = FileOpenDialog("Select bot file", @ScriptDir, "EXE file (*.exe)", 1)

	If @error Then
		Return False
	EndIf

	Local $pathArray = StringSplit($filepath, "\" )
	$HC_botName = $pathArray[$pathArray[0]]

	GUICtrlSetData($HC_botInput, $filepath)
EndFunc

Func HC_Run()
	If GUICtrlRead($HC_confInput) = "" Then
		MsgBox(64, "Warning", "Configuration not selected")
		Return
	EndIf

	If GUICtrlRead($HC_botInput) = "" Then
		MsgBox(64, "Warning", "Bot file not selected")
		Return
	EndIf

	GUICtrlSetOnEvent($HC_goButton, "HC_Stop")
	GUICtrlSetTip($HC_goButton, "Stop bot health checker")
	GUICtrlSetData($HC_goButton, "Stop")

	GUICtrlSetState ($HC_periodInput, $GUI_FOCUS)

	Local $cmd = @ScriptDir & '/Launcher.bat "' & $HC_botName & '" "' & GUICtrlRead($HC_confInput) & '" "True"'
	Run($cmd, @ScriptDir, @SW_MINIMIZE)
	$HC_Running = True
EndFunc

Func HC_Stop()
	$HC_Running = False
	GUICtrlSetOnEvent($HC_goButton, "HC_Run")
	GUICtrlSetTip($HC_goButton, "Run bot health checker")
	GUICtrlSetData($HC_goButton, "Run")
EndFunc

Func HC_CheckHealth()
	If Not ProcessExists($HC_botName) Then
		Local $windows = WinList($HC_WindowTitle)

		For $i = 1 to $windows[0][0]
			WinKill($windows[$i][1])
		Next

		HC_Run()
	EndIf
EndFunc

Func HC_CheckShutdown()
	If GUICtrlRead($HC_killCheckbox) = $GUI_UNCHECKED Then
		Return False
	EndIf

	Local $shutdownTime = StringSplit(GUICtrlRead($HC_killInput), ":", 2)

	If $shutdownTime[0] = String(@HOUR) And $shutdownTime[1] = String(@MIN) And ProcessExists($HC_botName) Then
		HC_CloseAllBotWindows()

		Local $windows = WinList($HC_WindowTitle)
		For $i = 1 to $windows[0][0]
			WinKill($windows[$i][1])
		Next
	EndIf
EndFunc

Func HC_CloseAllBotWindows()
	While ProcessExists($HC_botName)
		ProcessClose($HC_botName)
	WEnd
EndFunc