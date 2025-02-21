scriptName DivineAnimator extends DivineSignaler
; Lorkhan - The et'Ada most directly responsible for the existence of Nirn and is the god of all mortals.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

string property animationEvent = "" auto
{ The name of the animation event to play, or an animation variable name when one of the three `sendEventAsVariable` properties is set to True. Default: "" }

string property animationVariableValue = "" auto
{ The value of the animation variable to send to the animation graph. Used only when one of the three `sendEventAsVariable` properties is set to True. Default: "" }

bool property toPlayer = false auto
{ Determines if the animation or variable should be applied to the player. Default: False }

bool property sendEventAsFloatVariable = false auto
{ If True, sends `animationEvent` as a Float variable name to the animation graph. Default: False }

bool property sendEventAsBoolVariable = false auto
{ If True, sends `animationEvent` as a Bool variable name to the animation graph. Default: False }

bool property sendEventAsIntVariable = false auto
{ If True, sends `animationEvent` as an Int variable name to the animation graph. Default: False }

bool property subGraphAnimation = false auto
{ Determines if this animation is applied to an object attached to an actor. Default: False }

bool property gameBryoAnimation = false auto
{ Determines if this is a legacy GameBryo animation. Default: False }

bool property gameBryoStartOver = false auto
{ If True, starts the GameBryo animation from the beginning. Only applied if `gameBryoAnimation` is True. Default: False }

float property gameBryoEaseInTime = 0.0 auto
{ The duration (in seconds) for easing-in a GameBryo animation. Only applied if `gameBryoAnimation` is True. Default: 0.0 }

bool property lookAtPlayer = false auto
{ If True, actor-based linked references will look at the player. Default: False }

bool property lookAtPlayerWhilePathing = false auto
{ If True, actor-based linked references will look at the player while moving. 
  If this is set to True, `lookAtPlayer` will also be forced to True. Default: False }

bool property clearLookAt = false auto
{ If True, actor-based linked references will have their LookAt target cleared. 
  Overrides both `lookAtPlayer` and `lookAtPlayerWhilePathing`. Default: False }

bool property relayActivation = false auto
{ If True, sends an activation signal to the non-keyword linked reference instead of playing an animation. Default: False }

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
    parent.onSignalling()

    bool sendAsVariable = self.sendEventAsBoolVariable || \
                          self.sendEventAsFloatVariable || \
                          self.sendEventAsIntVariable

    if (!self.relayActivation)
        if (!sendAsVariable)
            self.animateReference(self.linkedRef)
        else
            self.setReferenceAnimationVariable(self.linkedRef)
        endIf
    else
        self.setRefActivated(self.linkedRef, self)
    endIf

    if (!sendAsVariable)
        self.animateKeywordRefs( \
            self.animationEvent, \
            self.subGraphAnimation, \
            self.gameBryoAnimation, \
            self.gameBryoStartOver, \
            self.gameBryoEaseInTime \
        )
    else
        self.setKeywordRefsAnimationVariable( \
            self.animationEvent, \
            self.animationVariableValue, \
            self.sendEventAsBoolVariable, \
            self.sendEventAsFloatVariable, \
            self.sendEventAsIntVariable \
        )
    endIf

    if (self.toPlayer)
        if (!sendAsVariable)
            self.animateReference(self.playerRef)
        else
            self.setReferenceAnimationVariable(self.playerRef)
        endIf
    endIf

    self.handleLookAtLogic()
endFunction

; =========================
;   ANIMATION FUNCTIONS
; =========================

function animateReference(objectReference objectRef)
    if (objectRef)
        self.animateRef( \
            objectRef, \
            self.animationEvent, \
            self.subGraphAnimation, \
            self.gameBryoAnimation, \
            self.gameBryoStartOver, \
            self.gameBryoEaseInTime \
        )
    endIf
endFunction

function setReferenceAnimationVariable(objectReference objectRef)
    if (objectRef)
        self.setRefAnimationVariable( \
            objectRef, \
            self.animationEvent, \
            self.animationVariableValue, \
            self.sendEventAsBoolVariable, \
            self.sendEventAsFloatVariable, \
            self.sendEventAsIntVariable \
        )
    endIf
endFunction

; =========================
;     LOOK-AT LOGIC
; =========================

function handleLookAtLogic()
    actor refActor = self.linkedRef as actor

    if (self.clearLookAt)
        if (refActor)
            refActor.clearLookAt()
        endIf
        self.clearKeywordRefsLookAt()
        return
    endIf

    if (self.lookAtPlayer || self.lookAtPlayerWhilePathing)
        if (refActor)
            refActor.setLookAt(self.playerRef, self.lookAtPlayerWhilePathing)
        endIf
        self.setKeywordRefsLookAt(self.playerRef, self.lookAtPlayerWhilePathing)
    endIf
endFunction
