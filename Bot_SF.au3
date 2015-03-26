;suicide fighter accelerator

#include <GUIConstants.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

#include "UnixTime.au3"

Opt("GUIOnEventMode", 1) ;enable onEvent functions
Opt("PixelCoordMode", 2) ;Отсчет координат пикселей от левого верхнего угла клиентской части окна
Opt("MouseCoordMode", 2) ;Отсчет координат мыши от левого верхнего угла клиентской части окна
Opt("MustDeclareVars", 1) ;Форсируем задачу переменных. То есть после задания этой опции перед тем как нам использовать какую-либо переменную нам надо обозначить ее.
Opt("SendKeyDelay", 100)

Global $SF_clientTitle = '[TITLE:EVE; CLASS:triuiScreen]'
Global $SF_windowInput[2]
Global $SF_windowSetButton[2]
Global $SF_mainWindow
Global $SF_goButton

SF_CreateGUI()	

While 1
	; loop
WEnd

Func SF_CreateGUI()	
	$SF_mainWindow = GuiCreate("Suicide fighter accelerator", 280, 55, 0, 0)
	
	GUICtrlCreateLabel("Window 1:", 10, 10)
	$SF_windowInput[0] = GUICtrlCreateInput ("", 105, 5, 85, 20)
	GUICtrlSetState($SF_windowInput[0], $GUI_DISABLE)
	$SF_windowSetButton[0] = GUICtrlCreateButton ("set", 70, 10, 30, 15)	
	GUICtrlSetOnEvent($SF_windowSetButton[0], "SF_SetWindow1")
	GUICtrlSetTip($SF_windowSetButton[0], "set suicide window 1. click, activate client window and wait")	
		
	GUICtrlCreateLabel("Window 2:", 10, 30)
	$SF_windowInput[1] = GUICtrlCreateInput ("", 105, 30, 85, 20)
	GUICtrlSetState($SF_windowInput[1], $GUI_DISABLE)
	$SF_windowSetButton[0] = GUICtrlCreateButton ("set", 70, 30, 30, 15)	
	GUICtrlSetOnEvent($SF_windowSetButton[0], "SF_SetWindow2")
	GUICtrlSetTip($SF_windowSetButton[0], "set suicide window 2. click, activate client window and wait")		
	
	
	$SF_goButton = GUICtrlCreateButton ("GO", 200, 5, 70, 45)	
	GUICtrlSetOnEvent($SF_goButton, "SF_Go")
	GUICtrlSetTip($SF_goButton, "SUICIDE SPACESHIP NOW")	
		
	GUISetOnEvent($GUI_EVENT_CLOSE, "SF_Close")

	GuiSetState()
EndFunc

Func SF_SetWindow1()
	GUICtrlSetData($SF_windowInput[0], "Wait...")
	For $i = 0 To 5 Step 1		
		SF_Wait(1, 1.1)		
	Next
					
	GUICtrlSetData($SF_windowInput[0], SF_GetActiveWindow())
EndFunc

Func SF_SetWindow2()
	GUICtrlSetData($SF_windowInput[1], "Wait...")
	For $i = 0 To 5 Step 1		
		SF_Wait(1, 1.1)		
	Next
						
	GUICtrlSetData($SF_windowInput[1], SF_GetActiveWindow())
EndFunc

Func SF_GetActiveWindow()
	Local $winlist = WinList($SF_clientTitle)
	For $i = 1 to $winlist[0][0]
		If $winlist[$i][0] <> "" and WinActive($winlist[$i][1]) Then
			Return $winlist[$i][1]
		EndIf
	Next
	Return ""
EndFunc

Func SF_Wait($min = 0.5, $max = 1)
    Sleep(Random($min*1000, $max*1000))
EndFunc

Func SF_Go()
	Local $start = _TimeGetStamp()
	GUICtrlSetData($SF_goButton, "Running...")
	GUICtrlSetState($SF_goButton, $GUI_DISABLE)
	For $i = 0 to UBound($SF_windowInput) - 1 Step 1
		Local $window = GUICtrlRead($SF_windowInput[$i])
		
		If $window <> "" Then			
			If Not WinActive($window) Then
				GUICtrlSetData($SF_goButton, "Activating...")
				WinActivate($window)
				;MsgBox(64, "w", WinActivate($window) & " - " & $window & " - " & @extended)
				SF_Wait(0.1, 0.15)
				While Not WinActive($window)
					GUICtrlSetData($SF_goButton, "Window...")
					WinActivate($window)
					SF_Wait(0.1, 0.15)
				WEnd
			EndIf
			
			GUICtrlSetData($SF_goButton, "Commanding...")
			Send("{F1}")
			SF_Wait(0.1, 0.15)
			Send("{ENTER}")
			Send("{F2}")
			Send("s")
			Send("q")			
		EndIf
	Next
	GUICtrlSetData($SF_goButton, "GO")
	GUICtrlSetState($SF_goButton, $GUI_ENABLE)
	
	MsgBox(64, "Completed", "Done in " & (_TimeGetStamp() - $start) & " sec")
EndFunc

Func SF_Close()
	GUIDelete()
	Exit 0
EndFunc