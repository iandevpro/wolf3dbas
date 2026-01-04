$Debug
$RESIZE:SMOOTH
' WOLF3D.BAS - QB64 Port of Wolfenstein 3D
' Original by id Software, Port by Ian Dichkovskyi

Option _Explicit
On Error GoTo ErrorHandler

' IFDEF defines
Const FALSE = 0
Const TRUE = -1

'$INCLUDE: 'WL_DEF.BI'
'$INCLUDE: 'ID_VL.BI'
'$INCLUDE: 'ID_VH.BI'
'$INCLUDE: 'WL_INTER.BI'
'$INCLUDE: 'WL_MENU.BI'
'$INCLUDE: 'ID_CA.BI'

Const tedlevel = 0 ' Stub, not implemented
' Const DEMOTEST = 0 'FALSE
' Const UPLOAD = 0 ' FALSE
' Const GOODTIMES = 0
' Const JAPAN = 0
' Const GERMANY = 0
' Const SPEARDEMO = 0
' Const SPEAR = 0
' $LET is equivalent to #define for usage with #ifdef'
' $Let SPEAR = 0

Const NOWAIT = 0

' Constants
Const VIEWGLOBAL = &H10000 ' globals visible flush to wall
Const VIEWWIDTH = 256 ' size of view window
Const VIEWHEIGHT = 144
Const ANGLES = 360
Const TILEGLOBAL = 65536
Const MINDIST = 0.5
Const PI = 3.141592653589793
Const HEIGHTRATIO = 0.5
Const MAXWALLTILES = 64

' Global Variables
Dim Shared FOCALLENGTH As Long
FOCALLENGTH = &H5700& ' in global coordinates
Dim Shared screenofs As Integer
Dim Shared centerx As Integer
Dim Shared shootdelta As Integer
Dim Shared scale As Long
Dim Shared maxslope As Long
Dim Shared heightnumerator As Long
Dim Shared minheightdiv As Integer

' Game State Variables
Dim Shared startgame As Integer
Dim Shared loadedgame As Integer
Dim Shared virtualreality As Integer
Dim Shared mouseadjustment As Integer

' File and Episode Variables
Dim Shared configname As String * 13
Dim Shared SaveName As String * 13
Dim Shared PageFileName As String * 13
Dim Shared audioname As String * 13
Dim Shared demoname As String * 13
Dim Shared EpisodeSelect(5) As Integer

' Arrays
Dim Shared dirangle(8) As Integer
Dim Shared sintable(ANGLES) As Long
Dim Shared costable(ANGLES) As Long
Dim Shared finetangent(ANGLES / 4) As Long
Dim Shared pixelangle(VIEWWIDTH) As Integer
'Dim Shared horizwall(MAXWALLTILES) As Integer
'Dim Shared vertwall(MAXWALLTILES) As Integer

' Main Program


''
Cls
Print "Debug: Starting program"
Print "Wolfenstein 3D - QB64 Port"
Print "Loading..."

' Check for episode files
Print "Debug: Checking for episodes"
Call CheckForEpisodes

' Initialize game systems
Print "Debug: Initializing game systems"
Call InitGame
'Signon - memory
' FinishSignon US_CPrint US_CPrintLine USL_DrawString VWB_DrawPropString VW_DrawPropString
'PC-13
'Wolfenstein 3D
'Options
Call DemoLoop

' Main game loop
'Print "Debug: Entering main loop"
'Do: Loop Until InKey$ <> ""
'Do
'' TODO: Implement main game loop
'Call GameLoop

'_Limit 60 ' Limit to ~60 FPS
'Loop Until InKey$ = Chr$(27) ' ESC to quit

End

ErrorHandler:
Print "Error: "; Err; " - Line: "; _ErrorLine
Print "ErrorMessage: "; _ErrorMessage$
Print "_InclErrorFile: "; _InclErrorFile$; "_InclErrorLine:"; _InclErrorLine
Print "Press any key to exit..."
Do: Loop Until InKey$ <> ""
System

'include modules
'$INCLUDE:'GAMEPAL.BAS'
'$INCLUDE:'WL_GAME.BM'
'$INCLUDE:'WL_INTER.BM'
'$INCLUDE:'ID_CA.BM'
'$INCLUDE:'WL_MENU.BM'

' SignonScreen - Displays the game's intro screen
Sub SignonScreen
    Dim introscn(63999) As _Unsigned _Byte ' Buffer for signon screen (320x200)
    Dim f As Integer

    ' Set screen mode (320x200 - closest to original VGA mode)
    Screen 13

    ' Load the game palette
    LoadGamePalette
    ' TODO - other calls in NonShareware
    ' NonShareware
    If Not virtualreality Then
        ' Load signon screen from SIGNON.OBJ
        f = FreeFile
        ' TODO - parse CHR files to generateGAMEPAL.BAS and SIGNON.BAS
        ' objsc101.zip - Scans MS .OBJ files, reports types of records
        Open "OBJ\signon.bin" For Binary As #f
        Get #f, , introscn()
        Close #f

        ' Munge the picture (convert from planar to chunky format)
        ' It seems, VL_MungePic is not needed, as we are using the Screen 13 mode
        ' Call VL_MungePic(introscn(), 320, 200)

        ' Display the screen
        Call VL_MemToScreen(introscn(), 320, 200, 0, 0)
    End If

    ' Wait a bit to show the screen
    _Delay 1
    Do: Loop Until InKey$ <> ""
    'VL_FadeOut 200,255,100,100,100,30
    IntroScreen
    'Do: Loop Until InKey$ <> ""
    'ClearMScreen
    Do: Loop Until InKey$ <> ""
    'VL_FadeOut 0,255,0,0,0,30
