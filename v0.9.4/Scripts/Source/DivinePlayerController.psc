scriptName DivinePlayerController extends DivineSignaler
; Morihaus (First Breath of Man) – ancient hero god of the Cyro-Nordics,
; associated with the Thu'um and Kynareth.

import DivineUtils

; =========================
;       PROPERTIES
; =========================

bool property forceFirstPersonCamera = false auto
{ Forces a first-person perspective on the player. }

bool property forceThirdPersonCamera = false auto
{ Forces a third-person perspective on the player. }

bool property disableAllPlayerControls = false auto
{ [Toggleable] Disables all player controls. }

bool property toggleControlSettings = false auto
{ Toggles control settings on each activation. }

bool property disablePlayerMovement = false auto
{ [Toggleable] Disables player movement controls. }

bool property disablePlayerFighting = false auto
{ [Toggleable] Disables player combat controls. }

bool property disablePlayerCamSwitching = false auto
{ [Toggleable] Disables player camera switching. }

bool property disablePlayerLooking = false auto
{ [Toggleable] Disables player look controls. }

bool property disablePlayerSneaking = false auto
{ [Toggleable] Disables player sneaking. }

bool property disablePlayerMenuControls = false auto
{ [Toggleable] Disables player menu controls. }

bool property disablePlayerActivation = false auto
{ [Toggleable] Disables player activation controls. }

bool property disablePlayerJournalTabs = false auto
{ [Toggleable] Disables player journal controls. }

int property disablePlayerPOVType = 0 auto
{ [Toggleable] Determines the POV disabling system (0 = Script, 1 = Werewolf). }

bool property disablePlayerFastTravel = false auto
{ [Toggleable] Disables fast travel. }

bool property stopPlayerCombat = false auto
{ Stops the player from engaging in combat. }

bool property transferPlayerControls = false auto
{ [Toggleable] Transfers player controls to the linked reference. }

