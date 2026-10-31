' ID_US.H - User Manager Header
$If INCLUDE_ID_US_BI = UNDEFINED Then
    $Let INCLUDE_ID_US_BI = 1

    ' PrintX, PrintY - Where the User Mgr will print (global coords)
    ' WindowX,WindowY,WindowW,WindowH - The dimensions of the current window
    Dim Shared PrintX As Integer, PrintY As Integer
    Dim Shared WindowX As Integer, WindowY As Integer, WindowW As Integer, WindowH As Integer

    Const MaxHighName = 57
    Const MaxScores = 7

    ' Same 66-byte layout as the C struct, so it can be read from CONFIG.WL6 as is
    Type HighScore
        name As String * 58 ' char name[MaxHighName + 1], zero terminated
        score As Long
        completed As Integer
        episode As Integer
    End Type

    Dim Shared Scores(0 To MaxScores - 1) As HighScore
    ' TODO: ReadConfig (WL_MAIN.C) loads the saved scores from CONFIG.WL6
    Scores(0).name = "id software-'92" + Chr$(0): Scores(0).score = 10000: Scores(0).completed = 1
    Scores(1).name = "Adrian Carmack" + Chr$(0): Scores(1).score = 10000: Scores(1).completed = 1
    Scores(2).name = "John Carmack" + Chr$(0): Scores(2).score = 10000: Scores(2).completed = 1
    Scores(3).name = "Kevin Cloud" + Chr$(0): Scores(3).score = 10000: Scores(3).completed = 1
    Scores(4).name = "Tom Hall" + Chr$(0): Scores(4).score = 10000: Scores(4).completed = 1
    Scores(5).name = "John Romero" + Chr$(0): Scores(5).score = 10000: Scores(5).completed = 1
    Scores(6).name = "Jay Wilbur" + Chr$(0): Scores(6).score = 10000: Scores(6).completed = 1

    Declare Sub US_Print (s As String)
    Declare Sub US_PrintUnsigned (n As Long)
    Declare Sub US_PrintSigned (n As Long)
    Declare Sub USL_PrintInCenter (s As String, ulx As Integer, uly As Integer, lrx As Integer, lry As Integer)
    Declare Sub US_PrintCentered (s As String)
    Declare Sub US_CPrintLine (s As String)
    Declare Sub US_CPrint (s As String)
    Declare Function US_LineInput% (x As Integer, y As Integer, buf As String, defaultstr As String, escok As Integer, maxchars As Integer, maxwidth As Integer)

    '
    ' ID_US_A.ASM: the table based random number generator (US_InitRndT / US_RndT)
    '
    Dim Shared rndindex As Integer
    Dim Shared rndtable(0 To 255) As Integer
    Dim rndsrc As String, rndi As Integer, rndp As Integer
    rndsrc = ""
    rndsrc = rndsrc + "000008109220222241149107075248254140016066074021"
    rndsrc = rndsrc + "211047080242154027205128161089077036095110085048"
    rndsrc = rndsrc + "212140211249022079200050028188052140202120068145"
    rndsrc = rndsrc + "062070184190091197152224149104025178252182202182"
    rndsrc = rndsrc + "141197004081181242145042039227156198225193219093"
    rndsrc = rndsrc + "122175249000175143070239046246163053163109168135"
    rndsrc = rndsrc + "002235025092020145138077069166078176173212166113"
    rndsrc = rndsrc + "094161041050239049111164070060002037171075136156"
    rndsrc = rndsrc + "011056042146138229073146077061098196135106063197"
    rndsrc = rndsrc + "195086096203113101170247181113080250108007255237"
    rndsrc = rndsrc + "129226079107112166103241024223239120198058060082"
    rndsrc = rndsrc + "128003184066143224145224081206163045063090168114"
    rndsrc = rndsrc + "059033159095028139123098125196015070194253054014"
    rndsrc = rndsrc + "109226071017161093186087244138020052123251026036"
    rndsrc = rndsrc + "017046052231232076031221084037216165212106197242"
    rndsrc = rndsrc + "098043039175254145190084118222187136120163236249"
    For rndi = 0 To 255
        rndtable(rndi) = Val(Mid$(rndsrc, rndi * 3 + 1, 3))
    Next rndi

$End If
