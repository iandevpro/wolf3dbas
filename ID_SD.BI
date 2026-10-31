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
    ' Output gain of the digitized sounds (8-bit samples scaled to -1..1)
    Const SD_DIGIGAIN = 0.7
    ' Sound Blaster DAC rate: time constant 256 - (1000000 / 7000) = 114, 1000000 / (256 - 114) Hz
    Const SD_DIGIRATE = 7042

    ' SMMode - music device
    Const smm_Off = 0
    Const smm_AdLib = 1

    ' SDSMode - digitized sound device
    Const sds_Off = 0
    Const sds_PC = 1
    Const sds_SoundSource = 2
    Const sds_SoundBlaster = 3

    ' Hardware present: an AdLib and a Sound Blaster Pro are emulated, the Sound Source is not
    Const AdLibPresent = TRUE
    Const SoundBlasterPresent = TRUE
    Const SBProPresent = TRUE
    Const SoundSourcePresent = FALSE

    Dim Shared MusicMode As Integer
    Dim Shared DigiMode As Integer

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
    Dim Shared LeftPosition As Integer, RightPosition As Integer
    Dim Shared nextsoundpos As Integer

    ' Digitized sounds
    Dim Shared DigiMap(0 To LASTSOUND - 1) As Integer
    Dim Shared DigiListPage(0 To 1023) As Long ' word _seg *DigiList: page, length pairs
    Dim Shared DigiListLen(0 To 1023) As Long ' (PMPageSize \ 4 pairs)
    Dim Shared NumDigi As Integer, DigiLeft As Long, DigiPage As Long
    Dim Shared DigiPlaying As Integer
    Dim Shared DigiNumber As Integer, DigiPriority As Integer
    Dim Shared sdDigiPtr As Long ' offset of the next sample in PMData
    Dim Shared sdDigiSegLeft As Long ' samples left in the segment (page)
    Dim Shared sdDigiAcc As Long ' SD_DIGIRATE clock accumulator, in output samples
    Dim Shared sdDigiSample As Single ' the current sample, -1..1
    Dim Shared sdDigiVolL As Single, sdDigiVolR As Single ' SB Pro mixer voice volume
    Dim Shared alSoundMem As _MEM ' Chunk of the AdLib sound being played
    Dim Shared alSoundOffset As Long ' Offset of the next data byte in alSoundMem, 0 = no sound
    Dim Shared alLengthLeft As Long
    Dim Shared alBlock As Integer
    Dim Shared TimeCount As Long ' 70Hz tick counter (TIME macro in ID_SD_A.ASM)
    ' The original advanced TimeCount every 2nd effects tick (count_time) of the 700Hz interrupt.
    ' The audio here is generated in bursts as the sound device drains its buffer, so TimeCount
    ' counts the clock instead (SDL_TimeCountService, from the same ON TIMER event)
    Dim Shared sdClockLast As Double ' Timer(.001) of the last TimeCount update
    Dim Shared sdClockAcc As Double ' tics not yet added to TimeCount
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
    Declare Function SD_SetMusicMode% (mode As Integer)
    Declare Sub SD_SetDigiDevice (mode As Integer)
    Declare Sub SD_StopDigitized ()
    Declare Sub SD_PositionSound (leftvol As Integer, rightvol As Integer)
    Declare Sub SD_SetPosition (leftpos As Integer, rightpos As Integer)

$End If
