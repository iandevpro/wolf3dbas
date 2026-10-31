' ID_HEADS.H

$If INCLUDE_ID_HEADS_BI = UNDEFINED Then
    $Let INCLUDE_ID_HEADS_BI = 1
    '$INCLUDE:'VERSION.BI'

    ' Version-specific includes (converted from C preprocessor directives)
    $If JAPAN = DEFINED Then
        $If JAPDEMO = DEFINED Then
                'REM '$INCLUDE:'FOREIGN\JAPAN\GFXV_WJ1.BI'
        $Else
                'REM '$INCLUDE:'FOREIGN\JAPAN\GFXV_WJ6.BI'
        $End If
            '$INCLUDE:'AUDIOWL6.BI'
            'REM: TODO: create file '$INCLUDE:'MAPSWL6.BI'
    $Else
        $If SPEAR = UNDEFINED Then
            ' IAN: This should be included for Wolf 3D
            '$INCLUDE:'GFXV_WL6.BI'
            '$INCLUDE:'AUDIOWL6.BI'
            '$INCLUDE:'MAPSWL6.BI'
        $Else
            $If SPEARDEMO = UNDEFINED Then
                    'REM '$INCLUDE:'GFXV_SOD.BI'
                    'REM '$INCLUDE:'AUDIOSOD.BI'
                    'REM '$INCLUDE:'MAPSSOD.BI'
            $Else
                    'REM '$INCLUDE:'GFXV_SDM.BI'
                    'REM '$INCLUDE:'AUDIOSDM.BI'
                    'REM '$INCLUDE:'MAPSSDM.BI'
            $End If
        $End If
    $End If

    ' Graphics extension
    Const GREXT = "VGA"

    ' Boolean type (QB64 doesn't have a built-in boolean type, so we'll use Integer)
    ' In QB64, 0 = False, -1 = True (or any non-zero value = True)

    ' Type definitions from ID_HEADS.H
    Type Point
        x As Integer
        y As Integer
    End Type

    Type Rect
        ul As Point ' upper left
        lr As Point ' lower right
    End Type

    ' Engine constants
    Const PORTTILESWIDE = 20 ' all drawing takes place inside a
    Const PORTTILESHIGH = 13 ' non displayed port of this size

    Const UPDATEWIDE = PORTTILESWIDE
    Const UPDATEHIGH = PORTTILESHIGH

    Const MAXTICS = 10
    Const DEMOTICS = 4

    Const UPDATETERMINATE = &H0301

    ' Shared variables from ID_HEADS.H
    Dim Shared mapwidth As Integer, mapheight As Integer, tics As Integer
    Dim Shared compatability As Integer ' boolean equivalent
    Dim Shared updateptr As _Offset
    Dim Shared uwidthtable(UPDATEHIGH - 1) As Integer
    Dim Shared blockstarts(UPDATEWIDE * UPDATEHIGH - 1) As Integer
    Dim Shared fontcolor As Integer, backcolor As Integer

    ' Function declarations (these will be implemented in other modules)
    ' Sub Quit(error As String)  ' defined in user program

$End If
