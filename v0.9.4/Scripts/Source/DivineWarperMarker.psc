scriptName DivineWarperMarker extends DivineMarker
; Akatosh – The Dragon God of Time and chief god of the pantheon

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property warpPlayer = false auto
{ Default: false - Should the player be warped to this marker? }

float property delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references warp to this marker. }

bool property collapseSpacing = false auto
{ Defualt: false - Should warped objects ignore original spacing and meet at the same postion on this marker? }

float property offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects positions in the X direction. }

float property offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects positions in the Y direction. }

float property offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects positions in the Z direction. }

float property offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects angles in the X direction. }

float property offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects angles in the Y direction. }

float property offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects angles in the Z direction. }

bool property limitX = false auto
{ Default: False - Prevent warping in the x axis. }

bool property limitY = false auto
{ Default: False - Prevent warping in the y axis. }

bool property limitZ = false auto
{ Default: False - Prevent warping in the z axis. }

bool property limitAX = false auto
{ Default: False - Prevent warping in the aX axis. }

bool property limitAY = false auto
{ Default: False - Prevent warping in the aY axis. }

bool property limitAZ = false auto
{ Default: False - Prevent warping in the aZ axis. }

bool property matchRotation = false auto
{ Default: false - Should the warping objects match the rotation of this marker when they arrive? }

bool property toPlayer = false auto
{ Default: False - Should the warping objects move to the player? }