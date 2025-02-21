scriptName DivineTranslatorMarker extends DivineMarker
; Zenithar - God of Work and Commerce, Trader God

import DivineUtils

; =========================
;        PROPERTIES
; =========================

float property delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references translate to this marker. }

float property speed = 100.0 auto
{ Default: 100.0 - Speed at which the keyword-linked object references will translate to this marker. }

float property rotationSpeedClamp = 0.0 auto
{ Default: 0.0 - Amount of rotation speed clamping applied to translating objects. (0.0 means don't clamp rotation speed) }

bool property rotateOnArrival = false auto
{ Default: False - Should rotation of the translating objects be prevented until they arrive at this marker? }

float property tangentMagnitude = 0.0 auto
{ Default: 0.0 - Magnitude of the spline tangents. If this value is 0.0 no splines will be created. } 

bool property collapseSpacing = false auto
{ Defualt: False - Should translating objects ignore original spacing and meet at the same postion on this marker? }

float property offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects positions in the X direction. }

float property offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects positions in the Y direction. }

float property offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects positions in the Z direction. }

float property offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects angles in the X direction. }

float property offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects angles in the Y direction. }

float property offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects angles in the Z direction. }

bool property limitX = false auto
{ Default: False - Prevent translation of the x axis. }

bool property limitY = false auto
{ Default: False - Prevent translation of the y axis. }

bool property limitZ = false auto
{ Default: False - Prevent translation of the z axis. }

bool property limitAX = false auto
{ Default: False - Prevent translation of the aX axis. }

bool property limitAY = false auto
{ Default: False - Prevent translation of the aY axis. }

bool property limitAZ = false auto
{ Default: False - Prevent translation of the aZ axis. }

bool property matchRotation = false auto
{ Default: False - Should the translating objects match the rotation of this marker when they arrive? }

bool property toPlayer = false auto
{ Default: False - Should the translating objects move to the player? }