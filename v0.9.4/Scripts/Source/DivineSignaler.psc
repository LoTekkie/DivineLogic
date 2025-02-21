scriptName DivineSignaler extends DivineObjectReference
; Base class for all Divine Logic signalers

import DivineUtils
import Math

; =========================
;        PROPERTIES
; =========================

bool property signalOnStart = false auto
{ Default: False - Send a signal to all attached objects when the game is loaded. }

bool property signalOnce = false auto
{ Default: False - Send a signal only once for the lifetime of the trigger. }

int property signalLimit = 0 auto
{ Default: 0 - How many times total should this trigger signal? (Overridden when setting signalOnce to True, values less than 0 will signal once) }

bool property signalContinuously = false auto
{ Default: False - Send a signal every x number of seconds where x is the value of "signalDelay".
Combine this with "signalOnStart" to automatically signal forever once the game is loaded. }

bool property detectHit = false auto
{ Default: False - Should this trigger send a signal when hit? }

string property detectHitSource = "" auto
{ Default: "" - Name of the source to filter detectHit by. (Only used when detectHit is True)} 

bool property detectPlayer = false auto
{ Default: False - Should this trigger send a signal when the Player enters it? }

bool property detectNPC = false auto
{ Default: False - Should this trigger send a signal when an NPC enters it? }

int property detectEquippedItemType = -1 auto
{ Default: -1 (Don't Detect) - Should this trigger require an equipped item type before it signals? 
Detected item types can be one of:
-1: Don't Detect
0: Nothing (Hand to hand)
1: One-handed sword
2: One-handed dagger
3: One-handed axe
4: One-handed mace
5: Two-handed sword
6: Two-handed axe/mace
7: Bow
8: Staff
9: Magic spell
10: Shield
11: Torch
12: Crossbow }

bool property paused = false auto hidden
{ Default: False - Prevent any input to or signaling from this trigger. }

bool property ignoreBusy = false auto hidden
{ Should we prevent reaching the busy state? }

bool property sendTogglePauseSignal = false auto
{ Default: False - Pause all attached signalers when this one sends a signal. }

bool property preventDefaultSignal = false auto
{ Default: False - Prevent the default signal behavior from occuring.
Pause signals will still be sent when this trigger signals. }

float property signalDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait before a signal is sent after activation. }

float property postSignalDelay = 2.0 auto
{ Default: 2.0 - Seconds to wait after a signal is sent before the trigger
accepts input or sends signals again. }

float[] property keywordRefSpacingOffsets auto hidden; x, y, z for each of the 9 keyword-linked object references
{ Reference to offsets from the calculated collective center of all attched object references. }

float property continuousSignalDelayMin = 0.25 autoReadOnly hidden
{ Minimum value for the user set delay when the signalContinuously property value is set to true. }

int property signalCount = 0 auto hidden
{ How many times has this signaled? }

; Set whether or not activation should be blocked
function setActivationBlocked(bool blocked=true)
  self.blockActivation(blocked)
endFunction

;/ Set whether or not a divineRef object is paused
Pausing prevents any input and disables activation/signalling until unpaused /;
function setRefPaused(DivineSignaler divineRef, bool pause=true)
  divineRef.paused = pause
  divineRef.setActivationBlocked(pause)
  dd(self + "@ signal: pause | ref: " + divineRef + " | paused: " + divineRef.paused, enabled=self.showDebug)
endFunction

; Set the keywordRefSpacingOffsets property
function setKeywordRefSpacingOffsets()
  if ( ! self.keywordRefSpacingOffsets.length )
    self.keywordRefSpacingOffsets = self.getKeywordRefSpacingOffsets()
    dd(self + "@ function: setKeywordRefSpacingOffsets | offsets: " + self.keywordRefSpacingOffsets, enabled=self.showDebug)
  endIf
endFunction

; Toggle the given objectReference paused
function toggleRefPaused(objectReference objectRef)
  DivineSignaler divineRef = objectRef as DivineSignaler
  if (divineRef)
    self.setRefPaused(divineRef, ! divineRef.paused)
  endIf
