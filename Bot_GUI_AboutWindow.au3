Global $GUI_aboutWindow
Global $GLB_aboutWindowSize[2] = [200, 100]

Global $GLB_eveOnlineVersion = "Scylla 1.0"

;create about window GUI
Func GUI_CreateAboutWindowGUI()
	$GUI_aboutWindow = GUICreate("About", $GLB_aboutWindowSize[0], $GLB_aboutWindowSize[1])

	GUICtrlCreateLabel("EVE Harvester v." & UTL_GetScriptVersion(), 5, 10)
	GUICtrlCreateLabel("Supports " & $GLB_eveOnlineVersion, 5, 30)

	; set window events
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_HideAboutWindow")

	; GUI MESSAGE LOOP
	GUISetState(@SW_HIDE)
EndFunc

;close about window
Func GUI_HideAboutWindow()
	GUISetState(@SW_HIDE, $GUI_aboutWindow)
EndFunc

; show about window
Func GUI_ShowAboutWindow()
	GUISetState(@SW_SHOW, $GUI_aboutWindow)
EndFunc

; open site window
Func GUI_AboutWindow_OpenSite()
	NET_OpenUrlInBrowser($NET_SERVER)
EndFunc

; open download docs window
Func GUI_AboutWindow_OpenDownloadDocuments()
	NET_OpenUrlInBrowser($NET_SERVER & "/download.html")
EndFunc

; open download docs window
Func GUI_AboutWindow_OpenRegister()
	NET_OpenUrlInBrowser($NET_SERVER & "/register.html")
EndFunc