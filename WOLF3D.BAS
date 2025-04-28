' WOLF3D.BAS - QB64 Port of Wolfenstein 3D
' Original by id Software, Port by Claude

' Constants
CONST VIEWGLOBAL = &H10000     ' globals visible flush to wall
CONST VIEWWIDTH = 256          ' size of view window
CONST VIEWHEIGHT = 144
CONST ANGLES = 360
CONST TILEGLOBAL = 65536
CONST MINDIST = 0.5
CONST PI = 3.141592653589793
CONST HEIGHTRATIO = 0.5
CONST MAXWALLTILES = 64

' Global Variables
DIM SHARED FOCALLENGTH AS LONG
FOCALLENGTH = &H5700&    ' in global coordinates
DIM SHARED screenofs AS INTEGER
DIM SHARED centerx AS INTEGER
DIM SHARED shootdelta AS INTEGER
DIM SHARED scale AS LONG
DIM SHARED maxslope AS LONG
DIM SHARED heightnumerator AS LONG
DIM SHARED minheightdiv AS INTEGER

' Game State Variables
DIM SHARED startgame AS INTEGER
DIM SHARED loadedgame AS INTEGER
DIM SHARED virtualreality AS INTEGER
DIM SHARED mouseadjustment AS INTEGER

' File and Episode Variables
DIM SHARED extension AS STRING * 4
DIM SHARED configname AS STRING * 13
DIM SHARED SaveName AS STRING * 13
DIM SHARED PageFileName AS STRING * 13
DIM SHARED audioname AS STRING * 13
DIM SHARED demoname AS STRING * 13
DIM SHARED EpisodeSelect(5) AS INTEGER

' Arrays
DIM SHARED dirangle(8) AS INTEGER
DIM SHARED sintable(ANGLES) AS LONG
DIM SHARED costable(ANGLES) AS LONG
DIM SHARED finetangent(ANGLES/4) AS LONG
DIM SHARED pixelangle(VIEWWIDTH) AS INTEGER
DIM SHARED horizwall(MAXWALLTILES) AS INTEGER
DIM SHARED vertwall(MAXWALLTILES) AS INTEGER

' Main Program
CLS
PRINT "Wolfenstein 3D - QB64 Port"
PRINT "Loading..."

' Check for episode files
CALL CheckForEpisodes

' Initialize game systems
CALL InitGame

' Main game loop
DO
    ' TODO: Implement main game loop
    ' CALL GameLoop
    _LIMIT 60  ' Limit to ~60 FPS
LOOP UNTIL INKEY$ = CHR$(27)  ' ESC to quit

END
' SignonScreen - Displays the game's intro screen
SUB SignonScreen
    ' Set screen mode (320x200 - closest to original VGA mode)
    SCREEN 13

    ' Load the game palette
    LoadGamePalette

    IF NOT virtualreality THEN
        ' Load and display intro screen
        ' Note: We'll need to create/load introscn image data
        DIM introscn(32000) AS INTEGER  ' 320x200 screen buffer
        LoadIntroScreen introscn()

        ' Display the intro screen
        PUT (0, 0), introscn
    END IF

    ' Wait a bit to show the screen
    _DELAY 1
END SUB

' LoadIntroScreen - Loads the intro screen data
SUB LoadIntroScreen(buffer() AS INTEGER)
    ' TODO: Load actual intro screen data
    ' For now, draw a placeholder screen
    CLS
    COLOR 15
    LOCATE 10, 15
    PRINT "Wolfenstein 3D"
    LOCATE 12, 15
    PRINT "QB64 Port"
    LOCATE 14, 15
    PRINT "Press any key to continue..."

    ' Get screen contents into buffer
    GET (0, 0)-(319, 199), buffer
END SUB

' Subroutines
SUB InitGame
    ' Initialize game systems
    CALL BuildTables
    CALL SetupWalls
    CALL NewViewSize(15)  ' Default view size

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
END SUB

