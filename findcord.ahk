#Persistent ; Keep the script running
SetTimer, ShowCursorPos, 10 ; Update every 10 milliseconds

ShowCursorPos:
    MouseGetPos, mouseX, mouseY ; Get the current mouse position (global coordinates)
    Tooltip, X: %mouseX%`nY: %mouseY% ; Display the coordinates in a tooltip
return
