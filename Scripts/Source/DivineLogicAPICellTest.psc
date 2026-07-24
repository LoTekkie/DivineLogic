; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.2.0

ScriptName DivineLogicAPICellTest Extends ObjectReference
; Julianos - God of Wisdom and Logic; maps to quick API cell-query validation.

import DivineLogicAPI

bool property runOnLoad = false auto
{ Default: False - run this API test when the reference loads. }

bool property activateMatches = false auto
{ Default: False - activate filtered signalers after the query runs. }

bool property showTrace = true auto
{ Default: True - write test output to the Papyrus log. }

string property filterType = "DivineActivator" auto
{ Divine signaler script name to filter by, such as DivineMessenger or DivineTranslator. }

DivineSignaler property expectedSignaler auto
{ Optional signaler expected to be found in this reference's cell. }

event OnLoad()
  if (self.runOnLoad)
    self.runTest(Game.GetPlayer())
  endIf
endEvent

event OnActivate(ObjectReference akActionRef)
  self.runTest(akActionRef)
endEvent

function runTest(ObjectReference activatorRef)
  DivineLogicAPI api = DivineLogicAPI.getInstance()

  if ( ! api )
    self.trace("API not found.")
    return
  endIf

  api.getSignalersInSameCell(self)

  int totalSignalers = api.count()
  bool foundExpected = false

  if (self.expectedSignaler)
    foundExpected = api.contains(self.expectedSignaler)
  endIf

  self.trace("Total Divine signalers in cell: " + totalSignalers)
  self.trace("Expected signaler found: " + foundExpected)

  api.filterByType(self.filterType)

  int filteredSignalers = api.count()
  self.trace("Filter type: " + self.filterType)
  self.trace("Filtered count: " + filteredSignalers)

  if (self.activateMatches && filteredSignalers > 0)
    self.trace("Activating filtered signalers.")
    api.activateAll(activatorRef)
  endIf
endFunction

function trace(string logMessage)
  if (self.showTrace)
    Debug.Trace("[DivineLogicAPICellTest] " + logMessage)
  endIf
endFunction
