scriptName DivineMarker extends DivineObjectReference
; ===================================
;        DivineMarker Script
; ===================================
; Base class for all Divine logic markers.
; This marker can activate keyword-linked object references 
; and toggle their enabled state when activated.
; ===================================

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
