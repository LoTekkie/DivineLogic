scriptName DivineActivator extends DivineSignaler
; Stendarr – God of Compassion, Mercy, Justice, Charity, Luck, and Righteous Rule by Might and Merciful Forbearance.

import DivineUtils

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
    parent.onSignalling()

    ; Activate the linked reference if it exists
    self.setRefActivated(self.linkedRef, self)

    ; Activate all keyword-linked references
    self.setKeywordRefsActivated()
endFunction