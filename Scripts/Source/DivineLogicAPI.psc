; Divine Logic API (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineLogicAPI

import Utility
import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property showDebug = false auto
{ Default: False - Output Divine Logic API debug messages to logs. }

string property EVENT_DIVINE_SIGNAL = "DivineSignalEvent" autoReadOnly hidden
{ Name of the custom event used for signaling. }

string property VERSION_MOD_CURRENT = "1.0" autoReadOnly hidden 
{ Current version of the Divine Logic mod. }

string property VERSION_API_CURRENT = "1.0" autoReadOnly hidden
{ Current version of the Divine Logic API. }

string property FILE_DIVINE_LOGIC = "DivineLogic.esm" autoReadOnly hidden
{ File name for the Divine Logic master plugin. }

; =========================
;         EVENTS
; =========================

event onInit()
    info(self + "@ event: onInit | DivineLogicAPI v" + self.getAPiVersion() + " initialized.", self.showDebug)
endEvent

; =========================
;        METHODS
; =========================

string function getAPiVersion()
    return self.VERSION_API_CURRENT
endFunction

string function getModVersion() 
    return self.VERSION_MOD_CURRENT
endFunction

function setDebug(bool showDebug)
    self.showDebug = showDebug
endFunction

; LISTENERS & SIGNALS

; Register an event to listen for Divine Logic signals
function registerForSignalEvents(Form akForm, string callbackName)
    form.RegisterForModEvent(self.EVENT_DIVINE_SIGNAL, callbackName)
    info(self + "@ function: registerForSignalEvents | registered callback: " + callbackName, self.showDebug)
endFunction

; Fire a signal event when a signal is sent
function fireSignalEvent(DivineSignaler signaler)
    form.SendModEvent(self.EVENT_DIVINE_SIGNAL, signaler)
    info(self + "@ function: fireSignalEvent | fired signal from: " + signaler, self.showDebug)
endFunction

; SIGNALER SEARCH API