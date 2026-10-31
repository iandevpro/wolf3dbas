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
' WL_MENU.BI is already included through WL_DEF.BI
'$INCLUDE: 'WL_MENU.BI'
'$INCLUDE: 'ID_CA.BI'
'$INCLUDE: 'ID_SD.BI'
'$INCLUDE: 'ID_IN.BI'
'$INCLUDE: 'ID_US.BI'
'$INCLUDE: 'WL_PLAY.BI'
'$INCLUDE: 'WL_TEXT.BI'
'$INCLUDE: 'ID_PM.BI'
'$INCLUDE: 'WL_ACT1.BI'
'$INCLUDE: 'WL_DRAW.BI'
'$INCLUDE: 'WL_SCALE.BI'
'$INCLUDE: 'WL_STATE.BI'
'$INCLUDE: 'WL_GAME.BI'

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
' (game constants: WL_DEF.BI)
Const VIEWGLOBAL = &H10000 ' globals visible flush to wall

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
Dim Shared viewwidth As Integer
Dim Shared viewheight As Integer
Dim Shared viewsize As Integer

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
' Initialized here like the C static initializers, CheckForEpisodes appends the extension
configname = "CONFIG." ' WL_MAIN.C
SaveName = "SAVEGAM?." ' WL_MENU.C, ? = save slot digit
PageFileName = "VSWAP." ' ID_PM.C
audioname = "AUDIO." ' ID_CA.C
demoname = "DEMO?." ' WL_GAME.C, ? = demo number
Dim Shared EpisodeSelect(5) As Integer
Dim Shared ElevatorBackTo(5) As Integer ' WL_GAME.C: the map after each episode's secret level
ElevatorBackTo(0) = 1: ElevatorBackTo(1) = 1: ElevatorBackTo(2) = 7
ElevatorBackTo(3) = 3: ElevatorBackTo(4) = 5: ElevatorBackTo(5) = 3

' Arrays
Dim Shared dirangle(8) As Integer ' WL_STATE.C: {0,ANGLES/8,2*ANGLES/8,...,8*ANGLES/8}
dirangle(0) = 0: dirangle(1) = ANGLES \ 8: dirangle(2) = 2 * ANGLES \ 8: dirangle(3) = 3 * ANGLES \ 8: dirangle(4) = 4 * ANGLES \ 8
dirangle(5) = 5 * ANGLES \ 8: dirangle(6) = 6 * ANGLES \ 8: dirangle(7) = 7 * ANGLES \ 8: dirangle(8) = 8 * ANGLES \ 8
' (sintable, costable, finetangent: WL_DRAW.BI)
Dim Shared pixelangle(0 To MAXVIEWWIDTH - 1) As Integer

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
' Port debug views (PORTDEBUG.BM, not in the original): WOLF3D.exe /mapview
If InStr(UCase$(Command$), "/MAPVIEW") Then
    PortDebugView
    Quit ""
End If

Call DemoLoop

' Main game loop
'Print "Debug: Entering main loop"
'Do: Loop Until InKey$ <> ""
'Do
'' TODO: Implement main game loop
'Call GameLoop

'_Limit 60 ' Limit to ~60 FPS
'Loop Until InKey$ = Chr$(27) ' ESC to quit

IN_Shutdown
SD_Shutdown
VL_SetPalette gamepal() ' undo VW_FadeOut, so QB64's end prompt is readable
_AutoDisplay ' VW_UpdateScreen switched to manual display
End

ErrorHandler:
IN_Shutdown
SD_Shutdown
Palette ' the screen may be faded to black
_AutoDisplay ' VW_UpdateScreen switched to manual display
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
'$INCLUDE:'ID_MM.BM'
'$INCLUDE:'ID_SD.BM'
'$INCLUDE:'ID_IN.BM'
'$INCLUDE:'ID_US_1.BM'
'$INCLUDE:'WL_TEXT.BM'
'$INCLUDE:'ID_PM.BM'
'$INCLUDE:'PORTDEBUG.BM'
'$INCLUDE:'WL_PLAY.BM'
'$INCLUDE:'WL_ACT1.BM'
'$INCLUDE:'WL_ACT2.BM'
'$INCLUDE:'WL_AGENT.BM'
'$INCLUDE:'WL_DRAW.BM'
'$INCLUDE:'WL_SCALE.BM'
'$INCLUDE:'WL_STATE.BM'