bool property transferPlayerCamera = false auto
{ [Toggleable] Transfers the player's camera to the linked reference. }

bool property killPlayer = false auto
{ Kills the player, bypassing god mode. }

bool property hidePlayer = false auto
{ [Toggleable] Makes the player invisible and ghosted. }

bool property enableGodMode = false auto
{ [Toggleable] Enables god mode for the player. }

bool property relayActivation = false auto
{ Sends an activation signal to the linked reference instead of transferring control. }

bool property activateKeywordRefs = false auto
{ Activates all keyword-linked references. }

int property triggerScreenBloodAmount = 0 auto
{ Triggers on-screen blood splatter when greater than 0. }

bool property enableBeastForm = false auto
{ [Toggleable] Forces the player into beast form. }

bool property toggleSettingsReady = false auto hidden
{ Internal state for toggling control settings. }

; =========================
;      UTILITY FUNCTIONS
; =========================

; Sets actor visibility and ghost status
function setActorVisible(actor actorRef, bool visible=true)
    float alpha = 1.0
    if (!visible)
        alpha = 0.0
    endIf
    actorRef.setAlpha(alpha)
    actorRef.setGhost(!visible)
endFunction

; =========================
;    MAIN SIGNAL HANDLING
; =========================

function onSignalling()
    parent.onSignalling()

    if (self.triggerScreenBloodAmount > 0)
        game.triggerScreenBlood(self.triggerScreenBloodAmount)
    endIf

    if (!self.relayActivation)
        self.handlePlayerControlTransfer()
    else
        self.setRefActivated(self.linkedRef, self)
    endIf

    if (self.stopPlayerCombat)
        self.playerRef.stopCombat()
    endIf

    self.handlePlayerSettings()

    if (self.forceFirstPersonCamera)
        game.forceFirstPerson()
    elseIf (self.forceThirdPersonCamera)
        game.forceThirdPerson()
    endIf

    self.toggleSettingsReady = !self.toggleSettingsReady

    if (self.activateKeywordRefs)
        self.setKeywordRefsActivated()
    endIf

    if (self.killPlayer)
        debug.setGodMode(false)
        self.playerRef.kill(self.playerRef)
    endIf
endFunction

; =========================
;    PLAYER CONTROL HANDLING
; =========================

function handlePlayerControlTransfer()
    if (self.transferPlayerControls && self.playerRef.getPlayerControls())
        self.transferControlToLinkedRef()
    elseIf (!self.playerRef.getPlayerControls() && self.toggleControlSettings)
        self.revertPlayerControlSettings()
    elseIf (!self.transferPlayerControls)
        self.handleCameraTransfer()
    endIf
endFunction

; Transfers player control to the linked reference
function transferControlToLinkedRef()
    actor actorRef = self.linkedRef as actor
    if (!actorRef)
        return
    endIf

    self.setRefEnabled(actorRef, true)
    self.playerRef.stopCombat()
    self.playerRef.setPlayerControls(false)
    game.disablePlayerControls(false, false, false, false, true, true, true, true)
    self.setActorVisible(self.playerRef, false)
    ;diabled because this causes issues
    ;self.playerRef.setMotionType(Motion_Keyframed)
    ;utility.setIniBool("bDisablePlayerCollision:Havok", true)
    self.playerRef.MoveTo(self)
    
    actorRef.setPlayerControls(true)
    actorRef.enableAI(true)

    if (self.transferPlayerCamera)
        game.setCameraTarget(actorRef)
    endIf
endFunction

; Reverts player control settings to original state
function revertPlayerControlSettings()
    actor actorRef = self.linkedRef as actor
    if (!actorRef)
        return
    endIf

    actorRef.stopCombat()
    actorRef.setPlayerControls(false)
    self.setRefEnabled(actorRef, false)
    self.playerRef.MoveTo(actorRef)
    ;diabled because this causes issues
    ;self.playerRef.setMotionType(Motion_Dynamic)
    ;utility.setIniBool("bDisablePlayerCollision:Havok", false)
    self.animateRef(self.playerRef, "IdleForceDefaultState")
    self.playerRef.clearLookAt()
    self.setActorVisible(self.playerRef, true)

    if (self.transferPlayerCamera)
        game.setCameraTarget(self.playerRef)
    endIf

    game.enablePlayerControls()
    self.playerRef.setPlayerControls(true)
endFunction

; Handles camera transfer separately from control transfer
function handleCameraTransfer()
    actor actorRef = self.linkedRef as actor
    if (!actorRef || !self.transferPlayerCamera)
        return
    endIf

    if (!self.toggleSettingsReady)
        game.setCameraTarget(actorRef)
    else
        game.setCameraTarget(self.playerRef)
    endIf
endFunction

; =========================
;    PLAYER SETTINGS HANDLING
; =========================

function handlePlayerSettings()
    bool individualControlsDisabled = \
        self.disablePlayerMovement     || \
        self.disablePlayerFighting     || \
        self.disablePlayerCamSwitching || \
        self.disablePlayerLooking      || \
        self.disablePlayerSneaking     || \
        self.disablePlayerMenuControls || \
        self.disablePlayerActivation   || \
        self.disablePlayerJournalTabs  || \
        self.disablePlayerPOVType as bool

    if (!self.toggleSettingsReady)  ; Apply user settings
        if (self.disableAllPlayerControls)
            game.disablePlayerControls(true, true, true, true, true, true, true, true)
        elseIf (individualControlsDisabled)
            game.disablePlayerControls( \
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

        if (self.hidePlayer)
            self.setActorVisible(self.playerRef, false)
        endIf

        game.enableFastTravel(!self.disablePlayerFastTravel)
        game.setBeastForm(self.enableBeastForm)
        debug.setGodMode(self.enableGodMode)

    elseIf (self.toggleControlSettings) ; Revert settings
        game.enablePlayerControls()
        self.setActorVisible(self.playerRef, true)
        game.enableFastTravel(true)
        game.setBeastForm(false)
        debug.setGodMode(false)
    endIf
endFunction
