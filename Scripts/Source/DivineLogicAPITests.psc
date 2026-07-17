; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.1

ScriptName DivineLogicAPITests extends DivineSignaler
; Julianos - God of Wisdom and Logic; maps to API validation and test assertions.

import DivineLogicAPI
import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property runOnStart = false auto
{ Default: False - run the Divine Logic API tests when the game is loaded. }

bool property runOnSignal = false auto
{ Default: False - run when the object this script is attached to sends a signal. }

bool property enableTests = false auto
{ Default: False - allow this development-only test script to run. Keep disabled in production cells. }

DivineSignaler Property signalerRef auto
{ a signaler object to test with }

bool property showAPIDebug = false auto
{ Default: False - should the unerlying api log to console? }

bool property profileScript = false auto
{ Default: False - should a script be profiled? }

string property profileScriptName auto
{ Default: "" - the name of the script to profile }

float property profileDuration = 10.0 auto
{ Default: 10.0 - seconds to profile when profileScript is enabled. }

bool property isTestsRunning = false auto hidden
{ Flag to indicate if tests are currently running. }

bool property isProfilerRunning = false auto hidden
{ Flag to indicate if the profiler is currently running. }

; =========================
;         EVENTS
; =========================

event onInit()
  self.api = getAPi()

  if ( ! self.hasTestRequirements(false) )
    err("@event: onInit | Unable to initialize DivineLogicAPiTests")
  else
    info(self + "@ event: onInit | DivineLogicAPITests initialized.", enabled=self.showDebug)
    
    self.api.showDebug = self.showAPIDebug
  endIf
endEvent

event onLoad()
    if (self.enableTests && self.runOnStart)
      if ( ! self.isTestsRunning )
        self.runTests()
      endIf  
      if ( ! self.isProfilerRunning )
        self.runProfiler()
      endIf  
    endIf
endEvent

event onSignalling()
  parent.onSignalling()
  if (self.enableTests && self.runOnSignal)
    if ( ! self.isTestsRunning )
      self.runTests()
    endIf  
    if ( ! self.isProfilerRunning )
      self.runProfiler()
    endIf  
  endIf
endEvent

; =========================
;         METHODS
; =========================

; Check that we have everything we need to properly test
bool function hasTestRequirements(bool quiet=true) 
  if ( ! self.api )
    err(self + "@ function: hasTestRequirements | missing api reference.", enabled=!quiet)
    return false
  endIf

  if ( ! self.signalerRef )
    err(self + "@ function: hasTestRequirements | missing signaler reference.", enabled=!quiet)
    return false
  endIf

  return true
endFunction

; Check that we have everything we need to properly run the profiler
bool function hasProfileRequirements(bool quiet=true)
  if (self.profileScript && ! self.profileScriptName)
    err(self + "@ function: hasProfileRequirements | missing script name.", enabled=!quiet)
    return false
  endIf
  return true
endFunction

function runProfiler()
  if ( ! self.enableTests )
    return
  endIf

  self.isProfilerRunning = true
  info(self + "@ function: runProfiler | start", enabled=self.showDebug)

  ; Run the profiler
  if (self.hasProfileRequirements())
    self.api.profileScriptStart(self.profileScriptName)
    if (self.profileScript && self.profileDuration > 0.0)
      utility.wait(self.profileDuration)
      self.api.profileScriptEnd(self.profileScriptName)
    endIf
  endIf  

  info(self + "@ function: runProfiler | end", enabled=self.showDebug)
  info(self + "@ function: runProfiler | report:", enabled=self.showDebug)
  info(self + "@ function: runProfiler | has requirements: " + self.hasProfileRequirements(), enabled=self.showDebug)
  self.isProfilerRunning = false
endFunction

; Run the tests
function runTests() 
    if ( ! self.enableTests )
      return
    endIf

    self.isTestsRunning = true
    info(self + "@ function: runTests | start", enabled=self.showDebug)
    bool[] results = new bool[3]
    
    ;run tests
    if (self.hasTestRequirements()) 
      results[0] = self.testRegisterForSignalEvents()
      results[1] = self.testFireSignalEvents()
      results[2] = self.testGetSignalersInSameCell()
    endIf  
    
    bool eval = isArrAllTrue(results)

    ;report
    info(self + "@ function: runTests | end", enabled=self.showDebug)
    info(self + "@ function: runTests | report:", enabled=self.showDebug)
    info(self + "@ function: runTests | has requirements: " + self.hasTestRequirements(), enabled=self.showDebug)
    info(self + "@ function: runTests | total tests run: " + results.length, enabled=self.showDebug)
    info(self + "@ function: runTests | results: " + results, enabled=self.showDebug)
    info(self + "@ function: runTests | eval: " + eval, enabled=self.showDebug)
    self.isTestsRunning = false
endFunction

; Test that we can register for signal events
bool function testRegisterForSignalEvents()
  return self.api.registerForSignalEvents(self, "onExternalSignal")
endFunction 

; Test that we can fire a signal event
bool function testFireSignalEvents()
  return self.api.fireSignalEvent(self)
endFunction

; Test that the API can find signalers in a loaded cell
bool function testGetSignalersInSameCell()
  DivineLogicAPI queryResult = self.api.getSignalersInSameCell(self.signalerRef)
  return queryResult && queryResult.contains(self.signalerRef)
endFunction

; Run some custom logic
function runCustomSignalLogic()
  ;do something else
endFunction

; Handler that is listening for external signal events
event onExternalSignal(string apiVersion, string signalName, string signalID, Form signaler)
  if (signalID == self.signalerRef.getSignalerID())
    info(self + "@ event: onExternalSignal | signal recieved! | api version: " \
    + apiVersion + " | signalName: " + signalName + " | signaler: " \
    + signaler + " | signalID: " + signalID, enabled=self.showDebug)
    ;self.signalerRef.shutDown()
    self.runCustomSignalLogic()
  endIf
endEvent
