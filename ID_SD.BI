' ID_SD.H - Sound Manager Header for Wolfenstein 3D
$If INCLUDE_ID_SD_BI = UNDEFINED Then
    $Let INCLUDE_ID_SD_BI = 1

    ' IMF playback rate: 700Hz (commands per second)
    Const IMF_RATE = 700

    ' Music playback state variables (IMF format)
    Dim Shared sqActive As Integer ' Music sequencer active flag
    Dim Shared sqHackMem As _MEM ' Memory block containing music data
    Dim Shared sqHackBaseOffset As Long ' Base offset to start of values array
    Dim Shared sqHackPtrOffset As Long ' Current offset within music data
    Dim Shared sqHackLen As Integer ' Remaining bytes in current sequence
    Dim Shared sqHackSeqLen As Integer ' Total length of sequence
    Dim Shared sqHackTime As Long ' Time for next command (in 700Hz ticks)
    Dim Shared alTimeCount As Long ' Current time counter (in 700Hz ticks)
    Dim Shared lastMusicUpdateTime As Double ' Last time we updated music (in seconds)

    ' MusicGroup structure in memory:
    ' Offset 0: word length (number of value words)
    ' Offset 2: word values[] (register/data pairs and delays)

    ' Function declarations
    DECLARE Sub SD_MusicOff ()
    DECLARE Sub SD_StartMusic (music As _Offset)
    DECLARE Sub SD_ServiceMusic ()

$End If

