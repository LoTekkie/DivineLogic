; Divine Logic API (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineLogicAPITests extends DivineSignaler
; Stendarr – God of Compassion, Mercy, Justice, Charity, Luck, and Righteous Rule by Might and Merciful Forbearance.

import DivineLogicAPI
import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property runOnStart = true auto
{ Default: True - run the Divine Logic API tests when the game is loaded. }

bool property runOnSignal = true auto
{ Default: True - run when the object this script is attached to sends a signal. }

DivineSignaler Property signalerRef auto
{ a signaler object to test with }

bool property showAPIDebug = false auto
{ Default: False - should the unerlying api log to console? }

; =========================
;         EVENTS
; =========================

event onInit()
  self.api = getAPi()

  if ( ! self.hasRequirements(false) )
    err("@event: onInit | Unable to initialize DivineLogicAPiTests")
  else
    info(self + "@ event: onInit | DivineLogicAPITests initialized.", enabled=self.showDebug)
    
    self.api.showDebug = self.showAPIDebug
  endIf
endEvent

event onLoad()
    if (self.runOnStart)
        self.runTests()
    endIf
endEvent

; =========================
;         METHODS
; =========================

bool function hasRequirements(bool quiet=true) 
  if ( ! self.api )
    err(self + "@ function: hasRequirements | missing api reference.", enabled=!quiet)
    return false
  endIf

  if ( ! self.signalerRef )
    err(self + "@ function: hasRequirements | missing signaler reference.", enabled=!quiet)
    return false
  endIf

  return true
endFunction

function runTests() 
    info(self + "@ function: runTests | start", enabled=self.showDebug)
    bool[] results = new bool[2]
    
    if (self.hasRequirements())
      results[0] = self.testRegisterForSignalEvents()
      results[1] = self.testFireSignalEvents()
    endIf  
    ;run tests

    bool eval = isArrAllTrue(results)

    ;report
    info(self + "@ function: runTests | end", enabled=self.showDebug)
    info(self + "@ function: runTests | report:", enabled=self.showDebug)
    info(self + "@ Has Requirements: " + self.hasRequirements(), enabled=self.showDebug)
    info(self + "@ Total tests run: " + results.length, enabled=self.showDebug)
    info(self + "@ Results: " + results, enabled=self.showDebug)
    info(self + "@ Eval: " + eval, enabled=self.showDebug)
endFunction    

bool function testRegisterForSignalEvents()
  return self.api.registerForSignalEvents(self, "onExternalSignal")
endFunction 

bool function testFireSignalEvents()
  return self.api.fireSignalEvent(self)
endFunction

function runCustomSignalLogic()
  ;do something else
endFunction

event onExternalSignal(string apiVersion, string signalName, string signalID, Form signaler)
  if (signalID == self.signalerRef.getSignalerID())
    info(self + "@ event: onExternalSignal | signal recieved! | api version: " \
    + apiVersion + " | signalName: " + signalName + " | signaler: " \
    + signaler + " | signalID: " + signalID, enabled=self.showDebug)
    ;self.signalerRef.shutDown()
    self.runCustomSignalLogic()
  endIf
endEvent

event onSignalling()
  parent.onSignalling()
  if (self.runOnSignal)
    runTests()
  endIf
endEvent