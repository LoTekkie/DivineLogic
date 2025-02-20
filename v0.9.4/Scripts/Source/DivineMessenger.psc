scriptName DivineMessenger extends DivineSignaler
; Reman – culture god-hero of the Second Empire.

import DivineUtils

string property messageText = "" auto
{ Default: False - Message to display (Only used when messageObject property is None). }
message property messageObject = none auto
{ Default: None - The Message object to use (Overrides use of the messageText property). }
float property messageObjectArg1 = 0.0 auto
{ Default: 0.0 - The number to substitute into the first spot in the messageObject text. }
float property messageObjectArg2 = 0.0 auto
{ Default: 0.0 - The number to substitute into the second spot in the messageObject text. }
float property messageObjectArg3 = 0.0 auto
{ Default: 0.0 - The number to substitute into the third spot in the messageObject text. }
float property messageObjectArg4 = 0.0 auto
{ Default: 0.0 - The number to substitute into the fourth spot in the messageObject text. }
float property messageObjectArg5 = 0.0 auto
{ Default: 0.0 - The number to substitute into the fifth spot in the messageObject text. }
float property messageObjectArg6 = 0.0 auto
{ Default: 0.0 - The number to substitute into the sixth spot in the messageObject text. }
float property messageObjectArg7 = 0.0 auto
{ Default: 0.0 - The number to substitute into the seventh spot in the messageObject text. }
float property messageObjectArg8 = 0.0 auto
{ Default: 0.0 - The number to substitute into the eighth spot in the messageObject text. }
float property messageObjectArg9 = 0.0 auto
{ Default: 0.0 - The number to substitute into the ninth spot in the messageObject text. }
bool property asMessageBox = false auto
{ Default: False - Should the message be displayed in a message box? 
(Used only when the messageText property is not empty and the messageObject property is None) }
bool property asNotification = false auto
{ Default: False - Should the message be displayed as a notification?
(Used only when the messageText property is not empty and the messageObject property is None) }
bool property asTrace = false auto
{ Default: False - Should the message be sent to Papyrus logs? }
bool property asTraceAndBox = false auto
{ Default: False - Should the message be sent to Papyrus logs and displayed in a message box? }
int property traceSeverity = 0 auto
{ Default: 0 - The severity of the strace statement. (Only used if the asTrace or asTraceAndBox property is set to True) 
  One of: 
  0 - Info (Default)
  1 - Warning
  2 - Error
}
bool property asHelpMessage = false auto
{ Default: False - Should the messageObject property be treated as a help message? }
string property helpMessageEvent = "" auto
{ Default: "" - Which event should the help message be applied to? 
(Only used if the messageObject property is not None and the asHelpMessage property is set to True) }
float property helpMessageDuration = 0.0 auto
{ Default: 0.0 - How long should the help message appear before going away? A value <= 0 means no time limit. 
(Only used if the messageObject property is not None and the asHelpMessage property is set to True) }
float property helpMessageInterval = 0.0 auto
{ Default: 0.0 - How much time should elapse in between showings of the help message?
(Only used if the messageObject property is not None and the asHelpMessage property is set to True) }
int property helpMessageMaxTimes = 0 auto
{ Default: 0 - After this many times of being shown, the help message will stop appearing. A value of <= 0 means no occurrence limit
(Only used if the messageObject property is not None and the asHelpMessage property is set to True) }
bool property resetHelpMessage = false auto
{ Default: False - Resets the status of the help message event, allowing a message to be displayed for that input event. }

function onSignalling()
  parent.onSignalling()
  if (self.messageObject != none) ; use message object
    if ( ! self.resetHelpMessage )
      if ( ! self.asHelpMessage )
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
          self.helpMessageEvent,              \
          self.helpMessageDuration,           \
          self.helpMessageInterval,           \
          self.helpMessageMaxTimes            \
        )
      endIf 
    else
      message.resetHelpMessage(self.helpMessageEvent)
    endIf
  elseIf(self.messageText != "") ; use message string
    if (self.asMessageBox)
      debug.messageBox(self.messageText)
    elseif (self.asNotification)
      debug.notification(self.messageText)
    elseIf (self.asTrace)
      debug.trace(self.messageText) 
    elseIf (self.asTraceAndBox)
      debug.traceAndBox(self.messageText, self.traceSeverity) 
    endIf     
  endIf 
endFunction 