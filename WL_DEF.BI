' WL_DEF.BI - Wolfenstein 3D Definitions for QB64

' Game Constants
CONST MAPSIZE = 64
CONST TILEWIDTH = 64
CONST TILEHEIGHT = 64
CONST MAXWALLTILES = 64
CONST MAXACTORS = 150
CONST MAXSTATS = 400
CONST MAXDOORS = 64
CONST MAXPUSHWALLS = 64

' Game States
CONST ex_stillplaying = 0
CONST ex_completed = 1
CONST ex_died = 2
CONST ex_victorious = 3
CONST ex_abort = 4
CONST ex_loaded = 5
CONST ex_quittogame = 6
CONST ex_quittomenu = 7

' Actor States
CONST ac_badobject = -1
CONST ac_removed = 0
CONST ac_ready = 1
CONST ac_attacking = 2
CONST ac_dying = 3
CONST ac_dead = 4

' Weapon Types
CONST wp_knife = 0
CONST wp_pistol = 1
CONST wp_machinegun = 2
CONST wp_chaingun = 3

' Game State Type
TYPE GameStateType
    difficulty AS INTEGER
    episode AS INTEGER
    mapon AS INTEGER
    health AS INTEGER
    ammo AS INTEGER
    lives AS INTEGER
    score AS LONG
    weapon AS INTEGER
    chosenweapon AS INTEGER
    bestweapon AS INTEGER
    nextextra AS INTEGER
    weaponstate(3) AS INTEGER
END TYPE

' Actor Type
TYPE ActorType
    active AS INTEGER
    ticcount AS INTEGER
    x AS LONG
    y AS LONG
    xmove AS LONG
    ymove AS LONG
    dir AS INTEGER
    angle AS INTEGER
    angleinc AS INTEGER
    speed AS INTEGER
    state AS INTEGER
    flags AS INTEGER
    tilex AS INTEGER
    tiley AS INTEGER
    viewx AS INTEGER
    viewy AS INTEGER
    viewheight AS INTEGER
    height AS INTEGER
    width AS INTEGER
    hitextra AS INTEGER
    temp1 AS INTEGER
    temp2 AS INTEGER
    temp3 AS INTEGER
    temp4 AS INTEGER
    temp5 AS INTEGER
    temp6 AS INTEGER
    temp7 AS INTEGER
    temp8 AS INTEGER
    next AS INTEGER
    prev AS INTEGER
END TYPE

' Wall Type
TYPE WallType
    tilex AS INTEGER
    tiley AS INTEGER
    tiletype AS INTEGER
    flags AS INTEGER
END TYPE

' Door Type
TYPE DoorType
    tilex AS INTEGER
    tiley AS INTEGER
    vertical AS INTEGER
    action AS INTEGER
    ticcount AS INTEGER
    lock AS INTEGER
    flags AS INTEGER
END TYPE

' Global Variables
DIM SHARED gamestate AS GameStateType
DIM SHARED player AS ActorType
DIM SHARED actors(MAXACTORS) AS ActorType
DIM SHARED walls(MAPSIZE, MAPSIZE) AS WallType
DIM SHARED doors(MAXDOORS) AS DoorType
DIM SHARED horizwall(MAXWALLTILES) AS INTEGER
DIM SHARED vertwall(MAXWALLTILES) AS INTEGER

' Function Declarations
DECLARE SUB InitGame ()
DECLARE SUB GameLoop ()
DECLARE SUB BuildTables ()
DECLARE SUB SetupWalls ()
DECLARE SUB NewViewSize (width AS INTEGER)
DECLARE SUB CalcProjection (focal AS LONG)
DECLARE SUB Quit (error AS STRING) 