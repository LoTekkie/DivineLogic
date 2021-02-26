scriptName DivineTranslator extends DivineSignaler
; Zenithar - God of Work and Commerce, Trader God
import DivineUtils

DivineTranslatorMarker property nextMarker auto hidden
{ Refernce to the current DivineTranslatorMarker object being processed. }
bool property noMarkersAttached = true auto hidden
{ Does this singaler have any markers attached when it's initializing? }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a translate signal. }
float property individualDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait between translation of each keyword-linked object reference. 
(A non-zero value will cause each object to translate one at a time) }

; Marker Properties m_*
float property m_delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references translate to this marker. }
float property m_speed = 100.0 auto
{ Default: 100.0 - Speed at which the keyword-linked object references will translate to this marker. }
float property m_rotationSpeedClamp = 0.0 auto
{ Default: 0.0 - Amount of rotation speed clamping applied to translating objects. (0.0 means don't clamp rotation speed) }
bool property m_rotateOnArrival = false auto
{ Default: false - Should rotation of the translating objects be prevented until they arrive at this marker? }
float property m_tangentMagnitude = 0.0 auto
{ Default: 0.0 - Magnitude of the spline tangents. If this value is 0.0 no splines will be created. }
bool property m_collapseSpacing = false auto
{ Defualt: false - Should translating objects ignore original spacing and meet at the same postion on this marker? }
float property m_offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects positions in the X direction. }
float property m_offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects positions in the Y direction. }
float property m_offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects positions in the Z direction. }
float property m_offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects angles in the X direction. }
float property m_offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects angles in the Y direction. }
float property m_offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects angles in the Z direction. }
bool property m_matchRotation = false auto
{ Default: false - Should the translating objects match the rotation of this marker when they arrive? }

event onInit()
	parent.onInit()
	if ( ! self.nextMarker )
		DivineTranslatorMarker linkedMarker = self.getLinkedRef() as DivineTranslatorMarker
		if (linkedMarker)
			self.nextMarker = linkedMarker
			self.noMarkersAttached = false
		endIf
	endIf
endEvent

;/ Make the given DivineTranslatorMarker object property values conform to 
this objects values of the same property name if those values are not default /; 
function conformMarkerProperties(DivineTranslatorMarker markerRef)
	markerRef.delay = conformFloat(markerRef.delay, self.m_delay, 0.0)
	markerRef.speed = conformFloat(markerRef.speed, self.m_speed, 100.0)
	markerRef.rotationSpeedClamp = clampf(conformFloat(markerRef.rotationSpeedClamp, self.m_rotationSpeedClamp, 0.0), 0, 100)
	markerRef.tangentMagnitude = conformFloat(markerRef.tangentMagnitude, self.m_tangentMagnitude, 0.0)
	markerRef.offsetX = conformFloat(markerRef.offsetX, self.m_offsetX, 0.0)
	markerRef.offsetY = conformFloat(markerRef.offsetY, self.m_offsetY, 0.0)
	markerRef.offsetZ = conformFloat(markerRef.offsetZ, self.m_offsetZ, 0.0)
	markerRef.offsetAX = conformFloat(markerRef.offsetAX, self.m_offsetAX, 0.0)
	markerRef.offsetAY = conformFloat(markerRef.offsetAY, self.m_offsetAY, 0.0)
	markerRef.offsetAZ = conformFloat(markerRef.offsetAZ, self.m_offsetAZ, 0.0)
	markerRef.collapseSpacing = conformBool(markerRef.collapseSpacing, self.m_collapseSpacing, false)
	markerRef.matchRotation = conformBool(markerRef.matchRotation, self.m_matchRotation, false)
	markerRef.rotateOnArrival = conformBool(markerRef.rotateOnArrival, self.m_rotateOnArrival, false)
endFunction

function onSignalling()
	if ( ! self.nextMarker && self.noMarkersAttached )
			self.translateKeywordRefsTo(     \
				self,                          \
				self.keywordRefSpacingOffsets, \
				self.m_speed,                  \
				self.m_rotationSpeedClamp,     \
				self.m_tangentMagnitude,       \
				self.individualDelay,          \
				self.m_offsetX,                \
				self.m_offsetY,                \
				self.m_offsetZ,                \
				self.m_offsetAX,               \
				self.m_offsetAY,               \
				self.m_offsetAZ,               \
				self.m_matchRotation,          \
				self.m_rotateOnArrival         \
		)
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
		self.translateKeywordRefsTo(          \
			self.nextMarker,                    \
			spacingOffsets,                     \ 
			self.nextMarker.speed,              \
			self.nextMarker.rotationSpeedClamp, \
			self.nextMarker.tangentMagnitude,   \
			self.individualDelay,               \
			self.nextMarker.offsetX,            \
			self.nextMarker.offsetY,            \
			self.nextMarker.offsetZ,            \
			self.nextMarker.offsetAX,           \
			self.nextMarker.offsetAY,           \
			self.nextMarker.offsetAZ,           \
			self.nextMarker.matchRotation,      \
			self.nextMarker.rotateOnArrival     \
		)
		self.setRefActivated(self.nextMarker, self)
		self.nextMarker = self.nextMarker.linkedRef as DivineTranslatorMarker
	endIf
endFunction