
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
