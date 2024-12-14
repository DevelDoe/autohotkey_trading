; Configurable delay times for actions
cancelDelay := 1005
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; Modes
parabolicMode := false  ; Default to Breakout Mode
scalpingMode := true    ; Default to Scalping Mode
currentMode := "Scalping" ; Track the current mode

; Counters
global XButton2_PressCount := 0
global sell_PressCount := 0

; Reset function to restore the script to its initial state
ResetScript() {
    global XButton2_PressCount, sell_PressCount
    global parabolicMode, scalpingMode, currentMode

    ; Reset counters
    XButton2_PressCount := 0
    sell_PressCount := 0

    ; Reset modes
    parabolicMode := false
    scalpingMode := true
    currentMode := "Scalping"

    ; Update GUI to reflect the initial state
    UpdateDisplay()

    ; Double beep to indicate reset
    SoundBeep, 700, 150  ; First beep
    Sleep, 100           ; Short delay between beeps
    SoundBeep, 700, 150  ; Second beep
}

; Hotkey to invoke the reset function
R::
    ResetScript()
return

; Initialize GUI for displaying counters and states
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vScriptState w200, Suspended
Gui, Add, Text, cWhite vXButton2Text w200, X: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, S: %sell_PressCount%
Gui, Add, Text, cWhite vModeText w200, Mode: %currentMode%
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Show, NoActivate x1900 y1360 AutoSize, Press Count Display

; Function to update the GUI display
UpdateDisplay() {
    global XButton2_PressCount, sell_PressCount, IsSuspended, currentMode
    GuiControl,, ScriptState, % (IsSuspended ? "Suspended" : "Active")
    GuiControl,, XButton2Text, % "X: " . XButton2_PressCount
    GuiControl,, SellPressText, % "S: " . sell_PressCount
    GuiControl,, ModeText, % "Mode: " . currentMode
}

; XButton2 toggles between Buy/Sell actions
XButton2::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global scalpingMode, parabolicMode, currentMode, XButton2_PressCount, sell_PressCount

    if (scalpingMode) {
        ; Scalping Mode Logic
        action := (XButton2_PressCount = 0) ? "^!h"         ; Buy High ask .05
                : (XButton2_PressCount = 1) ? "^!s"         ; Sell High ask -.01
                : (Mod(XButton2_PressCount, 2) = 0) ? "^!g" ; Buy Low ask .05
                : "^!f"                                     ; Sell Low ask -.01
        Send, %action%
        XButton2_PressCount++
        sell_PressCount := 0
    } else if (parabolicMode) {
        ; Parabolic Mode Logic
        if (XButton2_PressCount = 0) {
            Send, +!h                                       ; Buy High ask 0.15
        } else if (XButton2_PressCount = 1) {
            Send, ^!s                                       ; Sell High ask -.01
            Sleep, orderDelay
            Send, +!g                                       ; Buy Low 0.15
        } else {
            Send, ^!f                                       ; Sell Low ask -.01
            Sleep, orderDelay
            Send, +!g                                       ; Buy Low ask 0.15
        }
        XButton2_PressCount++
        sell_PressCount := 0
    } else {
        ; Breakout Mode Logic
        if (XButton2_PressCount = 0) {
            Send, ^!h                                       ; Buy High ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!s                                       ; Sell High ask -.01
            Sleep, orderDelay
            Send, ^!g                                       ; Buy Low ask .05
        } else {
            Send, ^!f                                       ; Sell Low ask -.01
            Sleep, orderDelay
            Send, ^!g                                       ; Buy Low ask .05
        }
        XButton2_PressCount++
        sell_PressCount := 0
    }

    ; Update GUI display
    UpdateDisplay()
return

; Toggle Parabolic Mode
G::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global parabolicMode, scalpingMode, currentMode
    parabolicMode := !parabolicMode
    scalpingMode := false
    currentMode := parabolicMode ? "Parabolic" : "Breakout"
    UpdateDisplay()
return

; Toggle Scalping Mode
V::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global scalpingMode, parabolicMode, currentMode
    scalpingMode := !scalpingMode
    parabolicMode := false
    currentMode := scalpingMode ? "Scalping" : "Breakout"
    UpdateDisplay()
return

; Cancel orders and reset press counts
A::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global XButton2_PressCount, sell_PressCount
    Send, ^!c
    Sleep, cancelDelay
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdateDisplay()
return

; Sell actions
S::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global XButton2_PressCount, sell_PressCount
    Send, +!q
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdateDisplay()
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

; Toggle Suspend with Tab
Tab::
    global XButton2_PressCount, sell_PressCount, IsSuspended
    Suspend, Toggle
    IsSuspended := !IsSuspended
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdateDisplay()
    SoundBeep, % (IsSuspended ? 300 : 600)  ; Low pitch for Suspended, high pitch for Active
return
