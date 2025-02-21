scriptName DivineTranslator extends DivineSignaler
; Zenithar - God of Work and Commerce, Trader God

import DivineUtils

; =========================
;        PROPERTIES
; =========================

DivineTranslatorMarker property nextMarker auto hidden
{ Reference to the current `DivineTranslatorMarker` object being processed. }

bool property noMarkersAttached = true auto hidden
{ Default: True - Does this signaler have any markers attached when it's initializing? }

bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instead of a translate signal. }

float property individualDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait between translation of each keyword-linked object reference. 
  (A non-zero value will cause each object to translate one at a time.) }

bool property treatAsHavok = false auto
{ Default: False - Treat all keyword-linked object references as Havok objects. 
  (Before translation, linked references will have their motion types set to `Motion_Keyframed`. 
  Upon ending translation, linked references will have their motion types set to `Motion_Dynamic`.) }

; =========================
;   MARKER PROPERTIES (m_)
; =========================

float property m_delay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the keyword-linked object references translate to this marker. }

float property m_speed = 100.0 auto
{ Default: 100.0 - Speed at which the keyword-linked object references will translate to this marker. }

float property m_rotationSpeedClamp = 0.0 auto
{ Default: 0.0 - Amount of rotation speed clamping applied to translating objects. 
  (0.0 means don't clamp rotation speed.) }

bool property m_rotateOnArrival = false auto
{ Default: False - Should rotation of the translating objects be prevented until they arrive at this marker? }

float property m_tangentMagnitude = 0.0 auto
{ Default: 0.0 - Magnitude of the spline tangents. If this value is 0.0, no splines will be created. }

bool property m_collapseSpacing = false auto
{ Default: False - Should translating objects ignore original spacing and meet at the same position on this marker? }

float property m_offsetX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' positions in the X direction. }

float property m_offsetY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' positions in the Y direction. }

float property m_offsetZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' positions in the Z direction. }

float property m_offsetAX = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' angles in the X direction. }

float property m_offsetAY = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' angles in the Y direction. }

float property m_offsetAZ = 0.0 auto
{ Default: 0.0 - How much to offset the translated objects' angles in the Z direction. }

bool property m_limitX = false auto
{ Default: False - Prevent translation of the X axis. }

bool property m_limitY = false auto
{ Default: False - Prevent translation of the Y axis. }

bool property m_limitZ = false auto
{ Default: False - Prevent translation of the Z axis. }

bool property m_limitAX = false auto
{ Default: False - Prevent rotation around the X axis. }

bool property m_limitAY = false auto
{ Default: False - Prevent rotation around the Y axis. }

bool property m_limitAZ = false auto
{ Default: False - Prevent rotation around the Z axis. }

bool property m_matchRotation = false auto
{ Default: False - Should the translating objects match the rotation of this marker when they arrive? }

bool property m_toPlayer = false auto
{ Default: False - Should the translating objects move to the player? }

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
  markerRef.limitX = conformBool(markerRef.limitX, self.m_limitX, false)
  markerRef.limitY = conformBool(markerRef.limitY, self.m_limitY, false)
  markerRef.limitZ = conformBool(markerRef.limitZ, self.m_limitZ, false)
  markerRef.limitAX = conformBool(markerRef.limitAX, self.m_limitAX, false)
  markerRef.limitAY = conformBool(markerRef.limitAY, self.m_limitAY, false)
  markerRef.limitAZ = conformBool(markerRef.limitAZ, self.m_limitAZ, false)
  markerRef.collapseSpacing = conformBool(markerRef.collapseSpacing, self.m_collapseSpacing, false)
  markerRef.matchRotation = conformBool(markerRef.matchRotation, self.m_matchRotation, false)
  markerRef.rotateOnArrival = conformBool(markerRef.rotateOnArrival, self.m_rotateOnArrival, false)
  markerRef.toPlayer = conformBool(markerRef.toPlayer, self.m_toPlayer, false)
endFunction

function onSignalling()
  if ( ! self.nextMarker && self.noMarkersAttached )
    if (self.treatAsHavok)
      self.setKeywordRefsAIEnabled(false)
      self.setKeywordRefsMotionType(Motion_Keyframed)
    endIf 
    objectReference destinationRef = self
    if (self.m_toPlayer)
      destinationRef = self.playerRef
    endIf
    bool[] axisLimits = self.buildAxisLimitsArray(   \
      self.m_limitX, self.m_limitY, self.m_limitZ,   \
      self.m_limitAX, self.m_limitAY, self.m_limitAZ \
    )
    self.translateKeywordRefsTo(     \
      destinationRef,                \
      self.keywordRefSpacingOffsets, \
      axisLimits,                    \
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
    if (self.treatAsHavok)
      self.setKeywordRefsMotionType(Motion_Dynamic)
      self.setKeywordRefsAIEnabled(true)
      self.animateKeywordRefs("IdleForceDefaultState")
    endIf 
  elseIf (self.nextMarker)
    if (self.treatAsHavok)
      self.setKeywordRefsAIEnabled(false)
      self.setKeywordRefsMotionType(Motion_Keyframed)
    endIf 
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
    self.translateKeywordRefsTo(          \
      destinationRef,                     \
      spacingOffsets,                     \
      axisLimits,                         \ 
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
    if ( ! self.nextMarker && self.treatAsHavok )
      self.setKeywordRefsMotionType(Motion_Dynamic)
      self.setKeywordRefsAIEnabled(true)
      self.animateKeywordRefs("IdleForceDefaultState")
    endIf 
  endIf
endFunction