' WL_ACT1.C globals - doors and areas
$If INCLUDE_WL_ACT1_BI = UNDEFINED Then
    $Let INCLUDE_WL_ACT1_BI = 1

    ' doorposition[] holds the amount the door is open, ranging from 0 to 0xffff
    Dim Shared doorposition(0 To MAXDOORS - 1) As Long ' unsigned, leading edge of door 0=closed
    Dim Shared doornum As Integer

    Dim Shared pwallstate As Long ' unsigned
    Dim Shared pwallpos As Long ' unsigned, amount a pushable wall has been moved (0-63)
    Dim Shared pwallx As Integer, pwally As Integer
    Dim Shared pwalldir As Integer

    Dim Shared areaconnect(0 To NUMAREAS - 1, 0 To NUMAREAS - 1) As _Unsigned _Byte
    Dim Shared areabyplayer(0 To NUMAREAS - 1) As Integer ' boolean

$End If
