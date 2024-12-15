; Configurable delay times for actions
cancelDelay := 1005
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; Modes
parabolicMode := false  ; Default to Parabolic Mode (off)
scalpingMode := true    ; Default to Scalping Mode
starterMode := false    ; Default to Starter Mode (off)
scaleMode := false      ; Default to Scale Mode (off)
currentMode := "Scalping" ; Track the current mode

; Counters
global XButton2_PressCount := 0
global sell_PressCount := 0

; Reset function to restore the script to its initial state
ResetScript() {
    global XButton2_PressCount, sell_PressCount

    ; Reset counters
    XButton2_PressCount := 0
    sell_PressCount := 0

    ; Double beep to indicate reset
    SoundBeep, 700, 150  ; First beep
    Sleep, 100           ; Short delay between beeps
    SoundBeep, 700, 150  ; Second beep

    ; Call UpdateDisplay safely
    UpdateDisplay()
}

; Initialize GUI for displaying counters and states
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vScriptState w200, Suspended
Gui, Add, Text, cWhite vXButton2Text w200, X: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, S: %sell_PressCount%
Gui, Add, Text, cWhite vModeText w200, Mode: %currentMode%
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Show, NoActivate x1900 y1360 AutoSize, Press Count Display

; Ensure GUI displays the initial state
UpdateDisplay()

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
    global scalpingMode, parabolicMode, starterMode, scaleMode, currentMode, XButton2_PressCount, sell_PressCount

    if (starterMode) {
        ; Starter Mode Logic
        if (XButton2_PressCount = 0) {
            Send, ^!g                                 ; Buy Low ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!n                                 ; Buy Trip ask .5
        } else if (XButton2_PressCount = 2) {
            Send, ^!m                                 ; Sell Half
        } else if (XButton2_PressCount = 3) {
            Send, ^!j                                 ; Sell 75%
            ; Transition to Scale Mode
            starterMode := false                      ; Deactivate Starter Mode
            scaleMode := true                         ; Activate Scale Mode
            currentMode := "Scale"                    ; Set current mode to Scale
            XButton2_PressCount := -1                 ; Reset press count
        }
        XButton2_PressCount++
    } else if (currentMode = "Scale") {
        ; Recursive scaling logic for Starter Scale Mode
        if (XButton2_PressCount = 0) {
            Send, ^!b    ; Step 1: Buy Smaller
        } else if (XButton2_PressCount = 1) {
            Send, ^!b    ; Step 2: Buy Smaller
        } else if (XButton2_PressCount = 2) {
            Send, ^!m    ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, +!q    ; Sell All
        }
        
        ; Increment after action is completed
        XButton2_PressCount++

        ; Reset after completing the full cycle
        if (XButton2_PressCount > 3) {
            XButton2_PressCount := 0  ; Reset count for the next cycle
        }
    } else if (scalpingMode) {
        ; Scalping Mode Logic
        action := (XButton2_PressCount = 0) ? "^!h"         ; Buy High ask .05
                : (XButton2_PressCount = 1) ? "^!s"         ; Sell High ask -.01
                : (Mod(XButton2_PressCount, 2) = 0) ? "^!g" ; Buy Low ask .05
                : "^!f"                                     ; Sell Low ask -.01
        Send, %action%
        XButton2_PressCount++
        sell_PressCount := 0
    } else if (parabolicMode) {
        ; Recursive two-click strategy for Parabolic Mode
        if (XButton2_PressCount = 0) {
            Send, +!g    ; Step 1: Buy low ask 0.15
        } else if (XButton2_PressCount = 1) {
            Send, ^!f    ; Step 2: Sell low ask -.01
        }
    
        ; Increment after action is completed
        XButton2_PressCount++
    
        ; Reset after completing the cycle
        if (XButton2_PressCount > 1) {
            XButton2_PressCount := 0  ; Reset count for the next cycle
        }
    }    

    ; Update GUI display
    UpdateDisplay()
return



; Toggle Scalping Mode
V::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global starterMode, scalpingMode, parabolicMode, currentMode
    scalpingMode := true
    starterMode := false
    parabolicMode := false
    currentMode := "Scalping"
    ResetScript()
    UpdateDisplay()
return

; Toggle Starter Mode
G::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global starterMode, scalpingMode, parabolicMode, currentMode
    starterMode := true
    scalpingMode := false
    parabolicMode := false
    currentMode := "Starter"
    ResetScript()
    UpdateDisplay()
return

; Toggle Parabolic Mode
T::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global parabolicMode, scalpingMode, starterMode, currentMode
    parabolicMode := true
    scalpingMode := false
    starterMode := false
    currentMode := "Parabolic"
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

; Toggle Suspend with Tab
Tab::
    global IsSuspended
    Suspend, Toggle                        ; Toggle suspension state
    if !IsSuspended {                      ; If the script is active (not suspended)
        ; Reset modes to Scalping (default)
        starterMode := false
        parabolicMode := false
        scalpingMode := true               ; Ensure scalping is the default mode
        currentMode := "Scalping"          ; Update current mode to Scalping
        ResetScript()                      ; Reset the script to its initial state
    }
    IsSuspended := !IsSuspended            ; Flip the suspension flag
    UpdateDisplay()                        ; Update the GUI to reflect the new state
    SoundBeep, % (IsSuspended ? 300 : 600) ; Low pitch for Suspended, high pitch for Active
return