; AutoHotkey Script with GUI for lowSellMode and highSellMode

; Initialize Global Variables
Suspend On
IsSuspended := true
liveMode := false
parabolicMode := false
parabolicX := 40
parabolicY := 10
liveX := 10
liveY := 10
tPressCount := 0

; Initialize Parabolic Mode GUI
Gui, 1: +AlwaysOnTop +ToolWindow -Caption
Gui, 1: Show, NoActivate x%parabolicX% y%parabolicY% w20 h20, Parabolic Mode
Gui, 1: Color, Black

; Initialize Live Mode GUI
Gui, 2: +AlwaysOnTop +ToolWindow -Caption
Gui, 2: Show, NoActivate x%liveX% y%liveY% w20 h20, Live Mode
Gui, 2: Color, Black

; Function to Update Display
UpdateDisplay() {
    global IsSuspended, parabolicMode, liveMode
    ; Determine background colors
    parabolicBgColor := IsSuspended ? "Gray" : (parabolicMode ? "Red" : "Black")
    liveBgColor := IsSuspended ? "Gray" : (liveMode ? "FF00FF" : "006666")
    ; Update GUI colors
    Gui, 1: Color, %parabolicBgColor%
    Gui, 2: Color, %liveBgColor%
}

; Allow dragging for all GUIs
OnMessage(0x201, "StartDrag") ; WM_LBUTTONDOWN for drag handling
OnMessage(0x202, "EndDrag")   ; WM_LBUTTONUP for drag ending

StartDrag(wParam, lParam, msg, hwnd) {
    if WinActive("Parabolic Mode") {
        Gui, 1:+LastFound
        PostMessage, 0xA1, 2 ; Start dragging
    } else if WinActive("Live Mode") {
        Gui, 2:+LastFound
        PostMessage, 0xA1, 2 ; Start dragging
    }
}

EndDrag(wParam, lParam, msg, hwnd) {
    global parabolicX, parabolicY, liveX, liveY
    ; Save new positions
    if WinActive("Parabolic Mode") {
        WinGetPos, parabolicX, parabolicY,,, Agg
    } else if WinActive("Live Mode") {
        WinGetPos, liveX, liveY,,, A
    }
}

; Toggle Suspend with Shift+Ctrl+Alt+S
+^!S::
    global IsSuspended
    Suspend, Toggle
    IsSuspended := !IsSuspended
    SoundBeep, % IsSuspended ? 200 : 600 ; Low pitch for Suspended, high pitch for Active
    UpdateDisplay()
return

; Toggle Parabolic Mode with 'G'
+^!G::
    if IsSuspended
        return
    global parabolicMode
    parabolicMode := !parabolicMode
    SoundBeep, % parabolicMode ? 900 : 300
    UpdateDisplay()
return

; Hotkey for the 'T' key
+^!$*t::
    if IsSuspended
        return
    global tPressCount, lastPressTime
    currentTime := A_TickCount

    if (currentTime - lastPressTime < 300) {  ; If pressed within 300ms, toggle liveMode
        liveMode := !liveMode
        SoundBeep, % liveMode ? 900 : 300
        UpdateDisplay()
        tPressCount := 0
    } else {
        tPressCount := 1
    }
    lastPressTime := currentTime
return

CheckDoubleTap:
    global tPressCount, liveMode
    if (tPressCount = 2) {
        ; Double-tap detected, toggle liveMode
        liveMode := !liveMode
        SoundBeep, % liveMode ? 900 : 300
        UpdateDisplay()
    }
    ; Reset the press count after checking
    tPressCount := 0
return

; Cancel All Orders with 'A'
+^!A::
    if IsSuspended
        return

    Send, ^q  ; CLX all orders
return

; SPB with 'S'
+^!X::
    if IsSuspended
        return
    global liveMode

    Send, % liveMode ? "+q" : "!+q"
return

; SPA with 'C'
+^!C::
    if IsSuspended
        return
    global liveMode

    Send, % liveMode ? "+a" : "!+a"
    SoundBeep, 200
return

; S75A with 'V'
+^!V::
    if IsSuspended
        return
    global liveMode

    Send, % liveMode ? "+s" : "!+s"
    SoundBeep, 200
return
beepIndex := 1  ; initialize global variable

global soundEnabled := true  ; Sound is enabled by default

^L::  ; Ctrl+L toggles sound
    soundEnabled := !soundEnabled
    ToolTip % "Sound " (soundEnabled ? "ON" : "OFF")
    SetTimer, RemoveToolTip, -1000
return

RemoveToolTip:
    ToolTip
return

startBeeps() {
    global beepIndex
    beepIndex := 5  ; Start from 5
    SetTimer, playBeeps, 1000
}

playBeeps:
    global beepIndex, soundEnabled
    if (beepIndex < 1) {
        SetTimer, playBeeps, Off
        return
    }

    if (soundEnabled) {
        voice := ComObjCreate("SAPI.SpVoice")
        voice.Volume := 10
        voice.Rate := 0
        voice.Speak(beepIndex, 1)
    }

    beepIndex--
return

; BLA with 'E'
+^!E::
    if IsSuspended
        return
    global liveMode, parabolicMode

    if parabolicMode {
        Send, % liveMode ? "+3" : "!+3"
    } else {
        Send, % liveMode ? "+1" : "!+1"
    }
    startBeeps()
return

; BHA with 'R'
+^!R::
    if IsSuspended
        return
    global liveMode, parabolicMode

    if parabolicMode {
        Send, % liveMode ? "+4" : "!+4"
    } else {
        Send, % liveMode ? "+2" : "!+2"
    }
    startBeeps()
return

UpdateDisplay()  ; Ensure GUI starts in the correct color state