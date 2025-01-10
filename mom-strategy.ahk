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

; GUI 1: Low Sell Mode
Gui, 1: Font, s8 Bold cWhite, Arial 
Gui, 1: +AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, 1: Add, Text, x0 y5 w25 h25 Center vLowBox, L
Gui, 1: Show, NoActivate x1600 y700 w25 h25, Low Sell Mode

; GUI 2: High Sell Mode
Gui, 2: Font, s8 Bold cWhite, Arial  
Gui, 2: +AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, 2: Add, Text, x0 y5 w25 h25 Center vHighBox, H
Gui, 2: Show, NoActivate x1652 y700 w25 h25, High Sell Mode


UpdateDisplay() {
    global lowSellMode, highSellMode, parabolicMode, IsSuspended

    ; Determine font and background colors
    if (IsSuspended) {
        lowSellFontColor := "Gray"
        highSellFontColor := "Gray"
        lowSellBgColor := "Gray"
        highSellBgColor := "Gray"
    } else {
        lowSellFontColor := (parabolicMode ? "Blue" : "White")
        highSellFontColor := (parabolicMode ? "Blue" : "White")
        lowSellBgColor := (lowSellMode ? "Red" : "Green")
        highSellBgColor := (highSellMode ? "Red" : "Green")
    }

    ; Recreate Low Sell Mode GUI
    Gui, 1: Destroy
    Gui, 1: +AlwaysOnTop +ToolWindow -Caption
    Gui, 1: Font, s8 Bold c%lowSellFontColor%, Arial
    Gui, 1: Add, Text, x0 y5 w25 h25 Center vLowBox, L
    Gui, 1: Color, %lowSellBgColor%
    Gui, 1: Show, NoActivate x1600 y700 w25 h25, Low Sell Mode

    ; Recreate High Sell Mode GUI
    Gui, 2: Destroy
    Gui, 2: +AlwaysOnTop +ToolWindow -Caption
    Gui, 2: Font, s8 Bold c%highSellFontColor%, Arial
    Gui, 2: Add, Text, x0 y5 w25 h25 Center vHighBox, H
    Gui, 2: Color, %highSellBgColor%
    Gui, 2: Show, NoActivate x1652 y700 w25 h25, High Sell Mode
}



; Allow dragging for both GUIs
OnMessage(0x201, "StartDrag") ; WM_LBUTTONDOWN message for drag handling

StartDrag(wParam, lParam, msg, hwnd) {
    if (WinActive("Low Sell Mode")) { ; Check if GUI 1 is active
        Gui, 1:+LastFound
        PostMessage, 0xA1, 2  ; WM_NCLBUTTONDOWN message for dragging
    } else if (WinActive("High Sell Mode")) { ; Check if GUI 2 is active
        Gui, 2:+LastFound
        PostMessage, 0xA1, 2  ; WM_NCLBUTTONDOWN message for dragging
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