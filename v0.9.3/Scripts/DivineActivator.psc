scriptName DivineActivator extends DivineSignaler
; Stendarr - God of Compassion, Mercy, Justice, charity, luck, and righteous rule by might and merciful forbearance

import DivineUtils

function onSignalling()
    parent.onSignalling()
    self.setRefActivated(self.linkedRef, self)
    self.setKeywordRefsActivated()
endFunction