' ID_IN.H - Input Manager Header
$If INCLUDE_ID_IN_BI = UNDEFINED Then
    $Let INCLUDE_ID_IN_BI = 1

    Declare Sub IN_ClearKeysDown ()
    Declare Function IN_CheckAck% ()
    Declare Sub IN_StartAck ()
    Declare Sub IN_Ack ()
    Declare Function IN_UserInput% (delay As Long)

$End If
