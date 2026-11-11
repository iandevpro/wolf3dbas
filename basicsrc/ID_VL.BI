$If INCLUDE_ID_VL_BI = UNDEFINED Then
    $Let INCLUDE_ID_VL_BI = 1

    Dim Shared palette1(255) As Long
    Dim Shared palette2(255) As Long
    Dim Shared screenfaded As Integer
    Dim Shared gamepal(255) As Long ' Game palette, set by LoadGamePalette (GAMEPAL.BAS)

$End If
