; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)

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
;         METHODS
; =========================

function handleRelayActivation()
    self.setRefActivated(self.linkedRef, self)
endFunction

function handleDestruction()
    self.deleteRef(self.linkedRef, self.whenAble)
endFunction

; =========================
;     LIFECYCLE HOOKS
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
