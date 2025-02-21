scriptName DivineComparer extends DivineSignaler
; Julianos – God of Wisdom and Logic

import DivineUtils

bool property andCompare = false auto
{ Default: False - Compare keyword-linked object references using the "AND" boolean operator.
  Example: [1, 1] => True | [1, 0] => False | [0, 0] => False.
  Must have at least 1 keyword object linked for comparisons. }

bool property notCompare = false auto
{ Default: False - Compare keyword-linked object references using the "NOT" boolean operator.
  Example: [0, 0] => True | [0, 1] => False | [1, 1] => False.
  Must have at least 1 keyword object linked for comparisons. }

bool property orCompare = false auto
{ Default: False - Compare keyword-linked object references using the "OR" boolean operator.
  Example: [1, 1] => True | [1, 0] => True | [0, 0] => False.
  Must have at least 1 keyword object linked for comparisons. }

bool property xorCompare = false auto
{ Default: False - Compare keyword-linked object references using the "XOR" boolean operator.
  Example: [1, 1] => False | [1, 0] => True | [0, 0] => False.
  Must have at least 1 keyword object linked for comparisons. }

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
  parent.onSignalling()
  
  ; Perform the boolean comparison based on properties
  bool result = false
  int trueCount = 0
  int falseCount = 0

  ; Iterate through all keyword-linked object references
  int refIndex = self.keywordRefs.length - 1
  while (refIndex >= 0)
    DivineObjectReference ref = self.keywordRefs[refIndex] as DivineObjectReference
    if (ref)
      if (ref.signaled)
        trueCount += 1
      else
        falseCount += 1
      endIf
    endIf
    refIndex -= 1
  endWhile

  ; Perform comparisons based on properties
  if (andCompare)
    result = (trueCount == self.keywordRefs.length)
  elseIf (notCompare)
    result = (trueCount == 0)
  elseIf (orCompare)
    result = (trueCount > 0)
  elseIf (xorCompare)
    result = (trueCount == 1)
  endIf

  ; Debugging output
  dd(self + "@ function: onSignalling | result: " + result, enabled=self.showDebug)

  ; Activate linked reference if result is true
  if (result)
    self.setRefActivated(self.linkedRef, self)
  endIf
endFunction
