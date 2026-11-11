' WL_DRAW.C - globals of the 3D refresh
$If INCLUDE_WL_DRAW_BI = UNDEFINED Then
    $Let INCLUDE_WL_DRAW_BI = 1

    Dim Shared wallheight(0 To MAXVIEWWIDTH - 1) As Long ' unsigned

    ' long tileglobal / mindist are the constants TILEGLOBAL / MINDIST (names are case-insensitive)

    Const ACTORSIZE = &H4000

    '
    ' DrawScaleds: the visible objects
    '
    Const MAXVISABLE = 50

    Type visobj_t
        viewx As Integer
        viewheight As Integer
        shapenum As Integer
    End Type

    Dim Shared vislist(0 To MAXVISABLE - 1) As visobj_t

    ' int weaponscale[NUMWEAPONS] = {SPR_KNIFEREADY,SPR_PISTOLREADY,SPR_MACHINEGUNREADY,SPR_CHAINREADY}
    Dim Shared weaponscale(0 To NUMWEAPONS - 1) As Integer
    weaponscale(0) = SPR_KNIFEREADY: weaponscale(1) = SPR_PISTOLREADY
    weaponscale(2) = SPR_MACHINEGUNREADY: weaponscale(3) = SPR_CHAINREADY

    '
    ' math tables (built by BuildTables in WOLF3D.BAS)
    '
    Dim Shared finetangent(0 To FINEANGLES \ 4 - 1) As Long
    ' fixed sintable[ANGLES+ANGLES/4], *costable = sintable+(ANGLES/4)
    ' (the C code writes one entry past the end, it is included here)
    Dim Shared sintable(0 To ANGLES + ANGLES \ 4) As Long
    Dim Shared costable(0 To ANGLES) As Long ' copy of sintable shifted by ANGLES/4

    '
    ' refresh variables
    '
    Dim Shared viewx As Long, viewy As Long ' fixed, the focal point
    Dim Shared viewangle As Integer
    Dim Shared viewsin As Long, viewcos As Long ' fixed

    '
    ' ray tracing variables
    '
    Dim Shared focaltx As Integer, focalty As Integer, viewtx As Integer, viewty As Integer
    Dim Shared midangle As Integer ' (the C global angle is not used, the ray caster keeps it in a register)
    Dim Shared xpartial As Long, ypartial As Long ' unsigned
    Dim Shared xpartialup As Long, xpartialdown As Long, ypartialup As Long, ypartialdown As Long ' unsigned
    Dim Shared xinttile As Long, yinttile As Long ' unsigned
    Dim Shared tilehit As Long ' unsigned
    Dim Shared pixx As Integer ' unsigned
    Dim Shared xtile As Long, ytile As Long
    Dim Shared xtilestep As Long, ytilestep As Long
    Dim Shared xintercept As Long, yintercept As Long
    Dim Shared xstep As Long, ystep As Long

    Dim Shared lastside As Integer ' true for vertical
    Dim Shared lastintercept As Long
    Dim Shared lasttilehit As Long

    ' long postsource: the page in the high word, the texture offset in the low word.
    ' Here postpage is the page offset in PMData and posttex the texture column offset
    Dim Shared postpage As Long
    Dim Shared posttex As Long
    Dim Shared postx As Integer ' unsigned
    Dim Shared postwidth As Integer ' unsigned

    ' screen access while drawing a frame (_MemImage of the Screen 13 page)
    Dim Shared drawscreen As _MEM
    Dim Shared viewscreenx As Integer, viewscreeny As Integer ' top left of the view on the screen

    ' unsigned vgaCeiling[] - ceiling color of each map, from origsrc/WL_DRAW.C
    ' (the color byte doubled in a word)
    Dim Shared vgaCeiling(0 To 59) As Long
    $If SPEAR = UNDEFINED Then
        vgaCeiling(0) = &H1D1D: vgaCeiling(1) = &H1D1D: vgaCeiling(2) = &H1D1D: vgaCeiling(3) = &H1D1D: vgaCeiling(4) = &H1D1D
        vgaCeiling(5) = &H1D1D: vgaCeiling(6) = &H1D1D: vgaCeiling(7) = &H1D1D: vgaCeiling(8) = &H1D1D: vgaCeiling(9) = &HBFBF
        vgaCeiling(10) = &H4E4E: vgaCeiling(11) = &H4E4E: vgaCeiling(12) = &H4E4E: vgaCeiling(13) = &H1D1D: vgaCeiling(14) = &H8D8D
        vgaCeiling(15) = &H4E4E: vgaCeiling(16) = &H1D1D: vgaCeiling(17) = &H2D2D: vgaCeiling(18) = &H1D1D: vgaCeiling(19) = &H8D8D
        vgaCeiling(20) = &H1D1D: vgaCeiling(21) = &H1D1D: vgaCeiling(22) = &H1D1D: vgaCeiling(23) = &H1D1D: vgaCeiling(24) = &H1D1D
        vgaCeiling(25) = &H2D2D: vgaCeiling(26) = &HDDDD: vgaCeiling(27) = &H1D1D: vgaCeiling(28) = &H1D1D: vgaCeiling(29) = &H9898
        vgaCeiling(30) = &H1D1D: vgaCeiling(31) = &H9D9D: vgaCeiling(32) = &H2D2D: vgaCeiling(33) = &HDDDD: vgaCeiling(34) = &HDDDD
        vgaCeiling(35) = &H9D9D: vgaCeiling(36) = &H2D2D: vgaCeiling(37) = &H4D4D: vgaCeiling(38) = &H1D1D: vgaCeiling(39) = &HDDDD
        vgaCeiling(40) = &H7D7D: vgaCeiling(41) = &H1D1D: vgaCeiling(42) = &H2D2D: vgaCeiling(43) = &H2D2D: vgaCeiling(44) = &HDDDD
        vgaCeiling(45) = &HD7D7: vgaCeiling(46) = &H1D1D: vgaCeiling(47) = &H1D1D: vgaCeiling(48) = &H1D1D: vgaCeiling(49) = &H2D2D
        vgaCeiling(50) = &H1D1D: vgaCeiling(51) = &H1D1D: vgaCeiling(52) = &H1D1D: vgaCeiling(53) = &H1D1D: vgaCeiling(54) = &HDDDD
        vgaCeiling(55) = &HDDDD: vgaCeiling(56) = &H7D7D: vgaCeiling(57) = &HDDDD: vgaCeiling(58) = &HDDDD: vgaCeiling(59) = &HDDDD
    $Else
        vgaCeiling(0) = &H6F6F: vgaCeiling(1) = &H4F4F: vgaCeiling(2) = &H1D1D: vgaCeiling(3) = &HDEDE: vgaCeiling(4) = &HDFDF
        vgaCeiling(5) = &H2E2E: vgaCeiling(6) = &H7F7F: vgaCeiling(7) = &H9E9E: vgaCeiling(8) = &HAEAE: vgaCeiling(9) = &H7F7F
        vgaCeiling(10) = &H1D1D: vgaCeiling(11) = &HDEDE: vgaCeiling(12) = &HDFDF: vgaCeiling(13) = &HDEDE: vgaCeiling(14) = &HDFDF
        vgaCeiling(15) = &HDEDE: vgaCeiling(16) = &HE1E1: vgaCeiling(17) = &HDCDC: vgaCeiling(18) = &H2E2E: vgaCeiling(19) = &H1D1D
        vgaCeiling(20) = &HDCDC
    $End If

$End If
