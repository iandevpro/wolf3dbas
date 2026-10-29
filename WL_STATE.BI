' The state table - statetype variables of WL_AGENT.C / WL_ACT1.C / WL_ACT2.C
'
' C has one statetype variable per state (s_player, s_grdstand...), with the next state and
' the think / action routines as pointers. Here the states are rows of states(), named
' by constants (index 0 = NULL), and the routines are ids dispatched by CallStateRoutine.
$If INCLUDE_WL_STATE_BI = UNDEFINED Then
    $Let INCLUDE_WL_STATE_BI = 1

    Const MAXSTATES = 1000 ' grows with the enemies (6g)
    Dim Shared states(0 To MAXSTATES) As statetype

    '
    ' routine ids (think / action), 0 = NULL
    '
    Const RT_NONE = 0
    Const RT_T_PLAYER = 1

    '
    ' state ids, 0 = NULL
    '
    ' WL_AGENT.C: statetype s_player = {false,0,0,T_Player,NULL,NULL};
    Const s_player = 1
    ' TODO 6e: s_attack = {false,0,0,T_Attack,NULL,NULL}

    Declare Sub InitStates ()
    Declare Sub CallStateRoutine (routine As Integer, ob As Integer)

$End If
