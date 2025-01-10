
MButton::
    Click             ; Double-click to select where to past
    Sleep, 500
    Send, ^v           ; Paste clipboard content
    Sleep, 500
    Send, {Enter}      ; Press Enter
return

XButton1::
    Click             ; First single click
    Sleep, 100
    Click             ; Second single click
    Sleep, 500
    Click 2           ; Double-click to select the text
    Sleep, 500
    Send, ^c          ; Copy the selected text
    Sleep, 500
    SanitizeClipboard()  ; Call function to clean up the clipboard content

    ; Display the clipboard content in a tooltip
    Tooltip, `n%clipboard%
    Sleep, 2000  ; Tooltip will stay for 2 seconds
    Tooltip  ; Remove the tooltip
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