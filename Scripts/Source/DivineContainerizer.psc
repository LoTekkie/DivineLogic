; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.1

scriptName DivineContainerizer extends DivineSignaler
; Zenithar - God of Work and Commerce; maps to item transfer and resource flow.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

bool property transferFromContainer = false auto
{ Default: False - Transfers all items away from the non-keyword linked reference.
  By default, items are transferred to the non-keyword linked reference unless transferToPlayer is set to True. }

bool property transferToPlayer = false auto
{ Default: False - Transfers all items away from all linked containers and adds them to the player. }

bool property transferFromPlayer = false auto
{ Default: False - 
  - If transferFromContainer is True: Transfers all items from the player to keyword-linked object references.
  - If transferFromContainer is False: Transfers all items from the player to the non-keyword linked reference. }

bool property transferQuestItems = false auto
{ Default: False - Includes quest items when transferring from the player. }

bool property keepOwnership = false auto
{ Default: False - Should ownership of the containers remain? }

bool property randomizeDestinationContainer = false auto
{ Default: False - Randomizes which keyword-linked container receives the items.
(Used only if transferFromContainer is True and transferToPlayer is False.) }

bool property relayActivation = false auto
{ Default: False - Sends an activation signal to the non-keyword linked reference instead of a transfer signal. }

; =========================
;         METHODS
; =========================

function transferToContainers()
  if (self.transferToPlayer)
    ; Transfer all keyword-linked container items to the player
    if (self.linkedRef)
      self.linkedRef.removeAllItems(self.playerRef, self.keepOwnership, self.transferQuestItems)
    endIf
    self.transferKeywordRefsItemsTo(self.playerRef, self.keepOwnership, self.transferQuestItems)
  else
    ; Transfer all keyword-linked container items to the linkedRef
    self.transferKeywordRefsItemsTo(self.linkedRef, self.keepOwnership, self.transferQuestItems)
    if (self.transferFromPlayer && self.linkedRef)
      self.playerRef.removeAllItems(self.linkedRef, self.keepOwnership, self.transferQuestItems)
    endIf
  endIf
endFunction

function transferFromContainers()
  if (self.transferToPlayer)
    ; Transfer all keyword-linked container items to the player
    if (self.linkedRef)
      self.linkedRef.removeAllItems(self.playerRef, self.keepOwnership, self.transferQuestItems)
    endIf
    self.transferKeywordRefsItemsTo(self.playerRef, self.keepOwnership, self.transferQuestItems)
  else
    ; Transfer from linkedRef to keyword-linked references
    self.tranferItemsToKeywordRefsFrom(self.linkedRef, self.keepOwnership, self.transferQuestItems, self.randomizeDestinationContainer)
    
    if (self.transferFromPlayer)
      self.transferItemsFromPlayer()
    endIf
  endIf
endFunction

function transferItemsFromPlayer()
  self.tranferItemsToKeywordRefsFrom(self.playerRef, self.keepOwnership, self.transferQuestItems, self.randomizeDestinationContainer)
endFunction

; =========================
;     LIFECYCLE HOOKS
; =========================

function onSignalling()
  parent.onSignalling()
  
  if (self.relayActivation)
    ; Relay activation instead of transferring items
    self.setRefActivated(self.linkedRef, self)
    if (!self.transferToPlayer && self.transferFromPlayer)
      self.transferItemsFromPlayer()
    else
      self.transferKeywordRefsItemsTo(self.playerRef, self.keepOwnership, self.transferQuestItems)
    endIf
    return
  endIf

  if (self.transferFromContainer)
    self.transferFromContainers()
  else
    self.transferToContainers()
  endIf
endFunction