'==========================
'=
'= Quit
'=
'==========================
Sub Quit (errmsg As String)
    ' TODO: WriteConfig, and the ORDERSCREEN / ERRORSCREEN text mode screens
    IN_Shutdown
    SD_Shutdown
    PM_Shutdown

    If Len(errmsg) Then
        Palette ' default colors, the screen may be faded out
        _AutoDisplay ' VW_UpdateScreen switched to manual display
        Cls
        Print errmsg
        Sleep
    End If

    System
End Sub

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
'=====================
'=
'= InitDigiMap
'=
'= wolfdigimap[]: the digitized sound of each sound (WL_MAIN.C)
'=
'=====================
Sub InitDigiMap
    $If SPEAR = UNDEFINED Then
        ' These first sounds are in the upload version
        DigiMap(HALTSND) = 0
        DigiMap(DOGBARKSND) = 1
        DigiMap(CLOSEDOORSND) = 2
        DigiMap(OPENDOORSND) = 3
        DigiMap(ATKMACHINEGUNSND) = 4
        DigiMap(ATKPISTOLSND) = 5
        DigiMap(ATKGATLINGSND) = 6
        DigiMap(SCHUTZADSND) = 7
        DigiMap(GUTENTAGSND) = 8
        DigiMap(MUTTISND) = 9
        DigiMap(BOSSFIRESND) = 10
        DigiMap(SSFIRESND) = 11
        DigiMap(DEATHSCREAM1SND) = 12
        DigiMap(DEATHSCREAM2SND) = 13
        DigiMap(DEATHSCREAM3SND) = 13
        DigiMap(TAKEDAMAGESND) = 14
        DigiMap(PUSHWALLSND) = 15

        DigiMap(LEBENSND) = 20
        DigiMap(NAZIFIRESND) = 21
        DigiMap(SLURPIESND) = 22

        DigiMap(YEAHSND) = 32

        $If UPLOAD = UNDEFINED Then
            ' These are in all other episodes
            DigiMap(DOGDEATHSND) = 16
            DigiMap(AHHHGSND) = 17
            DigiMap(DIESND) = 18
            DigiMap(EVASND) = 19

            DigiMap(TOT_HUNDSND) = 23
            DigiMap(MEINGOTTSND) = 24
            DigiMap(SCHABBSHASND) = 25
            DigiMap(HITLERHASND) = 26
            DigiMap(SPIONSND) = 27
            DigiMap(NEINSOVASSND) = 28
            DigiMap(DOGATTACKSND) = 29
            DigiMap(LEVELDONESND) = 30
            DigiMap(MECHSTEPSND) = 31

            DigiMap(SCHEISTSND) = 33
            DigiMap(DEATHSCREAM4SND) = 34 ' AIIEEE
            DigiMap(DEATHSCREAM5SND) = 35 ' DEE-DEE
            DigiMap(DONNERSND) = 36 ' EPISODE 4 BOSS DIE
            DigiMap(EINESND) = 37 ' EPISODE 4 BOSS SIGHTING
            DigiMap(ERLAUBENSND) = 38 ' EPISODE 6 BOSS SIGHTING
            DigiMap(DEATHSCREAM6SND) = 39 ' FART
            DigiMap(DEATHSCREAM7SND) = 40 ' GASP
            DigiMap(DEATHSCREAM8SND) = 41 ' GUH-BOY!
            DigiMap(DEATHSCREAM9SND) = 42 ' AH GEEZ!
            DigiMap(KEINSND) = 43 ' EPISODE 5 BOSS SIGHTING
            DigiMap(MEINSND) = 44 ' EPISODE 6 BOSS DIE
            DigiMap(ROSESND) = 45 ' EPISODE 5 BOSS DIE
        $End If
    $Else
        '
        ' SPEAR OF DESTINY DIGISOUNDS
        '
        DigiMap(HALTSND) = 0
        DigiMap(CLOSEDOORSND) = 2
        DigiMap(OPENDOORSND) = 3
        DigiMap(ATKMACHINEGUNSND) = 4
        DigiMap(ATKPISTOLSND) = 5
        DigiMap(ATKGATLINGSND) = 6
        DigiMap(SCHUTZADSND) = 7
        DigiMap(BOSSFIRESND) = 8
        DigiMap(SSFIRESND) = 9
        DigiMap(DEATHSCREAM1SND) = 10
        DigiMap(DEATHSCREAM2SND) = 11
        DigiMap(TAKEDAMAGESND) = 12
        DigiMap(PUSHWALLSND) = 13
        DigiMap(AHHHGSND) = 15
        DigiMap(LEBENSND) = 16
        DigiMap(NAZIFIRESND) = 17
        DigiMap(SLURPIESND) = 18
        DigiMap(LEVELDONESND) = 22
        DigiMap(DEATHSCREAM4SND) = 23 ' AIIEEE
        DigiMap(DEATHSCREAM3SND) = 23 ' DOUBLY-MAPPED!!!
        DigiMap(DEATHSCREAM5SND) = 24 ' DEE-DEE
        DigiMap(DEATHSCREAM6SND) = 25 ' FART
        DigiMap(DEATHSCREAM7SND) = 26 ' GASP
        DigiMap(DEATHSCREAM8SND) = 27 ' GUH-BOY!
        DigiMap(DEATHSCREAM9SND) = 28 ' AH GEEZ!
        DigiMap(GETGATLINGSND) = 38 ' Got Gat replacement

        $If SPEARDEMO = UNDEFINED Then
            DigiMap(DOGBARKSND) = 1
            DigiMap(DOGDEATHSND) = 14
            DigiMap(SPIONSND) = 19
            DigiMap(NEINSOVASSND) = 20
            DigiMap(DOGATTACKSND) = 21
            DigiMap(TRANSSIGHTSND) = 29 ' Trans Sight
            DigiMap(TRANSDEATHSND) = 30 ' Trans Death
            DigiMap(WILHELMSIGHTSND) = 31 ' Wilhelm Sight
            DigiMap(WILHELMDEATHSND) = 32 ' Wilhelm Death
            DigiMap(UBERDEATHSND) = 33 ' Uber Death
            DigiMap(KNIGHTSIGHTSND) = 34 ' Death Knight Sight
            DigiMap(KNIGHTDEATHSND) = 35 ' Death Knight Death
            DigiMap(ANGELSIGHTSND) = 36 ' Angel Sight
            DigiMap(ANGELDEATHSND) = 37 ' Angel Death
            DigiMap(GETSPEARSND) = 39 ' Got Spear replacement
        $End If
    $End If
