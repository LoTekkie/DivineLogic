scriptName DivineComparer extends DivineSignaler
; Julianos – God of Wisdom and Logic

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property andCompare = false auto
{ Default: False - Compare keyword-linked object references using the "AND" boolean operator 
  (examples: [1, 1] => True | [1, 0] => False | [0, 0] => False).
  When comparison is successful an activation signal is sent to the non-keyword linked object reference.
  All keyword-linked objects must be of type: DivineObjectRefernce. 
  Must have at least 1 keyword object linked for comparisons. }

bool property notCompare = false auto
{ Default: False - Compare keyword-linked object references using the "NOT" boolean operator 
  (examples: [0, 0] => True | [0, 1] => False | [1, 1] => False).
  When comparison is successful an activation signal is sent to the non-keyword linked object reference.
  All keyword-linked objects must be of type: DivineObjectRefernce. 
  Must have at least 1 keyword object linked for comparisons. }

bool property orCompare = false auto
{ Default: False - Compare keyword-linked object references using the "OR" boolean operator 
  (examples: [1, 1] => True | [1, 0] => True | [0, 0] => False).
  When comparison is successful an activation signal is sent to the non-keyword linked object reference.
  All keyword-linked objects must be of type: DivineObjectRefernce. 
  Must have at least 1 keyword object linked for comparisons. }

bool property xorCompare = false auto
{ Default: False - Compare keyword-linked object references using the "XOR" boolean operator 
  (examples: [1, 1] => False | [1, 0] => True | [0, 0] => False).
  When comparison is successful an activation signal is sent to the non-keyword linked object reference.
  All keyword-linked objects must be of type: DivineObjectRefernce. 
  Must have at least 1 keyword object linked for comparisons. }

function onSignalling()
  parent.onSignalling()
  bool result = self.compareKeywordRefs(andCompare, notCompare, orCompare, xorCompare)
  log(self + "@ function: compareKeywordRefs | result: " + result, enabled=self.showDebug)
  if (result)
    self.setRefActivated(self.linkedRef, self)
  endIf
endFunction