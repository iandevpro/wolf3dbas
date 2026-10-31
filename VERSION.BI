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
    $Let CARMACIZED = 1
    ' //#define UPLOAD

$End If
