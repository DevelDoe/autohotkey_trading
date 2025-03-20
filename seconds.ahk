#Persistent
SetTimer, ShowCountdown, 100
return

ShowCountdown:
    MouseGetPos, MouseX, MouseY
    FormatTime, CurrentSeconds, , ss  ; Get current seconds
    Countdown := 60 - CurrentSeconds  ; Invert seconds to count down
    ToolTip, %Countdown%, MouseX - 10, MouseY - 40
return

Esc::ExitApp