End Sub

Sub InitGame
    ' Initialize game systems
    InitStates ' the statetype initializers of the C files
    Call BuildTables
    Call SetupWalls
    Call NewViewSize(15) ' Default view size

    ' Set initial game state
    startgame = 0
    loadedgame = 0
    virtualreality = 0 ' VR mode off by default
    mouseadjustment = 5

    ' File names are initialized at the top of the program and completed by CheckForEpisodes

    ' Show signon screen
    SignonScreen

    'VW_Startup (); orig C - Video Startup - not needed in QB64, modern OSes
    IN_Startup ' Input Manager Startup - keyboard scan codes from _KeyHit
    PM_Startup ' Page Manager Startup - loads VSWAP
    'PM_UnlockMainMem (); orig C - related to memory management - not needed in QB64, modern OSes
    SD_Startup ' Sound Manager Startup - OPL2 emulator + _SndRaw output
    CA_Startup
    ' US_Startup - starts the User Mgr: random numbers (the original also checked for Ted, the level editor)
    US_InitRndT TRUE

    ' TODO: ReadConfig - with no config the sound effects default to the AdLib
    If SD_SetSoundMode(sdm_AdLib) Then CA_LoadAllSounds
    If SD_SetMusicMode(smm_AdLib) Then MusicMode = smm_AdLib
    If SoundBlasterPresent Then SD_SetDigiDevice sds_SoundBlaster ' (ReadConfig default)

    '
    ' load in and lock down some basic chunks
    '
    CA_CacheGrChunk STARTFONT

    LoadLatchMem

    InitDigiMap

    '
    ' initialize variables
    '
    InitRedShifts
