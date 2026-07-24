; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.2.0

scriptName DivineCutsceneCreator extends DivineSignaler
; Talos - Hero-God of Mankind; maps to staged heroic presentation and camera control.

import DivineUtils

; =========================
;       PROPERTIES
; =========================

DivineCutsceneCreatorMarker property nextMarker auto hidden
{ Reference to the current DivineCutsceneCreatorMarker object being processed. }

DivineCutsceneCreatorMarker property cameraActorHomeMarker auto hidden
{ Reference to the first marker in the chain, used as a starting point for the cutscene. }

bool property noMarkersAttached = true auto hidden
{ Default: True - Does this signaler have any markers attached when initializing? }

bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instead of a translate signal. }

imageSpaceModifier property fadeTo auto hidden
{ Screen effect used for fading in/out. }

imageSpaceModifier property fadeFrom auto hidden
{ Screen effect used for fading in/out. }

bool property inCutScene = false auto hidden
{ Are we currently in a cutscene? }

int property skipCutSceneKeyId = 28 auto hidden
{ Key ID used for skipping cutscenes. }

actor property cameraActor auto hidden
{ Reference to the actor used to view cutscenes through. }

int property cameraActorFormId = 0x0010D13E auto hidden ; 0x020239EA
{ Internal reference ID used as the camera actor. }

bool property cutSceneLocked = false auto hidden
{ Internal state of the cutscene creator, prevents starting and ending multiple times. }

bool property hidePlayer = true auto
{ Default: True - Should the player be hidden when the cutscene starts? }

float property fadeOutDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the scene fades out. }

float property fadeInDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the scene fades in. }

float property cutsceneEndDelay = 0.0 auto
{ Default: 0.0 - Seconds to wait before the cutscene ends after reaching the final marker. }

bool property cutsceneEndPause = false auto
{ Default: False - Should this signaler be paused when the cutscene has ended? }

bool property allowSkip = true auto
{ Default: True - Should the player be able to skip this cutscene? }

; =========================
;    MARKER PROPERTIES
; =========================

float property m_delay = 0.0 auto
{ Default: 0.0 - Seconds to wait after the camera arrives at this marker. }

float property m_speed = 100.0 auto
{ Default: 100.0 - Speed at which the keyword-linked object references will translate to this marker. }

float property m_rotationSpeedClamp = 0.0 auto
{ Default: 0.0 - Amount of rotation speed clamping applied to translating objects (0.0 means no clamp). }

bool property m_rotateOnArrival = false auto
{ Default: False - Should rotation of the translating objects be prevented until they arrive at this marker? }

float property m_tangentMagnitude = 0.0 auto
{ Default: 0.0 - Magnitude of the spline tangents. If this value is 0.0, no splines will be created. }

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
{ Default: False - Prevents translation on the X axis. }

bool property m_limitY = false auto
{ Default: False - Prevents translation on the Y axis. }

bool property m_limitZ = false auto
{ Default: False - Prevents translation on the Z axis. }

bool property m_limitAX = false auto
{ Default: False - Prevents rotation on the X axis. }

bool property m_limitAY = false auto
{ Default: False - Prevents rotation on the Y axis. }

bool property m_limitAZ = false auto
{ Default: False - Prevents rotation on the Z axis. }

bool property m_matchRotation = false auto
{ Default: False - Should the translating objects match the rotation of this marker when they arrive? }

