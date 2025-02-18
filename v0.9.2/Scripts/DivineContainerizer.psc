scriptName DivineContainerizer extends DivineSignaler
; Zenithar - God of Work and Commerce, Trader God

import DivineUtils

bool property transferFromContainer = false auto
{ Default: False - Transfer all items away from the non keyword-linked reference instead. By default items will be transfered to the non keyword-linked reference unless transferToPlayer is set to True. }
bool property transferToPlayer = false auto
{ Default: False - Transfer all items away from all linked containers and add them to the player. }
bool property transferFromPlayer = false auto
{ Default: False - 
  If transferFromContainer is set to True: Transfer all items away from the player and add them to the keyword-linked object references. 
  If transferFromContainer is set to False: Transfer all items away from the player and add them to the non keyword-linked object reference. }
bool property transferQuestItems = false auto
{ Default: False - Include quest items when transferFromPlayer property is set to True. }
bool property keepOwnership = false auto
{ Default: False - Should ownership of the containers remain? }
bool property randomizeDestinationContainer = false auto
{ Default: False - Randomize which keyword-linked container the items will arrive in. 
( Only used if transferFromContainer is set to True and tranferToPlayer is set to False.) }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instad of a transfer signal. }

function onSignalling()
  parent.onSignalling()
  if ( ! self.relayActivation )
    if ( ! self.transferFromContainer ) ; to container
      if ( ! self.transferToPlayer )
        self.transferKeywordRefsItemsTo(self.linkedRef, self.keepOwnership, self.transferQuestItems)
        if (self.transferFromPlayer)
          self.playerRef.removeAllItems(self.linkedRef, self.keepOwnership, self.transferQuestItems)
        endIf
      else ; to player
        self.linkedRef.removeAllItems(self.playerRef, self.keepOwnership, self.transferQuestItems )
        self.transferKeywordRefsItemsTo(self.playerRef, self.keepOwnership, self.transferQuestItems)    
      endIf 
    else ; from container
      if ( ! self.transferToPlayer )
        self.tranferItemsToKeywordRefsFrom(  \
          self.linkedRef,                    \
          self.keepOwnership,                \
          self.transferQuestItems,           \
          self.randomizeDestinationContainer \
        )
        if (self.transferFromPlayer)
          self.tranferItemsToKeywordRefsFrom(  \
            self.playerRef,                    \
            self.keepOwnership,                \
            self.transferQuestItems,           \
            self.randomizeDestinationContainer \
          )
        endIf 
      else ; to player
        self.linkedRef.removeAllItems(self.playerRef, self.keepOwnership, self.transferQuestItems)
        self.transferKeywordRefsItemsTo(self.playerRef, self.keepOwnership, self.transferQuestItems)    
      endIf 
    endIf 
  else
    self.setRefActivated(self.linkedRef, self)
    if ( ! self.transferToPlayer )
      if (self.transferFromPlayer)
        self.tranferItemsToKeywordRefsFrom(  \
          self.playerRef,                    \
          self.keepOwnership,                \
          self.transferQuestItems,           \
          self.randomizeDestinationContainer \
        )
      endIf 
    else ; to player
      self.transferKeywordRefsItemsTo(self.playerRef, self.keepOwnership, self.transferQuestItems)    
    endIf 
  endIf
endFunction