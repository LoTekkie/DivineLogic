scriptName DivineAnimator extends DivineSignaler
; Lorkhan - the et'Ada most directly responsible for the existence of Nirn and is the god of all mortals.

import DivineUtils

string property animationName = "" auto
{ Default: "" - Name of the animation to play. }

bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of an animation signal. }

function onSignalling()
	parent.onSignalling()
	if ( ! self.relayActivation )
		self.linkedRef.playAnimation(animationName)
		;animate target ref
	else
		self.setRefActivated(self.linkedRef, self)	
	endIf
endFunction