' WL_INPUT.BAS - Input handling for Wolfenstein 3D QB64 port

'$INCLUDE: 'wl_def.bi'

' Input Constants
CONST KEY_UP = 18432
CONST KEY_DOWN = 20480
CONST KEY_LEFT = 19200
CONST KEY_RIGHT = 19712
CONST KEY_ESC = 27
CONST KEY_SPACE = 32
CONST KEY_ENTER = 13

' Input Variables
DIM SHARED keyStates(0 TO 255) AS INTEGER
DIM SHARED mouseX AS INTEGER
DIM SHARED mouseY AS INTEGER
DIM SHARED mouseButtons AS INTEGER
DIM SHARED mouseEnabled AS INTEGER
DIM SHARED joystickEnabled AS INTEGER

' Initialize input system
Sub InitInput
    ' Initialize variables
    ERASE keyStates
    mouseX = 0
    mouseY = 0
    mouseButtons = 0
    mouseEnabled = 1
    joystickEnabled = 0
    
    ' Set up mouse if available
    IF _MOUSEINPUT THEN
        mouseEnabled = 1
    ELSE
        mouseEnabled = 0
    End If
    
    ' Set up joystick if available
    IF _JOYSTICK(1) THEN
        joystickEnabled = 1
    ELSE
        joystickEnabled = 0
    End If
End Sub

' Update input state
Sub UpdateInput
    DIM k AS INTEGER
    
    ' Update keyboard state
    DO WHILE _KEYHIT
        k = _KEYHIT
        IF k > 0 THEN
            keyStates(k AND 255) = 1
        ELSE
            keyStates((-k) AND 255) = 0
        End If
    LOOP
    
    ' Update mouse state if enabled
    IF mouseEnabled THEN
        _MOUSEINPUT
        mouseX = _MOUSEX
        mouseY = _MOUSEY
        mouseButtons = _MOUSEBUTTON(1) OR (_MOUSEBUTTON(2) * 2) OR (_MOUSEBUTTON(3) * 4)
    End If
End Sub

' Check if a key is pressed
Function KeyPressed (keyCode AS INTEGER) AS INTEGER
    KeyPressed = keyStates(keyCode)
End Function

' Get mouse position
Sub GetMousePosition (x AS INTEGER, y AS INTEGER)
    x = mouseX
    y = mouseY
End Sub

' Get mouse button state
Function MouseButtonPressed (button AS INTEGER) AS INTEGER
    MouseButtonPressed = (mouseButtons AND button) <> 0
End Function

' Get joystick position
Sub GetJoystickPosition (x AS INTEGER, y AS INTEGER)
    IF joystickEnabled THEN
        x = _JOYSTICK(1) \ 1000
        y = _JOYSTICK(2) \ 1000
    ELSE
        x = 0
        y = 0
    End If
End Sub

' Get joystick button state
Function JoystickButtonPressed (button AS INTEGER) AS INTEGER
    IF joystickEnabled THEN
        JoystickButtonPressed = _JOYSTICK(button + 4)
    ELSE
        JoystickButtonPressed = 0
    End If
End Function

' Wait for a key press
Function WaitKey AS INTEGER
    DIM k AS INTEGER
    
    DO
        k = _KEYHIT
        IF k > 0 THEN
            WaitKey = k AND 255
            EXIT Function
        End If
        _LIMIT 60
    LOOP
End Function

' Clear all input states
Sub ClearInput
    ERASE keyStates
    mouseButtons = 0
End Sub 