SUB CheckForEpisodes
    DIM fileExists AS INTEGER
    DIM i AS INTEGER
    DIM testFile AS STRING

    ' Check for full version (WL6)
    fileExists = 0
    testFile = "VSWAP.WL6"
    IF _FILEEXISTS(testFile) THEN fileExists = 1

    IF fileExists THEN
        extension = "WL6"
        ' Enable all episodes
        FOR i = 1 TO 5
            EpisodeSelect(i) = 1
        NEXT i
    ELSE
        ' Check for shareware version (WL1)
        testFile = "VSWAP.WL1"
        IF _FILEEXISTS(testFile) THEN
            extension = "WL1"
        ELSE
            PRINT "NO WOLFENSTEIN 3-D DATA FILES TO BE FOUND!"
            END
        END IF
    END IF

    ' Append extension to all file names
    configname = configname + extension
    SaveName = SaveName + extension
    PageFileName = PageFileName + extension
    audioname = audioname + extension
    demoname = demoname + extension
END SUB

SUB BuildTables
    ' Build sine/cosine tables
    DIM i AS INTEGER
    DIM angle AS SINGLE
    DIM anglestep AS SINGLE
    DIM tang AS DOUBLE
    DIM value AS LONG

    ' Calculate fine tangents
    FOR i = 0 TO ANGLES/8 - 1
        tang = TAN((i + 0.5) / (ANGLES/2/PI))
        finetangent(i) = tang * TILEGLOBAL
        finetangent(ANGLES/4 - 1 - i) = (1/tang) * TILEGLOBAL
    NEXT i

    ' Build sine/cosine tables
    angle = 0
    anglestep = PI/2/(ANGLES/4)
    FOR i = 0 TO ANGLES/4 - 1
        value = SIN(angle) * &H10000
        sintable(i) = value
        sintable(i + ANGLES/2) = value
        sintable(ANGLES/2 - 1 - i) = value
        sintable(ANGLES - 1 - i) = value OR &H80000000
        sintable(ANGLES/2 + i) = value OR &H80000000
        angle = angle + anglestep
    NEXT i
END SUB

SUB SetupWalls
    ' Initialize wall tile mappings
    DIM i AS INTEGER
    FOR i = 1 TO 63  ' MAXWALLTILES - 1
        horizwall(i) = (i - 1) * 2
        vertwall(i) = (i - 1) * 2 + 1
    NEXT i
END SUB

SUB GameLoop
    ' Main game loop - to be implemented
END SUB

SUB NewViewSize (width AS INTEGER)
    ' Set view size and calculate projection constants
    DIM newwidth AS INTEGER
    DIM newheight AS INTEGER

    ' Calculate view dimensions
    newwidth = width * 16        ' Must be divisible by 16
    newheight = width * 16 * HEIGHTRATIO  ' Must be even

    ' Calculate center and other view parameters
    centerx = newwidth \ 2 - 1
    shootdelta = newwidth \ 10

    ' Calculate projection constants
    CALL CalcProjection(FOCALLENGTH)
END SUB

SUB CalcProjection (focal AS LONG)
    DIM i AS INTEGER
    DIM intang AS LONG
    DIM angle AS SINGLE
    DIM tang AS DOUBLE
    DIM planedist AS DOUBLE
    DIM globinhalf AS DOUBLE
    DIM halfview AS INTEGER
    DIM halfangle AS DOUBLE
    DIM facedist AS DOUBLE

    ' Store focal length
    FOCALLENGTH = focal
    facedist = focal + MINDIST
    halfview = viewwidth \ 2  ' Half view in pixels

    ' Calculate scale value for vertical height calculations
    ' and sprite x calculations
    scale = halfview * facedist \ (VIEWGLOBAL \ 2)

    ' Calculate height numerator for posts distance to get posts height
    ' The pixel height is height >> 2
    heightnumerator = (TILEGLOBAL * scale) \ 64
    minheightdiv = heightnumerator \ &H7FFF + 1

    ' Calculate the angle offset from view angle of each pixel's ray
    FOR i = 0 TO halfview - 1
        ' Start 1/2 pixel over, so viewangle bisects two middle pixels
        tang = i * VIEWGLOBAL / viewwidth / facedist
        angle = ATN(tang)
        intang = angle * (ANGLES \ 2) / PI
        pixelangle(halfview - 1 - i) = intang
        pixelangle(halfview + i) = -intang
    NEXT i

    ' If a point's abs(y/x) is greater than maxslope, the point is outside
    ' the view area
    maxslope = finetangent(pixelangle(0)) \ 256
END SUB 