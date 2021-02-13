scriptName DivineSignaler extends DivineObjectReference
; Base class for all Divine Logic signalers

import DivineUtils

float continuousSignalDelayMin = 0.25
{ Minimum value for the user set delay when the signalContinuously property value is set to true. }
int markerPosArraySizeX = 3
{ X size value of the 2 dimensional spacingOffsets array. }
int markerPosArraySizeY = 9 ; maxKeywordRefs parent property value
{ Y size value of the 2 dimensional spacingOffsets array. }
int spacingOffsets = [27] ; x, y, z for each of the 9 keyword-linked object references
{ Reference to offsets from the calculated collective center of all attched object references. }

bool property signalOnStart = false auto
{ Default: False - Send a signal to all attached objects when the game is loaded. }
bool property signalOnce = false auto
{ Default: False - Send a signal only once for the lifetime of the trigger. }
bool property signalContinuously = false auto
;/ Default: False - Send a signal every x number of seconds where x is the value of "signalDelay".
Combine this with "signalOnStart" to automatically signal forever once the game is loaded. /;
bool property detectHit = false auto
{ Default: False - Should this trigger send a signal when hit? }
bool property detectPlayer = false auto
{ Default: False - Should this trigger send a signal when the Player enters it? }
bool property detectNPC = false auto
{ Default: False - Should this trigger send a signal when an NPC enters it? }
bool property paused = false auto hidden
{ Prevent any input to or signaling from this trigger. }
bool property sendTogglePauseSignal = false auto
{ Default: False - Pause all attached signalers when this one sends a signal. }
bool property preventDefaultSignal = false auto
;/ Default: False - Prevent the default signal behavior from occuring.
Pause signals will still be sent when this trigger signals. /;
float property signalDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait before a signal is sent after activation. }
float property postSignalDelay = 2.0 auto
;/ Default: 2.0 - Seconds to wait after a signal is sent before the trigger
accepts input or sends signals again. /;

; Set whether or not activation should be blocked
function setActivationBlocked(bool blocked=true)
	self.blockActivation(blocked)
	; TODO: should we alter form name here to prevent activation attempts?
endFunction

;/ Set whether or not a divineRef object is paused
Pausing prevents any input and disables activation/signalling until unpaused /;
function setRefPaused(DivineSignaler divineRef, bool pause=true)
	divineRef.paused = pause
	divineRef.setActivationBlocked(pause)
	dd(self + "@ signal: pause | ref: " + divineRef + " | paused: " + divineRef.paused, enabled=self.showDebug)
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
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		self.toggleRefPaused(ref)
		refCount -= 1
	endWhile
endFunction

; Make boolean comparisons on the signaled property of all keyword-linked object references
bool function compareKeywordRefs(bool andCompare, bool notCompare, bool orCompare)
	int refCount = self.keywordRefs.length
	bool result = false
	while (refCount > 0)
		int index = refCount - 1
		DivineSignaler divineRef = self.keywordRefs[index] as DivineSignaler
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
		refCount -= 1
	endWhile
	return result
endFunction

;/ Event method used to customize behavior within the "busy" state
To be overriden within child scripts /;
function onSignalling()
	dd(self + "@ eventHandler: onSignalling", enabled=self.showDebug)
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
	event onHit(objectReference objectRef, form source, projectile akProjectile, \
			bool powerAttack, bool sneakAttack, bool bashAttack, bool hitBlocked)
		if (self.detectHit)
			goToState("busy")
		endIf
		dd(self + "@ event: onHit | activate:" + self.detectHit, enabled=self.showDebug)
	endEvent
	event onTriggerEnter(objectReference objectRef)
		bool signal = false
		if (objectRef == playerRef && self.detectPlayer)
			signal = true
		endIf
		if (objectRef != playerRef && self.detectNPC) ; this may have to check for Actor script
			signal = true
		endIf
		dd(self + "@ event: onTriggerEnter | signal:" + signal, enabled=self.showDebug)
		if (signal)
			goToState("busy")
		endIf
	endEvent
endState

; Attempt to send signal to attached objects
state busy
	event onBeginState()
		dd(self + "@ state: busy", enabled=self.showDebug)
		if (self.paused)
			goToState("waiting")
			return
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
			self.onSignalling()
		endIf
		if ( ! self.signalContinuously )
			utility.wait(self.postSignalDelay)
		endIf
		self.setActivationBlocked(false)
		if ( ! self.signalOnce )
			goToState("routing")
		endIf
	endEvent
endState

; Decide which state to enter based on player set properties
state routing
	event onBeginState()
		dd(self + "@ state: routing", enabled=self.showDebug)
		if ( ! self.signalContinuously || self.paused )
			goToState("waiting")
		else
			float delay = clampf(              \
				self.signalDelay,              \
				self.continuousSignalDelayMin, \
				self.signalDelay               \
			)
			utility.wait(delay)
			goToState("busy")
		endIf	
	endEvent
endState