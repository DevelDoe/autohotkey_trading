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

liveMode := false
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
liveX := 1504
liveY := 700

; Initialize Low Sell Mode GUI
Gui, 1: +AlwaysOnTop +ToolWindow -Caption
Gui, 1: Font, s10  cWhite, Segoe UI
Gui, 1: Add, Text, x0 y0 w20 h20 Center vLowBox, L
Gui, 1: Show, NoActivate x%lowSellX% y%lowSellY% w20 h20, Low Sell Mode

; Initialize High Sell Mode GUI
Gui, 2: +AlwaysOnTop +ToolWindow -Caption
Gui, 2: Font, s10  cWhite, Segoe UI
Gui, 2: Add, Text, x0 y0 w20 h20 Center vHighBox, H
Gui, 2: Show, NoActivate x%highSellX% y%highSellY% w20 h20, High Sell Mode

; Initialize Parabolic Mode GUI
Gui, 3: +AlwaysOnTop +ToolWindow -Caption
Gui, 3: Show, NoActivate x%parabolicX% y%parabolicY% w20 h20, Parabolic Mode
Gui, 3: Color, Black

; Initialize live Mode GUI
Gui, 4: +AlwaysOnTop +ToolWindow -Caption
Gui, 4: Show, NoActivate x%liveX% y%liveY% w20 h20, Live Mode
Gui, 4: Color, Gray

UpdateDisplay() {
    global lowSellMode, highSellMode, parabolicMode, IsSuspended, parabolicX, parabolicY, liveX, liveY, liveMode

    ; Determine font and background colors
    if (IsSuspended) {
        lowSellFontColor := "Gray"
        highSellFontColor := "Gray"
        parabolicBgColor := "Gray"
        lowSellBgColor := "Gray"
        highSellBgColor := "Gray"
        liveBgColor := "Gray"
    } else {
        lowSellFontColor := "White"
        highSellFontColor := "White"
        parabolicBgColor := (parabolicMode ? "Red" : "Black")
        lowSellBgColor := (lowSellMode ? "Yellow" : "Green")
        highSellBgColor := (highSellMode ? "Yellow" : "Green")
        liveBgColor := (liveMode ? "FF00FF" : "00FFFF")
    }

    ; Update Low Sell Mode GUI
    Gui, 1: Font, s8 Bold c%lowSellFontColor%, Arial
    Gui, 1: Color, %lowSellBgColor%

    ; Update High Sell Mode GUI
    Gui, 2: Font, s8 Bold c%highSellFontColor%, Arial
    Gui, 2: Color, %highSellBgColor%

    ; Update Parabolic Mode GUI
    Gui, 3: Color, %parabolicBgColor%

    ; Update live Mode GUI
    Gui, 4: Color, %liveBgColor%
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
    } else if (WinActive("Live Mode")) {
        Gui, 4:+LastFound
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
    } else if (WinActive("Live Mode")) {
        WinGetPos, liveX, liveY,,, A
    }
}

; Reset script to initial state
ResetScript() {
    global parabolicMode, lowSellMode, highSellMode ,liveMode
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

tPressCount := 0
; Hotkey for the T key
$*t::
    if IsSuspended {
        return
    }
    global tPressCount
    tPressCount++
    if (tPressCount = 1) {
        ; Set a timer to check for double-tap within 300 milliseconds
        SetTimer, CheckDoubleTap, -300
    }
return

CheckDoubleTap:
    global tPressCount, liveMode
    if (tPressCount = 2) {
        ; Double-tap detected, toggle liveMode
        liveMode := !liveMode
        SoundBeep, % (liveMode ? 900 : 300)
        UpdateDisplay()
    }
    ; Reset the press count after checking
    tPressCount := 0
return

; Cancel All Orders
A::
    if IsSuspended {
        return
    }
    Send, ^q  ; CLX all orders
    ResetScript()
    UpdateDisplay()
return

; SPB
S::
    if IsSuspended {
        return
    }
    global liveMode
    if (liveMode) {
        Send, +q
    } else {
        Send, !+q
    }
    ResetScript()
    UpdateDisplay()
return

; SPA
C::
    if IsSuspended {
        return
    }
    global liveMode
    if (liveMode) {
        Send, +a  ; SLA 0
    } else {
        Send, !+a  ; SLA 0 with Alt modifier
    }
    SoundBeep, 200
return

; S75A
V::
    if IsSuspended {
        return
    }
    global liveMode
    if (liveMode) {
        Send, +s  ; SHA 0
    } else {
        Send, !+s  ; SHA 0 with Alt modifier
    }
    SoundBeep, 200
return

; BLA
D::
    if IsSuspended {
        return
    }
    global liveMode, parabolicMode
    if (parabolicMode) {
        if (liveMode) {
            Send, +^1
        } else {
            Send, !+^1
        }
    } else {
        if (liveMode) {
            Send, +1
        } else {
            Send, !+1
        }
    }
    SoundBeep, 500
return

; BHA
F::
    if IsSuspended {
        return
    }
    global liveMode, parabolicMode
    if (parabolicMode) {
        if (liveMode) {
            Send, +^2  ; BHA .15 (parabolic mode)
        } else {
            Send, !+^2  ; BHA .15 with Alt modifier (parabolic mode)
        }
    } else {
        if (liveMode) {
            Send, +2  ; BHA .05
        } else {
            Send, !+2  ; BHA .05 with Alt modifier
        }
    }
    SoundBeep, 500
return

; Low Auto Action Key
E::
    if IsSuspended {
        return
    }
    global liveMode, lowSellMode, parabolicMode
    if (lowSellMode) {
        if (liveMode) {
            Send, +a  ; SLA 0
        } else {
            Send, !+a  ; SLA 0 with Alt modifier
        }
        lowSellMode := false
    } else {
        if (parabolicMode) {
            if (liveMode) {
                Send, +^1  ; BLA .15 (parabolic mode)
            } else {
                Send, !+^1  ; BLA .15 with Alt modifier (parabolic mode)
            }
        } else {
            if (liveMode) {
                Send, +1  ; BLA .05
            } else {
                Send, !+1  ; BLA .05 with Alt modifier
            }
        }
        lowSellMode := true
    }
    SoundBeep, % (lowSellMode ? 500 : 200)
    UpdateDisplay()
return

; High Auto Action Key
R::
    if IsSuspended {
        return
    }
    global liveMode, highSellMode, parabolicMode
    if (highSellMode) {
        if (liveMode) {
            Send, +a  ; SLA 0
        } else {
            Send, !+a  ; SLA 0 with Alt modifier
        }
        highSellMode := false
    } else {
        if (parabolicMode) {
            if (liveMode) {
                Send, +^2  ; BHA .15 (parabolic mode)
            } else {
                Send, !+^2  ; BHA .15 with Alt modifier (parabolic mode)
            }
        } else {
            if (liveMode) {
                Send, +2  ; BHA .05
            } else {
                Send, !+2  ; BHA .05 with Alt modifier
            }
        }
        highSellMode := true
    }
    SoundBeep, % (highSellMode ? 500 : 200)
    UpdateDisplay()
return