End Sub

' IntroScreen - Displays memory bars and hardware detection
Sub IntroScreen
    Const MAINCOLOR = &H6C
    Const EMSCOLOR = &H6C
    Const XMSCOLOR = &H6C
    Const FILLCOLOR = 14

    Dim memory As Long, emshere As Long, xmshere As Long
    Dim i As Integer
    Dim main(9) As Integer
    Dim ems(9) As Integer
    Dim xms(9) As Integer

    ' Initialize memory arrays
    main(0) = 32: main(1) = 64: main(2) = 96: main(3) = 128: main(4) = 160
    main(5) = 192: main(6) = 224: main(7) = 256: main(8) = 288: main(9) = 320
    ems(0) = 100: ems(1) = 200: ems(2) = 300: ems(3) = 400: ems(4) = 500
    ems(5) = 600: ems(6) = 700: ems(7) = 800: ems(8) = 900: ems(9) = 1000
    xms(0) = 100: xms(1) = 200: xms(2) = 300: xms(3) = 400: xms(4) = 500
    xms(5) = 600: xms(6) = 700: xms(7) = 800: xms(8) = 900: xms(9) = 1000

    ' Hardcoded values as specified
    memory = 640
    emshere = 1000
    xmshere = 1000

    ' DRAW MAIN MEMORY
    For i = 0 To 9
        If memory >= main(i) Then
            Line (49, 163 - 8 * i)-(54, 163 - 8 * i + 4), MAINCOLOR - i, BF
        End If
    Next i

    ' DRAW EMS MEMORY
    For i = 0 To 9
        If emshere >= ems(i) Then
            Line (89, 163 - 8 * i)-(94, 163 - 8 * i + 4), EMSCOLOR - i, BF
        End If
    Next i

    ' DRAW XMS MEMORY
    For i = 0 To 9
        If xmshere >= xms(i) Then
            Line (129, 163 - 8 * i)-(134, 163 - 8 * i + 4), XMSCOLOR - i, BF
        End If
    Next i

    ' FILL BOXES for hardware detection
    ' Mouse
    Line (164, 82)-(175, 83), FILLCOLOR, BF

    ' Joystick (not present in our simplified version)

    ' Sound Blaster
    Line (164, 151)-(175, 152), FILLCOLOR, BF
End Sub

' VL_MungePic - Converts planar VGA data to chunky format
Sub VL_MungePic (buffer() As _Unsigned _Byte, width As Integer, height As Integer)
    Dim i As Long
    Dim j As Long
    Dim plane As Integer
    Dim temp(63999) As _Unsigned _Byte ' Fixed size to match buffer
    Dim src As Long
    Dim dst As Long
    Dim planeSize As Long

    ' Calculate size of each plane
    planeSize = width * height \ 4 ' Each plane is 1/4 of total size

    ' Copy original buffer to temp
    For i = 0 To 63999
        temp(i) = buffer(i)
    Next i

    ' Convert planar to chunky format
    For plane = 0 To 3
        src = plane * planeSize ' Start of current plane
        dst = 0
        For i = 0 To height - 1
            For j = 0 To width - 1
                If dst < 64000 And src < 64000 Then ' Check bounds
                    buffer(dst) = temp(src)
                    ' Print dst, buffer(dst)
                    dst = dst + 1
                    src = src + 1
                End If
            Next j
        Next i
    Next plane
    Do: Loop Until InKey$ <> ""

End Sub

' VL_MemToScreen - Copies buffer to screen
Sub VL_MemToScreen (buffer() As _Unsigned _Byte, width As Integer, height As Integer, x As Integer, y As Integer)
    Dim i As Long
    Dim j As Long
    Dim offset As Long

    ' Copy buffer to screen
    For i = 0 To height - 1
        For j = 0 To width - 1
            offset = i * width + j
            'IF offset < 64000 THEN  ' Check bounds
            PSet (j + x, i + y), buffer(offset)
            'Circle (j + x, i + y), 10, buffer(offset)
            'Print j + x, i + y, buffer(offset)
            'End If
        Next j
    Next i
End Sub

