# Wolf3D QB64 port: porting log

One entry per step, newest at the bottom. Each one records what was done, how it works, what is still missing, and how it was tested.
The plan for the next steps is in `next_steps_roadmap.plan.md`.

---

## 2026-10-25: OPL2 emulator and IMF music
Commit `6a3094e` (merged as `524f78b`). Plan: `qb64_opl2_emulator_fee1c44b.plan.md`.

- **Toolchain:** the installed compiler is classic QB64 v2.1, not QB64-PE, so the MIDI path from the first plan was dropped. Only `_SndOpenRaw`, `_SndRaw`, `_SndRawLen`, `_SndRawDone` and `_SndRate` are available.
- **`OPL2.BI` / `OPL2.BM` (new):** whole-number YM3812 emulator at the native 49716 Hz. It has logsin/exp tables, the envelope generator, KSL, tremolo/vibrato, feedback and 4 waveforms, and follows the chip behaviour documented by Nuked-OPL3. Rhythm mode is a TODO; Wolf3D music doesn't use it.
- **`ID_SD`:**
  - The IMF sequencer is clocked by generated samples rather than wall-clock time, so the tempo is exact.
  - `ON TIMER` calls `SD_PumpAudio`, which keeps 0.1 s queued in the `_SndRaw` pipe. Timer events fire between statements, so music keeps playing inside busy-wait loops.
- **`ID_CA`:** `CA_CacheAudioChunk` ported, `CA_FreeAudioChunk` added.
- **Bugs fixed in the earlier port:**
  - `_Mem` was applied to an `_Offset` variable, so it read the variable instead of the buffer.
  - The IMF length was doubled; it is in bytes.
  - Wall-clock timing with a 10-tick cap made the music play slow.
- **Tested:**
  - A 440 Hz test note measured 439 zero crossings per second.
  - After 30 s of the intro song, the sequencer position matched a Python model of the original exactly.
  - The emulator runs at 13.8x realtime, or 2.7x with `$Debug`.

## 2026-10-25: PG13 screen
Commit `0911fce`.

- **`ID_CA`:** `CA_CacheGrChunk`, `UNCACHEGRCHUNK` and `GRFILEPOS`; `grsegs()` / `grsegsMem()` hold the cached chunks.
- **`ID_VH` / `ID_VL`:**
  - `VWB_DrawPic`, `VW_FadeIn` / `VL_FadeIn`, and a `VW_UpdateScreen` stub (everything is drawn straight to the Screen 13 page).
  - `VL_PlanarMemToScreen` draws VGA 4-plane pictures through `_MemImage(0)`.
- **`ID_IN` (new):** `IN_UserInput`, `IN_CheckAck`, `IN_ClearKeysDown`.
- **`WL_INTER`:** `PG13`, called from `DemoLoop`.
- **Bugs fixed:**
  - The palette used 6-bit VGA values (0-63) directly in `_RGB32`, so every color showed at 1/4 brightness. `gamepal()` is now shared and scaled to 8-bit.
  - `CAL_OptimizeNodes` corrupted the Huffman node links, and the old `CAL_HuffExpand` wrote every byte into a separate `pictable().width`. The optimizer is now a no-op and the expander works on any `_MEM` block, so picture sizes are correct.
  - `VL_Bar` added the x/y offset twice.
  - `VWB_Bar` had a debug print and key wait.

## 2026-10-26: Step 1, title and credits screens
Commit `5d381fb`.

- **`CA_CacheScreen`:** decompresses a full-screen planar picture and draws it at 320x200.
- **`DemoLoop`:** the original `while (1)` attract loop, with the title for 15 s and the credits for 10 s, fades, and `IN_UserInput` to break out on a key press.
- **Exit:** before `End` the game palette is restored, and the error handler restores the default palette, so messages are readable after a fade-out.
- **Tested:** captured both screens in the running game; quitting from the title showed the normal exit prompt, not an error.

## 2026-10-26: Step 2, fonts and US_Print
Commit `256b1f6`.

- **`ID_VH`:** `VW_DrawPropString` / `VWB_DrawPropString` (proportional font drawn through `_MemImage`), `VW_MeasurePropString`, `SETFONTCOLOR`, and the `fontnumber` / `px` / `py` state.
- **`ID_US.BI` / `ID_US_1.BM` (new):**
  - `US_Print`, `US_CPrint`, `US_CPrintLine`, `US_PrintCentered`, `USL_PrintInCenter`, `US_PrintSigned` / `US_PrintUnsigned`, and the `PrintX` / `PrintY` / `Window*` state.
  - The C code's `\n` becomes `Chr$(10)`.
  - The measure and draw function pointers are replaced by direct calls.
- **`ID_IN`:** `IN_Ack` and `IN_StartAck`.
- **`WL_MENU.BI`:** the menu color constants.
- **`NonShareware`:** fully ported, with the "Attention" text. The debug key wait is gone.
- **Tested:** captured the screen in the running game; it matches the original.

## 2026-10-26: Step 3, high scores
Commit `046bb12`.

