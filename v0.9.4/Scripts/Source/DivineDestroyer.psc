scriptName DivineDestroyer extends DivineSignaler
; Arkay – God of the Cycle of Life and Death, overseeing mortal burials and funeral rites.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property whenAble = false auto
{ Determines whether deletion should wait for linked references to lose their parent cell 
  or for their parent cell to become detached before deletion. Default: False. }

bool property relayActivation = false auto
{ If enabled, sends an activation signal to the linked reference instead of deleting it. 
  Default: False. }

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
    parent.onSignalling()

    if (self.relayActivation)
        self.handleRelayActivation()
    else
        self.handleDestruction()
    endIf

    ; Always delete keyword-linked references
    self.deleteKeywordRefs(self.whenAble)
endFunction

; =========================
;   HANDLING RELAY ACTIVATION
; =========================

function handleRelayActivation()
    self.setRefActivated(self.linkedRef, self)
endFunction

; =========================
;  HANDLING DESTRUCTION LOGIC
; =========================

function handleDestruction()
    self.deleteRef(self.linkedRef, self.whenAble)
endFunction
