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
        Sleep, DelayAfterFirstEnter
        Send, {Enter}      ; Press Enter
    } else {
        ; Long press - single-click, paste, wait, Enter
        Click              ; Single click to select the content
        Sleep, DelayAfterClick
        Send, ^v           ; Paste clipboard content
        Sleep, DelayAfterFirstEnter
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
    } else {
        clipboard := ""  ; Clear the clipboard if it's empty or invalid
    }
}



; C key hotkey
C::
    Click             ; First single click
    Sleep, DelayAfterClick
    Click             ; Second single click
    Sleep, DelayBeforeDoubleClick
    Click 2           ; Double-click to select the text
    Sleep, DelayAfterDoubleClick
    Send, ^c          ; Copy the selected text
    Sleep, DelayAfterClick
    SanitizeClipboard()  ; Call function to clean up the clipboard content

    ; Display the clipboard content in a tooltip
    Tooltip, `n%clipboard%
    Sleep, 2000  ; Tooltip will stay for 2 seconds
    Tooltip  ; Remove the tooltip
return




; Define initial state variables
cancelState := false

; Sell keys
XButton1::
    Send, ^!c
    cancelState := false
    ShowTooltip("Cancel")
return

; Reset state with XButton2
XButton2::
    Send, ^!g
    cancelState := false
    ShowTooltip("+44")
    
return

CapsLock::
    Send, ^!{CapsLock}
    cancelState := false
    ShowTooltip("Sell All")
    
return

; A key hotkey
A::
    if (!cancelState) {
        Send, ^!a
        cancelState := true
        tooltipMessage := "-88"
    } else {
        Send, ^!c
        Sleep, cancelDelay
        Send, ^!a
        tooltipMessage := "c -88"
    }
    
    ShowTooltip(tooltipMessage)
return

; S key hotkey
S::
    if (!cancelState) {
        Send, ^!s
        cancelState := true
        tooltipMessage := "-88"
    } else {
        Send, ^!c
        Sleep, cancelDelay
        Send, ^!s
        tooltipMessage := "c-88"
    }
    
    ShowTooltip(tooltipMessage)
return

; D key hotkey
D::
    if (!cancelState) {
        Send, ^!d
        cancelState := true
        tooltipMessage := "-44"
    } else {
        Send, ^!c
        Sleep, cancelDelay
        Send, ^!d
        tooltipMessage := "c-44"
    }
    
    ShowTooltip(tooltipMessage)
return

; F key hotkey
F::
    if (!cancelState) {
        Send, ^!f
        cancelState := true
        tooltipMessage := "-44"
    } else {
        Send, ^!c
        Sleep, cancelDelay
        Send, ^!f
        tooltipMessage := "c-44"
    }
    
    ShowTooltip(tooltipMessage)
return

; Function to display a tooltip
ShowTooltip(message) {
    ToolTip, %message%
    Sleep, 1000  ; Tooltip stays visible for 1 second
    ToolTip  ; Clear the tooltip
}

; Press Shift+Alt+P to toggle suspend for the entire script with feedback
+!s::
    Suspend, Toggle
    IsSuspended := !IsSuspended  ; Toggle the suspension state
    if (IsSuspended) {
        Tooltip, Script Suspended
    } else {
        Tooltip, Script Active
    }
    Sleep, 1000  ; Display the tooltip briefly
    Tooltip  ; Remove the tooltip
return