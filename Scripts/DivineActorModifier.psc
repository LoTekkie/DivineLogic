scriptName DivineActorModifier extends DivineSignaler
; Julianos – God of Wisdom and Logic

import DivineUtils

string property valueName = "" auto
{ Default: "" - The name of the actor value to modify or compare. }
float property value = 0.0 auto
{ Default: 0.0 - The value to modify with or compare with. }
string property comparisonOperator = "==" auto
{ Default: "==" - The operator used to compare the current actor value and the comparisonValue property. 
  One of:
  "==" - Is the current actor value equal to the comparsionValue property? (Default)
  "!=" - Is the current actor value not equal to the comparsionValue property?
  ">" - Is the current actor value greater than the comparsionValue property?
  ">=" - Is the current actor value greater than or equal to the comparsionValue property?
  "<" - Is the current actor value less than the comparsionValue property?
  "<=" - Is the current actor value less than or equal to the comparsionValue property?
}
bool property forceActorValue = false auto
{ Default: False - Force the new actor value. (Modifies the permanent modifier as opposed to the base value) }
bool property damageActorValue = false auto
{ Default: False - Damage the current actor value. (Modifies the current value as opposed to the base value) }
bool property modActorValue = false auto
{ Default: False - Mod the current actor value. (Modifies the maxiumum value for the actor value as opposed to the base value) }
bool property restoreActorValue = false auto
{ Default: False - Restore the current actor value. (Modifies the current value as opposed to the base value) }
bool property setActorValue = true auto
{ Default: Fasle - Set the new actor value. (Modifies the base actor value) }
bool property compareActorValue = false auto
{ Default: False - Enable Compare mode and ensure an actor value matches the valueExpected property value. 
(relayActivation is not used in compare mode. Activation of the non-keyword linked object reference only occurs when a comparsion results in True) }
bool property compareActorBaseValue = false auto
{ Default: False - Enable Compare mode and ensure a base actor value matches the valueExpected property value. 
(relayActivation is not used in compare mode. Activation of the non-keyword linked object reference only occurs when a comparsion results in True) }
bool property compareActorValuePercentage = false auto
{ Default: False - Enable Compare mode and ensure an actor value percentage matches the valueExpected property value. 
(relayActivation is not used in compare mode. Activation of the non-keyword linked object reference only occurs when a comparsion results in True) }
bool property toPlayer = false auto
{ Default: False - Set or compare an actor value to the player. }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instead of a modify signal. 
(Only used when not comparing, otherwise activation out only occurs when comparisons result in True) }

function onSignalling()
  parent.onSignalling()
  actor targetActor = self.linkedRef as actor
  if (toPlayer) 
    targetActor = self.playerRef
  endIf
  bool shouldCompare = self.compareActorValue     || \  
                       self.compareActorBaseValue || \
                       self.compareActorValuePercentage
  if ( ! shouldCompare )
    if ( ! self.relayActivation )
      if (targetActor)
        self.modifyActorValue(    \
          targetActor,            \
          self.valueName,         \
          self.value,             \
          self.forceActorValue,   \
          self.damageActorValue,  \
          self.modActorValue,     \
          self.restoreActorValue, \
          self.setActorValue      \
        )
      endIf 
    else
      self.setRefActivated(self.linkedRef, self)
    endIf
    if (toPlayer)
      self.modifyActorValue(    \
        targetActor,            \
        self.valueName,         \
        self.value,             \
        self.forceActorValue,   \
        self.damageActorValue,  \
        self.modActorValue,     \
        self.restoreActorValue, \
        self.setActorValue      \
      )
    endIf
    self.modifyKeywordActorsValue( \
      self.valueName,              \
      self.value,                  \
      self.forceActorValue,        \
      self.damageActorValue,       \
      self.modActorValue,          \
      self.restoreActorValue,      \
      self.setActorValue           \
    )
  else ; compare mode
    bool playerResult = true
    if (toPlayer)
      playerResult = self.compareActorValue( \
        targetActor,                         \
        self.valueName,                      \
        self.value,                          \
        self.comparisonOperator,             \
        self.compareActorBaseValue,          \
        self.compareActorValuePercentage     \
      )
    endIf 
    bool keywordsResult = self.compareKeywordActorsValue( \
      self.valueName,                                     \
      self.value,                                         \
      self.comparisonOperator,                            \
      self.compareActorBaseValue,                         \
      self.compareActorValuePercentage                    \
    )
    dd(self + "@ function: onSignalling" + " | playerResult: " + playerResult + " | keywordsResult: " + keywordsResult, enabled=self.showDebug)
    if (playerResult && keywordsResult)
      self.setRefActivated(self.linkedRef, self)
    endIf 
  endIf 
endFunction