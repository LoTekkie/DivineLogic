scriptName DivineEnabler extends DivineSignaler
; Arkay – God of the Cycle of Life and Death, and Mortals burials and funeral rites

import DivineUtils

bool property waitForAnimation = true auto
{ Default: True - Allow objects to fade in/out when enabling/disabling them. }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of an enable signal. }

function onSignalling()
  parent.onSignalling()
  if ( ! self.relayActivation )
    self.toggleRefEnabled(self.linkedRef, self.waitForAnimation)
  else
    self.setRefActivated(self.linkedRef, self)  
  endIf
  self.toggleKeywordRefsEnabled(self.waitForAnimation)
endFunction