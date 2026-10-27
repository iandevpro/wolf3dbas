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

    Dim Shared lastmusic_gbl As Integer

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

$End If
