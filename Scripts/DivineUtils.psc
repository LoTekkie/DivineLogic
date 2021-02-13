scriptName DivineUtils

import Debug
import Utility
Import Math

; Log a debug message
function dd(string msg, string prefix="[*] > ", bool enabled=true) global
	Debug.traceConditional(prefix + msg, enabled)
endFunction

; Clap the given float value between min and max
float function clampf(float val, float min, float max) global
	if val <= min
		val = min
	elseIf val >= max
		val = max	
	endIf
	return val 
endFunction