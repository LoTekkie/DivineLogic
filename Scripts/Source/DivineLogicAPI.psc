; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.2.0

ScriptName DivineLogicAPI Extends Quest
; Julianos - God of Wisdom and Logic; maps to the public logic API and event contract.

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

DivineSignaler[] property signalers auto hidden
{ Reusable fixed-size signaler query result. }

int property refCount = 0 auto hidden
{ Number of active signalers in the current query result. }

int property MAX_SIGNALERS = 128 autoReadOnly hidden
{ Maximum signalers held by the reusable API query result. }

bool property showQueryDebug = false auto
{ Default: False - Output API query debug messages to logs. }

; =========================
;        FUNCTIONS
; =========================

; Get the current api version
string function getApiVersion() global
    return "1.2.0"
endFunction

; Get the current mod version
string function getModVersion() global
    return "1.2.0"
endFunction

; Get the string used to create signal mod events
string function getSignalEventName() global
    return "DivineLogic_SignalEvent"
endFunction

; Get the form id for this quest object
int function getApiFormID() global
    return 0x2029B87
endFunction

; Get the stable Divine Logic plugin file name
string function getModFileName(bool isEsm = true) global
    string extension = ".esp"
    if (isEsm)
        extension = ".esm"
    endIf    
    return "DivineLogic" + extension
endFunction

; Get the instance of DivineLogicAPI
DivineLogicAPI function getInstance() global
    string esmFileName = getModFileName(true)
    string espFileName = getModFileName(false)
    Quest apiQuest = none

    if (Game.IsPluginInstalled(esmFileName))
        apiQuest = Game.GetFormFromFile(getApiFormID(), esmFileName) as Quest
    endIf

    if (apiQuest == none && Game.IsPluginInstalled(espFileName))
        apiQuest = Game.GetFormFromFile(getApiFormID(), espFileName) as Quest
    endIf

    if apiQuest == none
        return none
    endIf

    return apiQuest as DivineLogicAPI
endFunction

; =========================
;        METHODS
; =========================

function ensureStorage()
  if (self.signalers.length != self.MAX_SIGNALERS)
    self.signalers = new DivineSignaler[128]
    self.refCount = 0
  endIf
endFunction

DivineLogicAPI function clear()
  self.ensureStorage()

  int index = 0
  while (index < self.MAX_SIGNALERS)
    self.signalers[index] = none
    index += 1
  endWhile

  self.refCount = 0
  return self
endFunction

int function count()
  return self.refCount
endFunction

DivineSignaler function getAt(int index)
  self.ensureStorage()

  if (index < 0 || index >= self.refCount)
    return none
  endIf

  return self.signalers[index]
endFunction

DivineSignaler[] function getRefs()
  self.ensureStorage()
  return self.signalers
endFunction

bool function contains(DivineSignaler signaler)
  if ( ! signaler )
    return false
  endIf

  int index = 0
  while (index < self.refCount)
    if (self.signalers[index] == signaler)
      return true
    endIf
    index += 1
  endWhile

  return false
endFunction

bool function add(DivineSignaler signaler)
  self.ensureStorage()

  if ( ! signaler || self.contains(signaler) )
    return false
  endIf

  if (self.refCount >= self.MAX_SIGNALERS)
    wrn(self + "@ function: add | API signaler query limit reached: " + self.MAX_SIGNALERS, enabled=self.showQueryDebug)
    return false
  endIf

  self.signalers[self.refCount] = signaler
  self.refCount += 1
  return true
endFunction

function removeAt(int index)
  if (index < 0 || index >= self.refCount)
    return
  endIf

  int nextIndex = index + 1
  while (nextIndex < self.refCount)
    self.signalers[nextIndex - 1] = self.signalers[nextIndex]
    nextIndex += 1
  endWhile

  self.refCount -= 1
  self.signalers[self.refCount] = none
endFunction

DivineLogicAPI function prune()
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if ( ! signaler )
      self.removeAt(index)
    else
      index += 1
    endIf
  endWhile

  return self
endFunction

DivineLogicAPI function filterByType(string signalerType)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    if ( ! self.matchesType(self.signalers[index], signalerType) )
      self.removeAt(index)
    else
      index += 1
    endIf
  endWhile

  return self
endFunction

DivineLogicAPI function filterBySignaled(bool value = true)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if ( ! signaler || signaler.signaled != value )
      self.removeAt(index)
    else
      index += 1
    endIf
  endWhile

  return self
endFunction

