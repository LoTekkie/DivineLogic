scriptName DivineGlobalModifier extends DivineSignaler
; Julianos – God of Wisdom and Logic

import DivineUtils

globalVariable property variable = none auto
{ Default: None - The global variable to modify. }
float property value = 0.0 auto
{ Default: 0.0 - The value to modify with or compare with. }
bool property asInt = false auto
{ Default: False - Modify or compare the globalVariable property as an Int rather than Float. }
bool property compareVariable = false auto
{ Default: False - Compare the variable property against the value property. }
bool property modValue = false auto
{ Default: False - Modify the global variable in a thread-safe way. }
string property comparisonOperator = "==" auto
{ Default: "==" - The operator used to compare the current global variable and the value property. 
  One of:
  "==" - Is the current global variable equal to the variable property? (Default)
  "!=" - Is the current global variable not equal to the variable property?
  ">" - Is the current global variable greater than the variable property?
  ">=" - Is the current global variable greater than or equal to the variable property?
  "<" - Is the current global variable less than the variable property?
  "<=" - Is the current global variable less than or equal to the variable property?
}
bool property relayActivation = false auto
{ Default: False - Send activation to the non-keyword linked reference instead of a modify signal. 
(Only used when not comparing, otherwise activation out only occurs when comparisons result in True) }
bool property activateKeywordRefs = false auto
{ Default: False - Send an activation to all keyword-linked object references. 
(If the compareVariable property is set to True, activation will only occurr if the comparison results in True) }

function onSignalling()
  parent.onSignalling()
  if ( ! compareVariable )
    if ( ! self.relayActivation )
      if ( ! self.modValue ) ; set
        if ( ! self.asInt)
          self.variable.setValue(value)
        else
          self.variable.setValue(value as int)
        endIf
      else ; mod
        self.variable.mod(value)
      endIf 
    else
      self.setRefActivated(self.linkedRef, self)
    endIf
    if (self.activateKeywordRefs)
      self.setKeywordRefsActivated()
    endIf 
  else ; compare mode
    float currentValue = self.variable.getValue()
    bool result = false
    if ( ! self.asInt )
      result = compareFloatValues(currentValue, self.comparisonOperator, self.value)
    else
      result = compareIntValues(currentValue as int, self.comparisonOperator, self.value as int)  
    endIf
    if (result)
      self.setRefActivated(self.linkedRef, self)
      if (self.activateKeywordRefs)
        self.setKeywordRefsActivated()
      endIf 
    endIf 
  endIf 
endFunction
