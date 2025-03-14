; Divine Logic API (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineLogicAPI Extends Quest
; Julianos – God of Wisdom and Logic

import Utility
import DivineUtils
import Debug

; =========================
;        PROPERTIES
; =========================

bool property showDebug = false auto
{ Default: False - Output divine logic api debug messages to logs. }

bool property signalEventsEnabled = true auto
{ Should events be broadcast? }

; =========================
;        FUNCTIONS
; =========================

; Get the current api version
string function getApiVersion() global
    return "1.0"
endFunction

; Get the current mod version
string function getModVersion() global
    return "1.0"
endFunction

; Get the string used to create signal mod events
string function getSignalEventName() global
    return "DivineLogic_SignalEvent"
endFunction

; Get the form id for this quest object
int function getApiFormID() global
    return 0x2029B87
endFunction

; Get the versioned mod file name
string function getModFileName(bool isEsm = false) global
    string extension = ".esp"
    if (isEsm)
        extension = ".esm"
    endIf    
    return "DivineLogic_v" + getApiVersion() + extension
endFunction

; Get the instance of DivineLogicAPI
DivineLogicAPI function getInstance() global
    Quest apiQuest = Game.GetFormFromFile(getApiFormID(), getModFileName()) as Quest
    if apiQuest == none
        err("@ function: getInstance | API Quest not found! | formID: " + getApiFormID() + " | modFileName: " + getModFileName())
        return none
    endIf
    return apiQuest as DivineLogicAPI
endFunction

; =========================
;        METHODS
; =========================

; Register an event to listen for Divine Logic signals
bool function registerForSignalEvents(Form listener, string callbackName)
    listener.RegisterForModEvent(getSignalEventName(), callbackName)
    info(self + "@ function: registerForSignalEvents | registered callback: " + callbackName, enabled=self.showDebug)
    return true
endFunction

; Fire a signal event when a signal is sent
bool function fireSignalEvent(DivineSignaler signaler)
  if ( ! self.signalEventsEnabled )
    info(self + "@ function: fireSignalEvent | signal events are disabled!", enabled=self.showDebug)
    return false
  endIf
  int handle = ModEvent.create(getSignalEventName())
	if (handle)
        ModEvent.PushString(handle, getApiVersion())
        ModEvent.PushString(handle, getSignalEventName())
        ModEvent.PushString(handle, signaler.getSignalerID())
        ModEvent.PushForm(handle, signaler)
        if (ModEvent.Send(handle))
            info(self + "@ function: fireSignalEvent | fired signal from: " + signaler, enabled=self.showDebug)
            return true
        endIf    
	endIf
    return false
endFunction

function profileScriptStart(string script)
  Debug.StartScriptProfiling(script)
endFunction

function profileScriptEnd(string script)
  Debug.StopScriptProfiling(script)
endFunction
