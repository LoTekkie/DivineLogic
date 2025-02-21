scriptName DivineUtils

import Debug
import Utility
Import Math

; Log a debug message
function log(string msg, string prefix="[DL:*] > ", bool enabled=true) global
  Debug.traceConditional(prefix + msg, enabled)
endFunction

; Log an error message
function err(string msg) global
  log(msg, "[DL:ERR] > ", true)
endFunction

; Log a warning message
function wrn(string msg) global
  log(msg, "[DL:WARN] > ", true)
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

; Set float value based on the given condition
float function ternaryFloat(bool condition, float trueValue, float falseValue) global
  if (condition)
    return trueValue
  else
    return falseValue
  endIf
endFunction

; Set bool value based on the given condition
bool function ternaryBool(bool condition, bool trueValue, bool falseValue) global
  if (condition)
    return trueValue
  else
    return falseValue
  endIf 
endFunction 

; Rotate the given object about its local axes
function setLocalAngle(objectReference objectRef, float localX, float localY, float localZ) global
  float angleX = localX * Math.cos(LocalZ) + localY * Math.sin(localZ)
  float angleY = localY * Math.cos(LocalZ) - localX * Math.sin(localZ)
  objectRef.setAngle(angleX, angleY, localZ)
endFunction

; Compare two float values by the given comparison operator
bool function compareFloatValues(float value, string compareOperator, float compareValue) global
  if (compareOperator == "==")
    return value == compareValue
  elseif (compareOperator == "!=")
    return value != compareValue
  elseIf (compareOperator == ">")
    return value > compareValue
  elseIf (compareOperator == ">=")
    return value >= compareValue
  elseIf (compareOperator == "<")
    return value < compareValue
  elseIf (compareOperator == "<=")
    return value <= compareValue
  else 
    return false
  endIf  
endFunction

; Compare two int values by the given comparison operator
bool function compareIntValues(int value, string compareOperator, int compareValue) global
  if (compareOperator == "==")
    return value == compareValue
  elseif (compareOperator == "!=")
    return value != compareValue
  elseIf (compareOperator == ">")
    return value > compareValue
  elseIf (compareOperator == ">=")
    return value >= compareValue
  elseIf (compareOperator == "<")
    return value < compareValue
  elseIf (compareOperator == "<=")
    return value <= compareValue
  else 
    return false
  endIf  
endFunction

; Ensure value is within tolerance to the compareValue
bool function floatsWithin(float value, float compareValue, float tolerance=0.01) global
  value = Math.abs(value)
  compareValue = Math.abs(compareValue)

  if (value == compareValue)
    return true
  elseif (value > compareValue)
    return value - compareValue <= tolerance
  elseif (value < compareValue)
    return compareValue - value <= tolerance
  endIf
endFunction

;-----------\
;Description \ Author: Chesko
;----------------------------------------------------------------
;Rotates a point (akObject offset from the center of
;rotation (akOrigin) by the supplied degrees fAngleX, fAngleY,
;fAngleZ, and returns the new position of the point.
 
;-------------\
;Return Values \
;----------------------------------------------------------------
;               fNewPos[0]      =        The new X position of the point
;               fNewPos[1]      =        The new Y position of the point
;               fNewPos[2]      =        The new Z position of the point
 
;                        |  1                    0                0     |
;Rx(t) =                 |  0                   cos(t)         -sin(t)  |
;                        |  0                   sin(t)          cos(t)  |
;
;                        | cos(t)                0              sin(t)  |
;Ry(t) =                 |  0                    1                0     |
;                        |-sin(t)                0              cos(t)  |
;
;                        | cos(t)              -sin(t)            0     |
;Rz(t) =                 | sin(t)               cos(t)            0     |
;                        |  0                    0                1     |
 
;R * v = Rv, where R = rotation matrix, v = column vector of point [ x y z ], Rv = column vector of point after rotation
;Provided angles must follow Bethesda's conventions (CW Z angle for example).
float[] function getPosXYZRotateAroundRef(ObjectReference akOrigin, ObjectReference akObject, float fAngleX, float fAngleY, float fAngleZ) global
  fAngleX = -(fAngleX)
  fAngleY = -(fAngleY)
  fAngleZ = -(fAngleZ)

  float myOriginPosX = akOrigin.GetPositionX()
  float myOriginPosY = akOrigin.GetPositionY()
  float myOriginPosZ = akOrigin.GetPositionZ()

  float fInitialX = akObject.GetPositionX() - myOriginPosX
  float fInitialY = akObject.GetPositionY() - myOriginPosY
  float fInitialZ = akObject.GetPositionZ() - myOriginPosZ

  float fNewX
  float fNewY
  float fNewZ

  ;Objects in Skyrim are rotated in order of Z, Y, X, so we will do that here as well.

  ;Z-axis rotation matrix
  float fVectorX = fInitialX
  float fVectorY = fInitialY
  float fVectorZ = fInitialZ
  fNewX = (fVectorX * cos(fAngleZ)) + (fVectorY * sin(-fAngleZ)) + (fVectorZ * 0)
  fNewY = (fVectorX * sin(fAngleZ)) + (fVectorY * cos(fAngleZ)) + (fVectorZ * 0)
  fNewZ = (fVectorX * 0) + (fVectorY * 0) + (fVectorZ * 1)        

  ;Y-axis rotation matrix
  fVectorX = fNewX
  fVectorY = fNewY
  fVectorZ = fNewZ
  fNewX = (fVectorX * cos(fAngleY)) + (fVectorY * 0) + (fVectorZ * sin(fAngleY))
  fNewY = (fVectorX * 0) + (fVectorY * 1) + (fVectorZ * 0)
  fNewZ = (fVectorX * sin(-fAngleY)) + (fVectorY * 0) + (fVectorZ * cos(fAngleY))

  ;X-axis rotation matrix
  fVectorX = fNewX
  fVectorY = fNewY
  fVectorZ = fNewZ        
  fNewX = (fVectorX * 1) + (fVectorY * 0) + (fVectorZ * 0)
  fNewY = (fVectorX * 0) + (fVectorY * cos(fAngleX)) + (fVectorZ * sin(-fAngleX))
  fNewZ = (fVectorX * 0) + (fVectorY * sin(fAngleX)) + (fVectorZ * cos(fAngleX))

  ;Return result
  float[] fNewPos = new float[3]
  fNewPos[0] = fNewX + myOriginPosX
  fNewPos[1] = fNewY + myOriginPosY
  fNewPos[2] = fNewZ + myOriginPosZ
  return fNewPos
endFunction