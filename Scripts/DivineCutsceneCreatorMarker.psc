scriptName DivineCutsceneCreatorMarker extends DivineMarker
; Talos - Hero-god of Mankind, conqueror God, God of Might, Honor, State, Law, and Man

import DivineUtils

float property delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references translate to this marker. }
float property speed = 100.0 auto
{ Default: 100.0 - Speed at which the keyword-linked object references will translate to this marker. }
float property rotationSpeedClamp = 0.0 auto
{ Default: 0.0 - Amount of rotation speed clamping applied to translating objects. (0.0 means don't clamp rotation speed) }
bool property rotateOnArrival = false auto
{ Default: false - Should rotation of the translating objects be prevented until they arrive at this marker? }
float property tangentMagnitude = 0.0 auto
{ Default: 0.0 - Magnitude of the spline tangents. If this value is 0.0 no splines will be created. } 
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
{ Default: false - Should the translating objects match the rotation of this marker when they arrive? }
bool property toPlayer = false auto
{ Default: False - Should the translating objects move to the player? }
bool property shakeCamera = false auto
{ Default: False - Shake the player camera? }
float property cameraShakeStrength = 0.5 auto
{ Default: 0.5 - How strong should the camera shake? (Only used when the shakeCamera property is set to True) }
float property cameraShakeDuration = 0.0 auto
{ Default: 0.0 - How long should the camera shake? (Only used when the shakeCamera property is set to True) }