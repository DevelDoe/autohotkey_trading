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

; Initialize GUI for displaying counters and states
Gui, Font, s10 Bold, Arial
Gui, Color, Black
Gui, Add, Text, cWhite vScriptState w200, Suspended
Gui, Add, Text, cWhite vXButton2Text w200, X: %XButton2_PressCount%
Gui, Add, Text, cWhite vSellPressText w200, S: %sell_PressCount%
Gui, Add, Text, cWhite vParabolicState w200, Normal
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Show, NoActivate x1900 y1400 AutoSize, Press Count Display

; Function to update the GUI display
UpdatePressCountDisplay() {
    global XButton2_PressCount, sell_PressCount, IsSuspended, parabolicMode
    GuiControl,, ScriptState, % "" . (IsSuspended ? "Suspended" : "Active")
    GuiControl,, XButton2Text, % "X " . XButton2_PressCount
    GuiControl,, SellPressText, % "S: " . sell_PressCount
    GuiControl,, ParabolicState, % "" . (parabolicMode ? "Parabolic" : "Normal")
}

; Copy past

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
        ; Remove unwanted text patterns
        clipboard := RegExReplace(clipboard, "\s*\(HOD\)\s*$")  ; Remove "(HOD)" at the end
        clipboard := RegExReplace(clipboard, "Copy$")           ; Remove "Copy" at the end
        clipboard := RegExReplace(clipboard, "\*$")            ; Remove trailing "*"
        
        ; Add a safety check for very large clipboard content
        if (StrLen(clipboard) > 1000) {
            clipboard := SubStr(clipboard, 1, 1000)  ; Truncate to a reasonable size
        }
    } else {
        clipboard := ""  ; Clear the clipboard if invalid
    }
}

; clicks

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
    if (XButton2_PressCount = 0) {
        if (parabolicMode) {
            Send, +!h  ; Shift+Alt+H for Buy High
        } else {
            Send, ^!h  ; Ctrl+Alt+H for Buy High
        }
        XButton2_PressCount += 1
        sell_PressCount := 0  ; Reset sell press count
        UpdatePressCountDisplay()
    } else if (XButton2_PressCount = 1) {
        if (parabolicMode) {
            Send, ^!a  ; Shift+Alt+D for Sell High
            Sleep, orderDelay
            Send, +!g  ; Shift+Alt+G for Buy Low
        } else {
            Send, ^!a  ; Ctrl+Alt+S for Sell High
            Sleep, orderDelay
            Send, ^!g  ; Ctrl+Alt+G for Buy Low
        }
        XButton2_PressCount += 1
        sell_PressCount := 0  ; Reset sell press count
        UpdatePressCountDisplay()
    } else {
        if (parabolicMode) {
            Send, ^!d  ; Shift+Alt+D for Sell Low
            Sleep, orderDelay
            Send, +!g  ; Shift+Alt+G for Buy Low
        } else {
            Send, ^!d  ; Ctrl+Alt+D for Sell Low
            Sleep, orderDelay
            Send, ^!g  ; Ctrl+Alt+G for Buy Low
        }
        XButton2_PressCount += 1
        sell_PressCount := 0  ; Reset sell press count
        UpdatePressCountDisplay()
    }
return

; Toggle Parabolic Mode
A::
    global parabolicMode
    parabolicMode := !parabolicMode
    SoundBeep, % (parabolicMode ? 900 : 400)  ; Higher pitch for On, lower for Off
    UpdatePressCountDisplay()
    ShowTooltip(parabolicMode ? "Parabolic Mode On" : "Parabolic Mode Off")
return

; Cancel orders and reset press counts
S::
    global XButton2_PressCount, sell_PressCount
    Send, ^!c
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdatePressCountDisplay()
    ShowTooltip("CANCEL ORDERS")
return

; Sell actions
D::
    global XButton2_PressCount, sell_PressCount
    Send, +!q
    sell_PressCount := 0
    XButton2_PressCount := 0
    UpdatePressCountDisplay()
    ShowTooltip("CLOSE POS")
return

F::
    global XButton2_PressCount, sell_PressCount
    if (sell_PressCount > 0) {
        Send, ^!c
        Sleep, cancelDelay
    }
    Send, ^!f
    sell_PressCount += 1
    XButton2_PressCount := 0
    UpdatePressCountDisplay()
    ShowTooltip("SELL LOW ASK")
return

G::
    global XButton2_PressCount, sell_PressCount
    if (sell_PressCount > 0) {
        Send, ^!c
        Sleep, cancelDelay
    }
    Send, ^!s
    sell_PressCount += 1
    XButton2_PressCount := 0
    UpdatePressCountDisplay()
    ShowTooltip("SELL HIGH ASK")
return

; Toggle Suspend with Tab
Tab::
    global XButton2_PressCount, sell_PressCount, IsSuspended
    Suspend, Toggle
    IsSuspended := !IsSuspended
    XButton2_PressCount := 0
    sell_PressCount := 0
    UpdatePressCountDisplay()
    SoundBeep, % (IsSuspended ? 300 : 600)  ; Low pitch for Suspended, high pitch for Active
    ShowTooltip(IsSuspended ? "Script Suspended" : "Script Active")
return

; Function to display a tooltip
ShowTooltip(message) {
    ToolTip, %message%
    Sleep, 500  ; Tooltip stays visible for 0.5 seconds
    ToolTip  ; Clear the tooltip
}
