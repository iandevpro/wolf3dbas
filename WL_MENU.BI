' WL_MENU.H'
' simulate IFDEFs settings
$If INCLUDE_WL_MENU_BI = UNDEFINED Then
    $Let INCLUDE_WL_MENU_BI = 1

    $If SPEAR = DEFINED Then
        Const BORDCOLOR = &H99
    $Else
        Const BORDCOLOR = &H29
        Const STRIPE = &H2C
    $End If

    $If SPEAR = UNDEFINED Then
        Const INTROSONG = 7 ' NAZI_NOR_MUS
    $Else
        Const INTROSONG = 23 ' XTOWER2_MUS
    $End If

    Dim Shared lastmusic_gbl As Integer

$End If
