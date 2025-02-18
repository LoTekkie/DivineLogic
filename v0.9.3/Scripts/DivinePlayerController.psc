scriptName DivinePlayerController extends DivineSignaler
; Morihaus (First Breath of Man) – ancient hero god of the Cyro-Nordics, associated with the Thu'um and Kynareth.

import DivineUtils

bool property forceFirstPersonCamera = false auto
{ Default: False - Force a first person camera perspective on the player. }
bool property forceThirdPersonCamera = false auto
{ Default: False - Force a thrid person camera perspective on the player. }
bool property disableAllPlayerControls = false auto
{ Default: False - [toggleable] : Disable all player controls. }
bool property toggleControlSettings = false auto
{ Default: False - Toggle control settings on each activation. (Cycles between applying initial settings and reverting them, only properties tagged [toggleable] will be affected) }
bool property disablePlayerMovement = false auto
{ Default: False - [toggleable] : Disable player movement controls. }
bool property disablePlayerFighting = false auto
{ Default: False - [toggleable] : Disable player fighting controls. }
bool property disablePlayerCamSwitching = false auto
{ Default: False - [toggleable] : Disable player camera switching. }
bool property disablePlayerLooking = false auto
{ Default: False - [toggleable] : Disable player looking controls. }
bool property disablePlayerSneaking = false auto
{ Default: False - [toggleable] : Disable player sneaking controls. }
bool property disablePlayerMenuControls = false auto
{ Default: False - [toggleable] : Disable player menu controls. }
bool property disablePlayerActivation = false auto
{ Default: False - [toggleable] : Disable player activation controls. }
bool property disablePlayerJournalTabs = false auto
{ Default: False - [toggleable] : Disable player journal controls. }
int property disablePlayerPOVType = 0 auto
{ Default: 0 - [toggleable] : What system is disabling POV.
  One of:
  0 - Script (Default)
  1 - Warewolf  
}
bool property disablePlayerFastTravel = false auto
{ Default: False - [toggleable] : Disable the players ability to fast travel. }
bool property stopPlayerCombat = false auto
{ Default: False - Stop the player from engaging in combat. }
bool property transferPlayerControls = false auto
{ Default: False - [toggleable] : Transfer player controls to the default linked object reference. 
  (Player will be hidden from view upon transfer and relocated to this trigger box until controls are handed back to the player through this script.
  To return control back to the player ensure toggleControlSettings is also set to True and this trigger sends a signal a second time.)
}
bool property transferPlayerCamera = false auto
{ Default: False - [toggleable] : Transfer the players camera to the non-keyword linked object reference. }
bool property killPlayer = false auto
{ Default: False - Should the player be killed? (Forces a player kill even if god mode is enabled) }
bool property hidePlayer = false auto
{ Default: False - [toggleable] : Set player invisible and ghosted. }
bool property enableGodMode = false auto
{ Default: False - [toggleable] : Make the player invincible. }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference instead of a transfer controls signal. }
bool property activateKeywordRefs = false auto
{ Default: False - Should all keyword-linked object references be activated? }
int property triggerScreenBloodAmount = 0 auto
{ Default: 0 - Trigger on-screen blood splatter with any value greater than 0. Value is the number of droplets to put on the screen. }
bool property setBeastForm = false auto
{ Default: False - [toggleable] : Shoud the player enter beast form? }
bool property toggleSettingsReady = false auto hidden

function setActorVisible(actor actorRef, bool visible=true)
  float alpha = 1.0
  if ( ! visible )
    alpha = 0.0
  endIf
  actorRef.setAlpha(alpha)
  actorRef.setGhost( ! visible )
endFunction

