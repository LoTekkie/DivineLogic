scriptName DivineMarker extends DivineObjectReference
; Base class for all Divine Logic markers

import DivineUtils

bool property activateKeywordRefs = true auto
{ Default: true - Should this marker activate keyword-linked object references when activated? }
bool property enableToggleKeywordRefs = false auto
{ Default: false - Should this marker toggle keyword-linked object references enabled when activated? }

state busy
  event onBeginState()
    if (self.activateKeywordRefs)
      self.setKeywordRefsActivated()
    endIf
    if (self.enableToggleKeywordRefs)
      self.toggleKeywordRefsEnabled()
    endIf
    goToState("waiting")
  endEvent
endState