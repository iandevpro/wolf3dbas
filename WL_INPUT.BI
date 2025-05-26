' WL_INPUT.BI - Input handling declarations for Wolfenstein 3D QB64 port

'$INCLUDE: 'wl_def.bi'

' Input Constants
Const KEY_UP = 18432
Const KEY_DOWN = 20480
Const KEY_LEFT = 19200
Const KEY_RIGHT = 19712
Const KEY_ESC = 27
Const KEY_SPACE = 32
Const KEY_ENTER = 13
Const KEY_1 = 49
Const KEY_2 = 50
Const KEY_3 = 51
Const KEY_4 = 52
Const KEY_5 = 53
Const KEY_6 = 54
Const KEY_7 = 55
Const KEY_8 = 56
Const KEY_9 = 57
Const KEY_0 = 48
Const KEY_F1 = 15104
Const KEY_F2 = 15360
Const KEY_F3 = 15616
Const KEY_F4 = 15872
Const KEY_F5 = 16128
Const KEY_F6 = 16384
Const KEY_F7 = 16640
Const KEY_F8 = 16896
Const KEY_F9 = 17152
Const KEY_F10 = 17408

' Mouse Button Constants
Const MOUSE_LEFT = 1
Const MOUSE_RIGHT = 2
Const MOUSE_MIDDLE = 4

' Joystick Constants
Const JOY_LEFT = 1
Const JOY_RIGHT = 2
Const JOY_UP = 4
Const JOY_DOWN = 8
Const JOY_BUTTON1 = 16
Const JOY_BUTTON2 = 32

' Input Variables
Dim Shared keyStates(0 To 255) As Integer
Dim Shared mouseX As Integer
Dim Shared mouseY As Integer
Dim Shared mouseButtons As Integer
Dim Shared mouseEnabled As Integer
Dim Shared joystickEnabled As Integer
Dim Shared lastKey As Integer
Dim Shared lastMouseX As Integer
Dim Shared lastMouseY As Integer
Dim Shared lastMouseButtons As Integer
Dim Shared lastJoystickX As Integer
Dim Shared lastJoystickY As Integer
Dim Shared lastJoystickButtons As Integer

' Function Declarations
DECLARE Sub InitInput
DECLARE Sub UpdateInput
DECLARE Function KeyPressed (keyCode AS INTEGER) AS INTEGER
DECLARE Sub GetMousePosition (x AS INTEGER, y AS INTEGER)
DECLARE Function MouseButtonPressed (button AS INTEGER) AS INTEGER
DECLARE Sub GetJoystickPosition (x AS INTEGER, y AS INTEGER)
DECLARE Function JoystickButtonPressed (button AS INTEGER) AS INTEGER
DECLARE Function WaitKey AS INTEGER
DECLARE Sub ClearInput
DECLARE Function GetKeyState (keyCode AS INTEGER) AS INTEGER
DECLARE Sub SetKeyState (keyCode AS INTEGER, state AS INTEGER)
DECLARE Function GetMouseState AS INTEGER
DECLARE Function GetJoystickState AS INTEGER
DECLARE Sub CalibrateJoystick
DECLARE Function IsInputDeviceEnabled (deviceType AS INTEGER) AS INTEGER
DECLARE Sub EnableInputDevice (deviceType AS INTEGER, enable AS INTEGER)
