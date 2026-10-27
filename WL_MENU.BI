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

$End If
