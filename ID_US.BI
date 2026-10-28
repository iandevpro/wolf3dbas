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

$End If
