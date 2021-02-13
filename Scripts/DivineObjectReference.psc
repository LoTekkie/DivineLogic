scriptName DivineObjectReference extends ObjectReference
; Divinity itself

import DivineUtils

int maxKeywordRefs = 9
{ The maxiumum number of keyword-linked references allowed to be attached to this object. }
string keywordRefSignature = "DivineRef"
{ The base keyword signature used to identify objects available to enter the keywordRefs property. }
string formName
{ A reference to the form name of this object when it's loaded. }
objectReference playerRef
{ A reference to the Player object. }

bool property signaled = false auto hidden
{ The current state of this object, used for communication between DivineObjectReferences. }
bool property linkedRefSignaled = false auto hidden
;/ The current state of the non-keyword linked object reference, used for 
communication between DivineObjectReferences. /;
objectReference property linkedRef auto hidden
{ The non-keyword linked object reference. }
objectReference[] property keywordRefs auto hidden
{ All keyword-linked object references that are attached with the "DivineRef" keyword. }
bool property showDebug = false auto
{ Default: False - Output divine logic debug messages to logs. }

; Set the "linkedRef" property
function setLinkedRef()
	if ( ! self.linkedRef ) 
		self.linkedRef = self.getLinkedRef() 
	endIf
endFunction

; Set the "keywordRefs" property
function setKeywordRefs()
	if ( ! self.keywordRefs.length )
		self.keywordRefs = self.getKeywordRefs()
	endIf	
endFunction

; Set the given objectReference active
function setRefActivated(objectReference objectRef, objectReference activatorRef)
	if ( ! objectRef )
		return
	endIf
	if (objectRef != self)
		objectRef.activate(activatorRef)
	else
		self.signaled = ! self.signaled
	endIf
	dd(self + "@ signal: activate | ref: " + objectRef, enabled=self.showDebug)
endFunction

; Set the given objectReference enabled
function setRefEnabled(objectReference objectRef, bool enabled=true, bool allowFade=false)
	if ( ! objectRef )
		return
	endIf
	if ( ! enabled )
		objectRef.disable(allowFade)
	else
		objectRef.enable(allowFade)
	endIf
	dd(objectRef + "@ signal: enable | enabled: " + ! objectRef.isDisabled(), enabled=self.showDebug)
endFunction

; Set each keyword-linked object reference as activated
function setKeywordRefsActivated()
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		self.setRefActivated(ref, self)
		refCount -= 1
	endWhile
endFunction

; Set each keyword-linked object reference as enabled
function setKeywordRefsEnabled(bool enabled=true, bool allowFade=false)
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		self.setRefEnabled(ref, enabled, allowFade)
		refCount -= 1
	endWhile	
endFunction

; Set the form name on the given objectReference
function setRefFormName(objectReference objectRef, string name="")
	form refForm = objectRef.getBaseObject()
	refForm.setName(name)
endFunction

; Get an array of keyword-linked object references attached with the "DivineRef" keyword signature
objectReference[] function getKeywordRefs()
	objectReference[] refs = new objectReference[9] ; int matches self.maxKeywordRefs
	int refIndex = self.maxKeywordRefs
	while(refIndex > 0)
		string kwName = self.keywordRefSignature + "0" + refIndex
		keyword kw = keyword.getKeyword(kwName)
		objectReference ref = self.getLinkedRef(kw)
		if (ref != self.linkedRef)
			int next = refs.find(none)
			refs[next] = ref
		endIf
		refIndex -= 1
	endWhile
	return refs	
endFunction

; Get the form name of the given objectReference
string function getRefFormName(objectReference objectRef)
	form refForm = objectRef.getBaseObject()
	return refForm.GetName()
endFunction

; Toggle the given objectReference enabled
function toggleRefEnabled(objectReference objectRef, bool allowFade=false)
	if ( ! objectRef )
		return
	endIf
	self.setRefEnabled(objectRef, objectRef.isDisabled(), allowFade)	
endFunction

; Toggle enabling of each keyword-linked object reference
function toggleKeywordRefsEnabled(bool allowFade=false)
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		self.toggleRefEnabled(ref, allowFade)
		refCount -= 1
	endWhile	
endFunction

; Scale the objectReference to the given scale
function scaleRef(objectReference objectRef, float scale, bool withCollision=false)
	objectRef.setScale(scale)
	if (withCollision)
		; TODO: is this needed?
	endIf
	dd(self + "@ function: scaleRef | ref: " + objectRef + " scale: " + scale, enabled=self.showDebug)
endFunction

; Scale the objectReference to a random scale between minScale and maxScale
function scaleRefBetween(objectReference objectRef, float minScale, float maxScale, bool withCollision=false)
	float newScale = utility.randomFloat(minScale, maxScale)
	self.scaleRef(objectRef, newScale, withCollision)
endFunction

; Scale all keyword-linked object refrences to a random scale between minScale and maxScale
function scaleKeywordRefsBetween(float minScale, float maxScale, bool withCollision=false)
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		self.scaleRefBetween(ref, minScale, maxScale, withCollision)
		refCount -= 1
	endWhile
endFunction

; Scale all keyword-linked object references to the given scale
function scaleKeywordRefs(float scale, bool withCollision=false)
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		self.scaleRef(ref, scale, withCollision)
		refCount -= 1
	endWhile
endFunction

; Move all keyword-linked object references to the given objectReference
function moveKeywordRefsTo(                                         \
		objectReference objectRef,                                  \
		float xOffset=0.0, float yOffset=0.0, float zOffset=0.0,    \
		float aXOffset=0.0, float aYOffset=0.0, float aZOffset=0.0, \
		bool matchRotation=false                                    \
	)
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		ref.setPosition(objectRef.X + xOffset, objectRef.Y + yOffset, objectRef.Z + zOffset)
		if (matchRotation)
			ref.setAngle(                         \
				objectRef.getAngleX() + aXOffset, \
				objectRef.getAngleY() + aYOffset, \
				objectRef.getAngleZ() + aZOffset  \
			)
		endIf
		refCount -= 1
	endWhile
endFunction

; Determine if all keyword-linked object references are at the same position as the given objectReference
bool function keywordRefsAt(objectReference objectRef, bool matchRotation=false)
	int refCount = self.keywordRefs.length
	while (refCount > 0)
		int index = refCount - 1
		objectReference ref = self.keywordRefs[index]
		if ( ref.getDistance(objectRef) )
			return false
		endIf
		refCount -= 1
	endWhile
	return true
endfunction

event onInit()
	dd(self + "@ event: onInit", enabled=self.showDebug)
	self.formName = self.getRefFormName(self) ; cached for later use
	self.playerRef = Game.getPlayer()
	self.setLinkedRef()
	self.setKeywordRefs()
endEvent

event onLoad()
	; Do something
endEvent

auto state waiting
	event onActivate (objectReference triggerRef)
		goToState("busy")
	endEvent
endState

state busy
	event onBeginState()
		goToState("waiting")
	endEvent
endState