scriptName DivineMessenger extends DivineSignaler
; Reman – culture god-hero of the Second Empire.

import DivineUtils

; =========================
;        PROPERTIES
; =========================

string property messageText = "" auto
{ Default: "" - Message to display (Only used when `messageObject` is None). }

message property messageObject = none auto
{ Default: None - The Message object to use (Overrides `messageText`). }

float property messageObjectArg1 = 0.0 auto
{ Default: 0.0 - The number to substitute into the first spot in `messageObject` text. }

float property messageObjectArg2 = 0.0 auto
{ Default: 0.0 - The number to substitute into the second spot in `messageObject` text. }

float property messageObjectArg3 = 0.0 auto
{ Default: 0.0 - The number to substitute into the third spot in `messageObject` text. }

float property messageObjectArg4 = 0.0 auto
{ Default: 0.0 - The number to substitute into the fourth spot in `messageObject` text. }

float property messageObjectArg5 = 0.0 auto
{ Default: 0.0 - The number to substitute into the fifth spot in `messageObject` text. }

float property messageObjectArg6 = 0.0 auto
{ Default: 0.0 - The number to substitute into the sixth spot in `messageObject` text. }

float property messageObjectArg7 = 0.0 auto
{ Default: 0.0 - The number to substitute into the seventh spot in `messageObject` text. }

float property messageObjectArg8 = 0.0 auto
{ Default: 0.0 - The number to substitute into the eighth spot in `messageObject` text. }

float property messageObjectArg9 = 0.0 auto
{ Default: 0.0 - The number to substitute into the ninth spot in `messageObject` text. }

bool property asMessageBox = false auto
{ Default: False - Should the message be displayed in a message box?
  (Used only when `messageText` is not empty and `messageObject` is None). }

bool property asNotification = false auto
{ Default: False - Should the message be displayed as a notification?
  (Used only when `messageText` is not empty and `messageObject` is None). }

bool property asTrace = false auto
{ Default: False - Should the message be sent to Papyrus logs? }

bool property asTraceAndBox = false auto
{ Default: False - Should the message be sent to Papyrus logs and displayed in a message box? }

int property traceSeverity = 0 auto
{ Default: 0 - The severity of the trace statement. (Only used if `asTrace` or `asTraceAndBox` is True).
  One of:
  0 - Info (Default)
  1 - Warning
  2 - Error }

bool property asHelpMessage = false auto
{ Default: False - Should the `messageObject` be treated as a help message? }

string property helpMessageEvent = "" auto
{ Default: "" - Which event should the help message be applied to?
  (Only used if `messageObject` is not None and `asHelpMessage` is True). }

float property helpMessageDuration = 0.0 auto
{ Default: 0.0 - How long should the help message appear before going away? A value <= 0 means no time limit.
  (Only used if `messageObject` is not None and `asHelpMessage` is True). }

float property helpMessageInterval = 0.0 auto
{ Default: 0.0 - How much time should elapse between showings of the help message?
  (Only used if `messageObject` is not None and `asHelpMessage` is True). }

int property helpMessageMaxTimes = 0 auto
{ Default: 0 - After this many times of being shown, the help message will stop appearing.
  A value of <= 0 means no occurrence limit.
  (Only used if `messageObject` is not None and `asHelpMessage` is True). }

bool property resetHelpMessage = false auto
{ Default: False - Resets the status of the help message event, allowing a message to be displayed for that input event. }

; =========================
;      MAIN FUNCTION
; =========================

function onSignalling()
    parent.onSignalling()

    if (self.messageObject != none) ; Use message object
        if (!self.resetHelpMessage)
            if (!self.asHelpMessage)
                self.messageObject.show(  \
                    self.messageObjectArg1, \
                    self.messageObjectArg2, \
                    self.messageObjectArg3, \
                    self.messageObjectArg4, \
                    self.messageObjectArg5, \
                    self.messageObjectArg6, \
                    self.messageObjectArg7, \
                    self.messageObjectArg8, \
                    self.messageObjectArg9  \
                )
            else
                self.messageObject.showAsHelpMessage( \
                    self.helpMessageEvent,           \
                    self.helpMessageDuration,        \
                    self.helpMessageInterval,        \
                    self.helpMessageMaxTimes         \
                )
            endIf
        else
            message.resetHelpMessage(self.helpMessageEvent)
        endIf

    elseIf (self.messageText != "") ; Use message string
        if (self.asMessageBox)
            debug.messageBox(self.messageText)
        elseif (self.asNotification)
            debug.notification(self.messageText)
        elseif (self.asTrace)
            debug.trace(self.messageText)
        elseif (self.asTraceAndBox)
            debug.traceAndBox(self.messageText, self.traceSeverity)
        endIf
    endIf
endFunction
