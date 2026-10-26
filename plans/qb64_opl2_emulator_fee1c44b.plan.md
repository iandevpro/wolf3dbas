# Wolf3D QB64 port: project status and revised music (OPL2) plan

## Context
Wolf3D's music is stored as IMF: a list of OPL2 (AdLib) register writes, played at 700 Hz by a timer interrupt. The QB64 port can already parse IMF but makes no sound. Another model wrote `plans/qb64_opl2_emulator_fee1c44b.plan.md`. I reviewed it against the code and the installed compiler, and it has blockers. The user chose to **build only the OPL2 path, on classic QB64 v2.1** (`C:\qb64\qb64.exe` reports "QB64 Compiler V2.1"). The goal is to hear the intro song (`StartCPMusic(INTROSONG)` in `DemoLoop`) through a pure-QB64 OPL2 emulator.

## Current project state
**Done:** palette (GAMEPAL); signon and intro screens; `BuildTables`, `NewViewSize`, `CalcProjection`; map, graphics and audio-header setup in `ID_CA.BM` (`CAL_SetupMapFile`, `CAL_SetupGrFile` + `CAL_HuffExpand`, `CAL_SetupAudioFile`); `CheckForEpisodes`; `StartCPMusic`; the IMF sequencer skeleton in `ID_SD.BM`; `ID_MM.BM` stubs.

