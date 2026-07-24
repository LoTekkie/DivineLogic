; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.2.0

scriptName DivineSpawnerMarker extends DivineMarker
; Mara - Mother Goddess; maps to spawn points and generative waypoints.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

float property delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references spawn to this marker. }
bool property collapseSpacing = false auto
{ Defualt: false - Should spawning objects ignore original spacing and meet at the same postion on this marker? }
float property offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects positions in the X direction. }
float property offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects positions in the Y direction. }
float property offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects positions in the Z direction. }
float property offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects angles in the X direction. }
float property offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects angles in the Y direction. }
float property offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects angles in the Z direction. }
bool property limitX = false auto
{ Default: False - Prevent spawning in the x axis. }
bool property limitY = false auto
{ Default: False - Prevent spawning in the y axis. }
bool property limitZ = false auto
{ Default: False - Prevent spawning in the z axis. }
bool property limitAX = false auto
{ Default: False - Prevent spawning in the aX axis. }
bool property limitAY = false auto
{ Default: False - Prevent spawning in the aY axis. }
bool property limitAZ = false auto
{ Default: False - Prevent spawning in the aZ axis. }
bool property matchRotation = false auto
{ Default: false - Should the spawning objects match the rotation of this marker when they arrive? }
bool property toPlayer = false auto
{ Default: False - Should the spawning objects move to the player? }
