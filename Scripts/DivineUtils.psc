scriptName DivineUtils

import Debug
import Utility
Import Math

; Log a debug message
function dd(string msg, string prefix="[DL:*] > ", bool enabled=true) global
	Debug.traceConditional(prefix + msg, enabled)
endFunction

; Log an error message
function err(string msg) global
	dd(msg, "[DL:ERR] > ", true)
endFunction

; Log a warning message
function wrn(string msg) global
	dd(msg, "[DL:WARN] > ", true)
endFunction

; Clamp the given float value between min and max
float function clampf(float val, float min, float max) global
	if (val <= min)
		val = min
	elseIf (val >= max)
		val = max	
	endIf
	return val 
endFunction

; Clamp the given int value between min and max
int function clampi(int val, int min, int max) global
	if (val <= min)
		val = min
	elseIf (val >= max)
		val = max
	endIf
	return val
endFunction

; Get the greater float value of the given two
float function greaterf(float val1, float val2) global
	if (val1 > val2)
		return val1
	elseIf (val2 > val1)
		return val2
	endIf
	return val1
endFunction

; Get the lesser float value of the given two
float function lesserf(float val1, float val2) global
	if (val1 < val2)
		return val1
	elseIf (val2 < val1)
		return val2
	endIf
	return val1
endFunction

; Get a float out of the given coordinate array at specified row and column
float function getFloatFromCoordinateArrayXY(float[] arr, int x, int y, int cols=9) global
	int index = getIndexFromCoordinateArrayXY(arr, x, y, cols)
	return arr[index]
endFunction

; Get the index at specified row and column of the given coordinate array
int function getIndexFromCoordinateArrayXY(float[] arr, int x, int y, int cols=9) global
	int rowLength = arr.length / cols
	return rowLength * y + x
endFunction

; Set a float value in the given coordinate array at specified row and column
function setFloatInCoordinateArrayXY(float[] arr, int x, int y, float value, int cols=9) global
	int index = getIndexFromCoordinateArrayXY(arr, x, y, cols)
	if (index < arr.length)
		arr[index] = value
	endIf
endFunction

; Set float to the conformed value if is not equal to the default value
float function conformFloat(float value, float conformed, float default) global
	if (value != default)
		return value
	else
		return conformed
	endIf 
endFunction

; Set bool to the conformed value if is not equal to the default value
bool function conformBool(bool value, bool conformed, bool default) global
	if (value != default)
		return value
	else
		return conformed
	endIf 
endFunction

; Rotate the given object about its local axes
function setLocalAngle(objectReference objectRef, float localX, float localY, float localZ) global
	float angleX = localX * Math.cos(LocalZ) + localY * Math.sin(localZ)
	float angleY = localY * Math.cos(LocalZ) - localX * Math.sin(localZ)
	objectRef.setAngle(angleX, angleY, localZ)
endFunction