; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.1

scriptName DivineEnabler extends DivineSignaler
; Arkay - God of the Cycle of Life and Death; maps to enable/disable state transitions.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property waitForAnimation = true auto
{ Determines whether objects should fade in/out when enabled or disabled.
  If True, objects will use smooth transitions. Default: True }

bool property relayActivation = false auto
{ If True, sends an activation signal to the non-keyword linked reference 
  instead of enabling/disabling it. Default: False }

; =========================
;     LIFECYCLE HOOKS
; =========================

function onSignalling()
    parent.onSignalling()

    if (!self.relayActivation)
        self.toggleRefEnabled(self.linkedRef, self.waitForAnimation)
    else
        self.setRefActivated(self.linkedRef, self)
    endIf

    self.toggleKeywordRefsEnabled(self.waitForAnimation)
endFunction
