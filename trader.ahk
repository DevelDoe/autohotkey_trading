; ^!y ; Buy Tiny ask .05
; ^!b ; Buy Small ask .05
; ^!g ; Buy Low ask .05
; ^!h ; Buy High ask .05
; ^!n ; Buy Trip ask .5

; +!y ; Buy Tiny ask .15
; ^!l ; Buy Small ask .15
; +!g ; Buy Low ask .15
; +!h ; Buy Hight ask .15
; ^!i ; Buy Trip ask .15

; ^!k ; Sell tiny  ask -.01
; ^!u ; Sell Small ask -.01
; ^!f ; Sell Low ask -.01
; ^!s ; Sell High ask .01
; ^!m ; Sell 75%
; ^!j ; Sell Half
; +!q ; Sell all

Suspend On
IsSuspended := true

parabolicMode := false
starterMode := false
beggerMode := true
scaleMode := false

buyTinyMode := false
buySmallMode := false
currentMode := "Begger"

global XButton2_PressCount := 0
global sell_PressCount := 0

Gui, Font, s10 Bold cBlack, Arial
Gui, Color, Gray
Gui, Add, Text, vXButton2Text w200, %XButton2_PressCount%
Gui, Add, Text, vModeText w200, Mode: %currentMode%
Gui, Add, Text, vTinyModeText w200, Tiny: BUY  ; Default value
Gui, Add, Text, vSmallModeText w200, Small: BUY  ; Default value
Gui, +AlwaysOnTop + ToolWindow - Caption
Gui, Show, NoActivate x1660 y700 w130 h130, Press Count Display


UpdateDisplay() {
    global currentMode, parabolicMode, XButton2_PressCount, sell_PressCount, buyTinyMode, buySmallMode, IsSuspended

    ; Update GUI values
    GuiControl,, XButton2Text, % "" . XButton2_PressCount
    GuiControl,, ModeText, % currentMode . (parabolicMode ? " (Parabolic)" : "")

    ; Update TinyModeText and SmallModeText values
    GuiControl,, TinyModeText, % "Tiny: " . (buyTinyMode ? "SELL" : "BUY")
    GuiControl,, SmallModeText, % "Small: " . (buySmallMode ? "SELL" : "BUY")

    ; Change GUI background color based on mode
    if (currentMode = "Begger") {
        Gui, Color, Yellow
    } else if (currentMode = "Starter") {
        Gui, Color, White
    } else if (currentMode = "Scale") {
        Gui, Color, Lime
    } else {
        Gui, Color, Gray  ; Default for unexpected modes
    }

    ; Override with fuchsia if in parabolicMode
    if (parabolicMode) {
        Gui, Color, Red
    }
    if (IsSuspended) {
        Gui, Color, Gray
    }
}



SwitchToMode(modeToKeep) {
    global beggerMode, starterMode, parabolicMode, scaleMode, buyTinyMode, buySmallMode, currentMode
    beggerMode := false
    starterMode := false
    scaleMode := false
    buyTinyMode := false
    buySmallMode := false

    if (modeToKeep = "Begger") {
        beggerMode := true
        currentMode := "Begger"
    } else if (modeToKeep = "Starter") {
        starterMode := true
        currentMode := "Starter"
    } else if (modeToKeep = "Scale") {
        scaleMode := true
        currentMode := "Scale"
    }
}

; Reset script to initial state
ResetScript() {
    global XButton2_PressCount, sell_PressCount
    parabolicMode := false
    starterMode := false
    beggerMode := true
    scaleMode := false

    buyTinyMode := false
    buySmallMode := false
    currentMode := "Begger"

    global XButton2_PressCount := 0
    global sell_PressCount := 0
    SoundBeep, 700, 150
    Sleep, 100
    SoundBeep, 700, 150
    UpdateDisplay()
}

; Toggle Suspend with Tab
Tab::
    global IsSuspended
    Suspend, Toggle                        ; Toggle suspension state
    if !IsSuspended {                      ; If the script is active (not suspended)
        ResetScript()                      ; Reset the script to its initial state
    }
    IsSuspended := !IsSuspended            ; Flip the suspension flag
    UpdateDisplay()                        ; Update the GUI to reflect the new state
    SoundBeep, % (IsSuspended ? 300 : 600) ; Low pitch for Suspended, high pitch for Active
