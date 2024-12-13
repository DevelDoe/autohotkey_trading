; Configurable delays
DelayAfterClick := 500  ; Delay after single click
DelayBeforeDoubleClick := 200  ; Delay before double-click
DelayAfterDoubleClick := 200  ; Delay after double-click
LongPressThreshold := 500  ; Long press threshold (in milliseconds)

; Middle Mouse Button Functionality with short and long press detection
MButton::
    PressStartTime := A_TickCount  ; Record the time when MButton is pressed
    KeyWait, MButton  ; Wait for the button to be released
    PressDuration := A_TickCount - PressStartTime  ; Calculate press duration

    if (PressDuration < LongPressThreshold) {
        ; Short press - double-click, paste, wait, Enter
        Click             ; Double-click to select the content
        Sleep, 500
        Send, ^v           ; Paste clipboard content
        Sleep, 500
        Send, {Enter}      ; Press Enter
    } else {
        ; Long press - click to activate window, double-click to select, copy content
        Click             ; First single click
        Sleep, 100
        Click             ; Second single click
        Sleep, 500
        Click 2           ; Double-click to select the text
        Sleep, 500
        Send, ^c          ; Copy the selected text
        Sleep, DelayAfterClick
        SanitizeClipboard()  ; Call function to clean up the clipboard content

        ; Display the clipboard content in a tooltip
        Tooltip, `n%clipboard%
        Sleep, 2000  ; Tooltip will stay for 2 seconds
        Tooltip  ; Remove the tooltip
    }
return

; Sanitize clipboard content by removing unwanted text (e.g., "HOD")
SanitizeClipboard() {
    ClipWait, 1
    if (!ErrorLevel) {
        ; Remove unwanted text patterns
        clipboard := RegExReplace(clipboard, "\s*\(HOD\)\s*$")  ; Remove "(HOD)" at the end
        clipboard := RegExReplace(clipboard, "Copy$")           ; Remove "Copy" at the end
        clipboard := RegExReplace(clipboard, "\*$")            ; Remove trailing "*"
        
        ; Add a safety check for very large clipboard content
        if (StrLen(clipboard) > 1000) {
            clipboard := SubStr(clipboard, 1, 1000)  ; Truncate to a reasonable size
        }
    } else {
        clipboard := ""  ; Clear the clipboard if invalid
    }
}
