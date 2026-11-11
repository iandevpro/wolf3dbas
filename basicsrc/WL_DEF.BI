' WL_DEF.H - Wolfenstein 3D definitions
'
' Pointers of the C structures are array indices here:
' - objlist(), statobjlist(), doorobjlist() replace the linked structures; -1 = NULL
' - actorat(x, y): 0 = empty, 1..255 = wall tile (as in C), OBJ_BASE + index = object in objlist()
' - statetype.nextstate and objtype.state are indices in the state table (step 6g),
'   think / action are routine ids dispatched with Select Case (QB64 has no function pointers)

$If INCLUDE_WL_DEF_BI = UNDEFINED Then
    $Let INCLUDE_WL_DEF_BI = 1

    '$INCLUDE: 'WL_SPR.BI'

    '
    ' =============================================================================
    '                          GLOBAL CONSTANTS
    ' =============================================================================
    '
    Const MAXACTORS = 150 ' max number of nazis, etc / map
    Const MAXSTATS = 400 ' max number of lamps, bonus, etc
    Const MAXDOORS = 64 ' max number of sliding doors
    Const MAXWALLTILES = 64 ' max number of wall tiles

    '
    ' tile constants
    '
    Const ICONARROWS = 90
    Const PUSHABLETILE = 98
    Const EXITTILE = 99 ' at end of castle
    Const AREATILE = 107 ' first of NUMAREAS floor tiles
    Const NUMAREAS = 37
    Const ELEVATORTILE = 21
    Const AMBUSHTILE = 106
    Const ALTELEVATORTILE = 107

    Const NUMBERCHARS = 9

    '----------------

    Const EXTRAPOINTS = 40000

    Const PLAYERSPEED = 3000
    Const RUNSPEED = 6000

    Const SCREENBWIDE = 80

    Const HEIGHTRATIO = 0.50 ' also defined in id_mm.c

    Const BORDERCOLOR = 3
    Const FLASHCOLOR = 5
    Const FLASHTICS = 4

    Const MINDIST = &H5800& ' (0x5800l)
    Const PLAYERSIZE = MINDIST ' player radius
    Const MINACTORDIST = &H10000 ' minimum dist from player center to any actor center

    Const NUMLATCHPICS = 100

    Const PI = 3.141592657

    Const GLOBAL1 = &H10000 ' (1l<<16)
    Const TILEGLOBAL = GLOBAL1
    Const PIXGLOBAL = GLOBAL1 \ 64
    Const TILESHIFT = 16
    Const UNSIGNEDSHIFT = 8

    Const ANGLES = 360 ' must be divisable by 4
    Const ANGLEQUAD = ANGLES \ 4
    Const FINEANGLES = 3600
    Const ANG90 = FINEANGLES \ 4
    Const ANG180 = ANG90 * 2
    Const ANG270 = ANG90 * 3
    Const ANG360 = ANG90 * 4
    Const VANG90 = ANGLES \ 4
    Const VANG180 = VANG90 * 2
    Const VANG270 = VANG90 * 3
    Const VANG360 = VANG90 * 4

    Const MAXSCALEHEIGHT = 256 ' largest scale on largest view

    Const MAXVIEWWIDTH = 320

    Const MAPSIZE = 64 ' maps are 64*64 max
    Const NORTH = 0
    Const EAST = 1
    Const SOUTH = 2
    Const WEST = 3

    Const STATUSLINES = 40

    Const SCREENSIZE = SCREENBWIDE * 208
    Const PAGE1START = 0
    Const PAGE2START = SCREENSIZE
    Const PAGE3START = SCREENSIZE * 2
    Const FREESTART = SCREENSIZE * 3

    Const PIXRADIUS = 512

    Const STARTAMMO = 8

    ' object flag values
    Const FL_SHOOTABLE = 1
    Const FL_BONUS = 2
    Const FL_NEVERMARK = 4
    Const FL_VISABLE = 8
    Const FL_ATTACKMODE = 16
    Const FL_FIRSTATTACK = 32
    Const FL_AMBUSH = 64
    Const FL_NONMARK = 128

    ' sprite constants: WL_SPR.BI

    '
    ' =============================================================================
    '                            GLOBAL TYPES
    ' =============================================================================
    '
    ' typedef long fixed; - fixed point 16.16 values are Long

    ' controldir_t (dirscan indices)
    Const di_north = 0
    Const di_east = 1
    Const di_south = 2
    Const di_west = 3

    ' door_t
    Const dr_normal = 0
    Const dr_lock1 = 1
    Const dr_lock2 = 2
    Const dr_lock3 = 3
    Const dr_lock4 = 4
    Const dr_elevator = 5

    ' activetype
    Const ac_badobject = -1
    Const ac_no = 0
    Const ac_yes = 1
    Const ac_allways = 2

    ' classtype
    Const nothing = 0
    Const playerobj = 1
    Const inertobj = 2
    Const guardobj = 3
    Const officerobj = 4
    Const ssobj = 5
    Const dogobj = 6
    Const bossobj = 7
    Const schabbobj = 8
    Const fakeobj = 9
    Const mechahitlerobj = 10
    Const mutantobj = 11
    Const needleobj = 12
    Const fireobj = 13
    Const bjobj = 14
    Const ghostobj = 15
    Const realhitlerobj = 16
    Const gretelobj = 17
    Const giftobj = 18
    Const fatobj = 19
    Const rocketobj = 20
    Const spectreobj = 21
    Const angelobj = 22
    Const transobj = 23
    Const uberobj = 24
    Const willobj = 25
    Const deathobj = 26
    Const hrocketobj = 27
    Const sparkobj = 28

    ' stat_t
    Const dressing = 0
    Const block = 1
    Const bo_gibs = 2
    Const bo_alpo = 3
    Const bo_firstaid = 4
    Const bo_key1 = 5
    Const bo_key2 = 6
    Const bo_key3 = 7
    Const bo_key4 = 8
    Const bo_cross = 9
    Const bo_chalice = 10
    Const bo_bible = 11
    Const bo_crown = 12
    Const bo_clip = 13
    Const bo_clip2 = 14
    Const bo_machinegun = 15
    Const bo_chaingun = 16
    Const bo_food = 17
    Const bo_fullheal = 18
    Const bo_25clip = 19
    Const bo_spear = 20

    ' dirtype, prefixed with dt_: QB64 names are case insensitive and the NORTH / EAST...
    ' defines above have other values
    Const dt_east = 0
    Const dt_northeast = 1
    Const dt_north = 2
    Const dt_northwest = 3
    Const dt_west = 4
    Const dt_southwest = 5
    Const dt_south = 6
    Const dt_southeast = 7
    Const dt_nodir = 8

    Const NUMENEMIES = 22
    ' enemy_t
    Const en_guard = 0
    Const en_officer = 1
    Const en_ss = 2
    Const en_dog = 3
    Const en_boss = 4
    Const en_schabbs = 5
    Const en_fake = 6
    Const en_hitler = 7
    Const en_mutant = 8
    Const en_blinky = 9
    Const en_clyde = 10
    Const en_pinky = 11
    Const en_inky = 12
    Const en_gretel = 13
    Const en_gift = 14
    Const en_fat = 15
    Const en_spectre = 16
    Const en_angel = 17
    Const en_trans = 18
    Const en_uber = 19
    Const en_will = 20
    Const en_death = 21

    '
    ' state structure
    '
    Type statetype
        rotate As Integer
        shapenum As Integer ' a shapenum of -1 means get from ob->temp1
        tictime As Integer
        think As Integer ' routine id (C: function pointer)
        action As Integer ' routine id (C: function pointer)
        nextstate As Integer ' state index (C: struct statestruct *next)
    End Type

    '---------------------
    '
    ' trivial actor structure
    '
    '---------------------
    Type statobj_t
        tilex As Integer ' byte
        tiley As Integer ' byte
        visspot As Integer ' byte *visspot: index tilex * MAPSIZE + tiley into spotvis()
        shapenum As Integer ' if shapenum == -1 the obj has been removed
        flags As Integer ' byte
        itemnumber As Integer ' byte
    End Type

    '---------------------
    '
    ' door actor structure
    '
    '---------------------
    ' action: enum {dr_open,dr_closed,dr_opening,dr_closing}
    Const dr_open = 0
    Const dr_closed = 1
    Const dr_opening = 2
    Const dr_closing = 3

    Type doorobj_t
        tilex As Integer ' byte
        tiley As Integer ' byte
        vertical As Integer ' boolean
        doorlock As Integer ' byte lock (LOCK is a QB64 keyword)
        action As Integer
        ticcount As Integer
    End Type

    '--------------------
    '
    ' thinking actor structure
    '
    '--------------------
    Type objtype
        active As Integer ' activetype
        ticcount As Integer
        obclass As Integer ' classtype
        state As Integer ' statetype *state - state index
        flags As Integer ' byte, FL_SHOOTABLE, etc
        distance As Long ' if negative, wait for that door to open
        dir As Integer ' dirtype
        x As Long ' fixed
        y As Long ' fixed
        tilex As Long ' unsigned
        tiley As Long ' unsigned
        areanumber As Integer ' byte
        viewx As Integer
        viewheight As Long ' unsigned
        transx As Long ' fixed, in global coord
        transy As Long ' fixed
        angle As Integer
        hitpoints As Integer
        speed As Long
        temp1 As Integer
        temp2 As Integer
        temp3 As Integer
        nextobj As Integer ' struct objstruct *next - objlist index, -1 = NULL
        prevobj As Integer ' struct objstruct *prev - objlist index, -1 = NULL
    End Type

    Const NUMBUTTONS = 8
    Const bt_nobutton = -1
    Const bt_attack = 0
    Const bt_strafe = 1
    Const bt_run = 2
    Const bt_use = 3
    Const bt_readyknife = 4
    Const bt_readypistol = 5
    Const bt_readymachinegun = 6
    Const bt_readychaingun = 7

    Const NUMWEAPONS = 5
    ' weapontype
    Const wp_knife = 0
    Const wp_pistol = 1
    Const wp_machinegun = 2
    Const wp_chaingun = 3

    ' difficulty
    Const gd_baby = 0
    Const gd_easy = 1
    Const gd_medium = 2
    Const gd_hard = 3

    '---------------
    '
    ' gamestate structure
    '
    '---------------
    Type gametype
        difficulty As Integer
        mapon As Integer
        oldscore As Long
        score As Long
        nextextra As Long
        lives As Integer
        health As Integer
        ammo As Integer
        keys As Integer
        bestweapon As Integer ' weapontype
        weapon As Integer
        chosenweapon As Integer
        faceframe As Integer
        attackframe As Integer
        attackcount As Integer
        weaponframe As Integer
        episode As Integer
        secretcount As Integer
        treasurecount As Integer
        killcount As Integer
        secrettotal As Integer
        treasuretotal As Integer
        killtotal As Integer
        TimeCount As Long
        killx As Long
        killy As Long
        victoryflag As Integer ' boolean, set during victory animations
    End Type

    ' exit_t
    Const ex_stillplaying = 0
    Const ex_completed = 1
    Const ex_died = 2
    Const ex_warped = 3
    Const ex_resetgame = 4
    Const ex_loadedgame = 5
    Const ex_victorious = 6
    Const ex_abort = 7
    Const ex_demodone = 8
    Const ex_secretlevel = 9

    '
    ' actorat() value of an object (C stores the objtype pointer, which is always > 255)
    '
    Const OBJ_BASE = 256

    '
    ' =============================================================================
    '                          GLOBAL VARIABLES
    ' =============================================================================
    '
    ' WL_MAIN
    Dim Shared joypadenabled As Integer
    Dim Shared joystickport As Integer

    ' WL_GAME
    Dim Shared ingame As Integer ' true while a game is running (menus show Back to Game)
    Dim Shared gamestate As gametype

    ' WL_PLAY: objtype objlist[MAXACTORS],*new,*obj,*player,*lastobj,*objfreelist,*killerobj
    Dim Shared objlist(0 To MAXACTORS - 1) As objtype
    Dim Shared newobj As Integer ' *new (NEW is a QB64 keyword)
    Dim Shared obj As Integer
    Dim Shared player As Integer
    Dim Shared lastobj As Integer
    Dim Shared objfreelist As Integer
    Dim Shared killerobj As Integer

    ' WL_ACT1: statobj_t statobjlist[MAXSTATS],*laststatobj; doorobj_t doorobjlist[MAXDOORS],*lastdoorobj
    Dim Shared statobjlist(0 To MAXSTATS - 1) As statobj_t
    Dim Shared laststatobj As Integer
    Dim Shared doorobjlist(0 To MAXDOORS - 1) As doorobj_t
    Dim Shared lastdoorobj As Integer

    ' WL_PLAY: map
    Dim Shared tilemap(0 To MAPSIZE - 1, 0 To MAPSIZE - 1) As _Unsigned _Byte ' wall values only
    Dim Shared spotvis(0 To MAPSIZE - 1, 0 To MAPSIZE - 1) As _Unsigned _Byte
    Dim Shared actorat(0 To MAPSIZE - 1, 0 To MAPSIZE - 1) As Integer ' see OBJ_BASE

    ' WL_DRAW
    Dim Shared horizwall(0 To MAXWALLTILES - 1) As Integer
    Dim Shared vertwall(0 To MAXWALLTILES - 1) As Integer

    ' Function declarations
    Declare Sub InitGame ()
    Declare Sub BuildTables ()
    Declare Sub SetupWalls ()
    Declare Sub NewViewSize (width As Integer)
    Declare Sub CalcProjection (focal As Long)
    Declare Sub Quit (errmsg As String)
    Declare Function FixedByFrac& (a As Long, b As Long)

    '$INCLUDE: 'ID_HEADS.BI'
    '$INCLUDE: 'WL_MENU.BI'
$End If
