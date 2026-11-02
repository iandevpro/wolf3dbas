' WL_INTER.C - intermission (LevelCompleted)
$If INCLUDE_WL_INTER_BI = UNDEFINED Then
    $Let INCLUDE_WL_INTER_BI = 1

    ' WL_MENU.H: typedef struct {int kill,secret,treasure; long time;} LRstruct;
    Type LRstruct
        kill As Integer
        secret As Integer
        treasure As Integer
        time As Long
    End Type

    $If SPEAR = UNDEFINED Then
        Dim Shared LevelRatios(0 To 7) As LRstruct
    $Else
        Dim Shared LevelRatios(0 To 19) As LRstruct
    $End If

    Const VBLWAIT = 30
    Const PAR_AMOUNT = 500
    Const PERCENT100AMT = 10000
    Const RATIOXX = 37 ' (Spanish: 33)

    Const STR_BONUS = "bonus"
    Const STR_TIME = "time"
    Const STR_PAR = " par"
    Const STR_RAT2KILL = "kill ratio    %"
    Const STR_RAT2SECRET = "secret ratio    %"
    Const STR_RAT2TREASURE = "treasure ratio    %"
    Const STR_DEFEATED = "defeated!"
    Const STR_SEEAGAIN = "Let's see that again!"
    Const STR_YOUWIN = "you win!"
    Const STR_TOTALTIME = "total time"
    Const STR_RATKILL = "kill    %"
    Const STR_RATSECRET = "secret    %"
    Const STR_RATTREASURE = "treasure    %"

    '
    ' Write: the picture of each character from '0' (alpha[] in Write)
    '
    Dim Shared writealpha(0 To 42) As Integer
    Dim writei As Integer
    For writei = 0 To 9: writealpha(writei) = L_NUM0PIC + writei: Next writei
    writealpha(10) = L_COLONPIC ' 11-16 are 0
    For writei = 0 To 25: writealpha(17 + writei) = L_APIC + writei: Next writei

    '
    ' parTimes[]: par time in minutes and as shown
    '
    Dim Shared partime(0 To 59) As Single
    Dim Shared partimestr(0 To 59) As String
    Dim partimesrc As String
    $If SPEAR = UNDEFINED Then
        ' Episode One to Six, the last two of each are the boss and the secret level
        partimesrc = "01:30 02:00 02:00 03:30 03:00 03:00 02:30 02:30 ??:?? ??:?? "
        partimesrc = partimesrc + "01:30 03:30 03:00 02:00 04:00 06:00 01:00 03:00 ??:?? ??:?? "
        partimesrc = partimesrc + "01:30 01:30 02:30 02:30 03:30 02:30 02:00 06:00 ??:?? ??:?? "
        partimesrc = partimesrc + "02:00 02:00 01:30 01:00 04:30 03:30 02:00 04:30 ??:?? ??:?? "
        partimesrc = partimesrc + "02:30 01:30 02:30 02:30 04:00 03:00 04:30 03:30 ??:?? ??:?? "
        partimesrc = partimesrc + "06:30 04:00 04:30 06:00 05:00 05:30 05:30 08:30 ??:?? ??:?? "
    $Else
        ' Spear of Destiny: bosses at 4, 9, 15, 17, secret levels 18, 19
        partimesrc = "01:30 03:30 02:45 03:30 ??:?? 04:30 03:15 02:45 04:45 ??:?? "
        partimesrc = partimesrc + "06:30 04:30 02:45 04:30 06:00 ??:?? 06:00 ??:?? ??:?? ??:?? "
    $End If
    For writei = 0 To Len(partimesrc) \ 6 - 1
        partimestr(writei) = Mid$(partimesrc, writei * 6 + 1, 5)
        If Left$(partimestr(writei), 1) <> "?" Then
            ' minutes, the seconds are quarters of a minute
            partime(writei) = Val(Left$(partimestr(writei), 2)) + Val(Mid$(partimestr(writei), 4, 2)) / 60
        End If
    Next writei

$End If
