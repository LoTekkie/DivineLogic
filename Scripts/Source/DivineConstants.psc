; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineConstants
; Akatosh - Chief Deity, God of Time and Order

; =========================
;       PROPERTIES
; =========================

int property KEYWORD_REFS_MAX = 9 auto hidden
{ The maxiumum number of keyword-linked references allowed to be attached to this object. }

string property KEYWORD_REFS_SIGNATURE = "DivineRef" auto hidden
{ The base keyword signature used to identify objects available to enter the keywordRefs property. }

; =========================
;        EVENTS
; =========================

string property EVENT_DIVINE_SIGNAL = "DivineSignalEvent" auto hidden
{ Name of the custom event used for signaling. }

; =========================
;        GENERAL
; =========================

string property VERSION_MOD_CURRENT = "1.0" auto hidden 
{ Current version of the Divine Logic mod. }

string property VERSION_API_CURRENT = "1.0" auto hidden
{ Current version of the Divine Logic API. }

; =========================
;        FILES
; =========================

string property FILE_DIVINE_LOGIC = "DivineLogic.esm" auto hidden
{ File name for the Divine Logic master plugin. }