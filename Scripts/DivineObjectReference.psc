scriptName DivineObjectReference extends ObjectReference
; Divinity itself

import DivineUtils

bool property signaled = false auto hidden
{ The current state of this object, used for communication between DivineObjectReferences. }
bool property linkedRefSignaled = false auto hidden
{ The current state of the non-keyword linked object reference, used for 
communication between DivineObjectReferences. }
objectReference property linkedRef auto hidden
{ The non-keyword linked object reference. }
objectReference[] property keywordRefs auto hidden
{ All keyword-linked object references that are attached with the "DivineRef" keyword. }
int property maxKeywordRefs = 9 auto hidden
{ The maxiumum number of keyword-linked references allowed to be attached to this object. }
string property keywordRefSignature = "DivineRef" auto hidden
{ The base keyword signature used to identify objects available to enter the keywordRefs property. }
string property formName auto hidden
{ A reference to the form name of this object when it's loaded. }
actor property playerRef auto hidden
{ A reference to the Player object. }
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
		dd(self + "@ function: setKeywordRefs | refs: " + self.keywordRefs, enabled=self.showDebug)
	endIf	
endFunction

; Set the given objectReference active
function setRefActivated(objectReference objectRef, objectReference activatorRef)
	if (objectRef && activatorRef)
		if (objectRef != self)
			objectRef.activate(activatorRef)
		else
			self.signaled = ! self.signaled
		endIf
		dd(self + "@ signal: activate | ref: " + objectRef, enabled=self.showDebug)
	endIf
endFunction

; Set the given objectReference enabled
function setRefEnabled(objectReference objectRef, bool enabled=true, bool allowFade=false)
	if (objectRef)
		if ( ! enabled )
			objectRef.disable(allowFade)
		else
			objectRef.enable(allowFade)
		endIf
		dd(objectRef + "@ signal: enable | enabled: " + ! objectRef.isDisabled(), enabled=self.showDebug)
	endIf
endFunction

; Set the form name on the given objectReference
function setRefFormName(objectReference objectRef, string name="")
	form refForm = objectRef.getBaseObject()
	refForm.setName(name)
endFunction

; Get the form name of the given objectReference
string function getRefFormName(objectReference objectRef)
	form refForm = objectRef.getBaseObject()
	return refForm.GetName()
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

; Scale the objectReference to the given scale
function scaleRef(objectReference objectRef, float scale, bool withCollision=false)
	objectRef.setScale(scale)
	if (withCollision)
		; TODO: is this needed?
	endIf
	dd(self + "@ function: scaleRef | ref: " + objectRef + " scale: " + scale, enabled=self.showDebug)
endFunction

; Scale the objectReference to a random scale between minScale and maxScale
function scaleRefBetween(         \
	objectReference objectRef,      \
	float minScale, float maxScale, \ 
	bool withCollision=false        \
	)
	float newScale = utility.randomFloat(minScale, maxScale)
	self.scaleRef(objectRef, newScale, withCollision)
endFunction

; Set the given objectReferences position
function setRefPosition(       \
	objectReference objectRef,   \
	float x, float y, float z,   \
	float aX, float aY, float aZ \
	)
	objectRef.setPosition(x, y, z)
	objectRef.setAngle(aX, aY, aZ)
endFunction

; Move the given objectReference to the destination objectReference
function moveRefTo(                                           \
	objectReference objectRef,                                  \
	objectReference destinationRef,                             \
	float xOffset=0.0, float yOffset=0.0, float zOffset=0.0,    \
	float aXOffset=0.0, float aYOffset=0.0, float aZOffset=0.0, \
	bool matchRotation=false                                    \
	)
	float newX = destinationRef.X + xOffset
	float newY = destinationRef.Y + yOffset
	float newZ = destinationRef.Z + zOffset
	objectReference rotationRef = destinationRef
	if ( ! matchRotation )
		rotationRef = objectRef
	endIf
	float newAx = rotationRef.getAngleX() + aXOffset
	float newAy = rotationRef.getAngleY() + aYOffset
	float newAz = rotationRef.getAngleZ() + aZOffset	
	objectRef.setPosition(newX, newY, newZ)
	objectRef.setAngle(newAx, newAy, newAz)
endFunction

; Apply a havok impulse to the given object reference with the specified direction and magnitude
function impulseRef(                        \
	objectReference objectRef,                \
	float forceX, float forceY, float forceZ, \
	float magnitude,                          \
	bool explode=false, bool implode=false    \
	)
	float xOffset = objectRef.X - self.X
	float yOffset = objectRef.Y - self.Y
	if (explode)
		forceX = xOffset
		forceY = yOffset
		forceZ = 1.0
	elseIf(implode)
		forceX = xOffset * -1
		forceY = yOffset * -1
		forceZ = -1.0
	endIf
	actor actorRef = objectRef as actor
	if (actorRef)
		self.playerRef.pushActorAway(actorRef, 0.0)
	endIf
	objectRef.applyHavokImpulse(forceX, forceY, forceZ, magnitude)
endFunction

; Wait for the given objectReference to be at the desired destination
function waitForRefAt(                  \
	objectReference objectRef,            \
	float[] destination,                  \
	bool positions=true, bool angles=true \
	)
	if (positions)
		float destX = destination[0]
		float destY = destination[1]
		float destZ = destination[2]
		while( ! self.refPosAt(objectRef, destX, destY, destZ) )
			; wait for object to finish translation
		endWhile
	endIf
	if (angles)
		float destAx = destination[3]
		float destAy = destination[4]
		float destAZ = destination[5]
		while ( ! self.refAnglesAt(objectRef, destAx, destAy, destAz) )
			; wait for object to finish translation
		endWhile
	endIf
endFunction

; Set each keyword-linked object reference as activated
function setKeywordRefsActivated()
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			self.setRefActivated(ref, self)
		endIf
		refIndex -= 1
	endWhile
endFunction

; Set each keyword-linked object reference as enabled
function setKeywordRefsEnabled(bool enabled=true, bool allowFade=false)
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			self.setRefEnabled(ref, enabled, allowFade)
		endIf
		refIndex -= 1
	endWhile	
endFunction

; Toggle the given objectReference enabled
function toggleRefEnabled(objectReference objectRef, bool allowFade=false)
	self.setRefEnabled(objectRef, objectRef.isDisabled(), allowFade)	
endFunction

; Determine if the object reference is at the same angles as the given coordinates
bool function refAnglesAt(              \
	objectReference objectRef,            \
	float posAx, float posAy, float posAz \
	)
	float refAx = objectRef.getAngleX()
	float refAy = objectRef.getAngleY()
	float refAz = objectRef.getAngleZ()
	if (refAx != posAx || refAy != posAy || refAz != posAz)
		return false
	endIf
	return true
endFunction

; Determine if the object reference is at the same position as the given coordinates
bool function refPosAt(               \
	objectReference objectRef,          \
	float posX, float posY, float posZ  \
	)
	float refX = objectRef.getPositionX()
	float refY = objectRef.getPositionY()
	float refZ = objectRef.getPositionZ()
	if (refX != posX || refY != posY || refZ != posZ)
		return false
	endIf
	return true
endFunction

; Toggle enabling of each keyword-linked object reference
function toggleKeywordRefsEnabled(bool allowFade=false)
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			self.toggleRefEnabled(ref, allowFade)
		endIf
		refIndex -= 1
	endWhile	
endFunction

; Scale all keyword-linked object refrences to a random scale between minScale and maxScale
function scaleKeywordRefsBetween(float minScale, float maxScale, bool withCollision=false)
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			self.scaleRefBetween(ref, minScale, maxScale, withCollision)
		endIf
		refIndex -= 1
	endWhile
endFunction

; Scale all keyword-linked object references to the given scale
function scaleKeywordRefs(float scale, bool withCollision=false)
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			self.scaleRef(ref, scale, withCollision)
		endIf
		refIndex -= 1
	endWhile
endFunction

; Move all keyword-linked object references to the given objectReference
function moveKeywordRefsTo(                                   \
	objectReference objectRef,                                  \
	float[] spacingOffsets,                                     \
	float delay=0.0,                                            \
	float xOffset=0.0, float yOffset=0.0, float zOffset=0.0,    \
	float aXOffset=0.0, float aYOffset=0.0, float aZOffset=0.0, \
	bool matchRotation=false                                    \
	)
	if ( spacingOffsets.length != 27 )
		spacingOffsets = new float[27]
	endIf
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			float xSpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 0, refIndex)
			float ySpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 1, refIndex)
			float zSpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 2, refIndex)
			float offsetX = xSpacingOffset + xOffset
			float offsetY = ySpacingOffset + yOffset
			float offsetZ = zSpacingOffset + zOffset
			self.moveRefTo(                 \
				ref,                          \
				objectRef,                    \
				offsetX, offsetY, offsetZ,    \
				aXOffset, aYOffset, aZOffset, \
				matchRotation                 \
			)
			if (delay > 0)
				utility.wait(delay)
			endIf
		endIf
		refIndex -= 1
	endWhile
