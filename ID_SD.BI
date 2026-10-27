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

    Const TickBase = 70 ' 70Hz per tick - used as a base for timer 0

    ' IMF playback rate: 700Hz (TickBase * 10 in SDL_SetTimerSpeed)
    Const IMF_RATE = 700

    ' Seconds of audio kept queued in the _SndRaw pipe
    Const SD_BUFFERSECS = 0.1
    ' Interval of the ON TIMER audio service, replaces the original timer interrupt
    Const SD_TIMERSECS = 0.01
    ' Output gain applied to the OPL2 mix
    Const SD_MUSICGAIN = 6

    ' SDMode - sound effects device
    Const sdm_Off = 0
    Const sdm_PC = 1
    Const sdm_AdLib = 2

    ' AdLibSound chunk layout:
    '   SoundCommon: longword length, word priority (offsets 0, 4)
    '   Instrument (16 bytes from offset 6): mChar,cChar,mScale,cScale,mAttack,cAttack,mSus,cSus,mWave,cWave,nConn,...
    '   byte block (offset 22), byte data[length] (offset 23): one frequency byte per 140Hz step, 0 = silence
    Const SOUND_PRIORITY = 4
    Const SOUND_INST = 6
    Const SOUND_BLOCK = 22
    Const SOUND_DATA = 23

    ' Sound effects state
    Dim Shared SoundMode As Integer
    Dim Shared SoundTableStart As Integer ' SoundTable = &audiosegs[SoundTableStart]
    Dim Shared SoundNumber As Integer
    Dim Shared SoundPriority As Integer
    Dim Shared SoundPositioned As Integer
    Dim Shared alSoundMem As _MEM ' Chunk of the AdLib sound being played
    Dim Shared alSoundOffset As Long ' Offset of the next data byte in alSoundMem, 0 = no sound
    Dim Shared alLengthLeft As Long
    Dim Shared alBlock As Integer
    Dim Shared sdCountFx As Integer ' count_fx in ID_SD_A.ASM: effects run every 5th 700Hz tick (140Hz)

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
    Dim Shared sdLock As Integer ' asm cli equivalent: SD_PumpAudio does nothing while set
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
    Declare Function SD_SetSoundMode% (mode As Integer)
    Declare Function SD_PlaySound% (snd As Integer)
    Declare Function SD_SoundPlaying% ()
    Declare Sub SD_StopSound ()
    Declare Sub SD_WaitSoundDone ()

$End If
