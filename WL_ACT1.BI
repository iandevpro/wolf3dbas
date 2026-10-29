' WL_ACT1.C globals - doors and areas
$If INCLUDE_WL_ACT1_BI = UNDEFINED Then
    $Let INCLUDE_WL_ACT1_BI = 1

    ' doorposition[] holds the amount the door is open, ranging from 0 to 0xffff
    Dim Shared doorposition(0 To MAXDOORS - 1) As Long ' unsigned, leading edge of door 0=closed
    Dim Shared doornum As Integer

    Const OPENTICS = 300

    Dim Shared pwallstate As Long ' unsigned
    Dim Shared pwallpos As Long ' unsigned, amount a pushable wall has been moved (0-63)
    Dim Shared pwallx As Integer, pwally As Integer
    Dim Shared pwalldir As Integer

    '
    ' statinfo[]: the picture and type of each static object (map tiles 23-74, Spear 23-...)
    '
    Dim Shared statpicnum(0 To 52) As Integer
    Dim Shared stattype(0 To 52) As Integer
    Dim statn As Integer

    ' {picnum, type}, block / dressing / bo_* - the last entry has picnum -1 (terminator)
    statn = 0
    StatInfo SPR_STAT_0, dressing, statn ' puddle          spr1v
    StatInfo SPR_STAT_1, block, statn ' Green Barrel    "
    StatInfo SPR_STAT_2, block, statn ' Table/chairs    "
    StatInfo SPR_STAT_3, block, statn ' Floor lamp      "
    StatInfo SPR_STAT_4, dressing, statn ' Chandelier      "
    StatInfo SPR_STAT_5, block, statn ' Hanged man      "
    StatInfo SPR_STAT_6, bo_alpo, statn ' Bad food        "
    StatInfo SPR_STAT_7, block, statn ' Red pillar      "
    '
    ' NEW PAGE
    '
    StatInfo SPR_STAT_8, block, statn ' Tree            spr2v
    StatInfo SPR_STAT_9, dressing, statn ' Skeleton flat   "
    StatInfo SPR_STAT_10, block, statn ' Sink            " (SOD:gibs)
    StatInfo SPR_STAT_11, block, statn ' Potted plant    "
    StatInfo SPR_STAT_12, block, statn ' Urn             "
    StatInfo SPR_STAT_13, block, statn ' Bare table      "
    StatInfo SPR_STAT_14, dressing, statn ' Ceiling light   "
    $If SPEAR = UNDEFINED Then
        StatInfo SPR_STAT_15, dressing, statn ' Kitchen stuff   "
    $Else
        StatInfo SPR_STAT_15, block, statn ' Gibs!
    $End If
    '
    ' NEW PAGE
    '
    StatInfo SPR_STAT_16, block, statn ' suit of armor   spr3v
    StatInfo SPR_STAT_17, block, statn ' Hanging cage    "
    StatInfo SPR_STAT_18, block, statn ' SkeletoninCage  "
    StatInfo SPR_STAT_19, dressing, statn ' Skeleton relax  "
    StatInfo SPR_STAT_20, bo_key1, statn ' Key 1           "
    StatInfo SPR_STAT_21, bo_key2, statn ' Key 2           "
    StatInfo SPR_STAT_22, block, statn ' stuff                (SOD:gibs)
    StatInfo SPR_STAT_23, dressing, statn ' stuff
    '
    ' NEW PAGE
    '
    StatInfo SPR_STAT_24, bo_food, statn ' Good food       spr4v
    StatInfo SPR_STAT_25, bo_firstaid, statn ' First aid       "
    StatInfo SPR_STAT_26, bo_clip, statn ' Clip            "
    StatInfo SPR_STAT_27, bo_machinegun, statn ' Machine gun     "
    StatInfo SPR_STAT_28, bo_chaingun, statn ' Gatling gun     "
    StatInfo SPR_STAT_29, bo_cross, statn ' Cross           "
    StatInfo SPR_STAT_30, bo_chalice, statn ' Chalice         "
    StatInfo SPR_STAT_31, bo_bible, statn ' Bible           "
    '
    ' NEW PAGE
    '
    StatInfo SPR_STAT_32, bo_crown, statn ' crown           spr5v
    StatInfo SPR_STAT_33, bo_fullheal, statn ' one up          "
    StatInfo SPR_STAT_34, bo_gibs, statn ' gibs            "
    StatInfo SPR_STAT_35, block, statn ' barrel          "
    StatInfo SPR_STAT_36, block, statn ' well            "
    StatInfo SPR_STAT_37, block, statn ' Empty well      "
    StatInfo SPR_STAT_38, bo_gibs, statn ' Gibs 2          "
    StatInfo SPR_STAT_39, block, statn ' flag                "
    '
    ' NEW PAGE
    '
    $If SPEAR = UNDEFINED Then
        StatInfo SPR_STAT_40, block, statn ' Call Apogee          spr7v
    $Else
        StatInfo SPR_STAT_40, dressing, statn ' Red light
    $End If
    '
    ' NEW PAGE
    '
    StatInfo SPR_STAT_41, dressing, statn ' junk            "
    StatInfo SPR_STAT_42, dressing, statn ' junk            "
    StatInfo SPR_STAT_43, dressing, statn ' junk            "
    $If SPEAR = UNDEFINED Then
        StatInfo SPR_STAT_44, dressing, statn ' pots            "
    $Else
        StatInfo SPR_STAT_44, block, statn ' Gibs!
    $End If
    StatInfo SPR_STAT_45, block, statn ' stove           " (SOD:gibs)
    StatInfo SPR_STAT_46, block, statn ' spears          " (SOD:gibs)
    StatInfo SPR_STAT_47, dressing, statn ' vines           "
    '
    ' NEW PAGE
    '
    $If SPEAR = DEFINED Then
        StatInfo SPR_STAT_48, block, statn ' marble pillar
        StatInfo SPR_STAT_49, bo_25clip, statn ' bonus 25 clip
        StatInfo SPR_STAT_50, block, statn ' truck
        StatInfo SPR_STAT_51, bo_spear, statn ' SPEAR OF DESTINY!
    $End If

    StatInfo SPR_STAT_26, bo_clip2, statn ' Clip            "
    StatInfo -1, dressing, statn ' terminator

    Dim Shared areaconnect(0 To NUMAREAS - 1, 0 To NUMAREAS - 1) As _Unsigned _Byte
    Dim Shared areabyplayer(0 To NUMAREAS - 1) As Integer ' boolean

$End If
