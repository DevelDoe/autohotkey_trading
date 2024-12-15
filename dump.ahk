
; Configurable delay times for actions
DelayAfterClick := 250
DelayAfterFirstEnter := 500
cancelDelay := 1005  ; Delay for canceling orders
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; Initialize variables
parabolicMode := false  ; Default to Normal Mode
global XButton2_PressCount := 0
global sell_PressCount := 0


; Initialize GUI for displaying XButton2_PressCount
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vXButton2Text w200, XButton2 Press Count: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, Sell Press Count: %sell_PressCount%
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Show, NoActivate x0 y0 AutoSize, Press Count Display

; Function to update the GUI display
UpdatePressCountDisplay() {
    global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
    GuiControl,, XButton2Text, XButton2 Press Count: %XButton2_PressCount%
    GuiControl,, SellPressText, Sell Press Count: %sell_PressCount%
}


; C key hotkey
C::
    Click             ; First single click
    Sleep, DelayAfterClick
    Click             ; Second single click
    Sleep, DelayBeforeDoubleClick
    Click 2           ; Double-click to select the text
    Sleep, DelayAfterDoubleClick
    Send, ^c          ; Copy the selected text
    Sleep, DelayAfterClick
    SanitizeClipboard()  ; Call function to clean up the clipboard content

    ; Display the clipboard content in a tooltip
    Tooltip, `n%clipboard%
    Sleep, 2000  ; Tooltip will stay for 2 seconds
    Tooltip  ; Remove the tooltip
return

; Sanitize clipboard content by removing unwanted text (e.g., "HOD")
SanitizeClipboard() {
    ClipWait, 1
    if (!ErrorLevel) {
        clipboard := RegExReplace(clipboard, "\s*\(HOD\)\s*$")
        clipboard := RegExReplace(clipboard, "Copy$")
        ; Add a safety check for very large clipboard content
        if (StrLen(clipboard) > 1000) {
            clipboard := SubStr(clipboard, 1, 1000)  ; Truncate to a reasonable size
        }
    } else {
        clipboard := ""  ; Clear the clipboard if invalid
    }
}

; Middle Mouse Button Functionality with short and long press detection
MButton::
    PressStartTime := A_TickCount  ; Record the time when MButton is pressed
    KeyWait, MButton  ; Wait for the button to be released
    PressDuration := A_TickCount - PressStartTime  ; Calculate press duration

    if (PressDuration < LongPressThreshold) {
        ; Short press - double-click, paste, wait, Enter
        Click 2            ; Double-click to select the content
        Sleep, DelayAfterClick
        Send, ^v           ; Paste clipboard content
        Sleep, DelayAfterFirstEnter
        Send, {Enter}      ; Press Enter
    } else {
        ; Long press - single-click, paste, wait, Enter
        Click              ; Single click to select the content
        Sleep, DelayAfterClick
        Send, ^v           ; Paste clipboard content
        Sleep, DelayAfterFirstEnter
        Send, {Enter}      ; Press Enter
    }
return


; XButton2 toggles between Buy/Sell actions
XButton2::
    global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
    XButton2_PressCount += 1
    sell_PressCount := 0  ; Reset sell press count
    UpdatePressCountDisplay()  ; Update GUI

    if (XButton2_PressCount = 1) {
        ; First press: Buy High
        if (parabolicMode) {
            Send, +!h  ; Shift+Alt+H for Buy High
            ShowTooltip("Parabolic BUY HIGH - Press Count: " . XButton2_PressCount)
        } else {
            Send, ^!h  ; Ctrl+Alt+H for Buy High
            ShowTooltip("Normal BUY HIGH - Press Count: " . XButton2_PressCount)
        }
    } else if (XButton2_PressCount = 2) {
        ; Second press: Sell High -> Buy Low
        if (parabolicMode) {
            Send, ^!a  ; Shift+Alt+D for Sell High
            Sleep, orderDelay
            Send, +!g  ; Shift+Alt+G for Buy Low
            ShowTooltip("Parabolic SELL HIGH -> BUY LOW - Press Count: " . XButton2_PressCount)
        } else {
            Send, ^!a  ; Ctrl+Alt+S for Sell High
            Sleep, orderDelay
            Send, ^!g  ; Ctrl+Alt+G for Buy Low
            ShowTooltip("Normal SELL HIGH -> BUY LOW - Press Count: " . XButton2_PressCount)
        }
    } else {
        ; Subsequent presses: Sell Low -> Buy Low
        if (parabolicMode) {
            Send, ^!d  ; Shift+Alt+D for Sell Low
            Sleep, orderDelay
            Send, +!g  ; Shift+Alt+G for Buy Low
            ShowTooltip("Parabolic SELL LOW -> BUY LOW - Press Count: " . XButton2_PressCount)
        } else {
            Send, ^!d  ; Ctrl+Alt+D for Sell Low
            Sleep, orderDelay
            Send, ^!g  ; Ctrl+Alt+G for Buy Low
            ShowTooltip("Normal SELL LOW -> BUY LOW - Press Count: " . XButton2_PressCount)
        }
    }
return

; Toggle Parabolic Mode 
A::
    parabolicMode := !parabolicMode
    if (parabolicMode) {
        SoundBeep, 900  ; Higher pitch for Parabolic Mode
        ShowTooltip("Parabolic Mode")
    } else {
        SoundBeep, 400  ; Lower pitch for Normal Mode
        ShowTooltip("Normal Mode")
    }
return

; canceling orders
S::
    Send, ^!c
    global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
    XButton2_PressCount := 0
    sell_PressCount := 0
    ShowTooltip("CANCEL ORDERS" . sell_PressCount)
    UpdatePressCountDisplay()  ; Update GUI
return

; Sell 
D::
    Send, +!q
    sell_PressCount := 0
    ShowTooltip("CLOSE")
return

; Sell low
F::
    if (sell_PressCount > 0) {
        Send, ^!c
        Sleep, cancelDelay
    } 
    Send, ^!f  ; Ctrl+Alt+D for Sell Low
    ShowTooltip("SELL LOW ASK")
    global sell_PressCount  ; Ensure variables are global
    sell_PressCount += 1
    UpdatePressCountDisplay()  ; Update GUI
return

G::
    Send, ^!a
    XButton2_PressCount := 0
    sell_PressCount += 1
    ShowTooltip("SELL HIGH Ask")
return

; R key sends Alt+H
R::
    Send, !h
return

; Toggle Suspend with A
Tab::
    Suspend, Toggle
    IsSuspended := !IsSuspended
    XButton2_PressCount := 0
    if (IsSuspended) {
        SoundBeep, 300  ; Low pitch for suspended
        ShowTooltip("Suspended")
    } else {
        SoundBeep, 600  ; High pitch for active
        ShowTooltip("Active")
    }
    Sleep, 1000
    Tooltip
return

; Function to display a tooltip
ShowTooltip(message) {
    ToolTip, %message%
    Sleep, 500  ; Tooltip stays visible for 1 second
    ToolTip  ; Clear the tooltip
}



; Configurable delay times for actions
DelayAfterClick := 250
DelayAfterFirstEnter := 500
cancelDelay := 1005  ; Delay for canceling orders
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; Initialize variables
parabolicMode := false  ; Default to Normal Mode
global XButton2_PressCount := 0
global sell_PressCount := 0

; Initialize GUI for displaying counters
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vXButton2Text w200, XButton2 Press Count: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, Sell Press Count: %sell_PressCount%
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Show, NoActivate x1900 y1400 AutoSize, Press Count Display

; Function to update the GUI display
UpdatePressCountDisplay() {
    global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
    GuiControl,, XButton2Text, XButton2 Press Count: %XButton2_PressCount%
    GuiControl,, SellPressText, Sell Press Count: %sell_PressCount%
}

; XButton2 toggles between Buy/Sell actions
XButton2::

    if (XButton2_PressCount = 0) {
        ; First press: Buy High
        if (parabolicMode) {
            Send, +!h  ; Shift+Alt+H for Buy High
            ShowTooltip("Parabolic BUY HIGH - Press Count: " . XButton2_PressCount)
            global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
            XButton2_PressCount += 1
            sell_PressCount := 0  ; Reset sell press count
            UpdatePressCountDisplay()  ; Update GUI
        } else {
            Send, ^!h  ; Ctrl+Alt+H for Buy High
            ShowTooltip("Normal BUY HIGH - Press Count: " . XButton2_PressCount)
            global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
            XButton2_PressCount += 1
            sell_PressCount := 0  ; Reset sell press count
            UpdatePressCountDisplay()  ; Update GUI
        }
    } else if (XButton2_PressCount = 1) {
        ; Second press: Sell High -> Buy Low
        if (parabolicMode) {
            Send, ^!a  ; Shift+Alt+D for Sell High
            Sleep, orderDelay
            Send, +!g  ; Shift+Alt+G for Buy Low
            ShowTooltip("Parabolic SELL HIGH -> BUY LOW - Press Count: " . XButton2_PressCount)
            global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
            XButton2_PressCount += 1
            sell_PressCount := 0  ; Reset sell press count
            UpdatePressCountDisplay()  ; Update GUI
        } else {
            Send, ^!a  ; Ctrl+Alt+S for Sell High
            Sleep, orderDelay
            Send, ^!g  ; Ctrl+Alt+G for Buy Low
            ShowTooltip("Normal SELL HIGH -> BUY LOW - Press Count: " . XButton2_PressCount)
            global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
            XButton2_PressCount += 1
            sell_PressCount := 0  ; Reset sell press count
            UpdatePressCountDisplay()  ; Update GUI
        }
    } else {
        ; Subsequent presses: Sell Low -> Buy Low
        if (parabolicMode) {
            Send, ^!d  ; Shift+Alt+D for Sell Low
            Sleep, orderDelay
            Send, +!g  ; Shift+Alt+G for Buy Low
            ShowTooltip("Parabolic SELL LOW -> BUY LOW - Press Count: " . XButton2_PressCount)
            global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
            XButton2_PressCount += 1
            sell_PressCount := 0  ; Reset sell press count
            UpdatePressCountDisplay()  ; Update GUI
        } else {
            Send, ^!d  ; Ctrl+Alt+D for Sell Low
            Sleep, orderDelay
            Send, ^!g  ; Ctrl+Alt+G for Buy Low
            ShowTooltip("Normal SELL LOW -> BUY LOW - Press Count: " . XButton2_PressCount)
            global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
            XButton2_PressCount += 1
            sell_PressCount := 0  ; Reset sell press count
            UpdatePressCountDisplay()  ; Update GUI
        }
    }
return


; Toggle Parabolic Mode 
A::
    parabolicMode := !parabolicMode
    if (parabolicMode) {
        SoundBeep, 900  ; Higher pitch for Parabolic Mode
        ShowTooltip("Parabolic Mode")
    } else {
        SoundBeep, 400  ; Lower pitch for Normal Mode
        ShowTooltip("Normal Mode")
    }
return

; Cancel orders and reset press counts
S::
    global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
    Send, ^!c
    ShowTooltip("CANCEL ORDERS")
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdatePressCountDisplay()  ; Update GUI
    
return

; Sell 
D::
    global XButton2_PressCount, sell_PressCount
    Send, +!q
    ShowTooltip("CLOSE POS")
    sell_PressCount := 0
    XButton2_PressCount := 0
    UpdatePressCountDisplay()  ; Update GUI
return

; Sell low
F::
    global XButton2_PressCount, sell_PressCount
    if (sell_PressCount > 0) {
        Send, ^!c
        Sleep, cancelDelay
    } 
    Send, ^!f  ; Ctrl+Alt+D for Sell Low
    ShowTooltip("SELL LOW ASK")
    sell_PressCount += 1
    UpdatePressCountDisplay()  ; Update GUI
return

; Sell high
G::
    global XButton2_PressCount, sell_PressCount  ; Ensure variables are global
    Send, ^!a
    ShowTooltip("SELL HIGH ASK")
    XButton2_PressCount := 0
    sell_PressCount += 1
    UpdatePressCountDisplay()  ; Update GUI
return

; Toggle Suspend with Tab
Tab::
    global XButton2_PressCount, sell_PressCount
    Suspend, Toggle
    IsSuspended := !IsSuspended
    if (IsSuspended) {
        SoundBeep, 300  ; Low pitch for suspended
        ShowTooltip("Suspended")
    } else {
        SoundBeep, 600  ; High pitch for active
        ShowTooltip("Active")
    }
    sell_PressCount := 0
    XButton2_PressCount := 0
    UpdatePressCountDisplay()  ; Update GUI
    Sleep, 1000
    Tooltip
return

; Function to display a tooltip
ShowTooltip(message) {
    ToolTip, %message%
    Sleep, 500  ; Tooltip stays visible for 1 second
    ToolTip  ; Clear the tooltip
}





; Configurable delay times for actions
DelayAfterClick := 250
DelayAfterFirstEnter := 500
cancelDelay := 1005  ; Delay for canceling orders
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; modes
parabolicMode := false  ; Default to Breakout Mode
scalpingMode := false  ; Default to Breakout Mode
currentMode := "Breakout" ; Track the current mode

; counters
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
    GuiControl,, ModeText, % "Mode: " . currentMode  ; Correctly update the mode display
}

; XButton2 toggles between Buy/Sell actions
XButton2::
    global scalpingMode, parabolicMode, currentMode, XButton2_PressCount, sell_PressCount

    if (scalpingMode) {
        ; Determine action based on press count in Scalping Mode
        action := (XButton2_PressCount = 0) ? "^!h"         ; Buy High ask .05
                : (XButton2_PressCount = 1) ? "^!s"         ; Sell High ask -.01
                : (Mod(XButton2_PressCount, 2) = 0) ? "^!g" ; Buy Low ask .05
                : "^!f"                                     ; Sell Low ask -.01
        Send, %action%
        XButton2_PressCount++
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

    UpdateDisplay()
    
return

; Toggle Parabolic Mode
G::
    global parabolicMode, scalpingMode, currentMode
    parabolicMode := !parabolicMode
    scalpingMode := false  ; Ensure Scalping Mode is off
    currentMode := parabolicMode ? "Parabolic" : "Breakout"
    SoundBeep, % (parabolicMode ? 900 : 400)  ; Higher pitch for On, lower for Off
    UpdateDisplay()
    ShowTooltip(parabolicMode ? "Parabolic Mode On" : "Parabolic Mode Off")
return

; Toggle Scalping Mode with H key
V::
    global scalpingMode, parabolicMode, currentMode
    scalpingMode := !scalpingMode
    parabolicMode := false  ; Ensure Parabolic Mode is off
    currentMode := scalpingMode ? "Scalping" : "Breakout"
    SoundBeep, % (scalpingMode ? 1000 : 500)  ; Higher pitch for On, lower for Off
    UpdateDisplay()
    ShowTooltip(scalpingMode ? "Scalping Mode On" : "Scalping Mode Off")
return

; Cancel orders and reset press counts
A::
    global XButton2_PressCount, sell_PressCount
    Send, ^!c
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdateDisplay()
    ShowTooltip("CANCEL ORDERS")
return

; Sell actions
S::
    global XButton2_PressCount, sell_PressCount
    Send, +!q
    sell_PressCount := 0
    XButton2_PressCount := 0
    UpdateDisplay()
    ShowTooltip("CLOSE POS")
return

D::
    global XButton2_PressCount, sell_PressCount
    if (sell_PressCount > 0) {
        Send, ^!c
        Sleep, cancelDelay
    }
    Send, ^!f
    sell_PressCount += 1
    XButton2_PressCount := 0
    UpdateDisplay()
    ShowTooltip("SELL LOW ASK")
return

F::
    global XButton2_PressCount, sell_PressCount
    if (sell_PressCount > 0) {
        Send, ^!c
        Sleep, cancelDelay
    }
    Send, ^!s
    sell_PressCount += 1
    XButton2_PressCount := 0
    UpdateDisplay()
    ShowTooltip("SELL HIGH ASK")
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
    ShowTooltip(IsSuspended ? "Script Suspended" : "Script Active")
return

; Function to display a tooltip
ShowTooltip(message) {
    ToolTip, %message%
    Sleep, 500  ; Tooltip stays visible for 0.5 seconds
    ToolTip  ; Clear the tooltip
}






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

; Reset function to restore the script to its initial state
ResetScript() {
    global XButton2_PressCount, sell_PressCount
    global parabolicMode, scalpingMode, currentMode

    ; Reset counters
    XButton2_PressCount := 0
    sell_PressCount := 0

    ; Reset modes
    parabolicMode := false
    scalpingMode := false
    currentMode := "Breakout"

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

;#####################################

; TODO
; mode starter at .9/.4 then add .98/48 take half .55/.05 take half .60/.10  
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
        ResetScript()                      ; Reset the script to its initial state
    }
    IsSuspended := !IsSuspended            ; Flip the suspension flag
    UpdateDisplay()                        ; Update the GUI to reflect the new state
    SoundBeep, % (IsSuspended ? 300 : 600) ; Low pitch for Suspended, high pitch for Active
return


;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; if starter mode is better than make the parabolic be a reflection of it instead

; Configurable delay times for actions
cancelDelay := 1005
orderDelay := 1500

; Start the script in suspended mode
Suspend On
IsSuspended := true  ; Match the starting state

; Modes
parabolicMode := false  ; Default to Agressive Mode
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
    global scalpingMode, parabolicMode, starterMode, currentMode, XButton2_PressCount, sell_PressCount

    if (starterMode) {
        ; Starter Mode Logic
        if (XButton2_PressCount = 0) {
            Send, ^!g                                 ; Buy Low ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!n                                 ; Buy Trip ask .5
        } else if (XButton2_PressCount = 2) {
            Send, ^!j                                 ; Sell Half
        } else if (XButton2_PressCount = 3) {
            Send, ^!m                                 ; Sell Half
            ; Transition to Scale Mode
            starterMode := false                      ; Deactivate Starter Mode
            scaleMode := true                         ; Activate Scale Mode
            currentMode := "Scale"                    ; Set current mode to Scale
            XButton2_PressCount := -1                 ; Reset press count
        }
        XButton2_PressCount++
    } else if (currentMode = "Scale") {
        ; Recursive scaling logic
        if (XButton2_PressCount = 0) {
            Send, ^!b    ; Step 1: Buy Smaller
        } else if (XButton2_PressCount = 1) {
            Send, ^!g   ; Step 2: Buy Small
        } else if (XButton2_PressCount = 2) {
            Send, ^!m    ; Step 3: Sell 75$
        } else if (XButton2_PressCount = 3) {
            Send, +!q    ; Step 4: Sell all
        }
        
        ; Increment after action is completed
        XButton2_PressCount++
    
        ; Reset after completing the full cycle
        if (XButton2_PressCount > 3) {
            XButton2_PressCount := 0  ; Reset count for the next cycle
        }
    }
    
     else if (scalpingMode) {
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
        ; Agressive Mode Logic
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

; Toggle Agressive Mode
G::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global scalpingMode, parabolicMode, starterMode, currentMode
    if (currentMode = "Agressive") {
        ; If already in Agressive mode, toggle back to Scalping
        scalpingMode := true
        parabolicMode := false
        starterMode := false
        currentMode := "Scalping"
    } else {
        ; Activate Agressive mode
        scalpingMode := false
        parabolicMode := false
        starterMode := false
        currentMode := "Agressive"
    }
    ResetScript()
    UpdateDisplay()
return

; Toggle Starter Mode
V::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global starterMode, scalpingMode, parabolicMode, currentMode
    if (currentMode = "Starter") {
        ; If already in Starter mode, toggle back to Scalping
        starterMode := false
        scalpingMode := true
        currentMode := "Scalping"
    } else {
        ; Activate Starter mode
        starterMode := true
        scalpingMode := false
        parabolicMode := false
        currentMode := "Starter"
    }
    ResetScript()
    UpdateDisplay()
return

; Toggle Parabolic Mode
T::
    if IsSuspended {
        return  ; Do nothing if suspended
    }
    global parabolicMode, scalpingMode, starterMode, currentMode
    if (currentMode = "Parabolic") {
        ; If already in Parabolic mode, toggle back to Scalping
        parabolicMode := false
        scalpingMode := true
        currentMode := "Scalping"
    } else {
        ; Activate Parabolic mode
        parabolicMode := true
        scalpingMode := false
        starterMode := false
        currentMode := "Parabolic"
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


; %%%%%%%%%%%%%%%%%%%%%%%%%


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
    global scalpingMode, parabolicMode, starterMode, currentMode, XButton2_PressCount, sell_PressCount

    if (starterMode) {
        ; Starter Mode Logic
        if (XButton2_PressCount = 0) {
            Send, ^!g                                 ; Buy Low ask .05
        } else if (XButton2_PressCount = 1) {
            Send, ^!n                                 ; Buy Trip ask .5
        } else if (XButton2_PressCount = 2) {
            Send, ^!j                                 ; Sell Half
        } else if (XButton2_PressCount = 3) {
            Send, ^!m                                 ; Sell Half
            ; Transition to Scale Mode
            starterMode := false                      ; Deactivate Starter Mode
            scaleMode := true                         ; Activate Scale Mode
            currentMode := "Scale"                    ; Set current mode to Scale
            XButton2_PressCount := -1                 ; Reset press count
        }
        XButton2_PressCount++
    } else if (currentMode = "Scale") {
        ; Recursive scaling logic
        if (XButton2_PressCount = 0) {
            Send, ^!b    ; Step 1: Buy Smaller
        } else if (XButton2_PressCount = 1) {
            Send, ^!b   ; Step 2: Buy smaller
        } else if (XButton2_PressCount = 2) {
            Send, ^!m    ; Sell 75%
        } else if (XButton2_PressCount = 3) {
            Send, +!q    ; Sell all
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
        ; Parabolic Mode Logic
        if (XButton2_PressCount = 0) {
            Send, +!h                                       ; Buy High ask 0.15
        } else if (XButton2_PressCount = 1) {
            Send, ^!s                                       ; Sell High ask -.01
        } else if (XButton2_PressCount = 2) {
            Send, +!g                                       ; Buy Low 0.15
        } else if (XButton2_PressCount = 3) {
            Send, ^!f                                       ; Sell Low ask -.01
            XButton2_PressCount := -1                 ; Reset press count
        }
        XButton2_PressCount++
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