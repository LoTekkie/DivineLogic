scriptName DivineScaler extends DivineSignaler
; Dibella – Goddess of Beauty and Love

import DivineUtils

; =========================
;        PROPERTIES
; =========================

float property scaleMin = 1.0 auto
{ Minimum scale value when the object is activated. }

float property scaleMax = 1.0 auto
{ Maximum scale value if "scaleRandomly" is enabled. }

bool property linearScale = false auto
{ Enables gradual scaling over time between "scaleMin" and "scaleMax". }

float property scaleInterval = 0.1 auto
{ Incremental scale adjustment per activation if "linearScale" is enabled. }

bool property scaleRandomly = false auto
{ If enabled, scales to a random value between "scaleMin" and "scaleMax".
  Overrides "toggleMinMax" when active. }

bool property scaleSync = true auto
{ Ensures all objects scale uniformly when "scaleRandomly" is enabled. }

bool property toggleMinMax = false auto
{ Cycles between "scaleMin" and "scaleMax" on each activation. 
  Starts with "scaleMin". }

bool property relayActivation = false auto
{ Sends an activation signal to the linked reference instead of scaling it. }

float property currentScale auto hidden
{ Tracks the current scale for linear scaling purposes. }

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
    parent.onSignalling()

    if (self.relayActivation)
        self.handleRelayActivation()
    else
        self.handleScaling()
    endIf
endFunction

; =========================
;  HANDLING RELAY ACTIVATION
; =========================

function handleRelayActivation()
    self.setRefActivated(self.linkedRef, self)

    if (self.scaleRandomly && !self.scaleSync)
        self.scaleKeywordRefsBetween(self.scaleMin, self.scaleMax, true)
    else
        float newScale = self.getNewScale()
        self.scaleKeywordRefs(newScale, true)
    endIf
endFunction

; =========================
;   SCALING LOGIC HANDLING
; =========================

function handleScaling()
    float newScale = self.getNewScale()

    if (self.scaleRandomly && !self.scaleSync)
        self.scaleRefBetween(self.linkedRef, self.scaleMin, self.scaleMax, true)
        self.scaleKeywordRefsBetween(self.scaleMin, self.scaleMax, true)
    else
        self.scaleRef(self.linkedRef, newScale, true)
        self.scaleKeywordRefs(newScale, true)
    endIf
endFunction

; Determines the new scale based on properties
float function getNewScale()
    float newScale = self.scaleMin

    if (self.scaleRandomly)
        newScale = utility.randomFloat(self.scaleMin, self.scaleMax)
    elseIf (self.toggleMinMax)
        if (self.signaled)
            newScale = self.scaleMin
        else
            newScale = self.scaleMax
        endIf
    elseIf (self.linearScale)
        newScale = self.getNextLinearScale()
    endIf

    return newScale
endFunction

; Handles incremental scaling for linear scaling mode
float function getNextLinearScale()
    if (self.currentScale == 0.0)
        self.currentScale = self.scaleMax
    endIf

    float newScale = self.currentScale - self.scaleInterval

    if (newScale < self.scaleMin)
        newScale = self.scaleMin
    endIf

    self.currentScale = newScale
    return newScale
endFunction
