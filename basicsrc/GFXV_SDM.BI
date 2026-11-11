' GFXV_SDM.BI - generated from origsrc/GFXV_SDM.H (IGRAB-ed on Mon Sep 21 14:20:19 1992) by tools/gen_headers.py

$If INCLUDE_GFXV_SDM_BI = UNDEFINED Then
    $Let INCLUDE_GFXV_SDM_BI = 1

    ' Lump Start
    Const C_BACKDROPPIC = 3
    Const C_MOUSELBACKPIC = 4
    Const C_CURSOR1PIC = 5
    Const C_CURSOR2PIC = 6
    Const C_NOTSELECTEDPIC = 7
    Const C_SELECTEDPIC = 8

    ' Lump Start
    Const C_CUSTOMIZEPIC = 9
    Const C_JOY1PIC = 10
    Const C_JOY2PIC = 11
    Const C_MOUSEPIC = 12
    Const C_JOYSTICKPIC = 13
    Const C_KEYBOARDPIC = 14
    Const C_CONTROLPIC = 15

    ' Lump Start
    Const C_OPTIONSPIC = 16

    ' Lump Start
    Const C_FXTITLEPIC = 17
    Const C_DIGITITLEPIC = 18
    Const C_MUSICTITLEPIC = 19

    ' Lump Start
    Const C_HOWTOUGHPIC = 20
    Const C_BABYMODEPIC = 21
    Const C_EASYPIC = 22
    Const C_NORMALPIC = 23
    Const C_HARDPIC = 24

    ' Lump Start
    Const C_DISKLOADING1PIC = 25
    Const C_DISKLOADING2PIC = 26
    Const C_LOADGAMEPIC = 27
    Const C_SAVEGAMEPIC = 28

    ' Lump Start
    Const HIGHSCORESPIC = 29
    Const C_WONSPEARPIC = 30

    ' Lump Start
    Const L_GUYPIC = 31
    Const L_COLONPIC = 32
    Const L_NUM0PIC = 33
    Const L_NUM1PIC = 34
    Const L_NUM2PIC = 35
    Const L_NUM3PIC = 36
    Const L_NUM4PIC = 37
    Const L_NUM5PIC = 38
    Const L_NUM6PIC = 39
    Const L_NUM7PIC = 40
    Const L_NUM8PIC = 41
    Const L_NUM9PIC = 42
    Const L_PERCENTPIC = 43
    Const L_APIC = 44
    Const L_BPIC = 45
    Const L_CPIC = 46
    Const L_DPIC = 47
    Const L_EPIC = 48
    Const L_FPIC = 49
    Const L_GPIC = 50
    Const L_HPIC = 51
    Const L_IPIC = 52
    Const L_JPIC = 53
    Const L_KPIC = 54
    Const L_LPIC = 55
    Const L_MPIC = 56
    Const L_NPIC = 57
    Const L_OPIC = 58
    Const L_PPIC = 59
    Const L_QPIC = 60
    Const L_RPIC = 61
    Const L_SPIC = 62
    Const L_TPIC = 63
    Const L_UPIC = 64
    Const L_VPIC = 65
    Const L_WPIC = 66
    Const L_XPIC = 67
    Const L_YPIC = 68
    Const L_ZPIC = 69
    Const L_EXPOINTPIC = 70
    Const L_APOSTROPHEPIC = 71
    Const L_GUY2PIC = 72
    Const L_BJWINSPIC = 73

    ' Lump Start
    Const TITLE1PIC = 74
    Const TITLE2PIC = 75
    Const STATUSBARPIC = 76
    Const PG13PIC = 77
    Const CREDITSPIC = 78

    ' Lump Start
    Const KNIFEPIC = 79
    Const GUNPIC = 80
    Const MACHINEGUNPIC = 81
    Const GATLINGGUNPIC = 82
    Const NOKEYPIC = 83
    Const GOLDKEYPIC = 84
    Const SILVERKEYPIC = 85
    Const N_BLANKPIC = 86
    Const N_0PIC = 87
    Const N_1PIC = 88
    Const N_2PIC = 89
    Const N_3PIC = 90
    Const N_4PIC = 91
    Const N_5PIC = 92
    Const N_6PIC = 93
    Const N_7PIC = 94
    Const N_8PIC = 95
    Const N_9PIC = 96
    Const FACE1APIC = 97
    Const FACE1BPIC = 98
    Const FACE1CPIC = 99
    Const FACE2APIC = 100
    Const FACE2BPIC = 101
    Const FACE2CPIC = 102
    Const FACE3APIC = 103
    Const FACE3BPIC = 104
    Const FACE3CPIC = 105
    Const FACE4APIC = 106
    Const FACE4BPIC = 107
    Const FACE4CPIC = 108
    Const FACE5APIC = 109
    Const FACE5BPIC = 110
    Const FACE5CPIC = 111
    Const FACE6APIC = 112
    Const FACE6BPIC = 113
    Const FACE6CPIC = 114
    Const FACE7APIC = 115
    Const FACE7BPIC = 116
    Const FACE7CPIC = 117
    Const FACE8APIC = 118
    Const GOTGATLINGPIC = 119
    Const GODMODEFACE1PIC = 120
    Const GODMODEFACE2PIC = 121
    Const GODMODEFACE3PIC = 122
    Const BJWAITING1PIC = 123
    Const BJWAITING2PIC = 124
    Const BJOUCHPIC = 125
    Const PAUSEDPIC = 126
    Const GETPSYCHEDPIC = 127
    Const ORDERSCREEN = 129
    Const ERRORSCREEN = 130
    Const TITLEPALETTE = 131
    Const T_DEMO0 = 132
    Const ENUMEND = 133

    ' Data LUMPs
    Const BACKDROP_LUMP_START = 3
    Const BACKDROP_LUMP_END = 8

    Const CONTROL_LUMP_START = 9
    Const CONTROL_LUMP_END = 15

    Const OPTIONS_LUMP_START = 16
    Const OPTIONS_LUMP_END = 16

    Const SOUND_LUMP_START = 17
    Const SOUND_LUMP_END = 19

    Const NEWGAME_LUMP_START = 20
    Const NEWGAME_LUMP_END = 24

    Const LOADSAVE_LUMP_START = 25
    Const LOADSAVE_LUMP_END = 28

    Const HIGHSCORES_LUMP_START = 29
    Const HIGHSCORES_LUMP_END = 30

    Const LEVELEND_LUMP_START = 31
    Const LEVELEND_LUMP_END = 73

    Const TITLESCREEN_LUMP_START = 74
    Const TITLESCREEN_LUMP_END = 75

    Const LATCHPICS_LUMP_START = 79
    Const LATCHPICS_LUMP_END = 127

    ' Amount of each data item
    Const NUMCHUNKS = 133
    Const NUMFONT = 2
    Const NUMFONTM = 0
    Const NUMPICS = 125
    Const NUMPICM = 0
    Const NUMSPRITES = 0
    Const NUMTILE8 = 72
    Const NUMTILE8M = 0
    Const NUMTILE16 = 0
    Const NUMTILE16M = 0
    Const NUMTILE32 = 0
    Const NUMTILE32M = 0
    Const NUMEXTERNS = 4

    ' File offsets for data items
    Const STRUCTPIC = 0

    Const STARTFONT = 1
    Const STARTFONTM = 3
    Const STARTPICS = 3
    Const STARTPICM = 128
    Const STARTSPRITES = 128
    Const STARTTILE8 = 128
    Const STARTTILE8M = 129
    Const STARTTILE16 = 129
    Const STARTTILE16M = 129
    Const STARTTILE32 = 129
    Const STARTTILE32M = 129
    Const STARTEXTERNS = 129

$End If
