; Configurable delay times for middle mouse button actions
DelayAfterClick := 250
DelayAfterFirstEnter := 500
DelayAfterDoubleClick := 250  ; Delay after double-click before copying
DelayBeforeDoubleClick := 100  ; New delay before the double-click

; Delay time for canceling orders in trading hotkeys
cancelDelay := 100  ; Adjust as needed

; Define the threshold for a long press (e.g., 500ms)
LongPressThreshold := 500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Ensure this matches the starting state

; Middle Mouse Button Functionality with short and long press detection
MButton::
    PressStartTime := A_TickCount  ; Record the time when MButton is pressed
    KeyWait, MButton  ; Wait for the button to be released
    PressDuration := A_TickCount - PressStartTime  ; Calculate press duration

    if (PressDuration < LongPressThreshold) {
        ; Short press - double-click, paste, wait, Enter
        Click 2            ; Double-click to select the content
        Sleep, DelayAfterClick
        Send, ^v           ; Paste clipboard content
        Sleep, 500         ; Wait 500ms
        Send, {Enter}      ; Press Enter
    } else {
        ; Long press - single-click, paste, wait, Enter
        Click              ; Single click to select the content
        Sleep, DelayAfterClick
        Send, ^v           ; Paste clipboard content
        Sleep, 700         ; Wait 500ms
        Send, {Enter}      ; Press Enter
    }
return

; Sanitize clipboard content by removing unwanted text (e.g., "HOD")
SanitizeClipboard() {
    ClipWait, 1  ; Wait for clipboard to contain data
    if (!ErrorLevel) {
        clipboard := RegExReplace(clipboard, "\s*\(HOD\)\s*$")  ; Remove "(HOD)" at the end
        clipboard := RegExReplace(clipboard, "Copy$")           ; Remove "Copy" if it's at the end
        ; Add more patterns if needed
    }
}

; Override the Tab key to single-click, delay, single-click, delay, double-click, and then copy
Tab::
    Click             ; First single click
    Sleep, DelayAfterClick
    Click             ; Second single click
    Sleep, DelayBeforeDoubleClick
    Click 2           ; Double-click to select the text
    Sleep, DelayAfterDoubleClick
    Send, ^c          ; Copy the selected text
    Sleep, 100        ; Small delay to ensure copy action is complete
    SanitizeClipboard()  ; Call function to clean up the clipboard content

    ; Display the clipboard content in a tooltip
    Tooltip, `n%clipboard%
    Sleep, 2000  ; Tooltip will stay for 2 seconds
    Tooltip  ; Remove the tooltip
return

; Trading hotkeys with ShareX recording control
W::
    Send, {Pause}  ; Start recording
    Send, !w       ; Press Shift+W for buy action
    return

E::
    Send, {Pause}  ; Start recording
    Send, !e       ; Press Shift+W for buy action
    return

A::
    Send, !a       ; Presses Shift+A to close position
    return

D::
    Send, !d       ; Presses Shift+D to sell at ask
    return

S::
    Send, !c       ; Presses Shift+C to cancel orders
    Sleep, cancelDelay
    Send, !s       ; Presses Shift+S to sell half
    return

C::
    Send, !c       ; Presses Alt+C
    return

F::
    Send, !f       ; Presses Shift+F to close position
    return

; Press Ctrl+Alt+S to toggle suspend for the entire script with feedback
^!s::
Suspend, Toggle
IsSuspended := !IsSuspended  ; Toggle the suspension state
if (IsSuspended) {
    Tooltip, Script Suspended
} else {
    Tooltip, Script Active
}
Sleep 1000  ; Display the tooltip briefly
Tooltip  ; Remove the tooltip
return
