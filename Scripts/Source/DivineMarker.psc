; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.2.0

scriptName DivineMarker extends DivineObjectReference
; Akatosh - Dragon God of Time; maps to ordered marker activation and sequence points.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property activateKeywordRefs = true auto
{ Default: True - Should this marker activate keyword-linked object references when activated? }

bool property enableToggleKeywordRefs = false auto
{ Default: False - Should this marker toggle keyword-linked object references enabled when activated? }

; =========================
;        STATES
; =========================

state busy
    event onBeginState()
        ; Activate keyword-linked object references if enabled
        if (self.activateKeywordRefs)
            self.setKeywordRefsActivated()
        endIf

        ; Toggle keyword-linked object references if enabled
        if (self.enableToggleKeywordRefs)
            self.toggleKeywordRefsEnabled()
        endIf

        ; Transition back to waiting state
        goToState("waiting")
    endEvent
endState
