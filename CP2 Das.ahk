
MButton::
    Click 1          ; Step 1: Click once
    Sleep, 100
    Send, ^a         ; Step 2: Select all
    Sleep, 100
    Send, {Backspace} ; Step 3: Delete selected text
    Sleep, 100
    Send, ^v         ; Step 4: Paste clipboard content
    Sleep, 100
    Send, {Enter}         ; Step 4: Paste clipboard content
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