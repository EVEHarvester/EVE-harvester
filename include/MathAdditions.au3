Func LN($x)
	Local $E = 2.718281828
	Return (Log($x)/Log($E))
EndFunc

Func ASinH($x)
	Return LN($x + Sqrt(1 + $x^2))
EndFunc
