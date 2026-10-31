' WL_MENU.H'
' simulate IFDEFs settings
$If INCLUDE_WL_MENU_BI = UNDEFINED Then
    $Let INCLUDE_WL_MENU_BI = 1

    $If SPEAR = DEFINED Then
            Const BORDCOLOR = &H99
            Const BORD2COLOR = &H93
            Const DEACTIVE = &H9B
            Const BKGDCOLOR = &H9D
    $Else
        Const BORDCOLOR = &H29
        Const BORD2COLOR = &H23
        Const DEACTIVE = &H2B
        Const BKGDCOLOR = &H2D
        Const STRIPE = &H2C
    $End If

    Const READCOLOR = &H4A
    Const READHCOLOR = &H47
    Const VIEWCOLOR = &H7F
    Const TEXTCOLOR = &H17
    Const HIGHLIGHT = &H13

    $If SPEAR = UNDEFINED Then
        Const INTROSONG = 7 ' NAZI_NOR_MUS
    $Else
            Const INTROSONG = 23 ' XTOWER2_MUS
    $End If

    Dim Shared menulastmusic As Integer ' static int lastmusic in WL_MENU.C, renamed: it clashes with LASTMUSIC

    Const MENUSONG = WONDERIN_MUS

    Const SENSITIVE = 60
    Const CENTER = SENSITIVE * 2

    Const MENU_X = 76
    Const MENU_Y = 55
    Const MENU_W = 178
    $If SPEAR = UNDEFINED Then
        Const MENU_H = 13 * 10 + 6
    $Else
            Const MENU_H = 13 * 9 + 6
    $End If

    '
    ' TYPEDEFS
    '
    Type CP_iteminfo
        x As Integer
        y As Integer
        amount As Integer
        curpos As Integer
        indent As Integer
    End Type

    ' "string" and the routine pointer of the C struct: txt and a routine id (CP_CallRoutine)
    Type CP_itemtype
        active As Integer
        txt As String * 36
        routine As Integer
    End Type

    ' Routine ids of menu items (C function pointers), 0 = none
    Const RTN_NONE = 0
    Const RTN_NEWGAME = 1
    Const RTN_SOUND = 2
    Const RTN_CONTROL = 3
    Const RTN_LOADGAME = 4
    Const RTN_SAVEGAME = 5
    Const RTN_CHANGEVIEW = 6
    Const RTN_READTHIS = 7
    Const RTN_VIEWSCORES = 8

    ' Ids of the custom draw routines passed to HandleMenu, 0 = none (TODO with the sub menus)
    Const DRAWRTN_NONE = 0

    ' menuitems enum, prefixed with mi_: QB64 names are case insensitive (Quit, NewGame subs)
    Const mi_newgame = 0
    Const mi_soundmenu = 1
    Const mi_control = 2
    Const mi_loadgame = 3
    Const mi_savegame = 4
    Const mi_changeview = 5
    ' READTHIS_ITEM: GOODTIMES and SPEAR have no "Read This!" item
    $Let READTHIS_ITEM = 1
    $If GOODTIMES = DEFINED Then
            $Let READTHIS_ITEM = 0
    $End If
    $If SPEAR = DEFINED Then
            $Let READTHIS_ITEM = 0
    $End If
    $If READTHIS_ITEM = 1 Then
        Const mi_readthis = 6
        Const mi_viewscores = 7
        Const mi_backtodemo = 8
        Const mi_quit = 9
        Const MAINMENU_ITEMS = 10
        Const STARTITEM = mi_readthis
    $Else
            Const mi_viewscores = 6
            Const mi_backtodemo = 7
            Const mi_quit = 8
            Const MAINMENU_ITEMS = 9
            Const STARTITEM = mi_newgame
    $End If

    ' Menu strings (FOREIGN.H)
    Const STR_NG = "New Game"
    Const STR_SD = "Sound"
    Const STR_CL = "Control"
    Const STR_LG = "Load Game"
    Const STR_SG = "Save Game"
    Const STR_CV = "Change View"
    Const STR_VS = "View Scores"
    Const STR_EG = "End Game"
    Const STR_BD = "Back to Demo"
    Const STR_QT = "Quit"
    Const STR_GAME = "Game"
    Const STR_DEMO = "Demo"

    Dim Shared MainItems As CP_iteminfo
    Dim Shared MainMenu(0 To MAINMENU_ITEMS - 1) As CP_itemtype
    Dim Shared endStrings(0 To 8) As String
    Dim Shared color_hlite(0 To 3) As Integer
    Dim Shared color_norml(0 To 3) As Integer
    ' StartGame in WL_MENU.C, renamed: QB64 names are case insensitive and startgame exists
    Dim Shared StartGameMenu As Integer
    Dim Shared SoundStatus As Integer
    Dim Shared SaveGamesAvail(0 To 9) As Integer

    ' CP_iteminfo MainItems={MENU_X,MENU_Y,10,STARTITEM,24}
    MainItems.x = MENU_X: MainItems.y = MENU_Y: MainItems.amount = MAINMENU_ITEMS
    MainItems.curpos = STARTITEM: MainItems.indent = 24

    MainMenu(mi_newgame).active = 1: MainMenu(mi_newgame).txt = STR_NG: MainMenu(mi_newgame).routine = RTN_NEWGAME
    MainMenu(mi_soundmenu).active = 1: MainMenu(mi_soundmenu).txt = STR_SD: MainMenu(mi_soundmenu).routine = RTN_SOUND
    MainMenu(mi_control).active = 1: MainMenu(mi_control).txt = STR_CL: MainMenu(mi_control).routine = RTN_CONTROL
    MainMenu(mi_loadgame).active = 1: MainMenu(mi_loadgame).txt = STR_LG: MainMenu(mi_loadgame).routine = RTN_LOADGAME
    MainMenu(mi_savegame).active = 0: MainMenu(mi_savegame).txt = STR_SG: MainMenu(mi_savegame).routine = RTN_SAVEGAME
    MainMenu(mi_changeview).active = 1: MainMenu(mi_changeview).txt = STR_CV: MainMenu(mi_changeview).routine = RTN_CHANGEVIEW
    $If READTHIS_ITEM = 1 Then
        $If SPANISH = DEFINED Then
                MainMenu(mi_readthis).active = 2: MainMenu(mi_readthis).txt = "Ve esto!": MainMenu(mi_readthis).routine = RTN_READTHIS
        $Else
            MainMenu(mi_readthis).active = 2: MainMenu(mi_readthis).txt = "Read This!": MainMenu(mi_readthis).routine = RTN_READTHIS
        $End If
    $End If
    MainMenu(mi_viewscores).active = 1: MainMenu(mi_viewscores).txt = STR_VS: MainMenu(mi_viewscores).routine = RTN_VIEWSCORES
    MainMenu(mi_backtodemo).active = 1: MainMenu(mi_backtodemo).txt = STR_BD: MainMenu(mi_backtodemo).routine = RTN_NONE
    MainMenu(mi_quit).active = 1: MainMenu(mi_quit).txt = STR_QT: MainMenu(mi_quit).routine = RTN_NONE

    $If SPEAR = UNDEFINED Then
        endStrings(0) = "Dost thou wish to" + Chr$(10) + "leave with such hasty" + Chr$(10) + "abandon?"
        endStrings(1) = "Chickening out..." + Chr$(10) + "already?"
        endStrings(2) = "Press N for more carnage." + Chr$(10) + "Press Y to be a weenie."
        endStrings(3) = "So, you think you can" + Chr$(10) + "quit this easily, huh?"
        endStrings(4) = "Press N to save the world." + Chr$(10) + "Press Y to abandon it in" + Chr$(10) + "its hour of need."
        endStrings(5) = "Press N if you are brave." + Chr$(10) + "Press Y to cower in shame."
        endStrings(6) = "Heroes, press N." + Chr$(10) + "Wimps, press Y."
        endStrings(7) = "You are at an intersection." + Chr$(10) + "A sign says, 'Press Y to quit.'" + Chr$(10) + ">"
        endStrings(8) = "For guns and glory, press N." + Chr$(10) + "For work and worry, press Y."
    $Else
            ' TODO: ENDSTR1..ENDSTR9 for SPEAR (FOREIGN.H)
    $End If

    color_hlite(0) = DEACTIVE: color_hlite(1) = HIGHLIGHT: color_hlite(2) = READHCOLOR: color_hlite(3) = &H67
    color_norml(0) = DEACTIVE: color_norml(1) = TEXTCOLOR: color_norml(2) = READCOLOR: color_norml(3) = &H6B
    SoundStatus = 1

    ' Sub menu positions (WL_MENU.H)
    Const SM_X = 48
    Const SM_W = 250
    Const SM_Y1 = 20
    Const SM_H1 = 4 * 13 - 7
    Const SM_Y2 = SM_Y1 + 5 * 13
    Const SM_H2 = 4 * 13 - 7
    Const SM_Y3 = SM_Y2 + 5 * 13
    Const SM_H3 = 3 * 13 - 7

    Const CTL_X = 24
    Const CTL_Y = 70
    Const CTL_W = 284
    Const CTL_H = 13 * 7 - 7

    Const NM_X = 50
    Const NM_Y = 100
    Const NM_W = 225
    Const NM_H = 13 * 4 + 15

    Const NE_X = 10
    Const NE_Y = 23
    Const NE_W = 320 - NE_X * 2
    Const NE_H = 200 - NE_Y * 2

    Const CST_X = 20
    Const CST_Y = 48
    Const CST_START = 60
    Const CST_SPC = 60

    ' More menu routine ids (see RTN_NONE)
    Const RTN_MOUSESENS = 9
    Const RTN_CUSTOMIZE = 10

    ' More draw routine ids (see DRAWRTN_NONE)
    Const DRAWRTN_NEWGAMEDIFF = 1
    Const DRAWRTN_FIXUPCUSTOM = 2

    ' enum {MOUSE,JOYSTICK,KEYBOARDBTNS,KEYBOARDMOVE}; // FOR INPUT TYPES
    Const CTRL_MOUSE = 0
    Const CTRL_JOYSTICK = 1
    Const CTRL_KEYBOARDBTNS = 2
    Const CTRL_KEYBOARDMOVE = 3

    ' CP_Control items: enum {MOUSEENABLE,JOYENABLE,USEPORT2,PADENABLE,MOUSESENS,CUSTOMIZE};
    Const CTL_MOUSEENABLE = 0
    Const CTL_JOYENABLE = 1
    Const CTL_USEPORT2 = 2
    Const CTL_PADENABLE = 3
    Const CTL_MOUSESENS = 4
    Const CTL_CUSTOMIZE = 5

    Const STR_NONE = "None"
    Const STR_PC = "PC Speaker"
    Const STR_ALSB = "AdLib/Sound Blaster"
    Const STR_DISNEY = "Disney Sound Source"
    Const STR_SB = "Sound Blaster"

    Const STR_MOUSEEN = "Mouse Enabled"
    Const STR_JOYEN = "Joystick Enabled"
    Const STR_PORT2 = "Use joystick port 2"
    Const STR_GAMEPAD = "Gravis GamePad Enabled"
    Const STR_SENS = "Mouse Sensitivity"
    Const STR_CUSTOM = "Customize controls"

    Const STR_DADDY = "Can I play, Daddy?"
    Const STR_HURTME = "Don't hurt me."
    Const STR_BRINGEM = "Bring 'em on!"
    Const STR_DEATH = "I am Death incarnate!"

    Const STR_MOUSEADJ = "Adjust Mouse Sensitivity"
    Const STR_SLOW = "Slow"
    Const STR_FAST = "Fast"

    Const STR_CRUN = "Run"
    Const STR_COPEN = "Open"
    Const STR_CFIRE = "Fire"
    Const STR_CSTRAFE = "Strafe"

    Const STR_LEFT = "Left"
    Const STR_RIGHT = "Right"
    Const STR_FRWD = "Frwd"
    Const STR_BKWD = "Bkwrd"
    Const STR_THINK = "Thinking"

    Const STR_SIZE1 = "Use arrows to size"
    Const STR_SIZE2 = "ENTER to accept"
    Const STR_SIZE3 = "ESC to cancel"

    Dim Shared SndItems As CP_iteminfo, CtlItems As CP_iteminfo, CusItems As CP_iteminfo
    Dim Shared NewEitems As CP_iteminfo, NewItems As CP_iteminfo
    Dim Shared SndMenu(0 To 11) As CP_itemtype
    Dim Shared CtlMenu(0 To 5) As CP_itemtype
    Dim Shared CusMenu(0 To 8) As CP_itemtype
    Dim Shared NewEmenu(0 To 10) As CP_itemtype
    Dim Shared NewMenu(0 To 3) As CP_itemtype
    Dim Shared CURGAME As String
    Dim Shared pickquick As Integer

    ' Custom controls: order[4]={RUN,OPEN,FIRE,STRAFE} (= bt_run, bt_use, bt_attack, bt_strafe),
    ' moveorder[4]={LEFT,RIGHT,FWRD,BKWD} (= di_west, di_east, di_north, di_south),
    ' mbarray[4][3]={"b0","b1","b2","b3"}
    Dim Shared order(0 To 3) As Integer
    Dim Shared moveorder(0 To 3) As Integer
    order(0) = bt_run: order(1) = bt_use: order(2) = bt_attack: order(3) = bt_strafe
    moveorder(0) = di_west: moveorder(1) = di_east: moveorder(2) = di_north: moveorder(3) = di_south

    CURGAME = "You are currently in" + Chr$(10) + "a game. Continuing will" + Chr$(10) + "erase old game. Ok?"

    ' SndItems={SM_X,SM_Y1,12,0,52}
    SndItems.x = SM_X: SndItems.y = SM_Y1: SndItems.amount = 12: SndItems.curpos = 0: SndItems.indent = 52
    ' CtlItems={CTL_X,CTL_Y,6,-1,56}
    CtlItems.x = CTL_X: CtlItems.y = CTL_Y: CtlItems.amount = 6: CtlItems.curpos = -1: CtlItems.indent = 56
    ' CusItems={8,CST_Y+13*2,9,-1,0}
    CusItems.x = 8: CusItems.y = CST_Y + 13 * 2: CusItems.amount = 9: CusItems.curpos = -1: CusItems.indent = 0
    ' NewEitems={NE_X,NE_Y,11,0,88}
    NewEitems.x = NE_X: NewEitems.y = NE_Y: NewEitems.amount = 11: NewEitems.curpos = 0: NewEitems.indent = 88
    ' NewItems={NM_X,NM_Y,4,2,24}
    NewItems.x = NM_X: NewItems.y = NM_Y: NewItems.amount = 4: NewItems.curpos = 2: NewItems.indent = 24

    SndMenu(0).active = 1: SndMenu(0).txt = STR_NONE
    SndMenu(1).active = 1: SndMenu(1).txt = STR_PC
    SndMenu(2).active = 1: SndMenu(2).txt = STR_ALSB
    SndMenu(5).active = 1: SndMenu(5).txt = STR_NONE
    SndMenu(6).active = 1: SndMenu(6).txt = STR_DISNEY
    SndMenu(7).active = 1: SndMenu(7).txt = STR_SB
    SndMenu(10).active = 1: SndMenu(10).txt = STR_NONE
    SndMenu(11).active = 1: SndMenu(11).txt = STR_ALSB

    CtlMenu(0).txt = STR_MOUSEEN
    CtlMenu(1).txt = STR_JOYEN
    CtlMenu(2).txt = STR_PORT2
    CtlMenu(3).txt = STR_GAMEPAD
    CtlMenu(4).txt = STR_SENS: CtlMenu(4).routine = RTN_MOUSESENS
    CtlMenu(5).active = 1: CtlMenu(5).txt = STR_CUSTOM: CtlMenu(5).routine = RTN_CUSTOMIZE

    CusMenu(0).active = 1: CusMenu(3).active = 1: CusMenu(6).active = 1: CusMenu(8).active = 1

    $If SPANISH = DEFINED Then
            NewEmenu(0).active = 1: NewEmenu(0).txt = "Episodio 1" + Chr$(10) + "Fuga desde Wolfenstein"
            NewEmenu(2).active = 3: NewEmenu(2).txt = "Episodio 2" + Chr$(10) + "Operacion Eisenfaust"
            NewEmenu(4).active = 3: NewEmenu(4).txt = "Episodio 3" + Chr$(10) + "Muere, Fuhrer, Muere!"
            NewEmenu(6).active = 3: NewEmenu(6).txt = "Episodio 4" + Chr$(10) + "Un Negro Secreto"
            NewEmenu(8).active = 3: NewEmenu(8).txt = "Episodio 5" + Chr$(10) + "Huellas del Loco"
            NewEmenu(10).active = 3: NewEmenu(10).txt = "Episodio 6" + Chr$(10) + "Confrontacion"
    $Else
        NewEmenu(0).active = 1: NewEmenu(0).txt = "Episode 1" + Chr$(10) + "Escape from Wolfenstein"
        NewEmenu(2).active = 3: NewEmenu(2).txt = "Episode 2" + Chr$(10) + "Operation: Eisenfaust"
        NewEmenu(4).active = 3: NewEmenu(4).txt = "Episode 3" + Chr$(10) + "Die, Fuhrer, Die!"
        NewEmenu(6).active = 3: NewEmenu(6).txt = "Episode 4" + Chr$(10) + "A Dark Secret"
        NewEmenu(8).active = 3: NewEmenu(8).txt = "Episode 5" + Chr$(10) + "Trail of the Madman"
        NewEmenu(10).active = 3: NewEmenu(10).txt = "Episode 6" + Chr$(10) + "Confrontation"
    $End If

    NewMenu(0).active = 1: NewMenu(0).txt = STR_DADDY
    NewMenu(1).active = 1: NewMenu(1).txt = STR_HURTME
    NewMenu(2).active = 1: NewMenu(2).txt = STR_BRINGEM
    NewMenu(3).active = 1: NewMenu(3).txt = STR_DEATH

    ' Load / save menu
    Const LSM_X = 85
    Const LSM_Y = 55
    Const LSM_W = 175
    Const LSM_H = 10 * 13 + 10

    ' DrawLSAction window
    Const LSA_X = 96
    Const LSA_Y = 80
    Const LSA_W = 130
    Const LSA_H = 42

    Const DRAWRTN_TRACKWHICHGAME = 3

    Const STR_LOADING = "Loading"
    Const STR_SAVING = "Saving"
    Const STR_EMPTY = "empty"

    Dim Shared LSItems As CP_iteminfo
    Dim Shared LSMenu(0 To 9) As CP_itemtype
    Dim Shared SaveGameNames(0 To 9) As String ' char SaveGameNames[10][32]
    Dim Shared GAMESVD As String
    Dim Shared ENDGAMESTR As String

    Const STR_LGC = "Load Game called" ' + "\n\"" (added where used)
    Const STR_SAVECHT1 = "Your Save Game file is,"
    Dim Shared STR_SAVECHT2 As String ' (Chr$ can't be in a Const)
    Const STR_SAVECHT3 = "But I'll let you go on and"
    Const STR_SAVECHT4 = "play anyway...."
    Const STR_CHEATER1 = "You now have 100% Health,"
    Const STR_CHEATER2 = "99 Ammo and both Keys!"
    Const STR_CHEATER3 = "Note that you have basically"
    Const STR_CHEATER4 = "eliminated your chances of"
    Const STR_CHEATER5 = "getting a high score!"

    GAMESVD = "There's already a game" + Chr$(10) + "saved at this position." + Chr$(10) + "      Overwrite?"
    STR_SAVECHT2 = "shall we say, " + Chr$(34) + "corrupted" + Chr$(34) + "."
    ENDGAMESTR = "Are you sure you want" + Chr$(10) + "to end the game you" + Chr$(10) + "are playing? (Y or N):"

    ' LSItems={LSM_X,LSM_Y,10,0,24}
    LSItems.x = LSM_X: LSItems.y = LSM_Y: LSItems.amount = 10: LSItems.curpos = 0: LSItems.indent = 24
    LSMenu(0).active = 1: LSMenu(1).active = 1: LSMenu(2).active = 1: LSMenu(3).active = 1: LSMenu(4).active = 1
    LSMenu(5).active = 1: LSMenu(6).active = 1: LSMenu(7).active = 1: LSMenu(8).active = 1: LSMenu(9).active = 1


$End If
