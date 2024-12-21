; ^!y ; Buy Tiny ask .05
; ^!b ; Buy Small ask .05
; ^!g ; Buy Low ask .05
; ^!h ; Buy High ask .05
; ^!n ; Buy Trip ask .5

; ^!l ; Buy Small ask 0.15
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

; Default states
Suspend On
IsSuspended := true   ; Match the starting state
parabolicMode := false ; offsets are increased to adjust for parabolic movement
starterMode := false ;

; Begger Mode - Slower-paced trades with room for scaling in and out.
; Allows more time to assess the trade and manage positions.
; Suitable for slightly wider spreads or slower-moving stocks.
; Offers flexibility to scale in with small positions before committing more capital.
; Cons:
; Might miss rapid moves in fast markets.
; Requires clear support/resistance levels for effective scaling.
; When to Use:
; If you’re cautious or less confident about the setup.
; If the market conditions are less volatile or more uncertain.
begMode := false ; Slower-paced trades with room for scaling in and out.
scaleMode := false
paraScaleMode := false

; Scalping Mode - Quick trades with tight spreads and minimal risk.
; Designed for rapid entry and exit.
; Limits exposure to market volatility.
; Can quickly capture small profits multiple times.
; Cons: Can be challenging in markets with high slippage or low liquidity.
; When to Use:
; If you’re confident about a setup with tight spreads and clear momentum.
; If the market conditions support quick scalps (e.g., high liquidity, low volatility).
scalpingMode:= true ; Quick trades with tight spreads and minimal risk.
currentMode := "Scalping"

; Counters
global XButton2_PressCount := 0
global sell_PressCount := 0

; GUI setup
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vScriptState w200, Suspended
Gui, Add, Text, cWhite vXButton2Text w200, X: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, S: %sell_PressCount%
Gui, Add, Text, cWhite vModeText w200, Mode: %currentMode%
Gui, Add, Text, cWhite vModeValues w200, Mode: %currentMode%
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Show, NoActivate x1660 y900 w130 h130, Press Count Display
; Gui, Show, NoActivate x1900 y1360 AutoSize, Press Count Display
; Gui, Show, NoActivate x1700 y1060 w400 h300, Press Count Display

; Update GUI display
; Update GUI display with detailed mode debugging
UpdateDisplay() {
    global XButton2_PressCount, sell_PressCount, IsSuspended, currentMode, parabolicMode, scalpingMode, starterMode, begMode, scaleMode, paraScaleMode

    ; Update ScriptState, XButton2Text, and SellPressText
    GuiControl,, ScriptState, % (IsSuspended ? "Suspended" : "Active")
    GuiControl,, XButton2Text, % "X: " . XButton2_PressCount
    GuiControl,, SellPressText, % "S: " . sell_PressCount

    ; Set color dynamically for ModeText
    if (currentMode = "Parabolic") {
        Gui, Font, cFuchsia
    } else if (currentMode = "Para Scale") {
        Gui, Font, cGreen
    } else if (currentMode = "Starter") {
        Gui, Font, cWhite
    } else if (currentMode = "Scale") {
        Gui, Font, cLime
    } else if (currentMode = "Begger") {
        Gui, Font, cRed
    } else if (currentMode = "Scalping") {
        Gui, Font, cYellow
    }
    GuiControl, Font, ModeText   ; Apply the font settings
    GuiControl,, ModeText, % "Mode: " . currentMode

    ; Debug All Modes: Ensure all modes are displayed clearly
    ; GuiControl,, ModeValues, % "Begger: " . (begMode ? "True" : "False")
    ;     . " | Starter: " . (starterMode ? "True" : "False")
    ;     . " | Parabolic: " . (parabolicMode ? "True" : "False")
    ;     . " | Scalping: " . (scalpingMode ? "True" : "False")
    ;     . " | Scale: " . (scaleMode ? "True" : "False")
    ;     . " | ParaScale: " . (paraScaleMode ? "True" : "False")
}

XButton2::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global scalpingMode, parabolicMode, starterMode, begMode, scaleMode, paraScaleMode, currentMode, XButton2_PressCount, sell_PressCount

    ; Handle Beginner Mode Logic
    if (begMode and !scaleMode) {
        if (XButton2_PressCount = 0) {
            Send, ^!b ; Buy Small ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!g  ; Buy Low ask .05 (again)
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, ^!j  ; Sell Half
            ; Transition to Scalping Mode
            ScaleMode := true
            currentMode := "Scale"
            XButton2_PressCount := 0
        }
        if (!scaleMode) {  ; Increment only if not transitioning
            XButton2_PressCount++
        }
    }

    ; Handle Starter Mode Logic
    else if (starterMode and !scaleMode) {
        if (XButton2_PressCount = 0) {
            Send, ^!g  ; Buy Low ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!n  ; Buy Trip ask .5
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, ^!j  ; Sell Half
            ; Transition to Starter Scale Mode
            scaleMode := true
            currentMode := "Scale"
            XButton2_PressCount := 0
        }
        if (!scaleMode) {  ; Increment only if not transitioning
            XButton2_PressCount++
        }
    }

    ; Handle Scaling Modes (Begger Scale, Starter Scale)
    else if ((begMode or starterMode) and scaleMode) {
        ; Begger Scale logic
        if (XButton2_PressCount = 0) {
            Send, ^!y  ; Buy Tiny ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!b  ; Buy Small ask .05
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, +!q  ; Sell all
        }
        XButton2_PressCount := (XButton2_PressCount + 1) > 3 ? 0 : XButton2_PressCount + 1
    }

    ; Handle Para Scale
    else if (parabolicMode and paraScaleMode) {
        if (XButton2_PressCount = 0) {
            Send, ^!l  ; Buy Small ask .15
        } else if (XButton2_PressCount = 1) {
            Send, ^!l  ; Buy Small ask .15
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, +!q  ; Sell all
        }
        XButton2_PressCount := (XButton2_PressCount + 1) > 3 ? 0 : XButton2_PressCount + 1
    }

    ; Handle Parabolic Mode (when ParaScale is not active)
    else if (parabolicMode and !paraScaleMode) {
        if (XButton2_PressCount = 0) {
            Send, +!g  ; Buy Low ask .15
        } else if (XButton2_PressCount = 1) {
            Send, +!h  ; Buy Trip ask .15
        } else if (XButton2_PressCount = 2) {
            Send, ^!m  ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, ^!j  ; Sell Half
            paraScaleMode := true
            currentMode := "Para Scale"
            XButton2_PressCount := 0
        }
        if (!paraScaleMode) {  ; Increment only if not transitioning
            XButton2_PressCount++
        }
    }

    else if (scalpingMode) {
        if (XButton2_PressCount = 0) {
            Send, ^!y ; Buy Tiny ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!k ; Sell tiny  ask -.01
        } else if (XButton2_PressCount = 2) {
            Send, ^!b  ; Buy Small ask .05
        } else if (XButton2_PressCount = 3) {
            Send, ^!u  ; Sell Small ask -.01
            ; Transition to Starter Scale Mode
            scalpingMode := false
            begMode := true
            currentMode := "Begger"
            XButton2_PressCount := 0
        }
        if (scalpingMode) {  ; Increment only if not transitioning
            XButton2_PressCount++
        }
    }

    UpdateDisplay()
