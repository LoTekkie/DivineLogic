scriptName DivineMixer extends DivineSignaler
; Dibella – Goddess of Beauty and Love

import DivineUtils

sound property soundObject = none auto
{ Default: None - The base sound object to manipulate. }
bool property playSound = false auto
{ Default: False - Plays the sound from the soundObject property at this location unless playSoundFromPlayer is set to True. }
bool property playSoundAndWait = false auto
{ Default: False - Plays the sound and waits for it to finish from the soundObject property at this location unless playSoundFromPlayer is set to True. }
bool property playSoundFromPlayer = false auto
{ Default: False - Plays the soundObject property sound from the players location instead of at this markers location. }
soundCategory property soundCategoryObject = none auto
{ Default: None - The soundCategory to manipulate. }
bool property muteSoundCategory = false auto
{ Default: False - Should the soundCategoryObject be muted? }
bool property unMuteSoundCategory = false auto
{ Default: False - Should the soundCategoryObject be un-muted? }
bool property pauseSoundCategory = false auto
{ Default: False - Should the soundCategoryObject be paused? }
bool property unPauseSoundCategory = false auto
{ Default: False - Should the soundCategoryObject be unpaused? }
float property soundCagetoryFrequency = 1.0 auto
{ Default: 1.0 - The frequency modifier for any sounds in the soundCagetoryObject. (a value between 0.0 - 1.0) }
float property soundCategoryVolume = 1.0 auto
{ Default: 1.0 - Set the volume for any sounds in the soundCagetoryObject. (a value between 0.0 - 1.0) }
musicType property musicTypeObject = none auto
{ Default: None - The musicType to manipulate. }
bool property addMusicType = false auto
{ Default: False - Should the musicTypeObject be added to the queue? }
bool property removeMusicType = false auto
{ Default: False - Should the musicTypeObject be removed from the queue? }
bool property relayActivation = false auto
{ Default: False - Send an activation signal to the non-keyword linked reference. }
bool property activateKeywordRefs = false auto 
{ Default: False - Activate all keyword-linked object references. }

function onSignalling()
    parent.onSignalling()
    if (soundObject)
		objectReference source = self
		if (self.playSoundFromPlayer)
			source = self.playerRef
		endIf
		if (playSound)
			self.soundObject.play(source)
		elseIf (playSoundAndWait)
			self.soundObject.playAndWait(source)
		endIf	
    endIf

    if(soundCategoryObject)
		self.soundCategoryObject.setFrequency(self.soundCagetoryFrequency)
		self.soundCategoryObject.setVolume(self.soundCategoryVolume)
		if (self.muteSoundCategory)
			self.soundCategoryObject.mute()
		elseIf (self.unMuteSoundCategory)
			self.soundCategoryObject.unMute()
		endIf
		if (self.pauseSoundCategory)
			self.soundCategoryObject.pause()
		elseIf (self.unPauseSoundCategory)
			self.soundCategoryObject.unPause()
		endIf	
	endIf
    
    if(musicTypeObject)
		if (self.addMusicType)
			self.musicTypeObject.add()
		elseIf (self.removeMusicType)
			self.musicTypeObject.remove()	
		endIf	
    endIf	

	if (self.relayActivation)
		self.setRefActivated(self.linkedRef, self)
	endIf
	if (self.activateKeywordRefs)
	self.setKeywordRefsActivated()
	endIf	
endFunction