function onSignalling()
  parent.onSignalling()
  if (self.triggerScreenBloodAmount > 0)
    game.triggerScreenBlood(self.triggerScreenBloodAmount)
  endIf  
  if ( ! self.relayActivation )
    if (self.transferPlayerControls && self.playerRef.getPlayerControls())
      actor actorRef = self.linkedRef as actor
      if (actorRef)
        self.setRefEnabled(actorRef, true)
        self.playerRef.stopCombat()
        self.playerRef.setPlayerControls(false)
        game.disablePlayerControls(false, false, false, false, true, true, true, true)
        self.setActorVisible(self.playerRef, false)
        self.playerRef.setMotionType(Motion_Keyframed)
        utility.setIniBool("bDisablePlayerCollision:Havok", true)
        self.playerRef.MoveTo(self)
        actorRef.setPlayerControls(true)
        actorRef.enableAI(true)
        if (self.transferPlayerCamera)
          game.setCameraTarget(actorRef)
        endIf 
      endIf
    elseIf( ! self.playerRef.getPlayerControls() && self.toggleControlSettings ) ; revert user settings
      actor actorRef = self.linkedRef as actor
      if (actorRef)
        actorRef.stopCombat()
        actorRef.setPlayerControls(false)
        self.playerRef.MoveTo(actorRef)
        self.playerRef.setMotionType(Motion_Dynamic)
        utility.setIniBool("bDisablePlayerCollision:Havok", false)
        self.setActorVisible(self.playerRef, true)
        self.animateRef(self.playerRef, "IdleForceDefaultState")
        self.playerRef.clearLookAt()
        if (self.transferPlayerCamera)
          game.setCameraTarget(self.playerRef)
        endIf 
        game.enablePlayerControls()
        self.playerRef.setPlayerControls(true)
      endIf
    elseIf ( ! self.transferPlayerControls )
        actor actorRef = self.linkedRef as actor
        if (actorRef && self.transferPlayerCamera)
          if ( ! self.toggleSettingsReady )
            game.setCameraTarget(actorRef)
          else
            game.setCameraTarget(self.playerRef)
          endIf     
        endIf 
    endIf 
  else
    self.setRefActivated(self.linkedRef, self)
  endIf
  if (self.stopPlayerCombat)
    self.playerRef.stopCombat()
  endIf
  bool individualControlsDisabled = self.disablePlayerMovement     || \
                                    self.disablePlayerFighting     || \
                                    self.disablePlayerCamSwitching || \
                                    self.disablePlayerLooking      || \
                                    self.disablePlayerSneaking     || \
                                    self.disablePlayerMenuControls || \
                                    self.disablePlayerActivation   || \
                                    self.disablePlayerJournalTabs  || \
                                    self.disablePlayerPOVType as bool
  if ( ! self.toggleSettingsReady ) ; apply user settings
    if (self.disableAllPlayerControls)
      game.disablePlayerControls(true, true, true, true, true, true, true, true)
    else
      if (individualControlsDisabled)
        game.disablePlayerControls(       \
          self.disablePlayerMovement,     \
          self.disablePlayerFighting,     \
          self.disablePlayerCamSwitching, \
          self.disablePlayerLooking,      \
          self.disablePlayerSneaking,     \
          self.disablePlayerMenuControls, \
          self.disablePlayerActivation,   \
          self.disablePlayerJournalTabs,  \
          self.disablePlayerPOVType       \
        )
      else
        game.enablePlayerControls()
      endIf   
    endIf
    if (self.hidePlayer)
      self.setActorVisible(self.playerRef, false)
    endIf
    if (self.disablePlayerFastTravel)
      game.enableFastTravel(false)
    endIf
    if (self.setBeastForm)
      game.setBeastForm(true)
    endIf  
    debug.setGodMode(self.enableGodMode)
  elseIf (self.toggleControlSettings) ; revert user settings
    if (individualControlsDisabled || self.disableAllPlayerControls)
      game.enablePlayerControls()
    endIf
    if (self.hidePlayer)
      self.setActorVisible(self.playerRef, true)
    endIf
    if (self.disablePlayerFastTravel)
      game.enableFastTravel(true)
    endIf
    if (self.setBeastForm)
      game.setBeastForm(false)
    endIf  
    if (self.enableGodMode)
      debug.setGodMode(false)
    endIf 
  endIf
  ; non toggled adjustments
  if (self.forceFirstPersonCamera)
    game.forceFirstPerson()
  elseIf (self.forceThirdPersonCamera)
    game.forceThirdPerson()
  endIf
  self.toggleSettingsReady = ! self.toggleSettingsReady
  if (self.activateKeywordRefs)
    self.setKeywordRefsActivated()
  endIf
  if (self.killPlayer)
    debug.setGodMode(false)
    self.playerRef.kill(self.playerRef)
  endIf 
endFunction