DivineLogicAPI function filterByPaused(bool value = true)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if ( ! signaler || signaler.paused != value )
      self.removeAt(index)
    else
      index += 1
    endIf
  endWhile

  return self
endFunction

DivineLogicAPI function filterByState(string stateName)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if ( ! signaler || signaler.GetState() != stateName )
      self.removeAt(index)
    else
      index += 1
    endIf
  endWhile

  return self
endFunction

DivineLogicAPI function filterByID(string signalerID)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if ( ! signaler || signaler.getSignalerID() != signalerID )
      self.removeAt(index)
    else
      index += 1
    endIf
  endWhile

  return self
endFunction

DivineLogicAPI function activateAll(ObjectReference activatorRef = none)
  self.ensureStorage()

  if ( ! activatorRef )
    activatorRef = Game.GetPlayer()
  endIf

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if (signaler)
      signaler.activate(activatorRef)
    endIf
    index += 1
  endWhile

  return self
endFunction

DivineLogicAPI function pauseAll(bool paused = true)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if (signaler)
      signaler.paused = paused
      signaler.setActivationBlocked(paused)
    endIf
    index += 1
  endWhile

  return self
endFunction

DivineLogicAPI function enableAll(bool enabled = true)
  self.ensureStorage()

  int index = 0
  while (index < self.refCount)
    DivineSignaler signaler = self.signalers[index]
    if (signaler)
      if (enabled)
        signaler.enable(false)
      else
        signaler.disable(false)
      endIf
    endIf
    index += 1
  endWhile

  return self
endFunction

; Get Divine signalers in the player's current cell
DivineLogicAPI function getSignalersInPlayerCell()
    Actor playerRef = Game.GetPlayer()
    if ( ! playerRef )
        return self.clear()
    endIf

    return self.getSignalersInSameCell(playerRef)
endFunction

; Get Divine signalers in the same cell as the given reference
DivineLogicAPI function getSignalersInSameCell(ObjectReference centerRef)
    self.clear()

    if ( ! centerRef )
        return self
    endIf

    Cell targetCell = centerRef.GetParentCell()
    if ( ! targetCell )
        return self
    endIf

    int refTotal = targetCell.GetNumRefs()
    int index = 0
    while (index < refTotal && self.refCount < self.MAX_SIGNALERS)
        ObjectReference ref = targetCell.GetNthRef(index)
        DivineSignaler signaler = ref as DivineSignaler
        if (signaler)
            self.add(signaler)
        endIf
        index += 1
    endWhile

    info(self + "@ function: getSignalersInSameCell | found: " + self.refCount, enabled=self.showQueryDebug)
    return self
endFunction

bool function matchesType(DivineSignaler signaler, string signalerType)
  if ( ! signaler )
    return false
  endIf

  if (signalerType == "" || signalerType == "DivineSignaler")
    return true
  elseIf (signalerType == "DivineActivator")
    return (signaler as DivineActivator) != none
  elseIf (signalerType == "DivineActorModifier")
    return (signaler as DivineActorModifier) != none
  elseIf (signalerType == "DivineAnimator")
    return (signaler as DivineAnimator) != none
  elseIf (signalerType == "DivineComparer")
    return (signaler as DivineComparer) != none
  elseIf (signalerType == "DivineContainerizer")
    return (signaler as DivineContainerizer) != none
  elseIf (signalerType == "DivineCutsceneCreator")
    return (signaler as DivineCutsceneCreator) != none
  elseIf (signalerType == "DivineDestroyer")
    return (signaler as DivineDestroyer) != none
  elseIf (signalerType == "DivineEnabler")
    return (signaler as DivineEnabler) != none
  elseIf (signalerType == "DivineForcer")
    return (signaler as DivineForcer) != none
  elseIf (signalerType == "DivineGlobalModifier")
    return (signaler as DivineGlobalModifier) != none
  elseIf (signalerType == "DivineMessenger")
    return (signaler as DivineMessenger) != none
  elseIf (signalerType == "DivineMixer")
    return (signaler as DivineMixer) != none
  elseIf (signalerType == "DivinePlayerController")
    return (signaler as DivinePlayerController) != none
  elseIf (signalerType == "DivineScaler")
    return (signaler as DivineScaler) != none
  elseIf (signalerType == "DivineSpawner")
    return (signaler as DivineSpawner) != none
  elseIf (signalerType == "DivineTranslator")
    return (signaler as DivineTranslator) != none
  elseIf (signalerType == "DivineWarper")
    return (signaler as DivineWarper) != none
  endIf

  return false
endFunction

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
