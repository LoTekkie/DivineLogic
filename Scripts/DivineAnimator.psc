scriptName DivineAnimator extends DivineSignaler
; Lorkhan - the et'Ada most directly responsible for the existence of Nirn and is the god of all mortals.

import DivineUtils

string property animationEvent = "" auto
{ Default: "" - Event name of the animation to play or an animation variable name when one of the three SendEventAsVariable properties is set to True. }
string property animationVariableValue = "" auto
{ Default: "" - Value of the animation variable to send to the animation graph. (Used only when one of the three SendEventAsVariable properties is set to True) }
bool property toPlayer = false auto
{ Default: False - Should the animation or variable be applied to the player also? }
bool property sendEventAsFloatVariable = false auto
{ Default: False - Send the animationEvent string as a Float variable name to the animation graph. (Used with the animationVariableValue property)}
bool property sendEventAsBoolVariable = false auto
{ Default: False - Send the animationEvent string as a Bool variable name to the animation graph. (Used with the animationVariableValue property)}
bool property sendEventAsIntVariable = false auto
{ Default: False - Send the animationEvent string as an Int variable name to the animation graph. (Used with the animationVariableValue property)}
bool property subGraphAnimation = false auto
{ Default: False - Is this animation being applied to an object attached to an actor? }
bool property gameBryoAnimation = false auto
{ Default: False - Is this a legacy GameBryo animation? }
bool property gameBryoStartOver = false auto
{ Default: False - Should the animation start over from the begining? (Only applied if gameBryoAnimation is True) }
float property gameBryoEaseInTime = 0.0 auto
{ Default: 0.0 - The amount of time to take to ease-in the animation, in seconds. (Only applied if gameBryoAnimation is True) }
bool property lookAtPlayer = false auto
{ Default: False - Should actor based linked references look at the player? }
bool property lookAtPlayerWhilePathing = false auto
{ Default: False - Should actor based linked references look at the player while moving? (If this property is set to True then the LookAtPlayer property will also be set to True regarless of its value in the editor) }
bool property clearLookAt = false auto
{ Default: False - Should actor based linked references have their look at target cleared? (Overrides looking at player properties) }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of an animation signal. }

function onSignalling()
	parent.onSignalling()
	bool sendAsVariable = self.sendEventAsBoolVariable  || \ 
												self.sendEventAsFloatVariable || \
											  self.sendEventAsIntVariable
	if ( ! self.relayActivation )
		if ( ! sendAsVariable )
			self.animateRef(          \
				self.linkedRef,         \
				self.animationEvent,    \
				self.subGraphAnimation, \
				self.gameBryoAnimation, \
				self.gameBryoStartOver, \
				self.gameBryoEaseInTime \
			)
		else
			self.setRefAnimationVariable(    \
				self.linkedRef,          			 \
				self.animationEvent,           \
				self.animationVariableValue,	 \
				self.sendEventAsBoolVariable,  \
				self.sendEventAsFloatVariable, \
				self.sendEventAsIntVariable    \
			)
		endIf	
	else
		self.setRefActivated(self.linkedRef, self)	
	endIf
	if ( ! sendAsVariable )
		self.animateKeywordRefs(   \
	    self.animationEvent,     \
	    self.subGraphAnimation,  \
	    self.gameBryoAnimation,  \
	    self.gameBryoStartOver,  \
	    self.gameBryoEaseInTime  \
	  )
	else
		self.setKeywordRefsAnimationVariable( \
			self.animationEvent,   							\
			self.animationVariableValue,				\
			self.sendEventAsBoolVariable,				\
			self.sendEventAsFloatVariable,			\
			self.sendEventAsIntVariable					\
		)
	endIf
	if (self.toPlayer)
		if ( ! sendAsVariable )
			self.animateRef(          \
				self.playerRef,         \
				self.animationEvent,    \
				self.subGraphAnimation, \
				self.gameBryoAnimation, \
				self.gameBryoStartOver, \
				self.gameBryoEaseInTime \
			)
		else
			self.setRefAnimationVariable(    \
				self.playerRef,          			 \
				self.animationEvent,           \
				self.animationVariableValue,	 \
				self.sendEventAsBoolVariable,  \
				self.sendEventAsFloatVariable, \
				self.sendEventAsIntVariable    \
			)
		endIf	
	endIf
	actor ref = self.linkedRef as actor
	if ( self.lookAtPlayer || self.lookAtPlayerWhilePathing && ! self.clearLookAt )
		if (ref)
			ref.setLookAt(self.playerRef, self.lookAtPlayerWhilePathing)
		endIf
		self.setKeywordRefsLookAt(self.playerRef, self.lookAtPlayerWhilePathing)
	elseIf (self.clearLookAt)
		if (ref)
			ref.clearLookAt()
		endIf
		self.clearKeywordRefsLookAt()
	endIf	
endFunction