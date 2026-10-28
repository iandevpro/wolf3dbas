' WL_PLAY.C globals - controls
' Needs the sc_ scan codes of ID_IN.BI, include it after that file
$If INCLUDE_WL_PLAY_BI = UNDEFINED Then
    $Let INCLUDE_WL_PLAY_BI = 1

    Dim Shared dirscan(0 To 3) As Integer
    Dim Shared buttonscan(0 To NUMBUTTONS - 1) As Integer
    Dim Shared buttonmouse(0 To 3) As Integer
    Dim Shared buttonjoy(0 To 3) As Integer

    ' int dirscan[4] = {sc_UpArrow,sc_RightArrow,sc_DownArrow,sc_LeftArrow};
    dirscan(di_north) = sc_UpArrow: dirscan(di_east) = sc_RightArrow
    dirscan(di_south) = sc_DownArrow: dirscan(di_west) = sc_LeftArrow
    ' int buttonscan[NUMBUTTONS] = {sc_Control,sc_Alt,sc_RShift,sc_Space,sc_1,sc_2,sc_3,sc_4};
    buttonscan(0) = sc_Control: buttonscan(1) = sc_Alt: buttonscan(2) = sc_RShift: buttonscan(3) = sc_Space
    buttonscan(4) = sc_1: buttonscan(5) = sc_2: buttonscan(6) = sc_3: buttonscan(7) = sc_4
    ' int buttonmouse[4]={bt_attack,bt_strafe,bt_use,bt_nobutton};
    buttonmouse(0) = bt_attack: buttonmouse(1) = bt_strafe: buttonmouse(2) = bt_use: buttonmouse(3) = bt_nobutton
    ' int buttonjoy[4]={bt_attack,bt_strafe,bt_use,bt_run};
    buttonjoy(0) = bt_attack: buttonjoy(1) = bt_strafe: buttonjoy(2) = bt_use: buttonjoy(3) = bt_run

$End If