**Not done:** `CA_CacheAudioChunk` (it's a stub, so `audiosegs()` is never filled), all audio output, `DemoLoop` after the intro song (the menu, the `while 1` loop at C line 1486, PG13), the game loop and renderer (`WL_GAME.BM`, `WL_RENDER.BAS` are partial), `MAPSWL6.BI`, and SFX (AdLib SFX and digitized sounds from VSWAP).

## Review of the existing plan
**Pros:** it separates the sequencer from the synth; uses the correct channel-to-operator maps (ID_SD.C:155–159); calls for fixed-point math and lookup tables; puts the chip in OPL2.BI/.BM, which fits the project's include conventions; and keeps the shared SD_* API.

**Cons and bugs it misses:**
1. **Wrong toolchain:** `_SNDRAWBATCH`, `_MIDISOUNDBANK`, `$EMBED` and `_EMBEDDED$` exist only in QB64-PE. QB64 2.1 has only `_SNDOPENRAW`, `_SNDRAW`, `_SNDRAWLEN`, `_SNDRAWDONE` and `_SNDRATE` (checked in `C:\qb64\source\subs_functions\subs_functions.bas`). Path B is dropped.
2. **`CA_CacheAudioChunk` is a stub:** even with an emulator, no music data reaches `SD_StartMusic`. The plan never mentions it.
3. **`_Mem(music)` bug in `SD_StartMusic`:** `_Mem` applied to an `_Offset` variable describes the 8-byte variable itself, not the buffer it points to. Every read returns garbage.
4. **Length bug:** `MusicGroup.length` is in **bytes** (C: `sqHackLen = music->length`, then `-= 4` per event). The port multiplies it by 2 and reads past the end of the buffer. `sqHackLen` and `sqHackSeqLen` are `Integer` but should be `Long`.
5. **Timing bug:** `SD_ServiceMusic` reads the wall clock (`Timer`) and caps work at 10 ticks per call. At 60 fps a frame is about 11.7 ticks, so music plays slow, the fractional part of each tick is lost, and `Timer` wraps at midnight. The plan keeps two independent clocks.
6. **Nothing services audio during blocking loops:** many `Do: Loop Until InKey$ <> ""` waits exist (WOLF3D.BAS:120, 163, 168, 262, …). Adding `SD_UpdateAudio` to every loop is fragile.
7. **The synth spec is too vague and leaves features out:** it omits the 0x01 waveform-select enable, tremolo/vibrato (AM/VIB bits and 0xBD depth), KSL, key-scale rate, and the real logsin/exp attenuation. "Approximations" risk wrong-sounding instruments.
8. Small issues: `'$INCLUDE:'ID_SD.BM'` is already active (WOLF3D.BAS:130). `StartCPMusic` tests `audiosegs(..) <> -1`, but the "empty" value is 0, as in C.

## Revised design
- **The audio pump owns the clock** (sample-accurate, like the original interrupt). Inside `SD_PumpAudio`, for each output sample: `imfAcc += 700: If imfAcc >= rate Then imfAcc -= rate: SDL_ServiceMusicTick`. One tick is exactly the C loop body at ID_SD.C:1506–1521. The `Timer` delta logic and the 10-tick cap go away.
- **The pump is driven by `ON TIMER`**, QB64's stand-in for the original timer interrupt. `ON TIMER(sdTimerId, 0.01)` calls the pump. QB64 checks events between statements, so it fires inside busy-wait loops too. The pump tops up the queue until `_SNDRAWLEN(pipe) >= 0.1` seconds. If QB64 2.1 refuses the `ON TIMER(n, t) SubName` form, use `GoSub` to a label in WOLF3D.BAS that calls `SD_PumpAudio`.
- **The OPL2 core** is integer-only and runs at the native 49716 Hz. A fractional accumulator resamples it to `_SNDRATE` (linear interpolation). Its structure follows the well-documented YM3812 model used by Nuked-OPL / dbopl: a 256-entry logsin table plus an exp table, a 9-bit envelope with rate counters, and 10-bit phase. All of it is ported to QB64 Long arithmetic. Output is mono `Single` in -1..1 through `_SNDRAW s!, s!, pipe&` (QB64 2.1 has no batch call; 44k calls a second is fine in compiled C++).

## Implementation steps
1. **Audio chunk cache.** Edit `ID_CA.BI` and `ID_CA.BM` to port `CA_CacheAudioChunk` (origsrc/ID_CA.C:1134, non-linked branch):
   - Add `Dim Shared audiosegMem(0 To NUMSNDCHUNKS - 1) As _MEM`.
   - Get `pos` and `compressed` by `_MemGet` of the 4-byte Longs at `audiostarts.OFFSET + chunk*4`.
   - `_MemNew(compressed)`, `Get #audiohandle, pos + 1, bytes()`, `_MemPut`, then set `audiosegs(chunk) = audiosegMem(chunk).OFFSET`.
   - Return early if the chunk is already loaded (`audiosegs(chunk) <> 0`).
   - In `ID_MM.BM`, add a small `CA_FreeAudioChunk chunk` (`_MemFree` and zero the entry), or teach `MM_FreePtr` to do it.
2. **`WL_MENU.BM` `StartCPMusic`:** use the `<> 0` test and pass `audiosegMem(STARTMUSIC + chunk)` to `SD_StartMusic`.
3. **New `OPL2.BI`:** include guard `INCLUDE_OPL2_BI`. Holds constants from origsrc/ID_SD.EQU (operator bases 0x20/0x40/0x60/0x80/0xE0, channel bases 0xA0/0xB0/0xC0, 0xBD, 0x01), `OPL2_RATE = 49716`, `Type OPL2Op`, operator and channel tables, logsin/exp tables, and the `DECLARE`s.
4. **New `OPL2.BM`** (~400–500 lines), with these subs:
   - `OPL2_Init`: builds the tables.
   - `OPL2_Reset`: zeroes registers 0x01–0xF5 and sets every envelope to silent, like `SDL_CleanAL`.
   - `OPL2_Write reg, value`: handles operator registers (decode the slot), A0/B0 (frequency number, block, key-on edge restarts the envelope), C0 (feedback and connection), BD (AM/VIB depth and rhythm), and 01 (waveform-select enable).
   - `OPL2_Sample&`: produces one native-rate sample covering 9 melodic channels, FM and additive connection, feedback, 4 waveforms, KSL, total level, tremolo and vibrato.
   - Rhythm mode is optional and comes last; Wolf3D music is melodic.
5. **`ID_SD.BI` and `ID_SD.BM`:**
   - Change `sqHackLen` and `sqHackSeqLen` to `Long`; add `sdPipe&`, `sdTimerId`, `imfAcc&`, `oplAcc&`.
   - `SD_StartMusic (music As _MEM)`: length = the first word in **bytes** (no ×2). Call `OPL2_Reset` on start and in `SD_MusicOff`.
   - `SDL_ServiceMusicTick` = the C tick body, calling `OPL2_Write reg, regData`. `alTimeCount` increments once per tick.
   - Remove the `Timer`-based `SD_ServiceMusic` logic.
   - Add `SD_Startup` (`OPL2_Init`, `OPL2_Write &H01, &H20`, `sdPipe& = _SndOpenRaw`, arm `ON TIMER`), `SD_Shutdown` (`Timer(sdTimerId) Off`, `_SndRawDone`, `_SndClose`), and `SD_PumpAudio`.
   - Include `OPL2.BI` and `OPL2.BM` from here.
6. **`WOLF3D.BAS`:** call `SD_Startup` in `InitGame` (line 312, replacing the comment). Call `SD_Shutdown` before `End` (line 113) and in `ErrorHandler`. Add the GoSub label only if the fallback from the design section is needed.
7. **Housekeeping:** rewrite `plans/qb64_opl2_emulator_fee1c44b.plan.md` to match this plan (drop Path B, record the bugs found), and update `TODO.txt` (AUDIOWL6.BI is now done, add sound TODOs). Follow the code style: CamelCase keywords, `$If X = UNDEFINED Then / $Let X = 1 / $End If` guards.

## Verification
- Compile with `C:\qb64\qb64.exe -x WOLF3D.BAS` after each step; `parse-format-qb64-error.awk` and `mymake.sh` help read errors.
- After step 1: temporarily print the chunk size and first word of `STARTMUSIC + INTROSONG`; the length should equal the chunk size minus 2 or 4.
- After step 4: a temporary test sub writes a single sine-wave note (frequency number 0x244, block 4 ≈ 440 Hz, key-on). It should be audible and in tune.
- End to end: run `WOLF3D.exe`. The intro song ("NAZI_NOR") should play during the signon/PG13 key waits at the right tempo (compare with DOSBox or a reference recording), with no dropouts (`_SNDRAWLEN` stays near 0.1 s), and should loop correctly at the end.

## Implementation status (2026-10-25)
- Steps 1–6 implemented: `CA_CacheAudioChunk`/`CA_FreeAudioChunk` (ID_CA), `StartCPMusic` (WL_MENU), `OPL2.BI`/`OPL2.BM`, rewritten `ID_SD.BI`/`ID_SD.BM`, `SD_Startup`/`SD_Shutdown` wiring in WOLF3D.BAS.
- `ON TIMER(n, t) SubName` works in QB64 2.1 (about 62 events/s on Windows, fires inside busy loops).
- Offline checks: a 440 Hz test note measured 439 zero crossings/s; after 30 s, the sequencer position matches a Python model of the original C loop exactly (byte 4718 of 8428 in NAZI_NOR).
- Speed: 13.8x realtime without `$Debug`, 2.7x with `$Debug` (WOLF3D.BAS has `$Debug` on).
- Still open: rhythm mode, AdLib/PC/digitized SFX, listening test against DOSBox.
