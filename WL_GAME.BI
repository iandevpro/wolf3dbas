' WL_GAME.C - globals of the game loop: the sound position tables (JAB)
$If INCLUDE_WL_GAME_BI = UNDEFINED Then
    $Let INCLUDE_WL_GAME_BI = 1

    Dim Shared globalsoundx As Long, globalsoundy As Long ' fixed
    Dim Shared leftchannel As Integer, rightchannel As Integer

    Const ATABLEMAX = 15

    ' byte righttable / lefttable [ATABLEMAX][ATABLEMAX*2]: the position (0 = loudest, 8 = far)
    ' of a sound by its distance across (x) and along (y + ATABLEMAX) the view, from WL_GAME.C
    Dim Shared righttable(0 To ATABLEMAX - 1, 0 To ATABLEMAX * 2 - 1) As _Unsigned _Byte
    Dim Shared lefttable(0 To ATABLEMAX - 1, 0 To ATABLEMAX * 2 - 1) As _Unsigned _Byte
    Dim atablesrc As String, atx As Integer, aty As Integer
    atablesrc = ""
    atablesrc = atablesrc + "888888877777760000013588888888"
    atablesrc = atablesrc + "888888877777640000024688888888"
    atablesrc = atablesrc + "888888877776641000124688888888"
    atablesrc = atablesrc + "888888877776542101235788888888"
    atablesrc = atablesrc + "888888887776543223356888888888"
    atablesrc = atablesrc + "888888887776654444567888888888"
    atablesrc = atablesrc + "888888888777665556678888888888"
    atablesrc = atablesrc + "888888888887776677888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    For atx = 0 To ATABLEMAX - 1
        For aty = 0 To ATABLEMAX * 2 - 1
            righttable(atx, aty) = Val(Mid$(atablesrc, atx * ATABLEMAX * 2 + aty + 1, 1))
        Next aty
    Next atx
    atablesrc = ""
    atablesrc = atablesrc + "888888885310000067777778888888"
    atablesrc = atablesrc + "888888886420000046777778888888"
    atablesrc = atablesrc + "888888886421000146677778888888"
    atablesrc = atablesrc + "888888887532101245677778888888"
    atablesrc = atablesrc + "888888888653322345677788888888"
    atablesrc = atablesrc + "888888888765444456677788888888"
    atablesrc = atablesrc + "888888888876655566777888888888"
    atablesrc = atablesrc + "888888888888776677788888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    atablesrc = atablesrc + "888888888888888888888888888888"
    For atx = 0 To ATABLEMAX - 1
        For aty = 0 To ATABLEMAX * 2 - 1
            lefttable(atx, aty) = Val(Mid$(atablesrc, atx * ATABLEMAX * 2 + aty + 1, 1))
        Next aty
    Next atx

$End If
