' WL_TEXT.C - local constants and variables
$If INCLUDE_WL_TEXT_BI = UNDEFINED Then
    $Let INCLUDE_WL_TEXT_BI = 1

    Const TEXTBACKCOLOR = &H11 ' BACKCOLOR in WL_TEXT.C, renamed: QB64 names are case insensitive and backcolor exists
    Const WORDLIMIT = 80
    Const FONTHEIGHT = 10
    Const TOPMARGIN = 16
    Const BOTTOMMARGIN = 32
    Const LEFTMARGIN = 16
    Const RIGHTMARGIN = 16
    Const PICMARGIN = 8
    Const TEXTROWS = (200 - TOPMARGIN - BOTTOMMARGIN) \ FONTHEIGHT
    Const SPACEWIDTH = 7
    Const SCREENPIXWIDTH = 320
    Const SCREENMID = SCREENPIXWIDTH \ 2

    Dim Shared pagenum As Integer, numpages As Integer
    Dim Shared leftmargin(0 To TEXTROWS - 1) As Integer, rightmargin(0 To TEXTROWS - 1) As Integer
    ' char far *text: the article is copied into layouttext, textpos is the 1-based position
    Dim Shared layouttext As String
    Dim Shared textpos As Long
    Dim Shared rowon As Integer
    Dim Shared picx As Integer, picy As Integer, picnum As Integer, picdelay As Integer
    Dim Shared layoutdone As Integer

$End If
