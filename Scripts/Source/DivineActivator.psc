; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.1

scriptName DivineActivator extends DivineSignaler
; Stendarr - God of Mercy and Righteous Rule; maps to deliberate activation and command.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property randomlyActivateKeywordRefs = false auto
{ Default: False - Activate one random keyword-linked reference instead of all keyword-linked references. }

bool property sequentiallyActivateKeywordRefs = false auto
{ Default: False - Activate one keyword-linked reference per signal, advancing through the keyword-linked reference list. Ignored when randomlyActivateKeywordRefs is True. }

int property nextKeywordRefIndex = 0 auto hidden
{ Internal index used by sequentiallyActivateKeywordRefs. }

; =========================
;     LIFECYCLE HOOKS
; =========================

function onSignalling()
    parent.onSignalling()

    ; Activate the linked reference if it exists
    self.setRefActivated(self.linkedRef, self)

    if (self.randomlyActivateKeywordRefs)
        self.activateRandomKeywordRef()
    elseIf (self.sequentiallyActivateKeywordRefs)
        self.activateSequentialKeywordRef()
    else
        ; Activate all keyword-linked references
        self.setKeywordRefsActivated()
    endIf
endFunction

function activateRandomKeywordRef()
    int refCount = self.keywordRefs.length
    if (refCount <= 0)
        return
    endIf

    int startIndex = utility.randomInt(0, refCount - 1)
    int offset = 0
    while (offset < refCount)
        int refIndex = startIndex + offset
        if (refIndex >= refCount)
            refIndex -= refCount
        endIf

        objectReference ref = self.keywordRefs[refIndex]
        if (ref)
            self.setRefActivated(ref, self)
            return
        endIf
        offset += 1
    endWhile
endFunction

function activateSequentialKeywordRef()
    int refCount = self.keywordRefs.length
    if (refCount <= 0)
        return
    endIf

    if (self.nextKeywordRefIndex < 0 || self.nextKeywordRefIndex >= refCount)
        self.nextKeywordRefIndex = 0
    endIf

    int offset = 0
    while (offset < refCount)
        int refIndex = self.nextKeywordRefIndex + offset
        if (refIndex >= refCount)
            refIndex -= refCount
        endIf

        objectReference ref = self.keywordRefs[refIndex]
        if (ref)
            self.nextKeywordRefIndex = refIndex + 1
            if (self.nextKeywordRefIndex >= refCount)
                self.nextKeywordRefIndex = 0
            endIf
            self.setRefActivated(ref, self)
            return
        endIf
        offset += 1
    endWhile

    self.nextKeywordRefIndex = 0
endFunction
