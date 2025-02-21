scriptName DivineCutsceneCreatorMarker extends DivineMarker
; Talos - Hero-god of Mankind, conqueror God, God of Might, Honor, State, Law, and Man
; Defines a marker used in cutscenes for positioning, movement, and camera effects.

import DivineUtils

; =========================
;       PROPERTIES
; =========================

float property delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references translate to this marker. }

float property speed = 100.0 auto
{ Default: 100.0 - Speed at which the keyword-linked object references will translate to this marker. }

float property rotationSpeedClamp = 0.0 auto
{ Default: 0.0 - Amount of rotation speed clamping applied to translating objects. (0.0 means no clamp) }

bool property rotateOnArrival = false auto
{ Default: False - Should rotation of the translating objects be prevented until they arrive at this marker? }

float property tangentMagnitude = 0.0 auto
{ Default: 0.0 - Magnitude of the spline tangents. If this value is 0.0, no splines will be created. }

; =========================
;     POSITION OFFSETS
; =========================

float property offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' positions in the X direction. }

float property offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' positions in the Y direction. }

float property offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' positions in the Z direction. }

float property offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' angles in the X direction. }

float property offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' angles in the Y direction. }

float property offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' angles in the Z direction. }

; =========================
;  MOVEMENT RESTRICTIONS
; =========================

bool property limitX = false auto
{ Default: False - Prevents translation on the X axis. }

bool property limitY = false auto
{ Default: False - Prevents translation on the Y axis. }

bool property limitZ = false auto
{ Default: False - Prevents translation on the Z axis. }

bool property limitAX = false auto
{ Default: False - Prevents rotation on the X axis. }

bool property limitAY = false auto
{ Default: False - Prevents rotation on the Y axis. }

bool property limitAZ = false auto
{ Default: False - Prevents rotation on the Z axis. }

; =========================
;   TARGETING & EFFECTS
; =========================

bool property matchRotation = false auto
{ Default: False - Should the translating objects match the rotation of this marker when they arrive? }

bool property toPlayer = false auto
{ Default: False - Should the translating objects move to the player's location instead of this marker? }

bool property shakeCamera = false auto
{ Default: False - Should the camera shake upon arrival? }

float property cameraShakeStrength = 0.5 auto
{ Default: 0.5 - Strength of the camera shake (only used if shakeCamera is True). }

float property cameraShakeDuration = 0.0 auto
{ Default: 0.0 - Duration of the camera shake (only used if shakeCamera is True). }
