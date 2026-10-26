$If INCLUDE_ID_VH_BI = UNDEFINED Then
    $Let INCLUDE_ID_VH_BI = 1

    ' Picture table type
    Type pictabletype
        width As Integer
        height As Integer
        ' Add other fields as needed based on the original structure
    End Type

    Declare Sub VW_FadeOut
    Declare Sub VW_FadeIn
    Declare Sub VW_UpdateScreen
    Declare Sub VWB_DrawPic (x As Integer, y As Integer, chunknum As Integer)

$End If
