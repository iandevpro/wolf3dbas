' WL_DEF.BI - Wolfenstein 3D Definitions for QB64

' Game Constants
Const MAPSIZE = 64
Const TILEWIDTH = 64
Const TILEHEIGHT = 64
Const MAXWALLTILES = 64
Const MAXACTORS = 150
Const MAXSTATS = 400
Const MAXDOORS = 64
Const MAXPUSHWALLS = 64

' Game States
Const ex_stillplaying = 0
Const ex_completed = 1
Const ex_died = 2
Const ex_victorious = 3
Const ex_abort = 4
Const ex_loaded = 5
Const ex_quittogame = 6
Const ex_quittomenu = 7

' Actor States
Const ac_badobject = -1
Const ac_removed = 0
Const ac_ready = 1
Const ac_attacking = 2
Const ac_dying = 3
Const ac_dead = 4

' Weapon Types
Const wp_knife = 0
Const wp_pistol = 1
Const wp_machinegun = 2
Const wp_chaingun = 3

' Game State Type
Type GameStateType
    difficulty As Integer
    episode As Integer
    mapon As Integer
    health As Integer
    ammo As Integer
    lives As Integer
    score As Long
    weapon As Integer
    chosenweapon As Integer
    bestweapon As Integer
    nextextra As Integer
End Type

' Actor Type
Type ActorType
    active As Integer
    ticcount As Integer
    x As Long
    y As Long
    xmove As Long
    ymove As Long
    dir As Integer
    angle As Integer
    angleinc As Integer
    speed As Integer
    state As Integer
    flags As Integer
    tilex As Integer
    tiley As Integer
    viewx As Integer
    viewy As Integer
    viewheight As Integer
    height As Integer
    width As Integer
    hitextra As Integer
    temp1 As Integer
    temp2 As Integer
    temp3 As Integer
    temp4 As Integer
    temp5 As Integer
    temp6 As Integer
    temp7 As Integer
    temp8 As Integer
    next As Integer
    prev As Integer
End Type

' Wall Type
Type WallType
    tilex As Integer
    tiley As Integer
    tiletype As Integer
    flags As Integer
End Type

' Door Type
Type DoorType
    tilex As Integer
    tiley As Integer
    vertical As Integer
    action As Integer
    ticcount As Integer
    doorlock As Integer
    flags As Integer
End Type

' Global Variables
Dim Shared gamestate As GameStateType
Dim Shared player As ActorType
Dim Shared actors(MAXACTORS) As ActorType
Dim Shared walls(MAPSIZE, MAPSIZE) As WallType
Dim Shared doors(MAXDOORS) As DoorType
Dim Shared horizwall(MAXWALLTILES) As Integer
Dim Shared vertwall(MAXWALLTILES) As Integer
Dim Shared weaponstate(3) As Integer ' Array of 4 weapon states (0-3)

' Function Declarations
DECLARE Sub InitGame ()
DECLARE Sub GameLoop ()
DECLARE Sub BuildTables ()
DECLARE Sub SetupWalls ()
DECLARE Sub NewViewSize (width AS INTEGER)
DECLARE Sub CalcProjection (focal AS LONG)
DECLARE Sub Quit (error AS STRING)
