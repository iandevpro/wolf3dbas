' WL_PLAY.C globals (and a few from WL_GAME / WL_AGENT used by the play loop)
' Needs the sc_ scan codes of ID_IN.BI, include it after that file
$If INCLUDE_WL_PLAY_BI = UNDEFINED Then
    $Let INCLUDE_WL_PLAY_BI = 1

    Dim Shared playstate As Integer ' exit_t
    Dim Shared madenoise As Integer ' true when shooting or screaming
    Dim Shared objcount As Integer
    Dim Shared lasttimecount As Long
    Dim Shared frameon As Long
    Dim Shared running As Integer
    Dim Shared anglefrac As Integer
    Dim Shared funnyticount As Long
    Dim Shared demorecord As Integer, demoplayback As Integer
    Dim Shared singlestep As Integer, godmode As Integer, noclip As Integer
    Dim Shared buttonheld(0 To NUMBUTTONS - 1) As Integer
    Dim Shared controlx As Integer, controly As Integer ' range from -100 to 100 per tic

    Const BASEMOVE = 35
    Const RUNMOVE = 70
    Const BASETURN = 35
    Const RUNTURN = 70
    Const JOYSCALE = 2
    Dim Shared buttonstate(0 To NUMBUTTONS - 1) As Integer

    ' WL_GAME
    Dim Shared fizzlein As Integer

    ' WL_AGENT
    Dim Shared facecount As Integer
    Dim Shared LastAttacker As Integer ' objtype *LastAttacker - objlist index, -1 = NULL
    Dim Shared thrustspeed As Long
    Dim Shared plux As Long, pluy As Long ' player coordinates scaled to unsigned
    Dim Shared playerxmove As Long, playerymove As Long

    Const MOVESCALE = 150
    Const BACKMOVESCALE = 100
    Const ANGLESCALE = 20

    Dim Shared dirscan(0 To 3) As Integer
    Dim Shared buttonscan(0 To NUMBUTTONS - 1) As Integer
    Dim Shared buttonmouse(0 To 3) As Integer
    Dim Shared buttonjoy(0 To 3) As Integer

    ' int dirscan[4] = {sc_UpArrow,sc_RightArrow,sc_DownArrow,sc_LeftArrow};
    dirscan(di_north) = sc_UpArrow: dirscan(di_east) = sc_RightArrow
    dirscan(di_south) = sc_DownArrow: dirscan(di_west) = sc_LeftArrow
    ' int buttonscan[NUMBUTTONS] = {sc_Control,sc_Alt,sc_RShift,sc_Space,sc_1,sc_2,sc_3,sc_4};
    buttonscan(0) = sc_Control: buttonscan(1) = sc_Alt: buttonscan(2) = sc_RShift: buttonscan(3) = sc_Space
    buttonscan(4) = sc_1: buttonscan(5) = sc_2: buttonscan(6) = sc_3: buttonscan(7) = sc_4
    ' int buttonmouse[4]={bt_attack,bt_strafe,bt_use,bt_nobutton};
    buttonmouse(0) = bt_attack: buttonmouse(1) = bt_strafe: buttonmouse(2) = bt_use: buttonmouse(3) = bt_nobutton
    ' int buttonjoy[4]={bt_attack,bt_strafe,bt_use,bt_run};
    buttonjoy(0) = bt_attack: buttonjoy(1) = bt_strafe: buttonjoy(2) = bt_use: buttonjoy(3) = bt_run


    ' int songs[] - music of each map (WL6), generated from origsrc/WL_PLAY.C
    Dim Shared songs(0 To 59) As Integer
    songs(0) = GETTHEM_MUS
    songs(1) = SEARCHN_MUS
    songs(2) = POW_MUS
    songs(3) = SUSPENSE_MUS
    songs(4) = GETTHEM_MUS
    songs(5) = SEARCHN_MUS
    songs(6) = POW_MUS
    songs(7) = SUSPENSE_MUS
    songs(8) = WARMARCH_MUS
    songs(9) = CORNER_MUS
    songs(10) = NAZI_OMI_MUS
    songs(11) = PREGNANT_MUS
    songs(12) = GOINGAFT_MUS
    songs(13) = HEADACHE_MUS
    songs(14) = NAZI_OMI_MUS
    songs(15) = PREGNANT_MUS
    songs(16) = HEADACHE_MUS
    songs(17) = GOINGAFT_MUS
    songs(18) = WARMARCH_MUS
    songs(19) = DUNGEON_MUS
    songs(20) = INTROCW3_MUS
    songs(21) = NAZI_RAP_MUS
    songs(22) = TWELFTH_MUS
    songs(23) = ZEROHOUR_MUS
    songs(24) = INTROCW3_MUS
    songs(25) = NAZI_RAP_MUS
    songs(26) = TWELFTH_MUS
    songs(27) = ZEROHOUR_MUS
    songs(28) = ULTIMATE_MUS
    songs(29) = PACMAN_MUS
    songs(30) = GETTHEM_MUS
    songs(31) = SEARCHN_MUS
    songs(32) = POW_MUS
    songs(33) = SUSPENSE_MUS
    songs(34) = GETTHEM_MUS
    songs(35) = SEARCHN_MUS
    songs(36) = POW_MUS
    songs(37) = SUSPENSE_MUS
    songs(38) = WARMARCH_MUS
    songs(39) = CORNER_MUS
    songs(40) = NAZI_OMI_MUS
    songs(41) = PREGNANT_MUS
    songs(42) = GOINGAFT_MUS
    songs(43) = HEADACHE_MUS
    songs(44) = NAZI_OMI_MUS
    songs(45) = PREGNANT_MUS
    songs(46) = HEADACHE_MUS
    songs(47) = GOINGAFT_MUS
    songs(48) = WARMARCH_MUS
    songs(49) = DUNGEON_MUS
    songs(50) = INTROCW3_MUS
    songs(51) = NAZI_RAP_MUS
    songs(52) = TWELFTH_MUS
    songs(53) = ZEROHOUR_MUS
    songs(54) = INTROCW3_MUS
    songs(55) = NAZI_RAP_MUS
    songs(56) = TWELFTH_MUS
    songs(57) = ZEROHOUR_MUS
    songs(58) = ULTIMATE_MUS
    songs(59) = FUNKYOU_MUS

$End If
