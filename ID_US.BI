' ID_US.H - User Manager Header
$If INCLUDE_ID_US_BI = UNDEFINED Then
    $Let INCLUDE_ID_US_BI = 1

    ' PrintX, PrintY - Where the User Mgr will print (global coords)
    ' WindowX,WindowY,WindowW,WindowH - The dimensions of the current window
    Dim Shared PrintX As Integer, PrintY As Integer
    Dim Shared WindowX As Integer, WindowY As Integer, WindowW As Integer, WindowH As Integer

    Declare Sub US_Print (s As String)
    Declare Sub US_PrintUnsigned (n As Long)
    Declare Sub US_PrintSigned (n As Long)
    Declare Sub USL_PrintInCenter (s As String, ulx As Integer, uly As Integer, lrx As Integer, lry As Integer)
    Declare Sub US_PrintCentered (s As String)
    Declare Sub US_CPrintLine (s As String)
    Declare Sub US_CPrint (s As String)

$End If
