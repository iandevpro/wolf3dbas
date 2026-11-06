' ID_IN.H - Input Manager Header
$If INCLUDE_ID_IN_BI = UNDEFINED Then
    $Let INCLUDE_ID_IN_BI = 1

    ' Scan codes (PC keyboard set 1, as read by the original keyboard interrupt)
    Const sc_None = 0
    Const sc_Bad = &HFF
    Const sc_Return = &H1C
    Const sc_Enter = sc_Return
    Const sc_Escape = &H01
    Const sc_Space = &H39
    Const sc_BackSpace = &H0E
    Const sc_Tab = &H0F
    Const sc_Alt = &H38
    Const sc_Control = &H1D
    Const sc_CapsLock = &H3A
    Const sc_LShift = &H2A
    Const sc_RShift = &H36
    Const sc_UpArrow = &H48
    Const sc_DownArrow = &H50
    Const sc_LeftArrow = &H4B
    Const sc_RightArrow = &H4D
    Const sc_Insert = &H52
    Const sc_Delete = &H53
    Const sc_Home = &H47
    Const sc_End = &H4F
    Const sc_PgUp = &H49
    Const sc_PgDn = &H51
    Const sc_F1 = &H3B
    Const sc_F2 = &H3C
    Const sc_F3 = &H3D
    Const sc_F4 = &H3E
    Const sc_F5 = &H3F
    Const sc_F6 = &H40
    Const sc_F7 = &H41
    Const sc_F8 = &H42
    Const sc_F9 = &H43
    Const sc_F10 = &H44
    Const sc_F11 = &H57
    Const sc_F12 = &H59

    Const sc_1 = &H02
    Const sc_2 = &H03
    Const sc_3 = &H04
    Const sc_4 = &H05
    Const sc_5 = &H06
    Const sc_6 = &H07
    Const sc_7 = &H08
    Const sc_8 = &H09
    Const sc_9 = &H0A
    Const sc_0 = &H0B

    Const sc_A = &H1E
    Const sc_B = &H30
    Const sc_C = &H2E
    Const sc_D = &H20
    Const sc_E = &H12
    Const sc_F = &H21
    Const sc_G = &H22
    Const sc_H = &H23
    Const sc_I = &H17
    Const sc_J = &H24
    Const sc_K = &H25
    Const sc_L = &H26
    Const sc_M = &H32
    Const sc_N = &H31
    Const sc_O = &H18
    Const sc_P = &H19
    Const sc_Q = &H10
    Const sc_R = &H13
    Const sc_S = &H1F
    Const sc_T = &H14
    Const sc_U = &H16
    Const sc_V = &H2F
    Const sc_W = &H11
    Const sc_X = &H2D
    Const sc_Y = &H15
    Const sc_Z = &H2C

    ' Motion
    Const motion_Left = -1
    Const motion_Up = -1
    Const motion_None = 0
    Const motion_Right = 1
    Const motion_Down = 1

    ' Direction
    Const dir_North = 0
    Const dir_NorthEast = 1
    Const dir_East = 2
    Const dir_SouthEast = 3
    Const dir_South = 4
    Const dir_SouthWest = 5
    Const dir_West = 6
    Const dir_NorthWest = 7
    Const dir_None = 8

    ' CursorInfo / ControlInfo
    Type ControlInfo
        button0 As Integer
        button1 As Integer
        button2 As Integer
        button3 As Integer
        x As Integer
        y As Integer
        xaxis As Integer
        yaxis As Integer
        dir As Integer
    End Type

    ' KeyboardDef KbdDefs = {0x1d,0x38,0x47,0x48,0x49,0x4b,0x4d,0x4f,0x50,0x51}
    Type KeyboardDef
        button0 As Integer
        button1 As Integer
        upleft As Integer
        up As Integer
        upright As Integer
        left As Integer
        right As Integer
        downleft As Integer
        down As Integer
        downright As Integer
    End Type

    Dim Shared Keyboard(0 To 127) As Integer
    Dim Shared LastScan As Integer
    Dim Shared LastASCII As Integer
    Dim Shared Paused As Integer
    Dim Shared KbdDefs As KeyboardDef
    Dim Shared mouseenabled As Integer
    Dim Shared joystickenabled As Integer
    Dim Shared joystickprogressive As Integer
    Dim Shared MousePresent As Integer
    Dim Shared JoysPresent(0 To 1) As Integer ' joystick 1 / 2: the first two game controllers

    ' joystick constants
    Const MaxJoys = 2
    Const JoyScaleMax = 32768
    Const JoyScaleShift = 8
    Const MaxJoyValue = 5000
    ' The game port gave timing counts for the stick position (a few hundred). The port
    ' turns a controller axis (-1 to 1) into the count 0 to JOYCOUNTS, so the calibration
    ' and scaling of the original work unchanged
    Const JOYCOUNTS = 1000

    Type JoystickDef
        joyMinX As Long
        joyMinY As Long
        threshMinX As Long
        threshMinY As Long
        threshMaxX As Long
        threshMaxY As Long
        joyMaxX As Long
        joyMaxY As Long
        joyMultXL As Long
        joyMultYL As Long
        joyMultXH As Long
        joyMultYH As Long
    End Type
    Dim Shared JoyDefs(0 To MaxJoys - 1) As JoystickDef
    ' The QB64 device of each joystick (0 = none) and its last state (INL_JoyService)
    Dim Shared inJoyDevice(0 To MaxJoys - 1) As Integer
    Dim Shared inJoyAxisX(0 To MaxJoys - 1) As Single, inJoyAxisY(0 To MaxJoys - 1) As Single
    Dim Shared inJoyButton(0 To MaxJoys - 1, 1 To 4) As Integer
    Dim Shared inAckJoyButtons As Integer ' joystick buttons held at IN_StartAck
    Dim Shared inDeferredRelease(0 To 127) As Integer ' see INL_KeyService
    Dim Shared inPressTime(0 To 127) As Double
    Dim Shared inAckButtons As Integer ' mouse buttons held at IN_StartAck
    ' The counters of the DOS mouse driver, fed by INL_MouseService from _MouseMovementX/Y
    ' (raw counts, like the mickeys): the motion since the last Mouse(MDelta)
    ' (INL_GetMouseDelta), and the virtual cursor of Mouse(3) / Mouse(4) (x 0-639, one
    ' mickey per pixel; y 0-199, two mickeys per pixel, so inMouseY is in mickeys)
    Dim Shared inMouseDX As Long, inMouseDY As Long
    Dim Shared inMouseX As Long, inMouseY As Long
    ' Key press queue (scan code + ASCII), the original only had LastScan / LastASCII.
    ' INL_KeyService handles all key events of up to ~16 ms at once, so text input
    ' (US_LineInput) reads the presses from here to not lose fast typed characters
    Const IN_KEYQUEUESIZE = 32
    Dim Shared inQueueScan(0 To IN_KEYQUEUESIZE - 1) As Integer
    Dim Shared inQueueASCII(0 To IN_KEYQUEUESIZE - 1) As Integer
    Dim Shared inQueueHead As Integer, inQueueTail As Integer
    Dim Shared inTimer As Long ' ON TIMER handle of INL_KeyService, 0 = not started

    Declare Sub IN_Startup ()
    Declare Sub IN_Shutdown ()
    Declare Sub IN_ClearKeysDown ()
    Declare Function IN_GetKeyPress% (scan As Integer, ascii As Integer)
    Declare Sub IN_ReadControl (player As Integer, info As ControlInfo)
    Declare Function IN_MouseButtons% ()
    Declare Sub INL_MouseService ()
    Declare Sub INL_GetMouseDelta (x As Long, y As Long)
    Declare Sub IN_ClearMouseDelta ()
    Declare Sub IN_GetMousePos (x As Integer, y As Integer)
    Declare Sub IN_SetMousePos (x As Integer, y As Integer)
    Declare Function IN_CheckAck% ()
    Declare Sub IN_StartAck ()
    Declare Sub IN_Ack ()
    Declare Function IN_UserInput% (delay As Long)

$End If
