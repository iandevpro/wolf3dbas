' WL_SCALE.C - globals of the scalers
$If INCLUDE_WL_SCALE_BI = UNDEFINED Then
    $Let INCLUDE_WL_SCALE_BI = 1

    Dim Shared maxscale As Integer, maxscaleshl2 As Integer
    Dim Shared stepbytwo As Integer

    ' The original built a compiled scaler (machine code) per height: scaler i draws a 64
    ' texel column 2*i pixels tall, centered in the view. Here each scaler is a table:
    ' scalersrc(i, row) is the texel of view row "row", drawn from scalertop(i) to scalerbottom(i).
    ' scalerof(i) gives the scaler used for index i (the C code shared one scaler between
    ' i, i+1, i+2 above stepbytwo, and index 0 uses scaler 1)
    ReDim Shared scalersrc(0, 0) As Integer
    ReDim Shared scalertop(0) As Integer
    ReDim Shared scalerbottom(0) As Integer
    Dim Shared scalerof(0 To MAXSCALEHEIGHT + 2) As Integer

    ' For the sprites the other way round, per source texel src (0-64) of scaler i:
    ' scalerwidth(i, src) is t_compscale width[src] (screen pixels of the unclipped texel),
    ' and the texel is drawn on view rows scalerfirst(i, src) to scalerlast(i, src) (clipped,
    ' none when first > last) - the rows the compiled code for that texel wrote
    ReDim Shared scalerwidth(0, 0) As Integer
    ReDim Shared scalerfirst(0, 0) As Integer
    ReDim Shared scalerlast(0, 0) As Integer

    '
    ' ScaleLine parameters (C: slinex, slinewidth, linecmds, linescale)
    '
    Dim Shared slinex As Integer, slinewidth As Integer
    Dim Shared linecmds As Long ' offset of the segment list of a shape column, in the shape
    Dim Shared lineshape As Long ' the shape: offset of its sprite page in PMData
    Dim Shared linescale As Integer ' the scaler (C: segment of the compiled scaler)

$End If
