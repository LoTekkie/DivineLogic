; Divine Logic (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)

scriptName DivineActivator extends DivineSignaler
; Stendarr – God of Compassion, Mercy, Justice, Charity, Luck, and Righteous Rule by Might and Merciful Forbearance.

import DivineUtils

; =========================
;     LIFECYCLE HOOKS
; =========================

function onSignalling()
    parent.onSignalling()

    ; Activate the linked reference if it exists
    self.setRefActivated(self.linkedRef, self)

    ; Activate all keyword-linked references
    self.setKeywordRefsActivated()
endFunction
