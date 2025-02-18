scriptName DivineDestroyer extends DivineSignaler
; Arkay – God of the Cycle of Life and Death, and Mortals burials and funeral rites

import DivineUtils

bool property whenAble = false auto
{ Default: False - Wait for linked references to lose their parent cell or for their parent cell to become detached before deleting. }

bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of an destroy signal. }

function onSignalling()
  parent.onSignalling()
  if ( ! self.relayActivation )
  	self.deleteRef(self.linkedRef, self.whenAble)
  else
    self.setRefActivated(self.linkedRef, self)  
  endIf
  self.deleteKeywordRefs(self.whenAble)
endFunction