- **`DrawHighScores`:**
  - Banner, headings, and the "E1/L1" level column.
  - Numbers use the font's fixed-width digit glyphs (codes 129-138).
  - The SPEAR branches are kept, apart from the SPEAR graphics loading, which is a TODO.
- **`ID_US.BI`:**
  - `Type HighScore` uses the 66-byte C layout.
  - The default `Scores()` table holds the id Software names.
  - Loading the saved scores from CONFIG.WL6 waits for `ReadConfig`.
- **`US_CString$`:** cuts a fixed-length string at its zero terminator.
- **`DemoLoop`:** shows the high scores for 10 s. A temporary `VW_FadeOut` stands in for the fade that `PlayDemo` does.
- **Tested:** captured the screen after the title and credits; it matches the original layout.

## 2026-10-26: Step 4, AdLib sound effects
Commit `d82e589`.

- **`ID_SD`:**
  - `SD_SetSoundMode`, `SD_PlaySound` (with the original priority rules), `SD_SoundPlaying`, `SD_StopSound`, `SD_WaitSoundDone`.
  - `SDL_ALPlaySound` / `SDL_AlSetFXInst` / `SDL_ALSoundService` play effects on OPL2 channel 0, which the music doesn't use.
  - Effects are serviced every 5th tick of the 700 Hz clock (140 Hz), from `SD_PumpAudio`.
  - The `sdLock` flag replaces the original's `asm cli`: the audio pump skips its turn while it is set.
- **`ID_CA`:** `CA_LoadAllSounds`.
- **`InitGame`:** AdLib effects by default, the original's choice when there is no config file. `ReadConfig` is a TODO.
- **Not ported:** PC speaker effects and digitized sounds (the latter need the VSWAP page manager).
- **Tested:**
  - A scratchpad harness played effects through `SD_PlaySound`. Durations matched the data length at 140 Hz exactly: 92, 192 and 1271 ms.
  - A fourth effect, `HITWALLSND`, measured 1 ms: it is sound number 0, so `SD_SoundPlaying` reports "not playing", the same quirk as the original. It did play.
  - Effects peak at about 24,500 against about 14,000 for the intro music at the current gain (6).

## 2026-10-26: Step 5a, input layer and main menu
Not committed yet.

Step 5 is split into three parts: 5a input and main menu, 5b sub-menus, 5c Load/Save and Read This.

- **What works:**
  - A key press on the title, credits or high scores opens the Options menu with the original layout.
  - The gun cursor animates and moves with Up/Down, with the half-step slide and its sounds, and skips the inactive Save Game. Typing a letter jumps to the item starting with it.
  - **View Scores** shows the high scores with the roster music.
  - **Back to Demo** returns to the title loop with the intro music.
  - **Quit** (or Esc) shows the confirm box with a random original message; N goes back, Y exits.
- **Still empty:** New Game, Sound, Control, Load Game, Change View and Read This. Selecting one just fades out and back.
- **Input (`ID_IN`):**
  - A `Keyboard()` table of the original PC scan codes is filled from `_KeyHit` events by `INL_KeyService` on its own `ON TIMER`, the equivalent of the original keyboard interrupt.
  - A key released within 50 ms of its press still reads as held; without that, quick taps were lost in testing.
  - Mouse buttons only count when newly pressed, as in the original `IN_StartAck`.
  - `IN_ReadControl`, `IN_Startup` / `IN_Shutdown`. Mouse motion and joystick are TODO.
- **`TimeCount`:** the original 70 Hz tick counter, advanced every 10 ticks of the audio pump's 700 Hz clock, as the original timer interrupt did.
- **Menu code (`WL_MENU`):**
  - `HandleMenu` and its gun-cursor helpers, `DrawMenu`, `DrawWindow`, `DrawOutline`, `Message`, `Confirm`, `US_ControlPanel`, `DrawMainMenu`, `CP_ViewScores`, `CP_Quit`.
  - Menu item routines are integer IDs dispatched by `CP_CallRoutine`, since QB64 has no function pointers.
- **`Quit` (`WOLF3D.BAS`):** shuts down input and sound, then exits. Writing the config and the DOS text-mode ending screens are TODOs.
- **`US_RndT`:** a plain random number for now. The original's fixed random table is still needed for demo playback.
- **Fixes:**
  - `VWB_Hlin` passed its arguments to `VL_Hlin` in the wrong order, so the stripe line under every title bar was drawn off-screen.
  - `VWB_Vlin` / `VL_Vlin` added.
  - `VL_FadeOut` now takes 6-bit VGA colors like the C version, so the menu fade goes to dark red.
  - `CA_LoadAllSounds` keeps the sound set when the mode hasn't changed, so it can't free an effect that is still playing.
- **Renames** (QB64 names are case-insensitive, or reserved):
  - menu item constants use an `mi_` prefix;
  - `StartGame` became `StartGameMenu`;
  - `ShootSnd` became `CP_ShootSnd`;
  - the C struct field `string` became `txt`.
- **Tested:** scripted key presses and screenshots in the running game. Menu navigation, View Scores, both confirm answers, Back to Demo and quitting all worked.
