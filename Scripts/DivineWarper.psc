scriptName DivineWarper extends DivineSignaler
; Akatosh – The Dragon God of Time and chief god of the pantheon

import DivineUtils

DivineWarperMarker property nextMarker auto hidden
{ Refernce to the current DivineWarperMarker object being processed. }
bool property noMarkersAttached = true auto hidden
{ Does this singaler have any markers attached when it's initializing? }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a warp signal. }
float property individualDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait between warping of each keyword-linked object reference. 
(A non-zero value will cause each object to translate one at a time) }

; Marker Properties m_*
bool property m_warpPlayer = false auto
{ Default: false - Should the player be warped to this marker? }
float property m_delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references warp to this marker. }
bool property m_collapseSpacing = false auto
{ Defualt: false - Should warped objects ignore original spacing and meet at the same postion on this marker? }
float property m_offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects positions in the X direction. }
float property m_offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects positions in the Y direction. }
float property m_offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects positions in the Z direction. }
float property m_offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects angles in the X direction. }
float property m_offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects angles in the Y direction. }
float property m_offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the warped objects angles in the Z direction. }
bool property m_limitX = false auto
{ Default: False - Prevent translation of the x axis. }
bool property m_limitY = false auto
{ Default: False - Prevent translation of the y axis. }
bool property m_limitZ = false auto
{ Default: False - Prevent translation of the z axis. }
bool property m_limitAX = false auto
{ Default: False - Prevent translation of the aX axis. }
bool property m_limitAY = false auto
{ Default: False - Prevent translation of the aY axis. }
bool property m_limitAZ = false auto
{ Default: False - Prevent translation of the aZ axis. }

bool property m_matchRotation = false auto
{ Default: false - Should the warping objects match the rotation of this marker when they arrive? }
bool property m_toPlayer = false auto
{ Default: False - Should the translating objects move to the player? }

event onInit()
	parent.onInit()
	if ( ! self.nextMarker )
		DivineWarperMarker linkedMarker = self.getLinkedRef() as DivineWarperMarker
		if (linkedMarker)
			self.nextMarker = linkedMarker
			self.noMarkersAttached = false
		endIf
	endIf
endEvent

;/ Make the given DivineWarperMarker object property values conform to 
this objects values of the same property name if those values are not default /; 
function conformMarkerProperties(DivineWarperMarker markerRef)
	markerRef.delay = conformFloat(markerRef.delay, self.m_delay, 0.0)
	markerRef.offsetX = conformFloat(markerRef.offsetX, self.m_offsetX, 0.0)
	markerRef.offsetY = conformFloat(markerRef.offsetY, self.m_offsetY, 0.0)
	markerRef.offsetZ = conformFloat(markerRef.offsetZ, self.m_offsetZ, 0.0)
	markerRef.offsetAX = conformFloat(markerRef.offsetAX, self.m_offsetAX, 0.0)
	markerRef.offsetAY = conformFloat(markerRef.offsetAY, self.m_offsetAY, 0.0)
	markerRef.offsetAZ = conformFloat(markerRef.offsetAZ, self.m_offsetAZ, 0.0)
	markerRef.limitX = conformBool(markerRef.limitX, self.m_limitX, false)
	markerRef.limitY = conformBool(markerRef.limitY, self.m_limitY, false)
	markerRef.limitZ = conformBool(markerRef.limitZ, self.m_limitZ, false)
	markerRef.limitAX = conformBool(markerRef.limitAX, self.m_limitAX, false)
	markerRef.limitAY = conformBool(markerRef.limitAY, self.m_limitAY, false)
	markerRef.limitAZ = conformBool(markerRef.limitAZ, self.m_limitAZ, false)
	markerRef.collapseSpacing = conformBool(markerRef.collapseSpacing, self.m_collapseSpacing, false)
	markerRef.matchRotation = conformBool(markerRef.matchRotation, self.m_matchRotation, false)
	markerRef.warpPlayer = conformBool(markerRef.warpPlayer, self.m_warpPlayer, false)
	markerRef.toPlayer = conformBool(markerRef.toPlayer, self.m_toPlayer, false)
endFunction

function onSignalling()
	if ( ! self.nextMarker && self.noMarkersAttached )
		objectReference destinationRef = self
		if (self.m_toPlayer)
			destinationRef = self.playerRef
		endIf
		bool[] axisLimits = self.buildAxisLimitsArray(   \
			self.m_limitX, self.m_limitY, self.m_limitZ,   \
			self.m_limitAX, self.m_limitAY, self.m_limitAZ \
		)
		self.moveKeywordRefsTo(          \
			destinationRef,                \
			self.keywordRefSpacingOffsets, \
			axisLimits,                    \
			self.individualDelay,          \
			self.m_offsetX,                \
			self.m_offsetY,                \
			self.m_offsetZ,                \
			self.m_offsetAX,               \
			self.m_offsetAY,               \
			self.m_offsetAZ,               \
			self.m_matchRotation           \
		)
		if (self.m_warpPlayer)
			self.moveRefTo(                 \
				self.playerRef,               \
				self,                         \
				axisLimits,                   \
				self.nextMarker.offsetX,      \
				self.nextMarker.offsetY,      \
				self.nextMarker.offsetZ,      \
				self.nextMarker.offsetAX,     \
				self.nextMarker.offsetAY,     \
				self.nextMarker.offsetAZ,     \
				self.nextMarker.matchRotation \
			)
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
		utility.wait(nextMarker.delay)
		objectReference destinationRef = self.nextMarker
		if (self.nextMarker.toPlayer)
			destinationRef = self.playerRef
		endIf
		bool[] axisLimits = self.buildAxisLimitsArray(                              \
			self.nextMarker.limitX, self.nextMarker.limitY, self.nextMarker.limitZ,   \
			self.nextMarker.limitAX, self.nextMarker.limitAY, self.nextMarker.limitAZ \
		)
		self.moveKeywordRefsTo(         \
			destinationRef,               \
			spacingOffsets,               \
			axisLimits,										\
			self.individualDelay,         \
			self.nextMarker.offsetX,      \
			self.nextMarker.offsetY,      \
			self.nextMarker.offsetZ,      \
			self.nextMarker.offsetAX,     \
			self.nextMarker.offsetAY,     \
			self.nextMarker.offsetAZ,     \
			self.nextMarker.matchRotation \
		)
		if (self.nextMarker.warpPlayer)
			self.moveRefTo(                 \
				self.playerRef,               \
				self.nextMarker,              \
				axisLimits,                   \
				self.nextMarker.offsetX,      \
				self.nextMarker.offsetY,      \
				self.nextMarker.offsetZ,      \
				self.nextMarker.offsetAX,     \
				self.nextMarker.offsetAY,     \
				self.nextMarker.offsetAZ,     \
				self.nextMarker.matchRotation \
			)
		endIf
		self.setRefActivated(self.nextMarker, self)
		self.nextMarker = self.nextMarker.linkedRef as DivineWarperMarker
	endIf
endFunction