; Divine Logic Signaler Collection (c) 2019-, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineSignalerCollection
; Stendarr – God of Compassion, Mercy, Justice, Charity, Luck, and Righteous Rule by Might and Merciful Forbearance.

import Utility

DivineSignaler[] signalers

; =========================
;         METHODS
; =========================

; Add a signaler to the collection
bool function add(DivineSignaler signaler)    
    signalers = signalers + [signaler]
    return self
endFunction

; Remove a signaler from the collection
function remove(DivineSignaler signaler)
    DivineSignaler[] newSignalers
    int count = signalers.length
    int i = 0

    while i < count
        if signalers[i] != signaler  ; Keep all elements except the one to remove
            newSignalers = newSignalers + [signalers[i]]
        endif
        i += 1
    endwhile

    signalers = newSignalers  ; Assign the filtered array back
    return self
endFunction 

; Activate all signalers in the collection
function activateAll()
    int i = 0
    while i < signalers.length
        signalers[i].activate(signalers[i])
        i += 1
    endWhile
    info(self + "@ function: activateAll | activated all signalers.", self.showDebug)
    return self
endFunction

; Destroy all signalers in the collection
function destroyAll(bool whenAble = false)
    int i = 0
    while i < signalers.length
        signalers[i].deleteRef(self, whenAble)
        i += 1
    endWhile
    info(self + "@ function: destroyAll | destroyed all signalers.", self.showDebug)
    return self
endFunction

; Filter signalers by active/inactive state
function filterBySignaledState(bool isSignaled)
    DivineSignalerCollection result = new DivineSignalerCollection
    int i = 0
    while i < signalers.length
        if signalers[i].signaled == isSignaled
            result = result + [signalers[i]]
        endIf
        i += 1
    endWhile
    info(self + "@ function: filterByActiveState | isSignaled: " + isSignaled + " | count: " + result.length, self.showDebug)
    return self
endFunction

; Compact the array by removing all None values
bool function compact()
    int count = self.DivineSignalerCollection.length
    int firstNoneIndex = -1
    bool moved = false

    int i = 0
    while i < count
        if self.DivineSignalerCollection[i] == None
            if firstNoneIndex == -1
                firstNoneIndex = i  ; Mark the first occurrence of None
            endif
        elseif firstNoneIndex != -1
            ; Move valid elements down to replace None values
            self.DivineSignalerCollection[firstNoneIndex] = self.DivineSignalerCollection[i]
            self.DivineSignalerCollection[i] = None
            firstNoneIndex += 1
            moved = true
        endif
        i += 1
    endwhile

    return self
endFunction

; Clear the signaler collection
function clear()
    int count = self.DivineSignalerCollection.length
    int i = 0
    while i < count
        self.DivineSignalerCollection[i] = None
        i += 1
    endwhile
endFunction

; Return the array of signalers
function getAll()
    return self.DivineSignalerCollection
endFunction

; Get the number of signalers in the collection
function count()
    return signalers.length
endFunction