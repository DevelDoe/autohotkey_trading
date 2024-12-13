; Configurable delay times for actions
cancelDelay := 1005
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; Modes
parabolicMode := false  ; Default to Breakout Mode
scalpingMode := false  ; Default to Breakout Mode
currentMode := "Breakout" ; Track the current mode

; Counters
global XButton2_PressCount := 0
global sell_PressCount := 0

; Initialize GUI for displaying counters and states
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vScriptState w200, Suspended
Gui, Add, Text, cWhite vXButton2Text w200, X: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, S: %sell_PressCount%
Gui, Add, Text, cWhite vModeText w200, Mode: Breakout
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
        action := (Mod(XButton2_PressCount, 2) = 0) ? "^!h" : "^!s"
    } else if (parabolicMode) {
        if (XButton2_PressCount = 0) {
            action := "+!h"
        } else if (XButton2_PressCount = 1) {
            action := "^!s"
        } else {
            action := "+!g"
        }
    } else {
        action := (XButton2_PressCount = 0) ? "^!h" : "^!f"
    }

    Send, %action%
    Sleep, DelayAfterClick
    XButton2_PressCount++
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

