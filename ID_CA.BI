' ID_CA.H
' simulate IFDEFs settings
$If INCLUDE_ID_CA_BI = UNDEFINED Then
    $Let INCLUDE_ID_CA_BI = 1

    Dim Shared profilehandle As Integer
    Dim Shared mapon As Integer
    Dim Shared ca_levelbit As Integer
    Dim Shared ca_levelnum As Integer

$End If
