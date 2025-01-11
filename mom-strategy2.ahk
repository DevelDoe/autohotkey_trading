; AutoHotkey Script with GUI for lowSellMode and highSellMode

; shift: +
; Ctrl: ^
; Alt: !

; +1 ; BLA .05
; +2 ; BHA .05

; +^1 ; BLA .15 (parabolic mode)
; +^2 ; BHA .15 (parabolic mode)

; +a ; SLA 0
; +s ; SHA 0

; +q ; Sell pos
; +w ; Sell 75%
; +e ; Sell Half

; ^!q ; CLX all orders

Suspend On
IsSuspended := true

parabolicMode := false
lowSellMode := false
highSellMode := false

; Variables to store GUI positions
lowSellX := 1600
lowSellY := 700
highSellX := 1652
highSellY := 700
parabolicX := 1704
parabolicY := 700

; Initialize Low Sell Mode GUI
Gui, 1: +AlwaysOnTop +ToolWindow -Caption
Gui, 1: Font, s8  cWhite, Segoe UI
Gui, 1: Add, Text, x0 y5 w25 h25 Center vLowBox, L
Gui, 1: Show, NoActivate x%lowSellX% y%lowSellY% w40 h40, Low Sell Mode

; Initialize High Sell Mode GUI
Gui, 2: +AlwaysOnTop +ToolWindow -Caption
Gui, 2: Font, s8  cWhite, Segoe UI
Gui, 2: Add, Text, x0 y5 w25 h25 Center vHighBox, H
Gui, 2: Show, NoActivate x%highSellX% y%highSellY% w40 h40, High Sell Mode

; Initialize Parabolic Mode GUI
Gui, 3: +AlwaysOnTop +ToolWindow -Caption
; Gui, 3: Font, s5 Bold cWhite, Arial
; Gui, 3: Add, Text, x0 y3 w25 h15 Center vParabolicBox, P
Gui, 3: Show, NoActivate x%parabolicX% y%parabolicY% w40 h15, Parabolic Mode
Gui, 3: Color, Black ; Initial color is black for !parabolicMode

UpdateDisplay() {
    global lowSellMode, highSellMode, parabolicMode, IsSuspended
    global parabolicX, parabolicY

    ; Determine font and background colors
    if (IsSuspended) {
        lowSellFontColor := "Gray"
        highSellFontColor := "Gray"
        parabolicBgColor := "Gray"
        lowSellBgColor := "Gray"
        highSellBgColor := "Gray"
    } else {
        lowSellFontColor := "White"
        highSellFontColor := "White"
        parabolicBgColor := (parabolicMode ? "Red" : "Black")
        lowSellBgColor := (lowSellMode ? "Yellow" : "Green")
        highSellBgColor := (highSellMode ? "Yellow" : "Green")
    }

    ; Update Low Sell Mode GUI
    Gui, 1: Font, s8 Bold c%lowSellFontColor%, Arial
    Gui, 1: Color, %lowSellBgColor%

    ; Update High Sell Mode GUI
    Gui, 2: Font, s8 Bold c%highSellFontColor%, Arial
    Gui, 2: Color, %highSellBgColor%

    ; Update Parabolic Mode GUI
    Gui, 3: Color, %parabolicBgColor%
}

; Allow dragging for all GUIs
OnMessage(0x201, "StartDrag") ; WM_LBUTTONDOWN for drag handling
OnMessage(0x202, "EndDrag") ; WM_LBUTTONUP for drag ending

StartDrag(wParam, lParam, msg, hwnd) {
    if (WinActive("Low Sell Mode")) {
        Gui, 1:+LastFound
        PostMessage, 0xA1, 2 ; Start dragging
    } else if (WinActive("High Sell Mode")) {
        Gui, 2:+LastFound
        PostMessage, 0xA1, 2 ; Start dragging
    } else if (WinActive("Parabolic Mode")) {
        Gui, 3:+LastFound
        PostMessage, 0xA1, 2 ; Start dragging
    }
}

EndDrag(wParam, lParam, msg, hwnd) {
    global lowSellX, lowSellY, highSellX, highSellY, parabolicX, parabolicY

    ; Save new positions
    if (WinActive("Low Sell Mode")) {
        WinGetPos, lowSellX, lowSellY,,, A
    } else if (WinActive("High Sell Mode")) {
        WinGetPos, highSellX, highSellY,,, A
    } else if (WinActive("Parabolic Mode")) {
        WinGetPos, parabolicX, parabolicY,,, A
    }
}


; Reset script to initial state
ResetScript() {
    global parabolicMode, lowSellMode, highSellMode
    parabolicMode := false
    lowSellMode := false
    highSellMode := false
    SoundBeep, 700, 150
    Sleep, 50
    SoundBeep, 700, 150
    UpdateDisplay()
}


; Toggle Suspend with Tab
+^!S::
    global IsSuspended
    Suspend, Toggle
    IsSuspended := !IsSuspended
    if IsSuspended {
        ResetScript()
    }
    SoundBeep, % (IsSuspended ? 200 : 600) ; Low pitch for Suspended, high pitch for Active
    UpdateDisplay()
return

; Parabolic Mode Toggle
G::
    if IsSuspended {
        return
    }
    global parabolicMode
    parabolicMode := !parabolicMode
    SoundBeep, % (parabolicMode ? 900 : 300)
    UpdateDisplay()
return

; Cancel All Orders
A::
    if IsSuspended {
        return
    }
    Send, ^!q ; CLX all orders
    ResetScript()
    UpdateDisplay()
return

; Sell Position
S::
    if IsSuspended {
        return
    }
    Send, +q ; Sell pos
    ResetScript()
    UpdateDisplay()
return

; Sell Low Action
C::
    if IsSuspended {
        return
    }
    Send, +a ; SLA 0
    SoundBeep, 200
return

; Sell High Action
V::
    if IsSuspended {
        return
    }
    Send, +s ; SHA 0
    SoundBeep, 200
return

; Buy Low Action
E::
    if IsSuspended {
        return
    }
    global parabolicMode

    if (parabolicMode) {
        Send, +^1 ; BLA .15 (parabolic mode)
    } else {
        Send, +1 ; BLA .05
    }
    SoundBeep, 500
return

; Buy High Action
R::
    if IsSuspended {
        return
    }
    global parabolicMode

    if (parabolicMode) {
        Send, +^2 ; BHA .15 (parabolic mode)
    } else {
        Send, +2 ; BHA .05
    }
    SoundBeep, 500
return

; Low Action Key
D::
    if IsSuspended {
        return
    }
    global lowSellMode, parabolicMode

    if (lowSellMode) {
        Send, +a ; SLA 0
        lowSellMode := false
    } else {
        if (parabolicMode) {
            Send, +^1 ; BLA .15 (parabolic mode)
        } else {
            Send, +1 ; BLA .05
        }
        lowSellMode := true
    }
    SoundBeep, % (lowSellMode ? 500  : 200)
    UpdateDisplay()
return

; High Action Key
F::
    if IsSuspended {
        return
    }
    global highSellMode, parabolicMode

    if (highSellMode) {
        Send, +s ; SHA 0
        highSellMode := false
    } else {
        if (parabolicMode) {
            Send, +^2 ; BHA .15 (parabolic mode)
        } else {
            Send, +2 ; BHA .05
        }
        highSellMode := true
    }
    SoundBeep, % (highSellMode ? 500  : 200)
    UpdateDisplay()
return
