$If INCLUDE_ID_VH_BI = UNDEFINED Then
    $Let INCLUDE_ID_VH_BI = 1

    ' Picture table type
    Type pictabletype
        width As Integer
        height As Integer
        ' Add other fields as needed based on the original structure
    End Type

    ' fontstruct layout in a cached font chunk (grsegsMem(STARTFONT + fontnumber)):
    '   int height, int location[256] (offset of each glyph), char width[256]
    ' A glyph is height rows of width bytes, a nonzero byte is drawn in fontcolor
    Const FONT_LOCATION = 2
    Const FONT_WIDTH = 514

    Dim Shared fontnumber As Integer
    Dim Shared px As Integer, py As Integer
    Dim Shared bufferwidth As Integer, bufferheight As Integer

    Declare Sub VW_FadeOut
    Declare Sub VW_FadeIn
    Declare Sub VW_UpdateScreen
    Declare Sub VWB_DrawPic (x As Integer, y As Integer, chunknum As Integer)

$End If
