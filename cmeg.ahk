; Configurable delay times for middle mouse button actions
DelayAfterClick := 250
DelayAfterFirstEnter := 500
DelayAfterDoubleClick := 250  ; Delay after double-click before copying
DelayBeforeDoubleClick := 100  ; New delay before the double-click

; Delay time for canceling orders in trading hotkeys
cancelDelay := 1000  ; Adjust as needed

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
    ClipWait, 1
    if (!ErrorLevel) {
        clipboard := RegExReplace(clipboard, "\s*\(HOD\)\s*$")
        clipboard := RegExReplace(clipboard, "Copy$")
        ; Add a safety check for very large clipboard content
        if (StrLen(clipboard) > 1000) {
            clipboard := SubStr(clipboard, 1, 1000)  ; Truncate to a reasonable size
        }
    } else {
        clipboard := ""  ; Clear the clipboard if invalid
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
base = true  ; Initial value for toggling
parabolicMode := false  ; New toggle for parabolic mode

; Mouse Wheel Up - Switch to 88
WheelUp::
    base := false
    SoundBeep, 750  ; Higher pitch for double mode
    ShowTooltip("Mode: double")
return

WheelDown::
    base := true
    SoundBeep, 500  ; Lower pitch for base mode
    ShowTooltip("Mode: base")
return

; Toggle Parabolic Mode with H
G::
    parabolicMode := !parabolicMode  ; Toggle parabolic mode
    if (parabolicMode) {
        SoundBeep, 900  ; Higher pitch for parabolic mode
        ShowTooltip("Parabolic Mode: ON")
    } else {
        SoundBeep, 400  ; Lower pitch for normal mode
        ShowTooltip("Parabolic Mode: OFF")
    }
return


; XButton2 toggles between buy orders with g and h
XButton2::
    if (parabolicMode) {
        if (base) {
            Send, +!g  ; Shift+Alt+g for base mode
            ShowTooltip("Parabolic +44")
        } else {
            Send, +!h  ; Shift+Alt+h for double mode
            ShowTooltip("Parabolic +88")
        }
    } else {
        if (base) {
            Send, ^!g  ; Ctrl+Alt+g for base mode
            ShowTooltip("+44")
        } else {
            Send, ^!h  ; Ctrl+Alt+h for double mode
            ShowTooltip("+88")
        }
    }
    cancelState := false
return

; A key hotkey
A::
    Send, ^!{CapsLock}
    cancelState := false
    ShowTooltip("clx")
return

; S key hotkey
S::
    Send, ^!c
    cancelState := false
    ShowTooltip("Cancel")
return

; D key hotkey
D::
    if (base) {
        ; Base mode behavior
        if (!cancelState) {
            Send, ^!d
            cancelState := true
            tooltipMessage := "-44"
        } else {
            Send, ^!c
            Sleep, cancelDelay
            Send, ^!d
            tooltipMessage := "c-44"
            cancelState := false
        }
    } else {
        ; Double mode behavior (previously A key)
        if (!cancelState) {
            Send, ^!a
            cancelState := true
            tooltipMessage := "-88"
        } else {
            Send, ^!c
            Sleep, cancelDelay
            Send, ^!a
            tooltipMessage := "c-88"
            cancelState := false
        }
    }
    ShowTooltip(tooltipMessage)
return

; F key hotkey
F::
    if (base) {
        ; Base mode behavior
        if (!cancelState) {
            Send, ^!f
            cancelState := true
            tooltipMessage := "-44"
        } else {
            Send, ^!c
            Sleep, cancelDelay
            Send, ^!f
            tooltipMessage := "c-44"
            cancelState := false
        }
    } else {
        ; Double mode behavior (previously S key)
        if (!cancelState) {
            Send, ^!s
            cancelState := true
            tooltipMessage := "-88"
        } else {
            Send, ^!c
            Sleep, cancelDelay
            Send, ^!s
            tooltipMessage := "c-88"
            cancelState := false
        }
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
Tab::  
    Suspend, Toggle
    IsSuspended := !IsSuspended
    if (IsSuspended) {
        SoundBeep, 300  ; Low pitch for suspended
        Tooltip, Script Suspended
    } else {
        SoundBeep, 600  ; High pitch for active
        Tooltip, Script Active
    }
    Sleep, 1000
    Tooltip
return