return

; Toggle Scalping Mode
V::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global parabolicMode, paraScaleMode, starterMode, begMode, scaleMode, currentMode
    scalpingMode := true
    parabolicMode := false
    paraScaleMode := false
    starterMode := false
    begMode := false
    scaleMode := false
    currentMode := "Scalping"
    ResetScript()
    UpdateDisplay()
return

T::
    if IsSuspended {
        return
    }
    global parabolicMode, paraScaleMode, starterMode, begMode, scaleMode, currentMode

    ; If in Para Scale, toggle back to Parabolic
    if (parabolicMode and paraScaleMode) {
        paraScaleMode := false
        currentMode := "Parabolic"
    }
    ; If in Parabolic, toggle to Para Scale
    else if (parabolicMode) {
        paraScaleMode := true
        currentMode := "Para Scale"
    }
    ; Otherwise, activate Parabolic Mode
    else {
        ResetModesExcept("parabolicMode")
        paraScaleMode := false
        currentMode := "Parabolic"
    }

    ResetScript()
    UpdateDisplay()
return

G::
    if IsSuspended {
        return
    }
    global starterMode, scaleMode, begMode, parabolicMode, paraScaleMode, currentMode

    ; If in Starter Scale, go back to Starter
    if (starterMode and scaleMode) {
        scaleMode := false
        currentMode := "Starter"
    }
    ; If not already in Starter, activate Starter (reset others)
    else if (!starterMode) {
        starterMode := true
        scaleMode := false
        begMode := false
        parabolicMode := false
        paraScaleMode := false
        currentMode := "Starter"
    }
    ; If in Starter, toggle to Starter Scale
    else if (starterMode and !scaleMode) {
        scaleMode := true
        currentMode := "Scale"
    } 

    ResetScript()
    UpdateDisplay()
return

B::
    if IsSuspended {
        return
    }
    global begMode, scaleMode, starterMode, parabolicMode, paraScaleMode, currentMode

    ; If in Begger Scale, toggle back to Begger
    if (begMode and scaleMode) {
        scaleMode := false
        currentMode := "Begger"
    }
    ; If in Begger, toggle to Begger Scale
    else if (begMode) {
        ResetModesExcept("begMode")
        scaleMode := true
        currentMode := "Scale"
    }
    ; Otherwise, activate Begger Mode
    else {
        ResetModesExcept("begMode")
        scaleMode := false
        scalpingMode := false
        currentMode := "Begger"
    }

    ResetScript()
    UpdateDisplay()
return

ResetModesExcept(modeToKeep) {
    global begMode, starterMode, parabolicMode, scalpingMode, scaleMode, paraScaleMode

    ; Reset all modes to false
    begMode := false
    starterMode := false
    parabolicMode := false
    scalpingMode := false
    scaleMode := false
    paraScaleMode := false

    ; Activate the specified mode
    %modeToKeep% := true
}

; Cancel orders and reset press counts
A::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    Send, ^!c
    ResetScript()
    UpdateDisplay()
return

; Sell actions
S::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    Send, +!q
    ResetScript()
return

; SELL LOW ASK
D::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global XButton2_PressCount, sell_PressCount
    Send, ^!f
    Sleep, DelayAfterClick
    sell_PressCount++
    XButton2_PressCount := 0
    UpdateDisplay()
return

; SELL HIGH ASK
F::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global XButton2_PressCount, sell_PressCount
    Send, ^!s
    Sleep, DelayAfterClick
    sell_PressCount++
    XButton2_PressCount := 0
    UpdateDisplay()
return

; Reset script to initial state
ResetScript() {
    global XButton2_PressCount, sell_PressCount
    XButton2_PressCount := 0
    sell_PressCount := 0
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
        ; Reset modes
        parabolicMode := false
        scalpingMode := true
        starterMode := false
        begMode := false
        scaleMode := false
        paraScaleMode := false
        currentMode := "Scalping"
        ResetScript()                      ; Reset the script to its initial state
    }
    IsSuspended := !IsSuspended            ; Flip the suspension flag
    UpdateDisplay()                        ; Update the GUI to reflect the new state
    SoundBeep, % (IsSuspended ? 300 : 600) ; Low pitch for Suspended, high pitch for Active
return