End Sub

'==================
'=
'= BuildTables
'=
'= Calculates:
'=
'= scale                 projection constant
'= sintable/costable     overlapping fractional tables
'=
'= C float math is done in Single, and Fix() truncates like the C conversions to integer
'=
'==================
Sub BuildTables
    Dim i As Integer
    Dim angle As Single, anglestep As Single
    Dim tang As Double
    Dim value As Long
    Dim radtoint As Single

    radtoint = FINEANGLES / 2 / PI ' const float radtoint = (float)FINEANGLES/2/PI

    '
    ' calculate fine tangents
    '
    For i = 0 To FINEANGLES \ 8 - 1
        tang = Tan((i + 0.5) / radtoint)
        finetangent(i) = Fix(tang * TILEGLOBAL)
        finetangent(FINEANGLES \ 4 - 1 - i) = Fix(1 / tang * TILEGLOBAL)
    Next i

    '
    ' costable overlays sintable with a quarter phase shift
    ' ANGLES is assumed to be divisable by four
    '
    ' The low word of the value is the fraction, the high bit is the sign bit,
    ' bits 16-30 should be 0
    '
    angle = 0
    anglestep = PI / 2 / ANGLEQUAD
    For i = 0 To ANGLEQUAD
        value = Fix(GLOBAL1 * Sin(CDbl(angle)))
        sintable(i) = value
        sintable(i + ANGLES) = value
        sintable(ANGLES \ 2 - i) = value
        sintable(ANGLES - i) = value Or &H80000000&
        sintable(ANGLES \ 2 + i) = value Or &H80000000&
        angle = angle + anglestep
    Next i

    ' fixed far *costable = sintable+(ANGLES/4)
    For i = 0 To ANGLES
        costable(i) = sintable(i + ANGLEQUAD)
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

'==========================
'=
'= SetViewSize
'=
'==========================
Function SetViewSize% (width As Integer, height As Integer)
    viewwidth = width And Not 15 ' must be divisable by 16
    viewheight = height And Not 1 ' must be even
    centerx = viewwidth \ 2 - 1
    shootdelta = viewwidth \ 10
    screenofs = (((200 - STATUSLINES - viewheight) \ 2) * 80 + (320 - viewwidth) \ 8) ' SCREENWIDTH = 80

    '
    ' calculate trace angles and projection constants
    '
    CalcProjection FOCALLENGTH

    ' top left of the view on the screen (the original added screenofs to bufferofs)
    viewscreenx = (screenofs Mod 80) * 4
    viewscreeny = screenofs \ 80

    '
    ' build all needed compiled scalers
    '
    SetupScaling Fix(viewwidth * 1.5)

    SetViewSize% = TRUE
End Function

Sub ShowViewSize (width As Integer)
    Dim oldwidth As Integer, oldheight As Integer

    oldwidth = viewwidth
    oldheight = viewheight

    viewwidth = width * 16
    viewheight = width * 16 * HEIGHTRATIO
    DrawPlayBorder

    viewheight = oldheight
    viewwidth = oldwidth
End Sub

Sub NewViewSize (width As Integer)
    Dim result As Integer

    ' CA_UpLevel, MM_SortMem, CA_DownLevel - memory management, not needed in QB64
    viewsize = width
    result = SetViewSize(width * 16, width * 16 * HEIGHTRATIO)
End Sub

'==================================
'=
'= SaveTheGame / LoadTheGame
'=
'= TODO: save and load the game state (gamestate, levels, actors, statics, doors...)
'= when the game is ported. The menus write and read the 32 byte save game name.
'=
'==================================
Function SaveTheGame% (handle As Long, x As Integer, y As Integer)
    SaveTheGame% = TRUE
End Function

Function LoadTheGame% (handle As Long, x As Integer, y As Integer)
    LoadTheGame% = TRUE
End Function

