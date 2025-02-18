scriptName DivineForcer extends DivineSignaler
; Kynareth - Goddess of Air, Wind, Sky and the Elements

import DivineUtils

bool property heartbeat = false auto hidden
{ Should we toggle between implode and explode? (True if both implode and explode are also True) }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a force signal. }
float property XforceVector = 0.0 auto
{ Default: 0.0 - X component of the force vector being applied. }
float property YforceVector = 0.0 auto
{ Default: 0.0 - Y component of the force vector being applied. }
float property ZforceVector = 0.0 auto
{ Default: 0.0 - Z component of the force vector being applied. }
float property forceMagnitude = 10.0 auto
{ Default: 10.0 - The magnitude of the force vector being applied. 
(How hard to hit the linked object refernces) }
bool property forcePlayer = false auto
{ Default: False - Should the force being applied effect the player? }
bool property explode = false auto
{ Default: False - Should all linked object references be pushed away from the signaler? }
bool property implode = false auto
{ Default: False - Should all linked object references be pulled toward the signaler? }

event onInit()
  parent.onInit()
  if (self.explode && self.implode)
    self.explode = false
    self.heartbeat = true
  endIf
endEvent

function onSignalling()
  if (self.heartbeat)
    self.explode = ! self.explode
    self.implode = ! self.implode
  endIf
  if (forcePlayer)
    self.impulseRef(       \
      self.playerRef,      \
      self.XforceVector,   \
      self.YforceVector,   \
      self.ZforceVector,   \
      self.forceMagnitude, \
      self.explode,        \
      self.implode         \
    )
  endIf
  self.impulseKeywordRefs( \
    self.XforceVector,     \
    self.YforceVector,     \
    self.ZforceVector,     \
    self.forceMagnitude,   \
    self.explode,          \
    self.implode           \
  )
  if ( ! self.relayActivation && self.linkedRef )
    self.impulseRef(       \
      self.linkedRef,      \
      self.XforceVector,   \
      self.YforceVector,   \
      self.ZforceVector,   \
      self.forceMagnitude, \
      self.explode,        \
      self.implode         \
    )
  else
    self.setRefActivated(self.linkedRef, self)
  endIf
endFunction