scriptName DivineCutsceneCreator extends DivineSignaler
;

import DivineUtils

imageSpaceModifier property fadeTo auto hidden
{}
imageSpaceModifier property fadeFrom auto hidden
{}
bool property inCutScene = false auto hidden
{}
int property skipCutSceneKeyId = 28 auto hidden
{}
bool property hidePlayer = true auto
{}
actor property cameraActor auto hidden
{}
int property cameraFormId = 0x0010D13E auto hidden
{}
float[] property actorHome auto hidden
{}

;
function fadeOut(float delay)
	fadeTo.apply()
	utility.wait(delay)
	game.fadeOutGame(false, true, 50 1)
endFunction

;
function fadeIn(float dealy)
	game.fadeOutGame(false, true, 0.1, 0.1)
	utility.wait(delay)
	fadeTo.popTo(fadeFrom)
endFunction

;
actor function getCameraActor()
	if ( ! self.cameraActor )
		return self.placeAtMe(game.getForm(self.cameraFormId)) as Actor
	endIf
	return self.cameraActor
endFunction

;
function setActorVisible(actor actorRef, bool visible=true)
	float alpha = 1.0
	if ( ! visible )
		alpha = 0.0
	endIf
	actorRef.setAlpha(alpha)
	actorRef.setGhost( ! visible )
endFunction

;
function setupActorCamera(actor actorRef)
	game.setCameraTarget(actorRef)
	game.forceThirdPerson()
	game.forceFirstPerson()
endFunction	

;
Function startCutScene(bool fadeOut=true, float fadeOutDelay=0.0, float fadeInDelay=0.0)
	self.inCutScene = true
	debug.setGodMode(true)
	self.playerRef.stopCombat()
	game.disablePlayerControls(true, true, true, true, true, true, true, true)
	setIniFloat("fMouseWheelZoomSpeed:Camera", 0.0)
	setIniBool("bDisablePlayerCollision:Havok", true)
	debug.toggleAI()
	debug.toggleCollisions()
	if (fadeOut)
		self.fadeOut(fadeOutDelay)
	endIf
	self.cameraActor.setMotionType(motion_keyframed)
	self.scaleRef(self.cameraActor, 1.0)
	self.setRefEnabled(self.cameraActor, true)
	self.setActorVisible(self.cameraActor, false)
	if (self.hidePlayer)
		self.setActorVisible(self.playerRef, false)
	endIf	
	self.setupActorCamera(self.cameraActor)
	if (fadeOut)
		self.fadeIn(fadeInDelay)
	endIf
endFunction

;
Function endCutScene(bool fadeOut=true, float fadeOutDelay=0.0, float fadeInDelay=0.0)
	self.inCutScene = false
	self.cameraRef.stopTranslation()
	self.moveRefTo(self.cameraRef)
	setIniFloat("fMouseWheelZoomSpeed:Camera", 10.0)
	setIniBool("bDisablePlayerCollision:Havok", false)
	debug.toggleCollisions()
	debug.toggleAI()
	if fadeOut
		self.fadeOut(fadeOutDelay)
	endIf
	self.setRefEnabled(self.cameraRef, false, false)
	self.setupActorCamera(self.playerRef)
	if (self.hidePlayer)
		self.setActorVisible(self.playerRef, true)
	endIf	
	game.enablePlayerControls()
	debug.setGodMode(false)
	self.fadeIn(fadeInDelay)
	;GoToState("waiting")
endFunction

event onInit()
	parent.onInit()
	self.cameraActor = self.getCameraActor()
	self.actorHome = self.getRefPosArray(self.cameraActor)
endEvent