endFunction

; Wait for all object references to be at the given destinations
function waitForKeywordRefsAt(float[] destinations, bool positions=true, bool angles=true)
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
				float[] destination = new float[6]
				destination[0] = getFloatFromCoordinateArrayXY(destinations, 0, refIndex) 
				destination[1] = getFloatFromCoordinateArrayXY(destinations, 1, refIndex)
				destination[2] = getFloatFromCoordinateArrayXY(destinations, 2, refIndex)
				destination[3] = getFloatFromCoordinateArrayXY(destinations, 3, refIndex)
				destination[4] = getFloatFromCoordinateArrayXY(destinations, 4, refIndex)
				destination[5] = getFloatFromCoordinateArrayXY(destinations, 5, refIndex)
				self.waitForRefAt(ref, destination, positions, angles)
		endIf
		refIndex -= 1
	endWhile
endFunction

; Translate the given objectReference to the destinationRef
function translateRefTo(                                      \
	objectReference objectRef,                                  \
	objectReference destinationRef,                             \
	float speed=100.0, float rotationSpeedClamp=0.0,            \
	float tangentMagnitude=0.0,                                 \
	float xOffset=0.0, float yOffset=0.0, float zOffset=0.0,    \
	float aXOffset=0.0, float aYOffset=0.0, float aZOffset=0.0, \
	bool matchRotation=false, bool rotateOnArrival=false        \
	)
  float[] destination = new float[6]
	float newX = destinationRef.X + xOffset
	float newY = destinationRef.Y + yOffset
	float newZ = destinationRef.Z + zOffset
	objectReference rotationRef = destinationRef
	if ( ! matchRotation )
		rotationRef = objectRef
	endIf
	float newAx = rotationRef.getAngleX() + aXOffset
	float newAy = rotationRef.getAngleY() + aYOffset
	float newAz = rotationRef.getAngleZ() + aZOffset
	destination[0] = newX
	destination[1] = newY
	destination[2] = newZ
	destination[3] = newAX
	destination[4] = newAY
	destination[5] = newAZ
	dd(self + "@ function: TranslateRefTo | destination: " + destination, enabled=self.showDebug)
	if (rotateOnArrival)
		newAx = objectRef.getAngleX()
		newAy = objectRef.getAngleY()
		newAz = objectRef.getAngleZ()
	endIf
	if ( tangentMagnitude == 0.0)
		objectRef.translateTo(      \
			newX, newY, newZ,         \
			newAx, newAy, newAz,      \
			speed, rotationSpeedClamp \
		)
	else
		objectRef.splineTranslateTo( \
			newX, newY, newZ,          \
			newAx, newAy, newAz,       \
			tangentMagnitude,          \
			speed, rotationSpeedClamp  \
		)
	endIf
	self.waitForRefAt(objectRef, destination, true, false)
	if (rotateOnArrival)
		objectRef.translateTo(                            \
			destination[0], destination[1], destination[2], \
			destination[3], destination[4], destination[5], \
			speed, rotationSpeedClamp                       \
		)
	endIf
	self.waitForRefAt(objectRef, destination, false, true)
