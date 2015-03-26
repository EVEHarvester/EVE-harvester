; Watcher role proxy function
Func Watcher($location, $state)
	If $location = "station" Then
		If $state = "free" Then
			Watcher_station_free()
		ElseIf $state = "delay" Then
			Watcher_station_delay()
		EndIf
	ElseIf $location = "space" Then
		If $state = "free" Then
			Watcher_space_free()
		EndIf
	ElseIf $location = "spot" Then
		If $state = "free" Then
			Watcher_spot_free()
		ElseIf $state = "delay" Then
			Watcher_spot_delay()
		EndIf
	ElseIf $location = "pos" Then
		If $state = "free" Then
			Watcher_pos_free()
		ElseIf $state = "delay" Then
			Watcher_pos_delay()
		EndIf
	EndIf
EndFunc

Func Watcher_station_free()
	GUI_SetLocationAndState("station", "delay")
EndFunc

Func Watcher_station_delay()
	BOT_CheckLocal()
EndFunc

Func Watcher_space_free()
	Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
	If $POS = "Station" Then
		ACT_DockToStation(True)
	ElseIf $POS = "Station and POS" Or $POS = "POS" Then
		ACT_WarpTo("pos")
	ElseIf $POS = "None" Then
		ACT_WarpTo("spot")
	EndIf
EndFunc

Func Watcher_spot_free()
	Local $POS = GUICtrlRead($GUI_systemPOS[$GLB_curBot])
	If $POS = "Station" Then
		ACT_DockToStation(True)
	ElseIf $POS = "Station and POS" Or $POS = "POS" Then
		ACT_WarpTo("pos")
	Else
		GUI_SetLocationAndState("spot", "delay")
	EndIf
EndFunc

Func Watcher_spot_delay()
	BOT_CheckLocal()
EndFunc

Func Watcher_pos_free()
	GUI_SetLocationAndState("pos", "delay")
EndFunc

Func Watcher_pos_delay()
	BOT_CheckLocal()
EndFunc

