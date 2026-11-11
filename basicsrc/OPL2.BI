' OPL2.BI - Yamaha YM3812 (OPL2 / AdLib) software emulator
' The original ID_SD.C wrote straight to the AdLib card ports (alOut). QB64 can't reach
' the hardware, so the chip is emulated here and its output is queued with _SndRaw.
' Integer only model of the chip: logsin/exp ROMs, 9-bit envelope generator and
' 10-bit phase generator, following the decapsulated chip behaviour as documented by Nuked-OPL3.
' Rhythm (percussion) mode is not emulated yet - Wolf3D music only uses melodic channels.
$If INCLUDE_OPL2_BI = UNDEFINED Then
    $Let INCLUDE_OPL2_BI = 1

    Const OPL2_RATE = 49716 ' Native sample rate: 3.579545 MHz / 72

    ' Envelope generator states
    Const OPL2_EG_ATTACK = 0
    Const OPL2_EG_DECAY = 1
    Const OPL2_EG_SUSTAIN = 2
    Const OPL2_EG_RELEASE = 3

    ' ROM tables
    Dim Shared oplLogSin(0 To 255) As Long ' -log2(sin) of the first quarter of a sine wave, 4.8 fixed point
    Dim Shared oplExp(0 To 255) As Long ' 2^x mantissa table, already shifted left by 1
    Dim Shared oplKslRom(0 To 15) As Long
    Dim Shared oplKslShift(0 To 3) As Long
    Dim Shared oplMt(0 To 15) As Long ' Frequency multipliers (x2)
    Dim Shared oplIncStep(0 To 3, 0 To 3) As Long
    Dim Shared oplPow2(0 To 30) As Long ' Shifts done with \ and *, _SHR doesn't keep the sign

    ' Chip registers and global state
    Dim Shared oplRegs(0 To 255) As Long
    Dim Shared oplWse As Long ' Waveform select enable (reg &H01 bit 5)
    Dim Shared oplNts As Long ' Note select (reg &H08 bit 6)
    Dim Shared oplTremoloShift As Long ' Tremolo depth (reg &HBD bit 7)
    Dim Shared oplVibShift As Long ' Vibrato depth (reg &HBD bit 6)
    Dim Shared oplTimer As Long
    Dim Shared oplEgTimer As Long
    Dim Shared oplEgState As Long
    Dim Shared oplEgAdd As Long
    Dim Shared oplEgTimerLo As Long
    Dim Shared oplTremoloPos As Long
    Dim Shared oplTremolo As Long
    Dim Shared oplVibPos As Long

    ' Per operator state, indexed by operator register offset 0..21 (6, 7, 14, 15 are unused)
    Dim Shared opValid(0 To 21) As Long
    Dim Shared opChan(0 To 21) As Long ' Channel the operator belongs to
    Dim Shared opIsCarrier(0 To 21) As Long
    Dim Shared opAm(0 To 21) As Long ' reg &H20: tremolo
    Dim Shared opVib(0 To 21) As Long ' reg &H20: vibrato
    Dim Shared opEgt(0 To 21) As Long ' reg &H20: sustaining envelope
    Dim Shared opKsr(0 To 21) As Long ' reg &H20: key scale rate
    Dim Shared opMult(0 To 21) As Long ' reg &H20: frequency multiplier
    Dim Shared opKsl(0 To 21) As Long ' reg &H40: key scale level
    Dim Shared opTl(0 To 21) As Long ' reg &H40: total level
    Dim Shared opAr(0 To 21) As Long ' reg &H60: attack rate
    Dim Shared opDr(0 To 21) As Long ' reg &H60: decay rate
    Dim Shared opSl(0 To 21) As Long ' reg &H80: sustain level
    Dim Shared opRr(0 To 21) As Long ' reg &H80: release rate
    Dim Shared opWave(0 To 21) As Long ' reg &HE0: waveform
    Dim Shared opKey(0 To 21) As Long
    Dim Shared opEgRout(0 To 21) As Long
    Dim Shared opEgGen(0 To 21) As Long
    Dim Shared opPhase(0 To 21) As Long
    Dim Shared opOut(0 To 21) As Long
    Dim Shared opPrevOut(0 To 21) As Long
    Dim Shared opFbMod(0 To 21) As Long

    ' Per channel state
    Dim Shared chMod(0 To 8) As Long ' Modulator operator offset
    Dim Shared chCar(0 To 8) As Long ' Carrier operator offset
    Dim Shared chFnum(0 To 8) As Long ' reg &HA0 / &HB0: frequency number
    Dim Shared chBlock(0 To 8) As Long ' reg &HB0: octave
    Dim Shared chFb(0 To 8) As Long ' reg &HC0: feedback
    Dim Shared chCon(0 To 8) As Long ' reg &HC0: 0 = FM, 1 = additive
    Dim Shared chKsl(0 To 8) As Long
    Dim Shared chKsv(0 To 8) As Long

    Declare Sub OPL2_Init ()
    Declare Sub OPL2_Reset ()
    Declare Sub OPL2_Write (reg As Long, value As Long)
    Declare Function OPL2_Generate& ()

$End If