' Subroutines
Sub InitGame
    ' Initialize game systems
    Call BuildTables
    Call SetupWalls
    Call NewViewSize(15) ' Default view size

    ' Set initial game state
    startgame = 0
    loadedgame = 0
    virtualreality = 0 ' VR mode off by default
    mouseadjustment = 5

    ' Initialize file names
    configname = "CONFIG."
    SaveName = "SAVE."
    PageFileName = "PAGE."
    audioname = "AUDIO."
    demoname = "DEMO."

    ' Show signon screen
    SignonScreen

    'VW_Startup (); orig C - Video Startup - not needed in QB64, modern OSes
    'IN_Startup (); orig C - Input Manager Startup - not needed in QB64, modern OSes
    'PM_Startup (); orig C - Page Manager Startup - not needed in QB64, modern OSes
    'PM_UnlockMainMem (); orig C - related to memory management - not needed in QB64, modern OSes
    'SD_Startup (); orig C - Sound Manager Startup - not needed in QB64, modern OSes
    CA_Startup
    'US_Startup (); orig C - Starts the User Mgr - it looks like there are some init for Rnd (not needed)
    ' and checks for running Ted (level editor)

End Sub

Sub BuildTables
    ' Build sine/cosine tables
    Dim i As Integer
    Dim angle As Single
    Dim anglestep As Single
    Dim tang As Double
    Dim value As Long

    ' Calculate fine tangents
    For i = 0 To ANGLES / 8 - 1
        tang = Tan((i + 0.5) / (ANGLES / 2 / PI))
        finetangent(i) = tang * TILEGLOBAL
        finetangent(ANGLES / 4 - 1 - i) = (1 / tang) * TILEGLOBAL
    Next i

    ' Build sine/cosine tables
    angle = 0
    anglestep = PI / 2 / (ANGLES / 4)
    For i = 0 To ANGLES / 4 - 1
        value = Sin(angle) * &H10000
        sintable(i) = value
        sintable(i + ANGLES / 2) = value
        sintable(ANGLES / 2 - 1 - i) = value
        sintable(ANGLES - 1 - i) = value Or &H80000000
        sintable(ANGLES / 2 + i) = value Or &H80000000
        angle = angle + anglestep
    Next i
End Sub

Sub SetupWalls
    ' Initialize wall tile mappings
    Dim i As Integer
    For i = 1 To 63 ' MAXWALLTILES - 1
        horizwall(i) = (i - 1) * 2
        vertwall(i) = (i - 1) * 2 + 1
    Next i
End Sub

Sub NewViewSize (width As Integer)
    ' Set view size and calculate projection constants
    Dim newwidth As Integer
    Dim newheight As Integer

    ' Calculate view dimensions
    newwidth = width * 16 ' Must be divisible by 16
    newheight = width * 16 * HEIGHTRATIO ' Must be even

    ' Calculate center and other view parameters
    centerx = newwidth \ 2 - 1
    shootdelta = newwidth \ 10

    ' Calculate projection constants
    Call CalcProjection(FOCALLENGTH)
End Sub

Sub CalcProjection (focal As Long)
    Dim i As Integer
    Dim intang As Long
    Dim angle As Single
    Dim tang As Double
    Dim planedist As Double
    Dim globinhalf As Double
    Dim halfview As Integer
    Dim halfangle As Double
    Dim facedist As Double

    ' Store focal length
    FOCALLENGTH = focal
    facedist = focal + MINDIST
    halfview = VIEWWIDTH \ 2 ' Half view in pixels

    ' Calculate scale value for vertical height calculations
    ' and sprite x calculations
    scale = halfview * facedist \ (VIEWGLOBAL \ 2)

    ' Calculate height numerator for posts distance to get posts height
    ' The pixel height is height >> 2
    heightnumerator = (TILEGLOBAL * scale) \ 64
    minheightdiv = heightnumerator \ &H7FFF + 1

    ' Calculate the angle offset from view angle of each pixel's ray
    For i = 0 To halfview - 1
        ' Start 1/2 pixel over, so viewangle bisects two middle pixels
        tang = i * VIEWGLOBAL / VIEWWIDTH / facedist
        angle = Atn(tang)
        intang = angle * (ANGLES \ 2) / PI
        pixelangle(halfview - 1 - i) = intang
        pixelangle(halfview + i) = -intang
    Next i

    ' If a point's abs(y/x) is greater than maxslope, the point is outside
    ' the view area
    maxslope = finetangent(pixelangle(0)) \ 256
End Sub



' DemoLoop - Main menu and demo attract loop
Sub DemoLoop
    Static LastDemo As Integer
    Dim done As Integer
    Dim skipLoop As Integer

    ' TEDLEVEL: Launch directly into a specific level (stubbed)
    If tedlevel Then
        '
    End If

    ' main game cycle
    $If DEMOTEST = UNDEFINED Then
        $If UPLOAD = UNDEFINED Then
            $If GOODTIMES = UNDEFINED Then
                $If SPEAR = UNDEFINED Then
                    $If JAPAN = UNDEFINED Then
                        If Not NOWAIT Then
                            Call NonShareware
                        End If
                    $End If
                $Else
                    $If GOODTIMES = UNDEFINED Then
                        $If SPEARDEMO = UNDEFINED Then
                                Call CopyProtection()
                        $End If
                    $End If
                $End If
            $End If
        $End If
        'Call StartCPMusic(INTROSONG)

        $If JAPAN = UNDEFINED Then
            If Not NOWAIT Then
                'Call PG13()
            End If
        $End If
    $End If
    ' Line 1486, while 1 ...
End Sub