'==========================
'=
'= NewGame
'=
'= Set up new game to start from the beginning
'=
'==========================
Sub NewGame (difficulty As Integer, episode As Integer)
    Dim empty As gametype

    gamestate = empty ' memset (&gamestate,0,sizeof(gamestate))
    gamestate.difficulty = difficulty
    gamestate.weapon = wp_pistol
    gamestate.bestweapon = wp_pistol
    gamestate.chosenweapon = wp_pistol
    gamestate.health = 100
    gamestate.ammo = STARTAMMO
    gamestate.lives = 3
    gamestate.nextextra = EXTRAPOINTS
    gamestate.episode = episode

    startgame = TRUE
End Sub

'====================
'=
'= CalcProjection
'=
'= Uses focallength
'=
'====================
Sub CalcProjection (focal As Long)
    Dim i As Integer
    Dim intang As Long
    Dim angle As Single
    Dim tang As Double
    Dim halfview As Integer
    Dim facedist As Double
    Dim radtoint As Single

    radtoint = FINEANGLES / 2 / PI ' const float radtoint = (float)FINEANGLES/2/PI

    FOCALLENGTH = focal ' focallength
    facedist = focal + MINDIST
    halfview = viewwidth \ 2 ' half view in pixels

    '
    ' calculate scale value for vertical height calculations
    ' and sprite x calculations
    '
    scale = Fix(halfview * facedist / (VIEWGLOBAL \ 2))

    '
    ' divide heightnumerator by a posts distance to get the posts height for
    ' the heightbuffer.  The pixel height is height>>2
    '
    heightnumerator = (TILEGLOBAL * scale) \ 64 ' >>6
    minheightdiv = heightnumerator \ &H7FFF + 1

    '
    ' calculate the angle offset from view angle of each pixel's ray
    '
    For i = 0 To halfview - 1
        ' start 1/2 pixel over, so viewangle bisects two middle pixels
        tang = ((CLng(i) * VIEWGLOBAL) \ viewwidth) / facedist ' (long)i*VIEWGLOBAL/viewwidth is integer math
        angle = Atn(tang)
        intang = Fix(angle * radtoint)
        pixelangle(halfview - 1 - i) = intang
        pixelangle(halfview + i) = -intang
    Next i

    '
    ' if a point's abs(y/x) is greater than maxslope, the point is outside
    ' the view area
    '
    maxslope = finetangent(pixelangle(0))
    maxslope = maxslope \ 256 ' >>= 8
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
        Call StartCPMusic(INTROSONG)

        $If JAPAN = UNDEFINED Then
            If Not NOWAIT Then
                Call PG13
            End If
        $End If
    $End If

    Do
        Do While Not NOWAIT
            '
            ' title page
            '
            $If DEMOTEST = UNDEFINED Then
                $If SPEAR = UNDEFINED Then
                    CA_CacheScreen TITLEPIC
                    VW_UpdateScreen
                    VW_FadeIn
                $Else
                    ' TODO: SPEAR title (TITLEPALETTE, TITLE1PIC, TITLE2PIC)
                $End If
                If IN_UserInput(TickBase * 15) Then Exit Do
                VW_FadeOut
                '
                ' credits page
                '
                CA_CacheScreen CREDITSPIC
                VW_UpdateScreen
                VW_FadeIn
                If IN_UserInput(TickBase * 10) Then Exit Do
                VW_FadeOut
                '
                ' high scores
                '
                DrawHighScores
                VW_UpdateScreen
                VW_FadeIn

                If IN_UserInput(TickBase * 10) Then Exit Do
            $End If
            '
            ' demo
            '
            ' TODO: PlayDemo (LastDemo++ Mod 4), If playstate = ex_abort Then Exit Do
            ' StartCPMusic INTROSONG
            VW_FadeOut ' Temporary: stands in for the fade out done by PlayDemo
        Loop

        VW_FadeOut

        ' TODO: RecordDemo (Tab + "goobers" parameter)
        US_ControlPanel 0

        If startgame Or loadedgame Then
            GameLoop
            VW_FadeOut
            StartCPMusic INTROSONG
        End If
    Loop
End Sub
