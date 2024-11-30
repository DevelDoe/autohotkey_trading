; Configurable delay time after double-click before copying
DelayAfterDoubleClick := 250

; Override the Tab key to double-click and then copy
Tab::
{
    Click 2  ; Double-click to select the text
    Sleep, DelayAfterDoubleClick
    Send, ^c  ; Copy the selected text
}
return

; Press Ctrl+Alt+S to toggle suspend
^!s::
Suspend, Toggle
Tooltip % "Script " (A_IsSuspended ? "Suspended" : "Active")
Sleep 1000  ; Display the tooltip briefly
Tooltip  ; Remove the tooltip
return
