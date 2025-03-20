; AutoHotkey Version 1 Script
; Press Ctrl+Alt+Shift+Home at the 58th and 28th minute of every hour

#Persistent ; Keep the script running
SetTimer, CheckTime, 1000 ; Check every second for better precision
return

CheckTime:
    FormatTime, CurrentTime,, HHmm

    ; Check if the current time ends with 28 or 58
    if (SubStr(CurrentTime, 3, 2) = "28" || SubStr(CurrentTime, 3, 2) = "58")
    {
        ; Send the hotkey sequence
        Send, ^!+{Home}
        Sleep, 60000 ; Prevents re-triggering within the same minute
    }
return
