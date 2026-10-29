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

$End If
