' VERSION.H

$If INCLUDE_VERSION_BI = UNDEFINED Then
    $Let INCLUDE_VERSION_BI = 1

    ' //#define SPEAR
    ' //#define JAPAN
    '? NonShareware function call depends on this in DemoLoop $Let GOODTIMES = 1
    $Let ARTSEXTERN = 1
    $Let DEMOSEXTERN = 1
    ' //#define MYPROFILE
    ' //#define DEBCHECK
    ' //#define UPLOAD
    '
    ' The shareware build (WOLF1.BAS, like WOLF1VER.H) sets UPLOAD and APOGEE_1_0 before
    ' it includes WOLF3D.BAS. APOGEE_1_0 is the v1.0 shareware data (May 1992, *.WL1):
    ' the maps are in MAPTEMP (not carmackized), and the graphics, sprites and demos
    ' differ from the v1.4 data this source was written for (see GFXV_WL1.BI)
    $If APOGEE_1_0 = UNDEFINED Then
        $Let CARMACIZED = 1
    $End If

$End If
