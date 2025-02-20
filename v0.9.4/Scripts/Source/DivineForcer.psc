scriptName DivineForcer extends DivineSignaler
; Kynareth - Goddess of Air, Wind, Sky, and the Elements

import DivineUtils

; =========================
;      FORCE PROPERTIES
; =========================

bool property heartbeat = false auto hidden
{ Internal: Toggles between `implode` and `explode` when both are enabled. }

bool property relayActivation = false auto
{ Default: False - Sends an activation signal to the non-keyword linked reference instead of applying a force signal. }

float property XforceVector = 0.0 auto
{ Default: 0.0 - X component of the applied force vector. }

float property YforceVector = 0.0 auto
{ Default: 0.0 - Y component of the applied force vector. }

float property ZforceVector = 0.0 auto
{ Default: 0.0 - Z component of the applied force vector. }

float property forceMagnitude = 10.0 auto
{ Default: 10.0 - The magnitude (strength) of the applied force. }

bool property forcePlayer = false auto
{ Default: False - Determines if the applied force should affect the player. }

bool property explode = false auto
{ Default: False - Pushes all linked object references **away** from this object. }

bool property implode = false auto
{ Default: False - Pulls all linked object references **toward** this object. }

; =========================
;      INITIALIZATION
; =========================

event onInit()
    parent.onInit()
    
    ; If both implode and explode are true, disable explode and enable heartbeat mode
    if (self.explode && self.implode)
        self.explode = false
        self.heartbeat = true
    endIf
endEvent

; =========================
;      FORCE APPLICATION
; =========================

function onSignalling()
    ; Toggle explode/implode in heartbeat mode
    if (self.heartbeat)
        self.explode = !self.explode
        self.implode = !self.implode
    endIf

    ; Apply force to the player if enabled
    if (self.forcePlayer)
        self.impulseRef(       \
            self.playerRef,    \
            self.XforceVector, \
            self.YforceVector, \
            self.ZforceVector, \
            self.forceMagnitude, \
            self.explode,      \
            self.implode       \
        )
    endIf

    ; Apply force to all keyword-linked object references
    self.impulseKeywordRefs( \
        self.XforceVector,   \
        self.YforceVector,   \
        self.ZforceVector,   \
        self.forceMagnitude, \
        self.explode,        \
        self.implode         \
    )

    ; Apply force to the linked reference or activate it
    if (!self.relayActivation && self.linkedRef)
        self.impulseRef(       \
            self.linkedRef,    \
            self.XforceVector, \
            self.YforceVector, \
            self.ZforceVector, \
            self.forceMagnitude, \
            self.explode,      \
            self.implode       \
        )
    else
        self.setRefActivated(self.linkedRef, self)
    endIf
endFunction