endFunction


; Translate all keyword-linked object references to the given objectReference
function translateKeywordRefsTo(                              \
	objectReference objectRef,                                  \
	float[] spacingOffsets,                                     \
	float speed=100.0, float rotationSpeedClamp=0.0,            \
	float tangentMagnitude=0.0,                                 \
	float delay=0.0,                                            \
	float xOffset=0.0, float yOffset=0.0, float zOffset=0.0,    \
	float aXOffset=0.0, float aYOffset=0.0, float aZOffset=0.0, \
	bool matchRotation=false, bool rotateOnArrival=false        \
	)
	if ( spacingOffsets.length != 27 )
		spacingOffsets = new float[27]
	endIf
	float[] destinations = new float[54]
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			float xSpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 0, refIndex)
			float ySpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 1, refIndex)
			float zSpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 2, refIndex)
			float newX = objectRef.X + xSpacingOffset + xOffset
			float newY = objectRef.Y + ySpacingOffset + yOffset
			float newZ = objectRef.Z + zSpacingOffset + zOffset
			objectReference rotationRef = objectRef
			if ( ! matchRotation )
				rotationRef = ref
			endIf
			float newAx = rotationRef.getAngleX() + aXOffset
			float newAy = rotationRef.getAngleY() + aYOffset
			float newAz = rotationRef.getAngleZ() + aZOffset	
			setFloatInCoordinateArrayXY(destinations, 0, refIndex, newX)
			setFloatInCoordinateArrayXY(destinations, 1, refIndex, newY)
			setFloatInCoordinateArrayXY(destinations, 2, refIndex, newZ)
			setFloatInCoordinateArrayXY(destinations, 3, refIndex, newAx)
			setFloatInCoordinateArrayXY(destinations, 4, refIndex, newAy)
			setFloatInCoordinateArrayXY(destinations, 5, refIndex, newAz)
			if (rotateOnArrival)
				newAx = ref.getAngleX()
				newAy = ref.getAngleY()
				newAz = ref.getAngleZ()
			endIf
			if ( tangentMagnitude != 0.0)
				ref.splineTranslateTo(      \
					newX, newY, newZ,         \
					newAx, newAy, newAz,      \
					tangentMagnitude,         \
					speed, rotationSpeedClamp \
				)
			else
				ref.translateTo(            \
					newX, newY, newZ,         \
					newAx, newAy, newAz,      \
					speed, rotationSpeedClamp \
				)
			endIf
			if (delay > 0)
				utility.wait(delay)
			endIf
		endIf
		refIndex -= 1
	endWhile
	self.waitForKeywordRefsAt(destinations, true, false)
	if (rotateOnArrival)
		refIndex = self.keywordRefs.length - 1
		while (refIndex >= 0)
			objectReference ref = self.keywordRefs[refIndex]
			if (ref)
				float newX = getFloatFromCoordinateArrayXY(destinations, 0, refIndex) 
				float newY = getFloatFromCoordinateArrayXY(destinations, 1, refIndex)
				float newZ = getFloatFromCoordinateArrayXY(destinations, 2, refIndex)
				float newAx = getFloatFromCoordinateArrayXY(destinations, 3, refIndex)
				float newAy = getFloatFromCoordinateArrayXY(destinations, 4, refIndex)
				float newAz = getFloatFromCoordinateArrayXY(destinations, 5, refIndex)
				ref.translateTo(            \
					newX, newY, newZ,         \
					newAx, newAy, newAz,      \
					speed, rotationSpeedClamp \
				)
			endIf
			refIndex -= 1
		endWhile
	endIf
	self.waitForKeywordRefsAt(destinations, false, true)
