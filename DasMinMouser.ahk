; AutoHotkey Script with GUI for lowSellMode and highSellMode

; Initialize Global Variables
Suspend On
IsSuspended := true
liveMode := false
parabolicMode := false
parabolicX := 1704
parabolicY := 700
liveX := 1504
liveY := 700
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

; Set coordinate mode to screen-relative
CoordMode, Mouse, Screen

; Define the monitor number (e.g., 2 for the second monitor)
monitorNumber := 2

; Retrieve the dimensions of the specified monitor (second monitor)
SysGet, monitorLeft, 76, monitorNumber
SysGet, monitorTop, 77, monitorNumber
SysGet, monitorRight, 78, monitorNumber
SysGet, monitorBottom, 79, monitorNumber


; Calculate the desired coordinates on the second monitor
centerX := monitorLeft + 1100 ; Offset for the desired X-coordinate on the second screen
centerY := monitorTop + 730  ; Offset for the desired Y-coordinate on the second screen

; Function to move the mouse and click at specific coordinates
MoveAndClick(x, y) {
    MouseMove, x, y ; Move the cursor to (x, y)
    Click ; Perform a mouse click at the current position
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
    MoveAndClick(centerX, centerY) ; Move and click at the defined coordinates
    Send, ^q  ; CLX all orders
return

; SPB with 'S'
+^!X::
    if IsSuspended
        return
    global liveMode
    MoveAndClick(centerX, centerY) ; Move and click at the defined coordinates
    Send, % liveMode ? "+q" : "!+q"
return

; SPA with 'C'
+^!C::
    if IsSuspended
        return
    global liveMode
    MoveAndClick(centerX, centerY) ; Move and click at the defined coordinates
    Send, % liveMode ? "+a" : "!+a"
    SoundBeep, 200
return

; S75A with 'V'
+^!V::
    if IsSuspended
        return
    global liveMode
    MoveAndClick(centerX, centerY) ; Move and click at the defined coordinates
    Send, % liveMode ? "+s" : "!+s"
    SoundBeep, 200
return

; BLA with 'E'
+^!E::
    if IsSuspended
        return
    global liveMode, parabolicMode
    MoveAndClick(centerX, centerY) ; Move and click at the defined coordinates
    if parabolicMode {
        Send, % liveMode ? "+3" : "!+3"
    } else {
        Send, % liveMode ? "+1" : "!+1"
    }
    SoundBeep, 500
return

; BHA with 'R'
+^!R::
    if IsSuspended
        return
    global liveMode, parabolicMode
    MoveAndClick(centerX, centerY) ; Move and click at the defined coordinates
    if parabolicMode {
        Send, % liveMode ? "+4" : "!+4"
    } else {
        Send, % liveMode ? "+2" : "!+2"
    }
    SoundBeep, 500
return

UpdateDisplay()  ; Ensure GUI starts in the correct color state