scriptName DivineScaler extends DivineSignaler
; Dibella – Goddess of Beauty and Love

import DivineUtils

float property scaleMin = 1.0 auto
{ Default: 1.0 - Minium scale to set the object to when activated. }
float property scaleMax = 1.0 auto
{ Default: 1.0 - Maximum scale to set the object to if "scaleRandomly" is set to True. }
bool property scaleRandomly = false auto
{ Default: False - Scale to a random size between "scaleMin" and "scaleMax" property values when activated. 
	Overrides "toggleMinMax" setting when set to True. }
bool property scaleSync = true auto
{ Default: True - Ensure all objects are the same scale when "scaleRandomly" is selected. }
bool property toggleMinMax = false auto
{ Default: False - Cycle between "scaleMin" and "scaleMax" property values on each activation. Scaling will start with the "scaleMin" value. }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a scale signal. }

function onSignalling()
	parent.onSignalling()
	float newScale = scaleMin
	if (self.scaleRandomly)
		newScale = utility.randomFloat(scaleMin, scaleMax)
	elseIf(self.toggleMinMax)
		dd(self + "@ signaled: " + self.signaled, enabled=self.showDebug)
		if ( ! self.signaled )
			newScale = scaleMax
		else
			newScale = scaleMin
		endIf
	endIf
	if ( ! self.relayActivation )
		if ((self.scaleRandomly && ! self.scaleSync))
			self.scaleRefBetween(self.linkedRef, scaleMin, scaleMax, true)
			self.scaleKeywordRefsBetween(scaleMin, scaleMax, true)	
		else
			self.scaleRef(self.linkedRef, newScale, true)
			self.scaleKeywordRefs(newScale, true)
		endIf
	else
		if ((self.scaleRandomly && ! self.scaleSync))
			self.setRefActivated(self.linkedRef, self)
			self.scaleKeywordRefsBetween(scaleMin, scaleMax, true)
		else
			self.setRefActivated(self.linkedRef, self)
			self.scaleKeywordRefs(newScale, true)
		endIf
	endIf
endFunction