return

XButton2::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global parabolicMode, starterMode, beggerMode, scaleMode, currentMode, XButton2_PressCount, sell_PressCount

    ; Handle Beginner Mode Logic
    if (beggerMode) {
        if (XButton2_PressCount = 0) {
            if(parabolicMode) {
                send, ^!l  ; Buy Small ask 0.15
            } else {
                Send, ^!b  ; Buy Small ask .05
            }
        } else if (XButton2_PressCount = 1) {
            if(parabolicMode) {
                Send, +!h ; Buy Hight ask .15
            } else {
                Send, ^!h ; Buy High ask .05
            }
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, +!q ; Sell all
            SwitchToMode("Scale")
            XButton2_PressCount := 0
        }
        if (beggerMode) {
            XButton2_PressCount++
        }
    }

    ; Handle Starter Mode Logic
    else if (starterMode) {
        if (XButton2_PressCount = 0) {
            if(parabolicMode) {
                send, +!g   ; Buy Low ask .15
            } else {
                Send, ^!g   ; Buy Low ask .05
            }
        } else if (XButton2_PressCount = 1) {
            if(parabolicMode) {
                send, ^!i   ; Buy Trip ask .15
            } else {
                Send, ^!n   ; Buy Trip ask .5
            }
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, ^!j  ; Sell Half
            SwitchToMode("Scale")
            XButton2_PressCount := 0
        }
        if (starterMode) {
            XButton2_PressCount++
        }
    }
    else if (scaleMode) {
        if (XButton2_PressCount = 0) {
            if(parabolicMode) {
                send, +!y   ; Buy Tiny ask .15
            } else {
                Send, ^!y   ; Buy Tiny ask .05
            }
        } else if (XButton2_PressCount = 1) {
            if(parabolicMode) {
                send, +!g   ; Buy Low ask .15
            } else {
                Send, ^!g   ; Buy Low ask .05
            }
        } else if (XButton2_PressCount = 2) {
            Send, ^ !m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, +!q  ; Sell all
        }
        XButton2_PressCount++
        if (XButton2_PressCount > 3) {
            XButton2_PressCount := 0
        }
    }

    UpdateDisplay()
return

G::
    if IsSuspended {
        return
    }
    global currentMode

    XButton2_PressCount := 0

    ; Toggle between beggerMode and starterMode
    if (currentMode = "Begger") {
        SwitchToMode("Starter")
    } else {
        SwitchToMode("Begger")
    }

    UpdateDisplay()
return

T::
    if IsSuspended {
        return
    }
    global parabolicMode

    ; Toggle parabolicMode
    if (parabolicMode) {
        parabolicMode := false
    } else {
        parabolicMode := true
    }

    UpdateDisplay()
return

; Cancel orders and reset press counts
A::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    Send, ^!c
    ResetScript()
    UpdateDisplay()
return

; SELL LOW ASK
S::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    Send, +!q
    ResetScript()
    UpdateDisplay()
return

D::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global buyTinyMode, parabolicMode

    if (buyTinyMode) {
        Send, ^!k  ; Sell Tiny ask -.01
        buyTinyMode := false
    } else {
        if (parabolicMode) {
            Send, +!y  ; Buy Tiny ask .15 (parabolic mode)
        } else {
            Send, ^!y  ; Buy Tiny ask .05 (normal mode)
        }
        buyTinyMode := true
    }

    UpdateDisplay()
return

F::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global buySmallMode, parabolicMode

    ; Toggle between Buy and Sell Tiny
    if (buySmallMode) {
        Send, ^!u  ; Sell Small ask -.01
        buySmallMode := false
    } else {
        if(parabolicMode) {
            send, ^!l  ; Buy Small ask 0.15
        } else {
            Send, ^!b  ; Buy Small ask .05
        }
        buySmallMode := true
    }

    UpdateDisplay()
return