endFunction

; Toggle pausing of each keyword object ref
function toggleKeywordRefsPaused()
  int refIndex = self.keywordRefs.length - 1
  while (refIndex >= 0)
    objectReference ref = self.keywordRefs[refIndex]
    self.toggleRefPaused(ref)
    refIndex -= 1
  endWhile
endFunction

; Make boolean comparisons on the signaled property of all keyword-linked object references
bool function compareKeywordRefs(bool andCompare=false, bool notCompare=false, bool orCompare=false, bool xorCompare=false)
  if ( ! xorCompare )
    int refIndex = self.keywordRefs.length - 1
    bool result = false
    while (refIndex >= 0)
      DivineSignaler divineRef = self.keywordRefs[refIndex] as DivineSignaler
      if (divineRef)
        result = true
        if (andCompare)
          if ( ! divineRef.signaled ) ; found false
            return false
          endIf
        elseIf (notCompare)
          if (divineRef.signaled) ; found true
            return false
          endIf
        elseIf (orCompare)
          result = false
          if (divineRef.signaled)
            return true ; at least one true found
          endIf  
        else
          return false ; no comparisons made
        endIf
      endIf
      refIndex -= 1
    endWhile
    return result
  else
    return !self.compareKeywordRefs(andCompare=true) && self.compareKeywordRefs(orCompare=true)
  endIf  
endFunction

; Get offsets from the calculated collective center of all attched object references
float[] function getKeywordRefSpacingOffsets()
  float xMax = 0.0
  float xMin = 0.0
  float yMax = 0.0
  float yMin = 0.0
  float zMax = 0.0
  float zMin = 0.0
  bool minMaxInitialized = false
  float[] offsets = new float[27]
  int refIndex = self.keywordRefs.length - 1
  while (refIndex >= 0)
    objectReference ref = self.keywordRefs[refIndex]
    if (ref)
      float posX = ref.X
      float posY = ref.Y
      float posZ = ref.Z
      if ( ! minMaxInitialized )
        xMax = posX
        xMin = posX
        yMax = posY
        yMin = posY
        zMax = posZ
        zMin = posZ
        minMaxInitialized = true
      endIf
      xMax = greaterf(xMax, posX)
      xMin = lesserf(xMin, posX)
      yMax = greaterf(yMax, posY)
      yMin = lesserf(yMin, posY)
      zMax = greaterf(zMax, posZ)
      zMin = lesserf(zMin, posZ)
    endIf
    refIndex -= 1
  endWhile
  float[] center = new float[3]
  center[0] = (xMax + xMin) / 2
  center[1] = (yMax + yMin) / 2
  center[2] = (zMax + zMin) / 2
  refIndex = self.keywordRefs.length - 1
  while (refIndex >= 0)
    objectReference ref = self.keywordRefs[refIndex]
    if (ref)
      float posX = ref.X
      float posY = ref.Y
      float posZ = ref.Z
      setFloatInCoordinateArrayXY(offsets, 0, refIndex, posX - center[0])
      setFloatInCoordinateArrayXY(offsets, 1, refIndex, posY - center[1])
      setFloatInCoordinateArrayXY(offsets, 2, refIndex, posZ - center[2])
    endIf
    refIndex -= 1
  endWhile
  return offsets
endFunction

; Redner this signaler useless
function destroySelf()
  self.linkedRef = none
  self.clearKeywordRefs()
  goToState("destroyed")
  self.setRefEnabled(self, false)
  self.onDestroyed()
endFunction  

;/ Event method used to customize behavior within the "busy" state
To be overriden within child scripts /;
function onSignalling()
  dd(self + "@ eventHandler: onSignalling", enabled=self.showDebug)
endFunction

;/ Event method used to customize behavior within the onUpdating event
of both the busy and waiting states. To be overriden within child scripts /;
function onUpdating()
endFunction

