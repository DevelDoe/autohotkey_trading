Suspend On
IsSuspended := true

parabolicMode := false
starterMode := false
beggerMode := true
scaleMode := false
buyTinyMode := false
buySmallMode := false
currentMode := "beggerMode"

global XButton2_PressCount := 0
global sell_PressCount := 0

Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vScriptState w200, Suspended
Gui, Add, Text, cWhite vXButton2Text w200, X: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, S: %sell_PressCount%
Gui, Add, Text, cWhite vModeText w200, Mode: %currentMode%
Gui, Add, Text, cWhite vModeValues w200, Mode: %currentMode%
Gui, +AlwaysOnTop + ToolWindow - Caption
Gui, Show, NoActivate x1660 y700 w130 h130, Press Count Display

UpdateDisplay() {
    global XButton2_PressCount, sell_PressCount, IsSuspended, currentMode, parabolicMode, starterMode, beggerMode, scaleMode, paraScaleMode

    GuiControl, , ScriptState, %(IsSuspended ? "Suspended" : "Active")
    GuiControl, , XButton2Text, %"X: " . XButton2_PressCount
    GuiControl, , SellPressText, %"S: " . sell_PressCount

    if (currentMode = "beggerMode"){
        Gui, Font, cYellow
    } else if (currentMode = "starterMode") {
        Gui, Font, cWhite
    } else if (currentMode = "scaleMode") {
        Gui, Font, cLime
    } else if (currentMode = "parabolicMode") {
        Gui, Font, cFuchsia
    }

    GuiControl, Font, ModeText
    GuiControl,, ModeText, % currentMode

}

ResetModesExcept(modeToKeep) {
    global beggerMode, starterMode, parabolicMode, scaleMode, paraScaleMode

    ; Reset all modes to false
    beggerMode := false
    starterMode := false
    parabolicMode := false
    scaleMode := false
    buyTinyMode := false
    buySmallMode := false

    ; Activate the specified mode
    %modeToKeep% := true
    currentMode := %modeToKeep%
}

; Reset script to initial state
ResetScript() {
    global XButton2_PressCount, sell_PressCount
    XButton2_PressCount := 0
    sell_PressCount := 0
    ResetModesExcept("beggerMode")
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
                Send, +!g  ; Buy Low ask .15
            } else {
                Send, ^!g  ; Buy Low ask .05
            }
        } else if (XButton2_PressCount = 2) {
            Send, ^ !m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, ^ !q  ; Sell Half
            ResetModesExcept("scaleMode")
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
            ResetModesExcept("scaleMode")
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
        XButton2_PressCount := 0
    }

    UpdateDisplay()
return

G::
    if IsSuspended {
        return
    }
    global currentMode

    ; Toggle between beggerMode and starterMode
    if (currentMode = "beggerMode") {
        ResetModesExcept("starterMode")
    } else {
        ResetModesExcept("beggerMode")
    }

    ResetScript()
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

    ResetScript()
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
D::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global XButton2_PressCount, sell_PressCount
    Send, ^!f
    ResetScript()
    UpdateDisplay()
return

D::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global buyTinyMode

    ; Toggle between Buy and Sell Tiny
    if (buyTinyMode) {
        Send, ^!k  ; Sell Tiny ask -.01
        buyTinyMode := false
    } else {
        if(parabolicMode) {
            send, +!y   ; Buy Tiny ask .15
        } else {
            Send, ^!y  ; Buy Tiny ask .05
        }
        Send, ^!y  ; Buy Tiny ask .05
        buyTinyMode := true
    }

    Sleep, DelayAfterClick
    UpdateDisplay()
return

F::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global buyTinyMode

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

    Sleep, DelayAfterClick
    UpdateDisplay()
return