bool property m_toPlayer = false auto
{ Default: False - Should the translating objects move to the player's location instead of this marker? }

bool property m_shakeCamera = false auto
{ Default: False - Should the camera shake upon arrival? }

float property m_cameraShakeStrength = 0.5 auto
{ Default: 0.5 - Strength of the camera shake (only used if shakeCamera is True). }

float property m_cameraShakeDuration = 0.0 auto
{ Default: 0.0 - Duration of the camera shake (only used if shakeCamera is True). }

; =========================
;     EVENTS
; =========================

event onInit()
  ; Call the parent class's initialization function
  parent.onInit()

  ; Check if there is no next marker assigned
  if (!self.nextMarker)
      DivineCutsceneCreatorMarker linkedMarker = self.getLinkedRef() as DivineCutsceneCreatorMarker

      ; If a linked marker is found, assign it as the next marker
      if (linkedMarker)
          self.nextMarker = linkedMarker
          self.noMarkersAttached = false
      endIf
  endIf
endEvent

; =========================
;     METHODS
; =========================

function conformMarkerProperties(DivineCutsceneCreatorMarker markerRef)
  markerRef.delay = conformFloat(markerRef.delay, self.m_delay, 0.0)
  markerRef.speed = conformFloat(markerRef.speed, self.m_speed, 100.0)
  markerRef.rotationSpeedClamp = clampf(conformFloat(markerRef.rotationSpeedClamp, self.m_rotationSpeedClamp, 0.0), 0, 100)
  markerRef.tangentMagnitude = conformFloat(markerRef.tangentMagnitude, self.m_tangentMagnitude, 0.0)
  
  ; Apply positional offsets
  markerRef.offsetX = conformFloat(markerRef.offsetX, self.m_offsetX, 0.0)
  markerRef.offsetY = conformFloat(markerRef.offsetY, self.m_offsetY, 0.0)
  markerRef.offsetZ = conformFloat(markerRef.offsetZ, self.m_offsetZ, 0.0)

  ; Apply rotational offsets
  markerRef.offsetAX = conformFloat(markerRef.offsetAX, self.m_offsetAX, 0.0)
  markerRef.offsetAY = conformFloat(markerRef.offsetAY, self.m_offsetAY, 0.0)
  markerRef.offsetAZ = conformFloat(markerRef.offsetAZ, self.m_offsetAZ, 0.0)

  ; Apply movement restrictions
  markerRef.limitX = conformBool(markerRef.limitX, self.m_limitX, false)
  markerRef.limitY = conformBool(markerRef.limitY, self.m_limitY, false)
  markerRef.limitZ = conformBool(markerRef.limitZ, self.m_limitZ, false)
  markerRef.limitAX = conformBool(markerRef.limitAX, self.m_limitAX, false)
  markerRef.limitAY = conformBool(markerRef.limitAY, self.m_limitAY, false)
  markerRef.limitAZ = conformBool(markerRef.limitAZ, self.m_limitAZ, false)

  ; Apply additional movement behavior settings
  markerRef.matchRotation = conformBool(markerRef.matchRotation, self.m_matchRotation, false)
  markerRef.rotateOnArrival = conformBool(markerRef.rotateOnArrival, self.m_rotateOnArrival, false)
  markerRef.toPlayer = conformBool(markerRef.toPlayer, self.m_toPlayer, false)

  ; Apply camera shake effects
  markerRef.shakeCamera = conformBool(markerRef.shakeCamera, self.m_shakeCamera, false)
  markerRef.cameraShakeStrength = conformFloat(markerRef.cameraShakeStrength, self.m_cameraShakeStrength, 0.5)
  markerRef.cameraShakeDuration = conformFloat(markerRef.cameraShakeDuration, self.m_cameraShakeDuration, 0.0)
endFunction

; Apply fadeTo imageSpaceModifier in the given number of seconds
function fadeOut(float delay)
  if (delay > 0.0)
    utility.wait(delay)
  endIf
  if (fadeTo)
    fadeTo.apply()
  endIf
  game.fadeOutGame(false, true, 50, 1)  ; Gradual fade to black
endFunction

; Apply the fadeFrom imageSpaceModifier in the given number of seconds
function fadeIn(float delay)
  if (delay > 0.0)
    utility.wait(delay)
  endIf
  game.fadeOutGame(false, true, 0.1, 0.1)  ; Quick fade back in
  if (fadeTo && fadeFrom)
    fadeTo.popTo(fadeFrom)  ; Restore original screen state
  endIf
endFunction

; Set the given Actor reference visibility
function setActorVisible(actor actorRef, bool visible=true)
  if ( ! actorRef )
    return
  endIf

  float alpha = 1.0
  if ( ! visible )
    alpha = 0.0
  endIf
  actorRef.setAlpha(alpha)
  actorRef.setGhost( ! visible )
endFunction

; Create a new camera actor
actor function createCameraActor()
    form cameraActorForm = game.getForm(self.cameraActorFormId)
    if ( ! cameraActorForm )
      return none
    endIf
    return self.placeAtMe(cameraActorForm) as Actor
endFunction

; Set which Actor reference should be used as our cutscene camera
function setCameraTarget(actor actorRef)
  if ( ! actorRef )
    return
  endIf

  game.setCameraTarget(actorRef)
  game.forceFirstPerson()
  game.forceThirdPerson()
endFunction

; Start the cutscene
function startCutScene(float fadeOutDelay=0.0, float fadeInDelay=0.0)
  self.inCutScene = true
  debug.setGodMode(true)
  self.playerRef.stopCombat()
  game.disablePlayerControls(true, true, true, true, true, true, true, true)
  utility.setIniFloat("fMouseWheelZoomSpeed:Camera", 0.0)
  utility.setIniBool("bDisablePlayerCollision:Havok", true)
  debug.toggleCollisions()
  self.fadeOut(fadeOutDelay)
  if ( ! self.cameraActor )
    self.cameraActor = self.createCameraActor()
    utility.wait(1.0)
  endIf
  if ( ! self.cameraActor )
    wrn(self + "@ function: startCutScene | camera actor unavailable", enabled=self.showDebug)
    utility.setIniFloat("fMouseWheelZoomSpeed:Camera", 10.0)
    utility.setIniBool("bDisablePlayerCollision:Havok", false)
    debug.toggleCollisions()
    game.enablePlayerControls()
    debug.setGodMode(false)
    self.fadeIn(fadeInDelay)
    self.inCutScene = false
    return
  endIf
  self.cameraActor.enableAI(false)
  self.setActorVisible(self.cameraActor, false)
  self.cameraActor.setMotionType(Motion_Keyframed, false)
  if (self.nextMarker)
    self.moveRefTo(self.cameraActor, self.nextMarker, self.buildAxisLimitsArray(), matchRotation=true)
  endIf
  if (self.hidePlayer)
    self.setActorVisible(self.playerRef, false)
  endIf 
  self.setCameraTarget(self.cameraActor)
  self.fadeIn(fadeInDelay)
endFunction

; End the cutscene
function endCutScene(float fadeOutDelay=0.0, float fadeInDelay=0.0)
  self.ignoreBusy = true
  self.cutSceneLocked = true
  unregisterForUpdate()
  info("Ending Cutscene", enabled=self.showDebug)
  self.fadeOut(fadeOutDelay)
  if (self.cameraActor)
    self.cameraActor.stopTranslation()
  endIf
  utility.setIniFloat("fMouseWheelZoomSpeed:Camera", 10.0)
  utility.setIniBool("bDisablePlayerCollision:Havok", false)
  if (self.cameraActor)
    self.cameraActor.delete()
  endIf
  self.cameraActor = None
  debug.toggleCollisions()
  self.setCameraTarget(self.playerRef)
  if (self.hidePlayer)
    self.setActorVisible(self.playerRef, true)
  endIf 
  game.enablePlayerControls()
  debug.setGodMode(false)
  self.nextMarker = self.cameraActorHomeMarker
  self.fadeIn(fadeInDelay)
  self.inCutScene = false
  if (self.cutsceneEndPause)
    self.paused = true
  endIf
endFunction

; =========================
;     LIFECYCLE HOOKS
; =========================

function onSignalling()
  parent.onSignalling()

  if ( ! self.inCutScene && ! self.cutSceneLocked )
    self.startCutScene(self.fadeOutDelay, self.fadeInDelay)
    if ( ! self.inCutScene )
      return
    endIf
    registerForSingleUpdate(0.0)
    if (self.nextMarker)
      self.setRefActivated(self.nextMarker, self)
      self.cameraActorHomeMarker = self.nextMarker
      self.nextMarker = self.nextMarker.linkedRef as DivineCutsceneCreatorMarker
    endIf
  endIf
  if ( ! self.nextMarker && self.noMarkersAttached )
    objectReference destinationRef = self
    if (self.m_toPlayer)
      destinationRef = self.playerRef
    endIf
    bool[] axisLimits = self.buildAxisLimitsArray(   \
      self.m_limitX, self.m_limitY, self.m_limitZ,   \
      self.m_limitAX, self.m_limitAY, self.m_limitAZ \
    )
    self.translateRefTo(         \
      self.cameraActor,          \
      destinationRef,            \
      axisLimits,                \
      self.m_speed,              \
      self.m_rotationSpeedClamp, \
      self.m_tangentMagnitude,   \
      self.m_offsetX,            \
      self.m_offsetY,            \
      self.m_offsetZ,            \
      self.m_offsetAX,           \
      self.m_offsetAY,           \
      self.m_offsetAZ,           \
      self.m_matchRotation,      \
      self.m_rotateOnArrival     \
    )
    if (self.m_shakeCamera)
       game.shakeCamera(self.playerRef, self.m_cameraShakeStrength, self.m_cameraShakeDuration)
    endIf  
    if (self.m_delay > 0.0)
      utility.wait(self.m_delay)
    endIf
    if (self.relayActivation)
      self.setRefActivated(self.linkedRef, self)  
    endIf
  elseIf (self.nextMarker)
    self.conformMarkerProperties(self.nextMarker)
    objectReference destinationRef = self.nextMarker
    if (self.nextMarker.toPlayer)
      destinationRef = self.playerRef
    endIf
    bool[] axisLimits = self.buildAxisLimitsArray(                              \
      self.nextMarker.limitX, self.nextMarker.limitY, self.nextMarker.limitZ,   \
      self.nextMarker.limitAX, self.nextMarker.limitAY, self.nextMarker.limitAZ \
    )
    self.translateRefTo(                  \
      self.cameraActor,                   \
      destinationRef,                     \
      axisLimits,                         \
      self.nextMarker.speed,              \
      self.nextMarker.rotationSpeedClamp, \
      self.nextMarker.tangentMagnitude,   \
      self.nextMarker.offsetX,            \
      self.nextMarker.offsetY,            \
      self.nextMarker.offsetZ,            \
      self.nextMarker.offsetAX,           \
      self.nextMarker.offsetAY,           \
      self.nextMarker.offsetAZ,           \
      self.nextMarker.matchRotation,      \
      self.nextMarker.rotateOnArrival     \
    )
    if (self.nextMarker.shakeCamera)
      game.shakeCamera(self.playerRef, self.nextMarker.cameraShakeStrength, self.nextMarker.cameraShakeDuration)
    endIf  
    if (self.nextMarker.delay > 0.0)
      utility.wait(self.nextMarker.delay)
    endIf
    DivineCutsceneCreatorMarker completedMarker = self.nextMarker
    self.nextMarker = completedMarker.linkedRef as DivineCutsceneCreatorMarker
    self.setRefActivated(completedMarker, self)
  endIf
  if ( ! self.nextMarker && self.inCutScene )
    utility.wait(self.cutsceneEndDelay)
    if ( ! self.cutSceneLocked )
      self.endCutScene(self.fadeOutDelay, self.fadeInDelay)
    endIf
  endIf
endFunction

function onUpdating()
  if (self.inCutScene)
    if (self.allowSkip)
      debug.notification("Hold Enter to skip")
      if (input.isKeyPressed(self.skipCutSceneKeyId))
        if ( ! self.cutSceneLocked )
          self.endCutScene(self.fadeOutDelay, self.fadeInDelay)
          goToState("waiting")
        endIf
      endIf
    else
      debug.notification("In Cutscene")
    endIf
    registerForSingleUpdate(0.25)
  endIf
endFunction

; =========================
;        STATES
; =========================

state waiting
  event onEndState()
    if ( ! self.inCutScene && self.cutSceneLocked )
      self.ignoreBusy = false
      self.cutSceneLocked = false
    endIF
  endEvent
endState
