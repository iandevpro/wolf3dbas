' ID_SD.H - Sound Manager Header for Wolfenstein 3D
$If INCLUDE_ID_SD_BI = UNDEFINED Then
    $Let INCLUDE_ID_SD_BI = 1

    '$INCLUDE: 'OPL2.BI'

    ' AdLib register bases (ID_SD.H)
    Const alChar = &H20
    Const alScale = &H40
    Const alAttack = &H60
    Const alSus = &H80
    Const alWave = &HE0
    Const alFreqL = &HA0
    Const alFreqH = &HB0
    Const alFeedCon = &HC0
    Const alEffects = &HBD

    Const sqMaxTracks = 10

    ' IMF playback rate: 700Hz (TickBase * 10 in SDL_SetTimerSpeed)
    Const IMF_RATE = 700

    ' Seconds of audio kept queued in the _SndRaw pipe
    Const SD_BUFFERSECS = 0.1
    ' Interval of the ON TIMER audio service, replaces the original timer interrupt
    Const SD_TIMERSECS = 0.01
    ' Output gain applied to the OPL2 mix
    Const SD_MUSICGAIN = 6

    ' Music playback state variables (IMF format)
    ' MusicGroup structure in memory:
    ' Offset 0: word length (in bytes)
    ' Offset 2: word values[] (register/data pairs and delays)
    Dim Shared sqActive As Integer ' Music sequencer active flag
    Dim Shared sqHackMem As _MEM ' Memory block containing music data
    Dim Shared sqHackPtrOffset As Long ' Current offset within music data
    Dim Shared sqHackLen As Long ' Remaining bytes in current sequence
    Dim Shared sqHackSeqLen As Long ' Total length of sequence in bytes
    Dim Shared sqHackTime As Long ' Time for next command (in 700Hz ticks)
    Dim Shared alTimeCount As Long ' Current time counter (in 700Hz ticks)

    ' Audio output state
    Dim Shared sdPipe As Long ' _SndOpenRaw handle, 0 = sound manager not started
    Dim Shared sdTimer As Long ' ON TIMER handle
    Dim Shared sdRate As Long ' Sound card sample rate
    Dim Shared sdInPump As Integer
    Dim Shared sdImfAcc As Long ' 700Hz music clock accumulator, in samples
    Dim Shared sdOplStep As Long ' OPL2_RATE / sdRate, 16.16 fixed point
    Dim Shared sdOplAcc As Long
    Dim Shared sdPrevSample As Long
    Dim Shared sdCurSample As Long

    ' Function declarations
    Declare Sub SD_Startup ()
    Declare Sub SD_Shutdown ()
    Declare Sub SD_MusicOff ()
    Declare Sub SD_StartMusic (music As _MEM)
    Declare Sub SD_PumpAudio ()

$End If
