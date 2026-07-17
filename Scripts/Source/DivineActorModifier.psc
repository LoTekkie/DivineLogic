; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.1

scriptName DivineActorModifier extends DivineSignaler
; Julianos - God of Wisdom and Logic; maps to actor-value rules and comparisons.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

string property valueName = "" auto
{ The name of the actor value to modify or compare. Default: "". }

float property value = 0.0 auto
{ The value to modify or compare against. Default: 0.0. }

string property comparisonOperator = "==" auto
{ The operator used for comparison in compare mode. Default: "==".
  Options:
  "=="  - Equal to value property.
  "!="  - Not equal to value property.
  ">"   - Greater than value property.
  ">="  - Greater than or equal to value property.
  "<"   - Less than value property.
  "<="  - Less than or equal to value property.
}

bool property forceActorValue = false auto
{ Forces the actor value modification (permanently changes the value). Default: False. }

bool property damageActorValue = false auto
{ Damages the actor value (affects current value instead of base value). Default: False. }

bool property modActorValue = false auto
{ Modifies the actor value cap. Default: False. }

bool property restoreActorValue = false auto
{ Restores the actor value to its base state. Default: False. }

bool property setActorValue = true auto
{ Sets the actor value directly. Default: True. }

bool property compareActorValue = false auto
{ Enables Compare mode, checking if the actor value matches the provided value.
  Activates linked reference only if the comparison is True. Default: False. }

bool property compareActorBaseValue = false auto
{ Enables Compare mode for base actor values. Activates linked reference if True. Default: False. }

bool property compareActorValuePercentage = false auto
{ Enables Compare mode for actor value percentage comparisons. Default: False. }

bool property toPlayer = false auto
{ Determines whether the action applies to the player. Default: False. }

bool property relayActivation = false auto
{ If enabled, activates the linked reference instead of modifying the actor value. Ignored in compare mode, where activation only occurs if the comparison is True. Default: False. }

; =========================
;         METHODS
; =========================

function handleModificationMode()
    if (!self.relayActivation)
        self.modifyActor(self.linkedRef as actor)
    else
        self.setRefActivated(self.linkedRef, self)
    endIf

    if (self.toPlayer)
        self.modifyActor(self.playerRef)
    endIf

    self.modifyKeywordActorsValue( \
        self.valueName,            \
        self.value,                \
        self.forceActorValue,      \
        self.damageActorValue,     \
        self.modActorValue,        \
        self.restoreActorValue,    \
        self.setActorValue         \
    )
endFunction

function modifyActor(actor actorRef)
    if (actorRef)
        self.modifyActorValue(    \
            actorRef,             \
            self.valueName,       \
            self.value,           \
            self.forceActorValue, \
            self.damageActorValue,\
            self.modActorValue,   \
            self.restoreActorValue,\
            self.setActorValue    \
        )
    endIf
endFunction

function handleComparisonMode()
    bool playerResult = true
    if (self.toPlayer)
        playerResult = self.compareActorValue( \
            self.playerRef,                    \
            self.valueName,                    \
            self.value,                        \
            self.comparisonOperator,           \
            self.compareActorBaseValue,        \
            self.compareActorValuePercentage   \
        )
    endIf 

    bool keywordsResult = self.compareKeywordActorsValue( \
        self.valueName,                                   \
        self.value,                                       \
        self.comparisonOperator,                          \
        self.compareActorBaseValue,                       \
        self.compareActorValuePercentage                  \
    )

    info(self + "@ function: onSignalling | playerResult: " + playerResult + " | keywordsResult: " + keywordsResult, \
        enabled=self.showDebug)

    if (playerResult && keywordsResult)
        self.setRefActivated(self.linkedRef, self)
    endIf 
endFunction

; =========================
;     LIFECYCLE HOOKS
; =========================

function onSignalling()
    parent.onSignalling()

    bool shouldCompare = self.compareActorValue || \
                         self.compareActorBaseValue || \
                         self.compareActorValuePercentage

    if (shouldCompare)
        self.handleComparisonMode()
    else
        self.handleModificationMode()
    endIf
endFunction
