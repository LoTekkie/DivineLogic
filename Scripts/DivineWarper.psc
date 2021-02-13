scriptName DivineWarper extends DivineSignaler
; Akatosh – The Dragon God of Time and chief god of the pantheon

import DivineUtils

DivineWarperMarker property nextMarker auto hidden
{ Refernce to the current DivineWarperMarker object being processed. }
bool property noMarkersAttached = true auto hidden
{ Does this singaler have any markers attached when it's initializing? }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a warp signal. }

; Marker Properties m_*
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
bool property m_matchRotation = false auto
{ Default: false - Should the warping objects match the rotation of this marker when they arrive? }

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

; Make the given DivineWarperMarker object property values conform to this objects values of the same name
function conformMarkerProperties(DivineWarperMarker markerRef)
	markerRef.delay = self.m_delay
	markerRef.collapseSpacing = self.m_collapseSpacing
	markerRef.offsetX = self.m_offsetX
	markerRef.offsetY = self.m_offsetY
	markerRef.offsetZ = self.m_offsetZ
	markerRef.offsetAX = self.m_offsetAX
	markerRef.offsetAY = self.m_offsetAY
	markerRef.offsetAZ = self.m_offsetAZ
	markerRef.matchRotation = self.m_matchRotation
endFunction

; Wait for all keyword-linked object refrecne positions to be the same as the given object reference positions
function waitForKeywordRefsAt(objectReference objectRef)
	bool waiting = true
	while (waiting)
		if ( self.keywordRefsAt(objectRef) )
			waiting = false
		endIf
	endWhile
endFunction

function onSignalling()
	if ( ! self.nextMarker && self.noMarkersAttached )
		self.moveKeywordRefsTo(  \
			self,                \
			self.m_offsetX,      \
			self.m_offsetY,      \
			self.m_offsetZ,      \
			self.m_offsetAX,     \
			self.m_offsetAY,     \
			self.m_offsetAZ,     \
			self.m_matchRotation \
		)
		self.waitForKeywordRefsAt(self)
		if (self.relayActivation)
			self.setRefActivated(self.linkedRef, self)	
		endIf
	elseIf (self.nextMarker)
		if (self.nextMarker.inheritSignalerProperties)
			self.conformMarkerProperties(self.nextMarker as DivineWarperMarker)
		endIf
		utility.wait(nextMarker.delay)
		self.moveKeywordRefsTo(           \
			self.nextMarker,              \
			self.nextMarker.offsetX,      \
			self.nextMarker.offsetY,      \
			self.nextMarker.offsetZ,      \
			self.nextMarker.offsetAX,     \
			self.nextMarker.offsetAY,     \
			self.nextMarker.offsetAZ,     \
			self.nextMarker.matchRotation \
		)
		self.waitForKeywordRefsAt(self.nextMarker)
		self.nextMarker = self.nextMarker.linkedRef as DivineWarperMarker
	endIf
endFunction