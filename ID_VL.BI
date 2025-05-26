'CONST FALSE = 0
'CONST TRUE = -1

$If INCLUDE_ID_VL_BI = UNDEFINED Then
    $Let INCLUDE_ID_VL_BI = 1

    Dim Shared palette1(255) As Long
    Dim Shared palette2(255) As Long
    Dim Shared screenfaded As Integer

$End If