endFunction

; Spawn an instance of all keyword-linked object references at the given objectReference location
function spawnKeywordRefsAt(                                  \
	objectReference objectRef,                                  \
	float[] spacingOffsets,                                     \
	float delay=0.0,                                            \
	float xOffset=0.0, float yOffset=0.0, float zOffset=0.0,    \
	float aXOffset=0.0, float aYOffset=0.0, float aZOffset=0.0, \
	bool matchRotation=false                                    \
	)
	if ( spacingOffsets.length != 27 )
		spacingOffsets = new float[27]
	endIf
	int spawnCount = 0;
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			float xSpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 0, refIndex)
			float ySpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 1, refIndex)
			float zSpacingOffset = getFloatFromCoordinateArrayXY(spacingOffsets, 2, refIndex)
			float offsetX = xSpacingOffset + xOffset
			float offsetY = ySpacingOffset + yOffset
			float offsetZ = zSpacingOffset + zOffset
			form refForm = ref.getBaseObject()
			objectReference spawnedRef = objectRef.placeAtMe(refForm, 1, false, true)
			self.moveRefTo(                 \
				ref,                          \
				objectRef,                    \
				offsetX, offsetY, offsetZ,    \
				aXOffset, aYOffset, aZOffset, \
				matchRotation                 \
			)
			self.setRefEnabled(spawnedRef)
			if (delay > 0)
				utility.wait(delay)
			endIf
		endIf
		refIndex -= 1
	endWhile
endFunction

; Apply a havok impulse to all keyword-linked object references with the specified direction and magnitude
function impulseKeywordRefs(                \
	float forceX, float forceY, float forceZ, \
	float magnitude,                          \
	bool explode=false, bool implode=false    \
	)
	int refIndex = self.keywordRefs.length - 1
	while (refIndex >= 0)
		objectReference ref = self.keywordRefs[refIndex]
		if (ref)
			self.impulseRef(          \
				ref,                    \
				forceX, forceY, forceZ, \
				magnitude,              \
				explode, implode        \
			)
		endIf
		refIndex -= 1
	endWhile
endFunction

event onInit()
	dd(self + "@ event: onInit", enabled=self.showDebug)
	self.formName = self.getRefFormName(self) ; cached for later use
	self.playerRef = game.getPlayer()
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