scriptName DivineMixer extends DivineSignaler
; Dibella – Goddess of Beauty and Love

import DivineUtils

; =========================
;        PROPERTIES
; =========================

sound property soundObject = none auto
{ Default: None - The base sound object to manipulate. }

bool property playSound = false auto
{ Default: False - Plays the sound from `soundObject` at this location unless `playSoundFromPlayer` is set to True. }

bool property playSoundAndWait = false auto
{ Default: False - Plays the sound and waits for it to finish from `soundObject` at this location unless `playSoundFromPlayer` is set to True. }

bool property playSoundFromPlayer = false auto
{ Default: False - Plays the `soundObject` sound from the player's location instead of this marker's location. }

soundCategory property soundCategoryObject = none auto
{ Default: None - The `soundCategory` to manipulate. }

bool property muteSoundCategory = false auto
{ Default: False - Should the `soundCategoryObject` be muted? }

bool property unMuteSoundCategory = false auto
{ Default: False - Should the `soundCategoryObject` be unmuted? }

bool property pauseSoundCategory = false auto
{ Default: False - Should the `soundCategoryObject` be paused? }

bool property unPauseSoundCategory = false auto
{ Default: False - Should the `soundCategoryObject` be unpaused? }

float property soundCategoryFrequency = 1.0 auto
{ Default: 1.0 - The frequency modifier for any sounds in `soundCategoryObject`. (a value between 0.0 - 1.0) }

float property soundCategoryVolume = 1.0 auto
{ Default: 1.0 - Set the volume for any sounds in `soundCategoryObject`. (a value between 0.0 - 1.0) }

musicType property musicTypeObject = none auto
{ Default: None - The `musicType` to manipulate. }

bool property addMusicType = false auto
{ Default: False - Should the `musicTypeObject` be added to the queue? }

bool property removeMusicType = false auto
{ Default: False - Should the `musicTypeObject` be removed from the queue? }

bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference. }

bool property activateKeywordRefs = false auto
{ Default: False - Activate all keyword-linked object references. }

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
    parent.onSignalling()

    ; =========================
    ;      SOUND HANDLING
    ; =========================
    if (self.soundObject)
        objectReference source = self
        if (self.playSoundFromPlayer)
            source = self.playerRef
        endIf

        if (self.playSound)
            self.soundObject.play(source)
        elseif (self.playSoundAndWait)
            self.soundObject.playAndWait(source)
        endIf
    endIf

    ; =========================
    ;  SOUND CATEGORY CONTROL
    ; =========================
    if (self.soundCategoryObject)
        self.soundCategoryObject.setFrequency(self.soundCategoryFrequency)
        self.soundCategoryObject.setVolume(self.soundCategoryVolume)

        if (self.muteSoundCategory)
            self.soundCategoryObject.mute()
        elseif (self.unMuteSoundCategory)
            self.soundCategoryObject.unMute()
        endIf

        if (self.pauseSoundCategory)
            self.soundCategoryObject.pause()
        elseif (self.unPauseSoundCategory)
            self.soundCategoryObject.unPause()
        endIf
    endIf

    ; =========================
    ;     MUSIC CONTROL
    ; =========================
    if (self.musicTypeObject)
        if (self.addMusicType)
            self.musicTypeObject.add()
        elseif (self.removeMusicType)
            self.musicTypeObject.remove()
        endIf
    endIf

    ; =========================
    ;  ACTIVATION HANDLING
    ; =========================
    if (self.relayActivation)
        self.setRefActivated(self.linkedRef, self)
    endIf

    if (self.activateKeywordRefs)
        self.setKeywordRefsActivated()
    endIf
endFunction
