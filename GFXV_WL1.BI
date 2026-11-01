' GFXV_WL1.BI - converted from GFXV_WL1.H (IGRAB-ed on Sun May 03 01:19:32 1992),
' the graphics of the v1.0 shareware data (VGAGRAPH.WL1)
'
' The pictures (3-138) are as in GFXV_WL1.H. The rest of that header does not fit the
' data: VGAHEAD.WL1 has 148 chunks, with no 16x16 tiles, and the externs after the
' 8x8 tiles are the order and error screens, the help text, one end text and four
' demos (in the v1.0 format, see PollControls).
' Not in v1.0: C_TIMECODEPIC, C_LEVELPIC, C_NAMEPIC, C_SCOREPIC, C_JOY1PIC, C_JOY2PIC,
' L_APOSTROPHEPIC and T_ENDART2-6 (the code that uses them checks APOGEE_1_0)

$If INCLUDE_GFXV_WL1_BI = UNDEFINED Then
    $Let INCLUDE_GFXV_WL1_BI = 1

    ' --- Graphics enum as Consts ---
    Const H_BJPIC = 3
    Const H_CASTLEPIC = 4
    Const H_KEYBOARDPIC = 5
    Const H_JOYPIC = 6
    Const H_HEALPIC = 7
    Const H_TREASUREPIC = 8
    Const H_GUNPIC = 9
    Const H_KEYPIC = 10
    Const H_BLAZEPIC = 11
    Const H_WEAPON1234PIC = 12
    Const H_WOLFLOGOPIC = 13
    Const H_VISAPIC = 14
    Const H_MCPIC = 15
    Const H_IDLOGOPIC = 16
    Const H_TOPWINDOWPIC = 17
    Const H_LEFTWINDOWPIC = 18
    Const H_RIGHTWINDOWPIC = 19
    Const H_BOTTOMINFOPIC = 20
    Const C_OPTIONSPIC = 21
    Const C_CURSOR1PIC = 22
    Const C_CURSOR2PIC = 23
    Const C_NOTSELECTEDPIC = 24
    Const C_SELECTEDPIC = 25
    Const C_FXTITLEPIC = 26
    Const C_DIGITITLEPIC = 27
    Const C_MUSICTITLEPIC = 28
    Const C_MOUSELBACKPIC = 29
    Const C_BABYMODEPIC = 30
    Const C_EASYPIC = 31
    Const C_NORMALPIC = 32
    Const C_HARDPIC = 33
    Const C_LOADSAVEDISKPIC = 34
    Const C_DISKLOADING1PIC = 35
    Const C_DISKLOADING2PIC = 36
    Const C_CONTROLPIC = 37
    Const C_CUSTOMIZEPIC = 38
    Const C_LOADGAMEPIC = 39
    Const C_SAVEGAMEPIC = 40
    Const C_EPISODE1PIC = 41
    Const C_EPISODE2PIC = 42
    Const C_EPISODE3PIC = 43
    Const C_EPISODE4PIC = 44
    Const C_EPISODE5PIC = 45
    Const C_EPISODE6PIC = 46
    Const C_CODEPIC = 47
    Const L_GUYPIC = 48
    Const L_COLONPIC = 49
    Const L_NUM0PIC = 50
    Const L_NUM1PIC = 51
    Const L_NUM2PIC = 52
    Const L_NUM3PIC = 53
    Const L_NUM4PIC = 54
    Const L_NUM5PIC = 55
    Const L_NUM6PIC = 56
    Const L_NUM7PIC = 57
    Const L_NUM8PIC = 58
    Const L_NUM9PIC = 59
    Const L_PERCENTPIC = 60
    Const L_APIC = 61
    Const L_BPIC = 62
    Const L_CPIC = 63
    Const L_DPIC = 64
    Const L_EPIC = 65
    Const L_FPIC = 66
    Const L_GPIC = 67
    Const L_HPIC = 68
    Const L_IPIC = 69
    Const L_JPIC = 70
    Const L_KPIC = 71
    Const L_LPIC = 72
    Const L_MPIC = 73
    Const L_NPIC = 74
    Const L_OPIC = 75
    Const L_PPIC = 76
    Const L_QPIC = 77
    Const L_RPIC = 78
    Const L_SPIC = 79
    Const L_TPIC = 80
    Const L_UPIC = 81
    Const L_VPIC = 82
    Const L_WPIC = 83
    Const L_XPIC = 84
    Const L_YPIC = 85
    Const L_ZPIC = 86
    Const L_EXPOINTPIC = 87
    Const L_GUY2PIC = 88
    Const L_BJWINSPIC = 89
    Const STATUSBARPIC = 90
    Const TITLEPIC = 91
    Const PG13PIC = 92
    Const CREDITSPIC = 93
    Const HIGHSCORESPIC = 94
    Const KNIFEPIC = 95
    Const GUNPIC = 96
    Const MACHINEGUNPIC = 97
    Const GATLINGGUNPIC = 98
    Const NOKEYPIC = 99
    Const GOLDKEYPIC = 100
    Const SILVERKEYPIC = 101
    Const N_BLANKPIC = 102
    Const N_0PIC = 103
    Const N_1PIC = 104
    Const N_2PIC = 105
    Const N_3PIC = 106
    Const N_4PIC = 107
    Const N_5PIC = 108
    Const N_6PIC = 109
    Const N_7PIC = 110
    Const N_8PIC = 111
    Const N_9PIC = 112
    Const FACE1APIC = 113
    Const FACE1BPIC = 114
    Const FACE1CPIC = 115
    Const FACE2APIC = 116
    Const FACE2BPIC = 117
    Const FACE2CPIC = 118
    Const FACE3APIC = 119
    Const FACE3BPIC = 120
    Const FACE3CPIC = 121
    Const FACE4APIC = 122
    Const FACE4BPIC = 123
    Const FACE4CPIC = 124
    Const FACE5APIC = 125
    Const FACE5BPIC = 126
    Const FACE5CPIC = 127
    Const FACE6APIC = 128
    Const FACE6BPIC = 129
    Const FACE6CPIC = 130
    Const FACE7APIC = 131
    Const FACE7BPIC = 132
    Const FACE7CPIC = 133
    Const FACE8APIC = 134
    Const GOTGATLINGPIC = 135
    Const MUTANTBJPIC = 136
    Const PAUSEDPIC = 137
    Const GETPSYCHEDPIC = 138

    ' externs (chunk numbers in VGAHEAD.WL1)
    Const ORDERSCREEN = 140
    Const ERRORSCREEN = 141
    Const T_HELPART = 142
    Const T_ENDART1 = 143
    Const T_DEMO0 = 144
    Const T_DEMO1 = 145
    Const T_DEMO2 = 146
    Const T_DEMO3 = 147
    Const ENUMEND = 148

    ' --- Data LUMPs ---
    Const README_LUMP_START = 3
    Const README_LUMP_END = 20
    Const CONTROLS_LUMP_START = 21
    Const CONTROLS_LUMP_END = 47
    Const LEVELEND_LUMP_START = 48
    Const LEVELEND_LUMP_END = 89
    Const LATCHPICS_LUMP_START = 95
    Const LATCHPICS_LUMP_END = 138

    ' --- Amount of each data item ---
    Const NUMCHUNKS = 148
    Const NUMFONT = 2
    Const NUMFONTM = 0
    Const NUMPICS = 136
    Const NUMPICM = 0
    Const NUMSPRITES = 0
    Const NUMTILE8 = 72
    Const NUMTILE8M = 0
    Const NUMTILE16 = 0
    Const NUMTILE16M = 0
    Const NUMTILE32 = 0
    Const NUMTILE32M = 0
    Const NUMEXTERNS = 8

    ' --- File offsets for data items ---
    Const STRUCTPIC = 0
    Const STARTFONT = 1
    Const STARTFONTM = 3
    Const STARTPICS = 3
    Const STARTPICM = 139
    Const STARTSPRITES = 139
    Const STARTTILE8 = 139
    Const STARTTILE8M = 140
    Const STARTTILE16 = 140
    Const STARTTILE16M = 140
    Const STARTTILE32 = 140
    Const STARTTILE32M = 140
    Const STARTEXTERNS = 140

$End If
