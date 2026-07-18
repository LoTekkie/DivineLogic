# Divine Logic

Divine Logic is a Skyrim Creation Kit framework for adding gameplay logic with pre-scripted, modular trigger boxes.

It is made for mod authors who want to build puzzle-heavy dungeons, moving objects, cutscenes, traps, item transfers, staged events, and other interactive systems without writing a new Papyrus script for every mechanic.

If you understand how to drag, drop, configure, and connect objects in the Creation Kit, you can use Divine Logic. You place boxes, set their properties, and wire them together. That keeps your logic visible, fast to iterate on, and easier to debug while building.

Divine Logic was created because Papyrus is a major barrier for many would-be creators. The goal is not to replace scripting for every possible mod idea, but to give authors a practical alternative for common dungeon and puzzle logic so more ideas can be built directly in the editor.

Under the hood, Divine Logic uses Skyrim's normal `Activate()` path as its signal bus. That keeps logic visible in the editor and lets boxes trigger other boxes the same way activators, doors, markers, and scripted references already interact.

The name comes from the idea that the gods lend a little of their power to your creations. Each script is associated with a deity whose sphere fits the box's role: Zenithar guides work and exchange, Akatosh shapes time and movement, Julianos governs logic and knowledge. For example, `DivineTranslator` belongs to Zenithar because it performs work by moving objects from one place to another. The theme is flavor, not a gameplay requirement, but it gives each tool a memorable identity.

## Index

