; Divine Logic API (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineLogicAPI Extends Quest

import Utility
import DivineUtils
import DivineConstants

; =========================
;        PROPERTIES
; =========================

bool property showDebug = false auto
{ Default: False - Output Divine Logic API debug messages to logs. }

; =========================
;        EVENTS
; =========================

event onInit()
    info(self + "@ event: onInit | DivineLogicAPI v" + self.getVersion() + " initialized.", self.showDebug)
endEvent

; =========================
;        METHODS
; =========================

function getVersion()
    return self.VERSION_API_CURRENT
endFunction

; LISTENERS & SIGNALS

; Register an external script to listen for Divine Logic signals
function registerForSignalEvents(ScriptObject listener)
    RegisterForCustomEvent(self, self.CUSTOM_EVENT_NAME)
    info(self + "@ function: registerForSignalEvents | registered listener: " + listener, self.showDebug)
endFunction

; Fire a signal event when a signal is sent
function fireSignalEvent(ObjectReference signaler)
    SendCustomEvent(self.CUSTOM_EVENT_NAME, signaler)
    info(self + "@ function: fireSignalEvent | fired signal from: " + signaler, self.showDebug)
endFunction

; SIGNALER SEARCH API

; Get all Divine Logic signalers by type
function getSignalersByType(string signalerType) global
    DivineSignalerCollection collection = new DivineSignalerCollection
    ObjectReference[] allRefs = Game.FindAllReferencesOfTypeFromRef(Game.GetFormFromFile(signalerType, "DivineLogic.esm"), None, 10000)
    
    int i = 0
    while i < allRefs.length
        if allRefs[i] as DivineSignaler
            collection.add(allRefs[i] as DivineSignaler)
        endIf
        i += 1
    endWhile
    
    info(self + "@ function: getSignalersByType | signalerType: " + signalerType + " | found: " + collection.count(), self.showDebug)
    return collection
endFunction

; Get all currently active signalers
function getActiveSignalers() global
    DivineSignalerCollection collection = new DivineSignalerCollection
    ObjectReference[] allRefs = Game.FindAllReferencesOfTypeFromRef(Game.GetFormFromFile("DivineSignaler", "DivineLogic.esm"), None, 10000)
    
    int i = 0
    while i < allRefs.length
        DivineSignaler signaler = allRefs[i] as DivineSignaler
        if signaler && signaler.isActive()
            collection.add(signaler)
        endIf
        i += 1
    endWhile

    info(self + "@ function: getActiveSignalers | found: " + collection.count(), self.showDebug)
    return collection
endFunction

; Get all inactive signalers
function getInactiveSignalers() global
    DivineSignalerCollection collection = new DivineSignalerCollection
    ObjectReference[] allRefs = Game.FindAllReferencesOfTypeFromRef(Game.GetFormFromFile(self.EVENT_DIVINE_SIGNAL, self.FILE_DIVINE_LOGIC), None, 10000)
    
    int i = 0
    while i < allRefs.length
        DivineSignaler signaler = allRefs[i] as DivineSignaler
        if signaler && !signaler.isActive()
            collection.add(signaler)
        endIf
        i += 1
    endWhile

    info(self + "@ function: getInactiveSignalers | found: " + collection.count(), self.showDebug)
    return collection
endFunction
