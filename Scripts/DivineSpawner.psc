scriptName DivineSpawner extends DivineSignaler
; Mara - Goddess of Love and compassion, the Mother Goddess

import DivineUtils

DivineSpawnerMarker property nextMarker auto hidden
{ Refernce to the current DivineSpawnerMarker object being processed. }
bool property noMarkersAttached = true auto hidden
{ Does this singaler have any markers attached when it's initializing? }
int property totalSpawns = 0 auto hidden
{ Total number of spawns this signaler has performed. }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a spawn signal. }
float property individualDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait between spawning of each keyword-linked object reference. 
(A non-zero value will cause each object to spawn one at a time) }
int property maxSpawns = 0 auto
{ Default: 0 - Maximum number of times spawning will occur. (Default value of 0 is equivalent to infinity) }

; Marker Properties m_*
float property m_delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references spawn at this marker. }
bool property m_collapseSpacing = false auto
{ Defualt: false - Should spawning objects ignore original spacing and meet at the same postion on this marker? }
float property m_offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects positions in the X direction. }
float property m_offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects positions in the Y direction. }
float property m_offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects positions in the Z direction. }
float property m_offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects angles in the X direction. }
float property m_offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects angles in the Y direction. }
float property m_offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the spawned objects angles in the Z direction. }
bool property m_matchRotation = false auto
{ Default: false - Should the spawning objects match the rotation of this marker when they arrive? }

event onInit()
	parent.onInit()
	if ( ! self.nextMarker )
		DivineSpawnerMarker linkedMarker = self.getLinkedRef() as DivineSpawnerMarker
		if (linkedMarker)
			self.nextMarker = linkedMarker
			self.noMarkersAttached = false
		endIf
	endIf
	self.maxSpawns = clampi(self.maxSpawns, 0, self.maxSpawns)
	if (self.maxSpawns == 0)
		self.totalSpawns += 1
	endIf
endEvent

;/ Make the given DivineSpawnerMarker object property values conform to 
this objects values of the same property name if those values are not default /; 
function conformMarkerProperties(DivineSpawnerMarker markerRef)
	markerRef.delay = conformFloat(markerRef.delay, self.m_delay, 0.0)
	markerRef.offsetX = conformFloat(markerRef.offsetX, self.m_offsetX, 0.0)
	markerRef.offsetY = conformFloat(markerRef.offsetY, self.m_offsetY, 0.0)
	markerRef.offsetZ = conformFloat(markerRef.offsetZ, self.m_offsetZ, 0.0)
	markerRef.offsetAX = conformFloat(markerRef.offsetAX, self.m_offsetAX, 0.0)
	markerRef.offsetAY = conformFloat(markerRef.offsetAY, self.m_offsetAY, 0.0)
	markerRef.offsetAZ = conformFloat(markerRef.offsetAZ, self.m_offsetAZ, 0.0)
	markerRef.collapseSpacing = conformBool(markerRef.collapseSpacing, self.m_collapseSpacing, false)
	markerRef.matchRotation = conformBool(markerRef.matchRotation, self.m_matchRotation, false)
endFunction

function onSignalling()
	if ( ! self.nextMarker && self.noMarkersAttached )
		if (self.totalSpawns != self.maxSpawns)
			self.spawnKeywordRefsAt(         \
				self,                          \
				self.keywordRefSpacingOffsets, \
				self.individualDelay,          \
				self.m_offsetX,                \
				self.m_offsetY,                \
				self.m_offsetZ,                \
				self.m_offsetAX,               \
				self.m_offsetAY,               \
				self.m_offsetAZ,               \
				self.m_matchRotation           \
			)
			self.totalSpawns += 1
		endIf
		if (self.relayActivation)
			self.setRefActivated(self.linkedRef, self)
		endIf
	elseIf (self.nextMarker)
		self.conformMarkerProperties(self.nextMarker)
		float[] spacingOffsets = new float[27]
		if ( ! self.nextMarker.collapseSpacing )
			spacingOffsets = self.keywordRefSpacingOffsets
		endIf
		utility.wait(self.nextMarker.delay)
		if (self.totalSpawns != self.maxSpawns)
			self.spawnKeywordRefsAt(        \
				self.nextMarker,              \
				spacingOffsets,               \
				self.individualDelay,         \
				self.nextMarker.offsetX,      \
				self.nextMarker.offsetY,      \
				self.nextMarker.offsetZ,      \
				self.nextMarker.offsetAX,     \
				self.nextMarker.offsetAY,     \
				self.nextMarker.offsetAZ,     \
				self.nextMarker.matchRotation \
			)
			self.totalSpawns += 1
		endIf
		self.setRefActivated(self.nextMarker, self)
		self.nextMarker = self.nextMarker.linkedRef as DivineSpawnerMarker
	endIf
endFunction