- [Requirements](#requirements)
- [Release Format](#release-format)
- [Quick Start](#quick-start)
- [How Signals Work](#how-signals-work)
- [Activation vs Signal](#activation-vs-signal)
- [Linked References](#linked-references)
- [Base Signaler Properties](#base-signaler-properties)
- [Quest State](#quest-state)
- [Marker Defaults And Overrides](#marker-defaults-and-overrides)
- [Logic Box Reference](#logic-box-reference)
- [Box Properties](#box-properties): [Activator](#activator), [Actor Modifier](#actor-modifier), [Animator](#animator), [Comparer](#comparer), [Containerizer](#containerizer), [Cutscene Creator](#cutscene-creator), [Destroyer](#destroyer), [Enabler](#enabler), [Forcer](#forcer), [Global Modifier](#global-modifier), [Marker](#marker), [Messenger](#messenger), [Mixer](#mixer), [Player Controller](#player-controller), [Scaler](#scaler), [Spawner](#spawner), [Translator](#translator), [Warper](#warper)
- [Marker Reference](#marker-reference): [Cutscene Marker Properties](#cutscene-marker-properties), [Spawner Marker Properties](#spawner-marker-properties), [Translator Marker Properties](#translator-marker-properties), [Warper Marker Properties](#warper-marker-properties)
- [Divine Logic API](#divine-logic-api): [Getting The API](#getting-the-api), [Live Signaler Queries](#live-signaler-queries), [Query Examples](#query-examples), [Signal Events](#signal-events), [API Settings](#api-settings)
- [Common Examples](#common-examples)
- [Divine Laboratory](#divine-laboratory)
- [Performance And Release Guidance](#performance-and-release-guidance)
- [Compatibility Notes](#compatibility-notes)
- [Community And Support](#community-and-support)
- [License](#license)
- [Credits](#credits)

## Requirements

- Skyrim Special Edition / Anniversary Edition runtime supported by this release.
- SKSE matching the player's Skyrim runtime.
- Launch the game through the SKSE loader.
- Creation Kit if you are building a mod that depends on Divine Logic.

SKSE is required. Divine Logic uses SKSE-backed Papyrus behavior for runtime names, events, and integration support.

## Release Format

Divine Logic ships as a master plugin and compiled scripts.

- `DivineLogic_v1.1.esm` is the framework master.
- `Scripts/*.pex` files provide runtime behavior.
- `Scripts/Source/*.psc` files are included for reference and documentation.

Do not edit `DivineLogic_v1.1.esm` directly. Create your own plugin, make Divine Logic a master, and build your content there.

## Quick Start

1. Install Divine Logic and SKSE.
2. Open the Creation Kit.
3. Load `DivineLogic_v1.1.esm`.
4. Create or load your own plugin and make it active.
5. Place one or more Divine Logic boxes in your cell.
6. Configure each box through script properties.
7. Connect boxes and targets with normal linked refs or `DivineRef01` through `DivineRef09` keyword-linked refs.
8. Save your plugin.
9. Test in game through SKSE.

The simplest chain is a `DivineActivator` linked to another object. Activate the box in game, and the linked object receives an activation signal. From there, chains can branch into comparers, translators, markers, player controllers, messages, item transfers, and other boxes.

## How Signals Work

Most public boxes inherit from `DivineSignaler`. A signaler can run when:

- the player activates it;
- another Divine Logic box activates it;
- the player or an NPC enters its trigger volume;
- it is hit;
- it loads with `signalOnStart`;
- it repeats with `signalContinuously`.

When a box receives a valid signal, it enters a busy state, performs its work, and then returns to waiting. While busy, the same box does not restart its signal cycle. Player-started activations temporarily block native activation while the box is busy; downstream Divine-to-Divine activation relies on the state machine.

## Activation vs Signal

An activation is the input event. It is Skyrim telling an object that something activated it. That activation can come from the player, another game object, or another Divine Logic box.

A signal is the Divine Logic action that happens after an activation passes the box's checks. A box can receive activations without always producing a signal.

Examples:

- `signalEvery = 3`: the first two valid activations count upward; the third valid activation produces one signal.
- `signalOnce = True`: the first valid signal runs; later activations are ignored.
- `signalLimit = 2`: the box can signal twice; later activations do nothing.
- `preventDefaultSignal = True`: the box can receive activation but skip its normal action.

Use activation to describe the incoming trigger. Use signal to describe the Divine Logic event or action that actually fires.

## Linked References

Divine Logic uses two link types.

| Link type | How to set it | Meaning |
| --- | --- | --- |
| Normal linked ref | Standard linked reference field | Primary target, destination, or next box. |
| Keyword linked refs | Linked refs using `DivineRef01` through `DivineRef09` | Up to nine secondary targets. |

Common patterns:

- Use the normal linked ref for the next box, a primary target, or the first marker in a chain.
- Use keyword refs for groups of objects being moved, enabled, compared, deleted, scaled, spawned, or modified.
- Marker chains use normal linked refs from one marker to the next marker.
- A final marker can link back to the starting box when the box itself should act as the final sequence point.

## Base Signaler Properties

Most boxes inherit these properties.

| Property | Default | Description |
| --- | --- | --- |
| `signalOnStart` | `False` | Signal when the object loads. |
| `signalOnce` | `False` | Allow only one successful signal. |
| `signalLimit` | `0` | Maximum successful signals. `0` means unlimited. |
| `signalEvery` | `1` | Require this many valid activations before one signal fires. Resets after firing. |
| `signalContinuously` | `False` | Repeat signaling on `signalDelay`. |
| `detectHit` | `False` | Signal when hit. |
| `detectHitSource` | `""` | Optional source or projectile name required for hit detection. |
| `detectPlayer` | `False` | Signal when the player enters the trigger. |
| `detectNPC` | `False` | Signal when an NPC enters the trigger. |
| `detectEquippedItemType` | `-1` | Require the player to have an equipped item type. `-1` disables the check. |
| `sendTogglePauseSignal` | `False` | Toggle pause on attached Divine signalers. |
| `preventDefaultSignal` | `False` | Allow pause behavior but skip the box's normal action. |
| `signalDelay` | `0.0` | Wait before signaling. |
| `postSignalDelay` | `2.0` | Wait after signaling before returning to waiting. |
| `signalerID` | `""` | Optional public ID used by API signal events. |
| `showDebug` | `False` | Write debug traces. Keep disabled in release content. |

Equipped item type values:

| Value | Meaning |
| --- | --- |
| `-1` | Do not check equipped item type. |
| `0` | Nothing / hand to hand. |
| `1` | One-handed sword. |
| `2` | One-handed dagger. |
| `3` | One-handed axe. |
| `4` | One-handed mace. |
| `5` | Two-handed sword. |
| `6` | Two-handed axe or mace. |
| `7` | Bow. |
| `8` | Staff. |
| `9` | Magic spell. |
| `10` | Shield. |
| `11` | Torch. |
| `12` | Crossbow. |

## Quest State

Use `DivineGlobalModifier` for quest state.

Skyrim quest script variables are not a good public target for Divine Logic. Papyrus and core SKSE do not expose a clean `GetQuestVariableByName()` or `SetQuestVariableByName()` API that a trigger box can call by string. Creation Kit conditions can check some quest variables, but that is not the same as a Papyrus function that Divine Logic can use.

For Creation Kit-friendly quest state, create named `GlobalVariable` forms and prefix them clearly:

```text
DL_Q001_PuzzleCount
DL_Q001_DoorUnlocked
DL_Q001_CurrentPhase
DL_Q001_TrialComplete
```

Then use `DivineGlobalModifier` to set, increment, or compare those globals. This keeps state visible in the Creation Kit, usable in conditions, and easy to connect to Divine Logic boxes.

If Divine Logic later adds a quest-specific box, it should control actual quest operations such as start, stop, set stage, complete quest, or objective state. It should not hide quest variables behind another storage script.

## Marker Defaults And Overrides

Translators, warpers, spawners, and cutscene creators can use marker chains.

The main box has `m_` marker defaults. Each marker has matching properties. A marker value overrides the box default when it differs from the marker's default sentinel value.

Important defaults:

- most numeric marker values default to `0.0`;
- movement speed defaults to `100.0`;
- most booleans default to `False`.

Because defaults also act as sentinels, a marker cannot always distinguish "explicitly use `0.0`" from "use the box default." Use box defaults for global behavior and marker values for non-default per-marker changes.

## Logic Box Reference

| Box | Script | Divine Theme | Purpose |
| --- | --- | --- | --- |
| Activator | `DivineActivator.psc` | Stendarr - mercy, justice, righteous action | Activates the normal linked ref and all, one random, or one sequential keyword-linked ref. |
| Actor Modifier | `DivineActorModifier.psc` | Julianos - wisdom, knowledge, ordered rules | Modifies or compares actor values on linked actors and optionally the player. |
| Animator | `DivineAnimator.psc` | Lorkhan - change, embodiment, mortal motion | Plays animation events, sets animation variables, or controls actor look-at behavior. |
| Comparer | `DivineComparer.psc` | Julianos - logic, comparison, judgment | Compares keyword-linked Divine refs and activates the linked ref when true. |
| Containerizer | `DivineContainerizer.psc` | Zenithar - work, trade, exchange | Transfers inventory between the player, linked container, and keyword-linked containers. |
| Cutscene Creator | `DivineCutsceneCreator.psc` | Talos - heroic action, command, spectacle | Runs camera-driven cutscenes with optional marker chains. |
| Destroyer | `DivineDestroyer.psc` | Arkay - endings, death, release | Deletes linked and keyword-linked references. |
| Enabler | `DivineEnabler.psc` | Arkay - cycles, passage, return | Toggles linked and keyword-linked references enabled or disabled. |
| Forcer | `DivineForcer.psc` | Kynareth - wind, motion, natural force | Applies Havok impulses to linked refs, keyword refs, and optionally the player. |
| Global Modifier | `DivineGlobalModifier.psc` | Julianos - numbers, rules, recorded state | Sets, modifies, or compares a global variable. |
| Marker | `DivineMarker.psc` | Akatosh - time, sequence, destination | Activates or enable-toggles keyword-linked refs. |
| Messenger | `DivineMessenger.psc` | Reman - proclamation, command, public voice | Shows messages, notifications, help messages, or trace output. |
| Mixer | `DivineMixer.psc` | Dibella - art, sound, atmosphere | Plays sounds, adjusts sound categories, or adds/removes music types. |
| Player Controller | `DivinePlayerController.psc` | Morihaus - strength, control, battle-presence | Controls player camera, controls, fast travel, visibility, god mode, combat, and handoff behavior. |
| Scaler | `DivineScaler.psc` | Dibella - form, beauty, proportion | Scales linked and keyword-linked refs. |
| Spawner | `DivineSpawner.psc` | Mara - creation, care, bringing forth | Spawns copies of keyword-linked refs at the box, player, or marker chain. |
| Translator | `DivineTranslator.psc` | Zenithar - labor, movement, purposeful work | Smoothly moves keyword-linked refs to the box, player, or marker chain. |
| Warper | `DivineWarper.psc` | Akatosh - time, space, sudden passage | Instantly moves keyword-linked refs and optionally the player. |

The theme column is documentation only. It is a quick Elder Scrolls deity association for each script's role.

## Box Properties

Only box-specific public properties are listed here. Most boxes also inherit the base signaler properties above.

### Activator

Script: `DivineActivator.psc`

| Property | Default | Description |
| --- | --- | --- |
| `randomlyActivateKeywordRefs` | `False` | Activate one random keyword-linked ref instead of all keyword-linked refs. |
| `sequentiallyActivateKeywordRefs` | `False` | Activate one keyword-linked ref per signal, advancing through the list. Ignored when random mode is enabled. |

The normal linked ref always receives activation first. If both keyword-ref modes are disabled, all keyword-linked refs are activated.

### Actor Modifier

Script: `DivineActorModifier.psc`

| Property | Default | Description |
| --- | --- | --- |
| `valueName` | `""` | Actor value name to modify or compare. |
| `value` | `0.0` | Value to apply or compare against. |
| `comparisonOperator` | `"=="` | Comparison operator: `==`, `!=`, `>`, `>=`, `<`, `<=`. |
| `forceActorValue` | `False` | Force the actor value. |
| `damageActorValue` | `False` | Damage the actor value. |
| `modActorValue` | `False` | Modify the actor value. |
| `restoreActorValue` | `False` | Restore the actor value. |
| `setActorValue` | `True` | Set the actor value directly. |
| `compareActorValue` | `False` | Compare current actor value instead of modifying. |
| `compareActorBaseValue` | `False` | Compare base actor value. |
| `compareActorValuePercentage` | `False` | Compare actor value percentage. |
| `toPlayer` | `False` | Include the player as a target. |
| `relayActivation` | `False` | Activate the linked ref instead of modifying. Ignored in compare mode. |

Targets: normal linked actor, keyword-linked actors, and optionally the player.

### Animator

Script: `DivineAnimator.psc`

| Property | Default | Description |
| --- | --- | --- |
| `animationEvent` | `""` | Animation event name, or animation variable name when variable mode is enabled. |
| `animationVariableValue` | `""` | Value sent to the animation graph in variable mode. |
| `toPlayer` | `False` | Apply to the player. |
| `sendEventAsFloatVariable` | `False` | Treat `animationEvent` as a float animation variable. |
| `sendEventAsBoolVariable` | `False` | Treat `animationEvent` as a bool animation variable. |
| `sendEventAsIntVariable` | `False` | Treat `animationEvent` as an int animation variable. |
| `subGraphAnimation` | `False` | Use subgraph animation behavior. |
| `gameBryoAnimation` | `False` | Use legacy GameBryo animation. |
| `gameBryoStartOver` | `False` | Restart GameBryo animation from the beginning. |
| `gameBryoEaseInTime` | `0.0` | Ease-in time for GameBryo animation. |
| `lookAtPlayer` | `False` | Actor refs look at the player. |
| `lookAtPlayerWhilePathing` | `False` | Actor refs keep looking at the player while pathing. |
| `clearLookAt` | `False` | Clear actor look-at targets. Overrides look-at options. |
| `relayActivation` | `False` | Activate the linked ref instead of animating. |

Targets: normal linked ref, keyword-linked refs, and optionally the player.

### Comparer

Script: `DivineComparer.psc`

| Property | Default | Description |
| --- | --- | --- |
| `andCompare` | `False` | True only when all keyword-linked Divine refs are signaled. |
| `notCompare` | `False` | True only when no keyword-linked Divine refs are signaled. |
| `orCompare` | `False` | True when any keyword-linked Divine ref is signaled. |
| `xorCompare` | `False` | True when keyword-linked Divine refs contain both true and false signal states. |

Result: activates the normal linked ref when the comparison passes.

### Containerizer

Script: `DivineContainerizer.psc`

| Property | Default | Description |
| --- | --- | --- |
| `transferFromContainer` | `False` | Transfer items away from the normal linked container. |
| `transferToPlayer` | `False` | Transfer items to the player. |
| `transferFromPlayer` | `False` | Transfer items away from the player. |
| `transferQuestItems` | `False` | Include quest items when transferring from the player. |
| `keepOwnership` | `False` | Preserve container ownership. |
| `randomizeDestinationContainer` | `False` | Randomize which keyword-linked container receives transferred items. |
| `relayActivation` | `False` | Activate the linked ref instead of transferring items. |

Targets: player, normal linked container, and keyword-linked containers.

### Cutscene Creator

Script: `DivineCutsceneCreator.psc`

| Property | Default | Description |
| --- | --- | --- |
| `relayActivation` | `False` | Activate the linked ref after the cutscene action. |
| `hidePlayer` | `True` | Hide and ghost the player during the cutscene. |
| `fadeOutDelay` | `0.0` | Wait before fade out. |
| `fadeInDelay` | `0.0` | Wait before fade in. |
| `cutsceneEndDelay` | `0.0` | Wait before ending after the final marker. |
| `cutsceneEndPause` | `False` | Pause this box after the cutscene ends. |
| `allowSkip` | `True` | Allow the player to hold Enter to skip. |

Marker-default properties:

| Property | Default | Description |
| --- | --- | --- |
| `m_delay` | `0.0` | Wait after the camera arrives. |
| `m_speed` | `100.0` | Camera translation speed. |
| `m_rotationSpeedClamp` | `0.0` | Rotation speed clamp. |
| `m_rotateOnArrival` | `False` | Delay rotation until arrival. |
| `m_tangentMagnitude` | `0.0` | Spline tangent magnitude. |
| `m_offsetX/Y/Z` | `0.0` | Position offsets. |
| `m_offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `m_limitX/Y/Z` | `False` | Prevent movement on position axes. |
| `m_limitAX/AY/AZ` | `False` | Prevent rotation on angle axes. |
| `m_matchRotation` | `False` | Match marker rotation. |
| `m_toPlayer` | `False` | Move camera to player instead of marker. |
| `m_shakeCamera` | `False` | Shake camera on arrival. |
| `m_cameraShakeStrength` | `0.5` | Camera shake strength. |
| `m_cameraShakeDuration` | `0.0` | Camera shake duration. |

Use `DivineCutsceneCreatorMarker` objects for multi-point camera paths.

### Destroyer

Script: `DivineDestroyer.psc`

| Property | Default | Description |
| --- | --- | --- |
| `whenAble` | `False` | Use delayed deletion behavior. |
| `relayActivation` | `False` | Activate the linked ref instead of deleting it. |

Targets: normal linked ref and keyword-linked refs.

### Enabler

Script: `DivineEnabler.psc`

| Property | Default | Description |
| --- | --- | --- |
| `waitForAnimation` | `True` | Use fade animation when enabling or disabling. |
| `relayActivation` | `False` | Activate the linked ref instead of toggling enabled state. |

Targets: normal linked ref and keyword-linked refs.

### Forcer

Script: `DivineForcer.psc`

| Property | Default | Description |
| --- | --- | --- |
| `relayActivation` | `False` | Activate the linked ref instead of applying force. |
| `XforceVector` | `0.0` | X component of force. |
| `YforceVector` | `0.0` | Y component of force. |
| `ZforceVector` | `0.0` | Z component of force. |
| `forceMagnitude` | `10.0` | Force strength. |
| `forcePlayer` | `False` | Also apply force to the player. |
| `explode` | `False` | Push targets away from this box. |
| `implode` | `False` | Pull targets toward this box. |

If both `explode` and `implode` are enabled, the box alternates between them.

### Global Modifier

Script: `DivineGlobalModifier.psc`

| Property | Default | Description |
| --- | --- | --- |
| `variable` | `None` | Global variable to modify or compare. |
| `value` | `0.0` | Value to set, modify by, or compare against. |
| `asInt` | `False` | Treat values as ints. |
| `compareVariable` | `False` | Compare instead of modifying. |
| `modValue` | `False` | Modify the global instead of setting it. |
| `comparisonOperator` | `"=="` | Comparison operator: `==`, `!=`, `>`, `>=`, `<`, `<=`. |
| `relayActivation` | `False` | Activate the linked ref instead of modifying. |
| `activateKeywordRefs` | `False` | Activate keyword-linked refs after modification or successful comparison. |

Use this box for quest-scoped globals as described in [Quest State](#quest-state).

### Marker

Script: `DivineMarker.psc`

| Property | Default | Description |
| --- | --- | --- |
| `activateKeywordRefs` | `True` | Activate keyword-linked refs. |
| `enableToggleKeywordRefs` | `False` | Toggle keyword-linked refs enabled or disabled. |

### Messenger

Script: `DivineMessenger.psc`

| Property | Default | Description |
| --- | --- | --- |
| `messageText` | `""` | Text used when `messageObject` is not set. |
| `messageObject` | `None` | Skyrim Message form. Overrides `messageText`. |
| `messageObjectArg1` through `messageObjectArg9` | `0.0` | Numeric replacement arguments for Message text. |
| `asMessageBox` | `False` | Show `messageText` in a message box. |
| `asNotification` | `False` | Show `messageText` as a notification. |
| `asTrace` | `False` | Send `messageText` to Papyrus logs. |
| `asTraceAndBox` | `False` | Trace and show a message box. |
| `traceSeverity` | `0` | Trace severity: `0` info, `1` warning, `2` error. |
| `asHelpMessage` | `False` | Treat `messageObject` as a help message. |
| `helpMessageEvent` | `""` | Help message event name. |
| `helpMessageDuration` | `0.0` | Help message duration. `0.0` means no time limit. |
| `helpMessageInterval` | `0.0` | Time between help message showings. |
| `helpMessageMaxTimes` | `0` | Maximum times to show. `0` means unlimited. |
| `resetHelpMessage` | `False` | Reset help message state for the event. |

### Mixer

Script: `DivineMixer.psc`

| Property | Default | Description |
| --- | --- | --- |
| `soundObject` | `None` | Sound to play. |
| `playSound` | `False` | Play sound at this box or the player. |
| `playSoundAndWait` | `False` | Play sound and wait for completion. |
| `playSoundFromPlayer` | `False` | Use the player as the sound source. |
| `soundCategoryObject` | `None` | Sound category to adjust. |
| `muteSoundCategory` | `False` | Mute the sound category. |
| `unMuteSoundCategory` | `False` | Unmute the sound category. |
| `pauseSoundCategory` | `False` | Pause the sound category. |
| `unPauseSoundCategory` | `False` | Unpause the sound category. |
| `soundCategoryFrequency` | `1.0` | Sound category frequency. |
| `soundCategoryVolume` | `1.0` | Sound category volume. |
| `musicTypeObject` | `None` | Music type to add or remove. |
| `addMusicType` | `False` | Add the music type. |
| `removeMusicType` | `False` | Remove the music type. |
| `relayActivation` | `False` | Activate normal linked ref. |
| `activateKeywordRefs` | `False` | Activate keyword-linked refs. |

### Player Controller

Script: `DivinePlayerController.psc`

| Property | Default | Description |
| --- | --- | --- |
| `forceFirstPersonCamera` | `False` | Force first-person camera. |
| `forceThirdPersonCamera` | `False` | Force third-person camera. |
| `disableAllPlayerControls` | `False` | Disable all player controls. |
| `toggleControlSettings` | `False` | Toggle configured control settings on each activation. |
| `disablePlayerMovement` | `False` | Disable movement. |
| `disablePlayerFighting` | `False` | Disable fighting. |
| `disablePlayerCamSwitching` | `False` | Disable camera switching. |
| `disablePlayerLooking` | `False` | Disable looking. |
| `disablePlayerSneaking` | `False` | Disable sneaking. |
| `disablePlayerMenuControls` | `False` | Disable menu controls. |
| `disablePlayerActivation` | `False` | Disable activation controls. |
| `disablePlayerJournalTabs` | `False` | Disable journal tabs. |
| `disablePlayerPOVType` | `0` | POV disable mode: `0` script, `1` werewolf. |
| `disablePlayerFastTravel` | `False` | Disable fast travel. |
| `stopPlayerCombat` | `False` | Stop player combat. |
| `transferPlayerControls` | `False` | Transfer controls to the linked actor. |
| `transferPlayerCamera` | `False` | Transfer camera to the linked actor. |
| `killPlayer` | `False` | Kill the player, bypassing god mode. |
| `hidePlayer` | `False` | Hide and ghost the player. |
| `enableGodMode` | `False` | Enable god mode. |
| `relayActivation` | `False` | Activate linked ref instead of player-control behavior. |
| `activateKeywordRefs` | `False` | Activate keyword-linked refs. |
| `triggerScreenBloodAmount` | `0` | Trigger screen blood when greater than zero. |

### Scaler

Script: `DivineScaler.psc`

| Property | Default | Description |
| --- | --- | --- |
| `scaleMin` | `1.0` | Minimum scale or fixed target scale. |
| `scaleMax` | `1.0` | Maximum scale for random, toggle, or linear modes. |
| `linearScale` | `False` | Step from `scaleMax` toward `scaleMin`. |
| `scaleInterval` | `0.1` | Step amount for linear scale. |
| `scaleRandomly` | `False` | Pick a random scale between min and max. |
| `scaleSync` | `True` | Use one random scale for all refs. |
| `toggleMinMax` | `False` | Toggle between min and max each activation. |
| `relayActivation` | `False` | Activate linked ref instead of scaling it. |

Targets: normal linked ref and keyword-linked refs.

### Spawner

Script: `DivineSpawner.psc`

| Property | Default | Description |
| --- | --- | --- |
| `relayActivation` | `False` | Activate linked ref instead of spawning. |
| `individualDelay` | `0.0` | Delay between each keyword-linked ref spawn. |
| `maxSpawns` | `0` | Maximum spawn cycles. `0` means unlimited. |

Marker-default properties:

| Property | Default | Description |
| --- | --- | --- |
| `m_delay` | `0.0` | Wait before spawning at marker. |
| `m_collapseSpacing` | `False` | Ignore original spacing and spawn together. |
| `m_offsetX/Y/Z` | `0.0` | Position offsets. |
| `m_offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `m_limitX/Y/Z` | `False` | Prevent position axis changes. |
| `m_limitAX/AY/AZ` | `False` | Prevent angle axis changes. |
| `m_matchRotation` | `False` | Match destination rotation. |
| `m_toPlayer` | `False` | Spawn at the player instead of the box or marker. |

### Translator

Script: `DivineTranslator.psc`

| Property | Default | Description |
| --- | --- | --- |
| `relayActivation` | `False` | Activate linked ref after translation. |
| `individualDelay` | `0.0` | Delay between moving each keyword-linked ref. |
| `treatAsHavok` | `False` | Temporarily keyframe keyword refs during movement, then restore dynamic motion. |

Marker-default properties:

| Property | Default | Description |
| --- | --- | --- |
| `m_delay` | `0.0` | Wait after arrival. |
| `m_speed` | `100.0` | Translation speed. |
| `m_rotationSpeedClamp` | `0.0` | Rotation speed clamp. |
| `m_rotateOnArrival` | `False` | Delay rotation until arrival. |
| `m_tangentMagnitude` | `0.0` | Spline tangent magnitude. |
| `m_collapseSpacing` | `False` | Ignore original spacing and move together. |
| `m_offsetX/Y/Z` | `0.0` | Position offsets. |
| `m_offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `m_limitX/Y/Z` | `False` | Prevent movement on position axes. |
| `m_limitAX/AY/AZ` | `False` | Prevent rotation on angle axes. |
| `m_matchRotation` | `False` | Match destination rotation. |
| `m_toPlayer` | `False` | Move to the player instead of the box or marker. |

Targets: keyword-linked refs. Use `DivineTranslatorMarker` for paths.

### Warper

Script: `DivineWarper.psc`

| Property | Default | Description |
| --- | --- | --- |
| `relayActivation` | `False` | Activate linked ref after warping. |
| `individualDelay` | `0.0` | Delay between each keyword-linked ref warp. |

Marker-default properties:

| Property | Default | Description |
| --- | --- | --- |
| `m_warpPlayer` | `False` | Also warp the player. |
| `m_delay` | `0.0` | Wait before warping. |
| `m_collapseSpacing` | `False` | Ignore original spacing and warp together. |
| `m_offsetX/Y/Z` | `0.0` | Position offsets. |
| `m_offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `m_limitX/Y/Z` | `False` | Prevent position axis changes. |
| `m_limitAX/AY/AZ` | `False` | Prevent angle axis changes. |
| `m_matchRotation` | `False` | Match destination rotation. |
| `m_toPlayer` | `False` | Warp to the player instead of the box or marker. |

Targets: keyword-linked refs and optionally the player. Use `DivineWarperMarker` for paths.

## Marker Reference

Markers are destination and sequence points. They also inherit `DivineMarker` behavior.

| Marker | Script | Used by |
| --- | --- | --- |
| Cutscene Marker | `DivineCutsceneCreatorMarker.psc` | `DivineCutsceneCreator` |
| Spawner Marker | `DivineSpawnerMarker.psc` | `DivineSpawner` |
| Translator Marker | `DivineTranslatorMarker.psc` | `DivineTranslator` |
| Warper Marker | `DivineWarperMarker.psc` | `DivineWarper` |

### Cutscene Marker Properties

| Property | Default | Description |
| --- | --- | --- |
| `delay` | `0.0` | Wait after camera arrival. |
| `speed` | `100.0` | Camera translation speed. |
| `rotationSpeedClamp` | `0.0` | Rotation speed clamp. |
| `rotateOnArrival` | `False` | Delay rotation until arrival. |
| `tangentMagnitude` | `0.0` | Spline tangent magnitude. |
| `offsetX/Y/Z` | `0.0` | Position offsets. |
| `offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `limitX/Y/Z` | `False` | Prevent movement on position axes. |
| `limitAX/AY/AZ` | `False` | Prevent rotation on angle axes. |
| `matchRotation` | `False` | Match marker rotation. |
| `toPlayer` | `False` | Move to player instead of marker. |
| `shakeCamera` | `False` | Shake camera on arrival. |
| `cameraShakeStrength` | `0.5` | Camera shake strength. |
| `cameraShakeDuration` | `0.0` | Camera shake duration. |

### Spawner Marker Properties

| Property | Default | Description |
| --- | --- | --- |
| `delay` | `0.0` | Wait before spawning. |
| `collapseSpacing` | `False` | Ignore original spacing and spawn together. |
| `offsetX/Y/Z` | `0.0` | Position offsets. |
| `offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `limitX/Y/Z` | `False` | Prevent position axis changes. |
| `limitAX/AY/AZ` | `False` | Prevent angle axis changes. |
| `matchRotation` | `False` | Match marker rotation. |
| `toPlayer` | `False` | Spawn at player instead of marker. |

### Translator Marker Properties

| Property | Default | Description |
| --- | --- | --- |
| `delay` | `0.0` | Wait after arrival. |
| `speed` | `100.0` | Translation speed. |
| `rotationSpeedClamp` | `0.0` | Rotation speed clamp. |
| `rotateOnArrival` | `False` | Delay rotation until arrival. |
| `tangentMagnitude` | `0.0` | Spline tangent magnitude. |
| `collapseSpacing` | `False` | Ignore original spacing and move together. |
| `offsetX/Y/Z` | `0.0` | Position offsets. |
| `offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `limitX/Y/Z` | `False` | Prevent movement on position axes. |
| `limitAX/AY/AZ` | `False` | Prevent rotation on angle axes. |
| `matchRotation` | `False` | Match marker rotation. |
| `toPlayer` | `False` | Move to player instead of marker. |

### Warper Marker Properties

| Property | Default | Description |
| --- | --- | --- |
| `warpPlayer` | `False` | Also warp the player to this marker. |
| `delay` | `0.0` | Wait before warping. |
| `collapseSpacing` | `False` | Ignore original spacing and warp together. |
| `offsetX/Y/Z` | `0.0` | Position offsets. |
| `offsetAX/AY/AZ` | `0.0` | Angle offsets. |
| `limitX/Y/Z` | `False` | Prevent position axis changes. |
| `limitAX/AY/AZ` | `False` | Prevent angle axis changes. |
| `matchRotation` | `False` | Match marker rotation. |
| `toPlayer` | `False` | Warp to player instead of marker. |

## Divine Logic API

Normal Divine Logic usage does not require the API or custom Papyrus. The boxes work through linked refs, properties, and activation.

`DivineLogicAPI.psc` is for advanced mod authors who do want to write scripts and integrate with Divine Logic directly. It can query active Divine Logic boxes, chain actions against them, listen for Divine Logic signals, or run profiling while developing. It is a quest script included with the framework.

### Getting The API

Import the API script and request the shared API quest:

```papyrus
import DivineLogicAPI

DivineLogicAPI api = DivineLogicAPI.getInstance()
if ( ! api )
  return
endIf
```

`getInstance()` looks for the `DivineLogic_v1.1.esm` framework master. If Divine Logic is not loaded, it returns `None`.

### Live Signaler Queries

The API can query the currently loaded cell for active Divine signalers. This does not use a global registry and it does not require each signaler to manually register itself. It asks SKSE for the references loaded in the target cell, filters them to Divine signalers, and returns the API itself as a reusable query result.

```papyrus
DivineLogicAPI api = DivineLogicAPI.getInstance()

api.getSignalersInPlayerCell() \
  .filterByType("DivineTranslator") \
  .filterBySignaled(false) \
  .activateAll(Game.GetPlayer())
```

Use this for intentional scripted interactions, not per-frame polling. The API-owned query result is reusable and capped at 128 signalers. Do not store it long term or start a second query before you finish using the current result.

The pattern is:

1. Get the API.
2. Run one query.
3. Apply filters.
4. Read or act on the result.
5. Let the result be reused by the next query.

Do not treat the result as permanent state. It represents what was loaded and matched when the query ran.

Query methods:

| Function | Purpose |
| --- | --- |
| `getSignalersInPlayerCell()` | Finds Divine signalers in the player's current cell. |
| `getSignalersInSameCell(centerRef)` | Finds Divine signalers in the same cell as `centerRef`. |

Query filter methods:

| Function | Purpose |
| --- | --- |
| `filterByType(typeName)` | Keeps signalers whose script matches a known Divine script name, such as `DivineTranslator`. |
| `filterBySignaled(value)` | Keeps signalers with `signaled` matching `value`. |
| `filterByPaused(value)` | Keeps signalers with `paused` matching `value`. |
| `filterByState(stateName)` | Keeps signalers currently in the named Papyrus state. |
| `filterByID(signalerID)` | Keeps signalers with a matching public `signalerID`. |

Query action methods:

| Function | Purpose |
| --- | --- |
| `activateAll(activatorRef)` | Activates every signaler in the current query result. Defaults to the player if no activator is passed. |
| `pauseAll(paused)` | Sets `paused` and activation blocking on every signaler in the current query result. |
| `enableAll(enabled)` | Enables or disables every signaler in the current query result. |
| `clear()` | Clears the reusable query result. |
| `count()` | Returns how many signalers are currently in the query result. |
| `getAt(index)` | Returns one signaler by query result index. |
| `getRefs()` | Returns the fixed backing array. Entries after `count()` are unused. |

### Query Examples

Count all Divine signalers in the player's cell:

```papyrus
DivineLogicAPI api = DivineLogicAPI.getInstance()
if (api)
  int total = api.getSignalersInPlayerCell().count()
  Debug.Trace("Divine signalers in player cell: " + total)
endIf
```

Activate every un-signaled translator in the player's cell:

```papyrus
DivineLogicAPI api = DivineLogicAPI.getInstance()
if (api)
  api.getSignalersInPlayerCell() \
    .filterByType("DivineTranslator") \
    .filterBySignaled(false) \
    .activateAll(Game.GetPlayer())
endIf
```

Pause every signaler with a specific public ID:

```papyrus
DivineLogicAPI api = DivineLogicAPI.getInstance()
if (api)
  api.getSignalersInPlayerCell() \
    .filterByID("PuzzleRoom_ResetTargets") \
    .pauseAll(true)
endIf
```

Find signalers in the same cell as another reference:

```papyrus
DivineLogicAPI api = DivineLogicAPI.getInstance()
if (api)
  api.getSignalersInSameCell(myMarkerRef)
  Debug.Trace("Matches: " + api.count())
endIf
```

Use canonical Divine script names for `filterByType()`, such as `DivineActivator`, `DivineMessenger`, `DivineTranslator`, or `DivineWarper`.

### Signal Events

Register a listener form with:

```papyrus
DivineLogicAPI api = DivineLogicAPI.getInstance()
api.registerForSignalEvents(self, "OnDivineLogicSignal")
```

Then implement the callback:

```papyrus
Event OnDivineLogicSignal(string apiVersion, string eventName, string signalerID, Form signaler)
EndEvent
```

When a Divine signaler fires, the API sends the event named:

```text
DivineLogic_SignalEvent
```

Payload order:

1. API version.
2. Event name.
3. Signaler ID.
4. Signaler form.

Set `signalerID` on important boxes when external listeners need a stable ID. If `signalerID` is blank, Divine Logic falls back to the signaler's form ID.

### API Settings

| Property or function | Purpose |
| --- | --- |
| `signalEventsEnabled` | Enables or disables API signal event broadcasting. |
| `showDebug` | Enables API trace output. Keep disabled in release content. |
| `showQueryDebug` | Enables API query trace output. Keep disabled in release content. |
| `getApiVersion()` | Returns the API version string. |
| `getModVersion()` | Returns the Divine Logic version string. |
| `profileScriptStart(scriptName)` | Starts Papyrus profiling for a script. Development only. |
| `profileScriptEnd(scriptName)` | Stops Papyrus profiling for a script. Development only. |

## Common Examples

### Open A Secret Door After Two Switches

1. Place two player-activated boxes.
2. Place a `DivineComparer`.
3. Keyword-link the two switches to the comparer with `DivineRef01` and `DivineRef02`.
4. Set `andCompare = True`.
5. Link the comparer to a `DivineActivator`.
6. Link the activator to the door.

When both switches have signaled, the comparer activates the door chain.

### Track A Quest Puzzle Count

1. Create a global named `DL_Q001_PuzzleCount`.
2. Place a `DivineGlobalModifier`.
3. Set `variable = DL_Q001_PuzzleCount`.
4. Set `modValue = True`.
5. Set `value = 1.0`.

Each signal increments the quest-scoped global. A second `DivineGlobalModifier` can compare that same global and activate the next step when it reaches the required value.

### Move Statues To A Marker

1. Place a `DivineTranslator`.
2. Keyword-link the statues to the translator.
3. Link the translator to a `DivineTranslatorMarker`.
4. Set marker speed, offsets, limits, and delay.
5. Activate the translator.

The statues move to the marker and wait for the marker delay before continuing.

### Create A Camera Scene

1. Place a `DivineCutsceneCreator`.
2. Link it to the first `DivineCutsceneCreatorMarker`.
3. Link each marker to the next marker.
4. Configure speed, offsets, delay, and camera shake per marker.
5. Activate the cutscene creator.

The player enters a controlled cutscene state, the camera actor follows the marker chain, and the scene ends at the final marker.

## Divine Laboratory

`DivineLabratory` is the included demonstration and stress-test cell. The name is spelled that way in the plugin.

Use it to inspect working examples, test boxes safely, and see how logic chains are wired. It is a learning and testing cell, not content that should be copied directly into a released mod.

To visit it in game:

```text
coc DivineLabratory
```

Recommended workflow:

1. Start a test profile with SKSE enabled.
2. Load Divine Logic.
3. Use `coc DivineLabratory`.
4. Activate one exhibit at a time.
5. Inspect the placed boxes and linked refs in the Creation Kit.
6. Rebuild the pattern in your own plugin.

The lab is intentionally dense. Do not judge release performance from every lab showcase running at once.

## Performance And Release Guidance

- Keep `showDebug` disabled for release.
- Keep API debug, API tests, and profiling disabled for release.
- Avoid unnecessary continuous signalers.
- Use `signalDelay`, `postSignalDelay`, and marker delays to pace large chains.
- Prefer marker chains and state-machine timing over rapid repeated activation.
- Use quest-scoped globals for puzzle and quest state.
- Test complex setups on a clean save.
- Package the `.esm` and compiled `.pex` files needed by the release.

## Compatibility Notes

- Divine Logic requires SKSE.
- Mods using Divine Logic should declare `DivineLogic_v1.1.esm` as a master.
- Do not rename or remove serialized Papyrus properties on placed objects in an existing release.
- Existing saves can retain old script property data. Test script/property changes carefully.
- If your mod depends on Divine Logic, list Divine Logic and SKSE as requirements.

## Community And Support

For examples, usage discussion, and questions, join the Discord:

```text
https://discord.gg/jTXqGnNJ8r
```

Use the `#skyrim_divine-logic` channel.

## License

Divine Logic is licensed under the BSD 3-Clause License. See `LICENSE`.

Copyright (c) 2019, Sjshovan (LoTekkie).

## Credits

Created by Sjshovan (LoTekkie).

Special thanks to Bruno Mara for helping test Divine Logic and motivating me to finish it.