;/ Event method used to customize behavior when the signaler has been destroyed
To be overriden within child scripts /;
function onDestroyed()
endFunction

; Ensure all rotation angles on this signaler are not 0 to allow for player activation 
function initRotation()
  if (self.getAngleX() || self.getAngleY() || self.getAngleZ())
    return
  endIf
  self.setAngle(0.00, 0.00, 0.0000001)
endFunction

event onInit()
  parent.onInit()
  self.initRotation()
  self.setKeywordRefSpacingOffsets()
endEvent

event onLoad()
  parent.onLoad()
  if (self.signalOnStart)
    self.activate(self)
  endIf
endEvent

; Wait for and detect player input
state waiting
  event onBeginState()
    dd(self + "@ state: waiting", enabled=self.showDebug)
  endEvent
  event onActivate (objectReference triggerRef)
    goToState("busy")
  endEvent
  event onHit(                                           \
    objectReference objectRef,                           \
    form source,                                         \
    projectile akProjectile,                             \
    bool powerAttack, bool sneakAttack, bool bashAttack, \
    bool hitBlocked                                      \
    )
    if (self.detectHit)
      dd(self + "@ event: onHit | activate: " + self.detectHit + " | source: " + source.getName() + " | projectile: " + akProjectile.getName(),  enabled=self.showDebug)
      if (self.detectHitSource != "")
        if (self.detectHitSource == source.getName() || self.detectHitSource == akProjectile.getName())
          goToState("busy")
        endIf 
      else
        goToState("busy")
      endIf 
    endIf
  endEvent  
  event onTriggerEnter(objectReference objectRef)
    bool signal = false
    if (objectRef as actor == self.playerRef as actor && self.detectPlayer)
      signal = true
    endIf
    if (objectRef as actor != self.playerRef as actor && self.detectNPC)
      signal = true
    endIf
    dd(self + "@ event: onTriggerEnter | signal:" + signal, enabled=self.showDebug)
    if (signal)
      goToState("busy")
    endIf
  endEvent
  event onUpdate()
    self.onUpdating()
  endEVent
endState

; Attempt to send signal to attached objects
state busy
  event onBeginState()
    dd(self + "@ state: busy", enabled=self.showDebug)
    if (self.paused || self.ignoreBusy)
      goToState("waiting")
      return
    endIf
    if (self.detectEquippedItemType != -1)
      bool leftDetected = self.playerRef.getEquippedItemType(0) == self.detectEquippedItemType
      bool rightDetected = self.playerRef.getEquippedItemType(1) == self.detectEquippedItemType
      if ( !leftDetected && !rightDetected )
        goToState("waiting")
        return
      endIf
    endIf 
    self.setRefActivated(self, self)
    self.setActivationBlocked(true)
    if ( ! self.signalContinuously )
      utility.wait(self.signalDelay)
    endIf
    if (self.sendTogglePauseSignal)
      self.toggleRefPaused(self.linkedRef)
      self.toggleKeywordRefsPaused()
    endIf
    if ( ! self.preventDefaultSignal )
      self.signalCount += 1
      self.onSignalling()
    endIf
    if ( ! self.signalContinuously )
      utility.wait(self.postSignalDelay)
    endIf
    self.setActivationBlocked(false)
    dd(self + "@ state: busy | signalLimit:" + self.signalLimit + " | signalCount: " + self.signalCount, enabled=self.showDebug)
    if ( ! self.signalOnce && ternaryBool(self.signalLimit == 0, true, self.signalCount + 1 <= self.signalLimit) )
      if ( ! self.signalContinuously || self.paused || self.ignoreBusy )
        goToState("waiting")
      else
        float delay = clampf(            \
          self.signalDelay,              \
          self.continuousSignalDelayMin, \
          self.signalDelay               \
        )
        utility.wait(delay)
        goToState("busy")
      endIf 
    endIf
  endEvent
  event onUpdate()
    self.onUpdating()
  endEVent
endState