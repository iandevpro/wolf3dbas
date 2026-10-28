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
Commit `788ec93`.

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

## 2026-10-27: Step 5b, menu sub-menus
Commit `478f25c`.

- **What works:**
  - **New Game:** episode screen ("Which episode to play?"), then the difficulty screen ("How tough are you?") with the face picture following the cursor. Choosing a difficulty calls `NewGame`.
    - Without `GameLoop` no game runs yet; the game returns to the title loop, and the temporary block in `DemoLoop` undoes what starting a game changes in the menu.
  - **Sound:** effects None / PC Speaker / AdLib, and music None / AdLib. The digitized sound rows are inactive because digitized sounds aren't ported.
  - **Control:** Mouse Enabled toggle, Mouse Sensitivity slider, Customize Controls. The joystick rows are inactive (joystick not ported).
  - **Customize Controls:** shows the mouse, joystick and keyboard bindings and lets you rebind them. Key names come from `IN_GetScanName$`, including the arrow glyphs.
  - **Change View:** resizes the view box (`ShowViewSize` / `DrawPlayBorder`); Enter applies it with `NewViewSize`, Esc cancels.
- **Still empty:** Load Game (5c), Read This (5c).
- **Sound manager:**
  - `MusicMode` with `SD_SetMusicMode`; `SD_StartMusic` only plays when the music mode is AdLib.
  - `DigiMode` with an `SD_SetDigiDevice` stub (only Off).
  - `AdLibPresent` = TRUE; the Sound Blaster and Sound Source present flags are FALSE.
- **New globals:**
  - `WL_PLAY.BI` (new): `dirscan()`, `buttonscan()`, `buttonmouse()`, `buttonjoy()` with the original defaults.
  - `WL_DEF.BI`: `NUMBUTTONS`, `bt_*`, `di_*`, `STATUSLINES`, `STARTAMMO`, `EXTRAPOINTS`, `joypadenabled`, `joystickport`.
  - `ID_IN.BI`: `MousePresent`, `JoysPresent()`.
- **View size (`WOLF3D.BAS`):**
  - New `viewwidth` / `viewheight` / `viewsize` globals and `SetViewSize`. `NewViewSize` now follows the original.
  - The port's made-up `VIEWWIDTH` / `VIEWHEIGHT` constants were replaced with the original `MAXVIEWWIDTH`, and `CalcProjection` now uses `viewwidth` as in the C code.
- **Other code:** `NewGame` (`WOLF3D.BAS`), `ShowViewSize` (`WOLF3D.BAS`), `DrawPlayBorder` (`WL_GAME.BM`), `VWB_Plot` (`ID_VH.BM`).
- **Fixes:**
  - `GameStateType.nextextra` is now a `Long`, because `EXTRAPOINTS` (40000) doesn't fit an `Integer`.
  - `EpisodeSelect(0)` is set to 1 (C: `EpisodeSelect[6]={1}`); otherwise episode 1 would ask you to order it.
- **Porting notes:**
  - Draw and print routines that the C code passed as function pointers (`HandleMenu`, `EnterCtrlData`) are selected by integer IDs or the control type.
  - In `EnterCtrlData`, keys are cleared once before waiting for the new binding, not on every pass as in the original, because the keyboard timer could otherwise update the keys right before such a clear and the press would be lost.
  - `mouseenabled` is now 0/1 like the C boolean, since the menu toggles it with `Xor 1`.
  - `SD_PlaySound` as a statement is `CP_PlaySound`.
- **Renames** (QB64 names are case-insensitive or reserved): the C enums `FIRE`/`RUN`/`OPEN`/`STRAFE` and `LEFT`/`RIGHT`/`FWRD`/`BKWD` became the matching `bt_*` / `di_*` constants; `MOUSE`..`KEYBOARDMOVE` became `CTRL_*`; the `CP_Control` enum became `CTL_*`.
- **Tested:** scripted key presses and screenshots in the running game.
  - New Game episode and difficulty screens, and returning to the title after choosing a difficulty.
  - Sound, Control, Customize, Mouse Sensitivity (slider moved) and Change View (view resized) screens all match the original.
  - Rebinding Run from RShft to Z on the keyboard row worked.

## 2026-10-27: Step 5c, Load/Save and Read This
Commit `046f8ea`. This finishes step 5 (the menus).

- **What works:**
  - **Read This!** shows the help article ("pg 1 of 41") with the original layout: page frame, colors, pictures with the text flowing around them, and page numbers. Arrows, PgUp/PgDn and Enter change the page; Esc returns to the menu. It plays the corner music, as in the original.
  - **Load Game** lists the 10 save slots, reading the 32-byte name from `SAVEGAM?.WL6` (for example "oleg 6/2" from the existing `SAVEGAM0.WL6`). Choosing a saved slot shows the "Loading..." window.
  - **Save Game** (active only during a game, as in the original) lets you type a name (`US_LineInput`), asks before overwriting a slot, and writes the file with the 32-byte name.
  - F1 in the control panel opens the help.
- **Stubs:** `LoadTheGame` / `SaveTheGame` (`WOLF3D.BAS`) do nothing yet, because the game state they serialize isn't ported. Loading returns to the title loop for now, and a saved file only holds the name.
- **`WL_TEXT.BI` / `WL_TEXT.BM` (new):**
  - The page layout engine (`PageLayout`, `HandleCommand`, `HandleWord`, `NewLine`, `BackPage`, `CacheLayoutGraphics`) and `ShowArticle`, `HelpScreens` and `EndText` (end of episode text, used later).
  - The C code walked a char pointer through the text; here the article is copied from its graphics chunk into a string, and a position index (`textpos`) moves through it.
- **WL_MENU:**
  - `CP_LoadGame`, `CP_SaveGame`, `DrawLoadSaveScreen`, `PrintLSEntry`, `TrackWhichGame`, `DrawLSAction`.
  - `ScanSaveGames` (the save file scan from `SetupControlPanel`), `CP_ReadThis`, `FreeMusic`.
- **`US_LineInput` and `USL_XORICursor` (`ID_US_1.BM`):** text entry with the blinking cursor, Home/End, Backspace and Delete.
- **Input:** a key press queue (`IN_GetKeyPress`). The original only kept the latest key (`LastScan` / `LastASCII`), and the keyboard service handles up to ~16 ms of key events at once, so fast typing lost characters ("test save" came out as "te") until text input read from the queue.
- **Fixes:**
  - Font 0 (`STARTFONT`) was never loaded at startup. The original loads it in `InitGame`; without it, the save slot names were invisible unless the help or high scores had been shown before.
  - The file names (`configname`, `SaveName`, ...) were reset by `InitGame` after `CheckForEpisodes` had added the extension, and appending to a fixed-length string didn't work anyway. They are now initialized at the top of the program with the original values, `SaveName` is `SAVEGAM?.` (it was "SAVE."), and `CheckForEpisodes` appends with `RTrim$`.
  - `FreeMusic` stops the music before freeing its chunk. The original freed the chunk while it was still being played, which here would read freed memory.
- **Renames** (QB64 keywords or case-insensitive clashes):
  - `BACKCOLOR` (WL_TEXT.C) became `TEXTBACKCOLOR`.
  - The `def` parameter of `US_LineInput` became `defaultstr`, since both `DEF` and `DEFSTR` are keywords.
- **Tested:** scripted key presses and screenshots in the running game.
  - Help pages 1, 2 and 5 (with a picture), paging back and forward, Esc back to the menu.
  - The Load Game list with the existing save.
  - Saving, with a temporary build that enabled Save Game outside a game: the name typed into an empty slot was written ("test save" + zero padding) and listed by Load Game. The test file was then deleted and the switch reverted.
  - Choosing a slot in Load Game (the "Loading..." window) was not tested.

## 2026-10-28: Step 6a, groundwork for the game
Commit `d02513f`. Plan: `step6_game.plan.md`; the four decisions listed there are applied.

- **Early drafts removed:**
  - `WL_RENDER.BAS`, `WL_GRAPH.BAS`, `WL_INPUT.BAS`, `WL_INPUT.BI` deleted; none of them was included in the build.
  - `WL_GAME.BM` now only holds the ported `DrawPlayBorder`.
- **`WL_DEF.BI` rewritten from WL_DEF.H:**
  - The constants (tile numbers, angles, `GLOBAL1`, `MINDIST` = &H5800 instead of the port's 0.5, page sizes, `FL_*` flags...).
  - The enums: `door_t`, `activetype`, `classtype`, `stat_t`, `dirtype`, `enemy_t`, weapons, difficulty, and `exit_t` with the original values (the port had e.g. `ex_abort` = 4, the original 7).
  - The structures `statetype`, `statobj_t`, `doorobj_t`, `objtype` and `gametype`.
  - The global arrays `objlist()`, `statobjlist()`, `doorobjlist()`, `tilemap()`, `spotvis()`, `actorat()`.
  - The invented types (`GameStateType`, `ActorType`, `WallType`, `DoorType`, `walls()`...) are gone.
- **Pointers as indices:** object links are `nextobj` / `prevobj` indices (-1 = NULL); `actorat()` stores objects as `OBJ_BASE` (256) + index; `objtype.state`, `statetype.nextstate` and the routine ids are indices. Explained at the top of `WL_DEF.BI`.
- **Generated from the C headers:**
  - `WL_SPR.BI`: 436 sprite numbers (`SPR_*`, WL6 build), matching the 436 sprite pages in VSWAP.WL6.
  - `MAPSWL6.BI`: 62 map name values (60 maps and two placeholders), now included by `ID_HEADS.BI`.
- **`FixedByFrac`** (`WOLF3D.BAS`): 16.16 value times a sintable fraction (sign bit + 16-bit fraction), with `_Integer64`. The original was assembly that isn't in these sources.
- **Display:**
  - `VW_UpdateScreen` calls `_Display` (manual display), so half-drawn frames never show.
  - `VL_SetPalette` / `VL_FillPalette` also call `_Display`, so fades show.
  - The exit paths (`End`, `Quit` with an error, the error handler) turn automatic display back on, so their messages appear.
- **`$Debug` removed** from WOLF3D.BAS (it made the compiled code about 5x slower).
- **Renames** (QB64 names are case-insensitive or keywords):
  - `dirtype` values are prefixed `dt_` (they clash with `NORTH`/`EAST`... and with the input `dir_*`);
  - `doorobj_t.lock` became `doorlock`;
  - the `new` object pointer became `newobj`;
  - object and state links are `nextobj` / `prevobj` / `nextstate`.
- **Fixes:**
  - `&H80000000` without the `&` suffix is a positive 64-bit number in QB64, not the Long sign bit. `BuildTables` used it for the negative `sintable` entries; it now uses `&H80000000&`.
  - Duplicate constants in WOLF3D.BAS were removed (they're in WL_DEF.BI now).
- **Not yet:** `BuildTables` / `CalcProjection` still don't match the original (`FINEANGLES` tables); they are re-ported with the raycaster in 6d.
- **Tested:**
  - `FixedByFrac` in a scratch harness: 1.0 × 0.5, ±3.0 × ±0.5 and 3000 × 0.99998 all gave the expected results.
  - The game: signon, the memory screen, NonShareware, PG13, title, menu, help, the Quit confirm and exit all work with manual display (screenshots).
  - QB64 2.1 console note found along the way: `Print a, b` (comma zones) in `$Console:Only` printed endless spaces, so use `;`.

## 2026-10-28: Step 6b, map and VSWAP data
Not committed yet.

- **Maps (`ID_CA`):**
  - `CA_CacheMap` with `CAL_CarmackExpand` and `CA_RLEWexpand`; GAMEMAPS.WL6 is carmack + RLEW compressed (`CARMACIZED`).
  - The two planes are now the array `mapsegs(plane, y * 64 + x)` instead of C pointers to allocated buffers. `MAPSPOT(x, y, plane)` reads it, like the C macro.
  - `RLEWtag` is read from MAPHEAD.WL6 (it was never set). `planelength` and `RLEWtag` are read as unsigned words.
- **Page manager (`ID_PM.BI` / `ID_PM.BM`, new):**
  - `PM_Startup` reads the VSWAP header (`ChunksInFile`, `PMSpriteStart`, `PMSoundStart`) and the page offset and length tables, then loads the whole file (1.5 MB) into one `_MEM` block (`PMData`). No EMS/XMS paging is needed.
  - `PM_GetPage` / `PM_GetSpritePage` / `PM_GetSoundPage` return the byte offset of a page inside `PMData`.
  - `InitGame` calls `PM_Startup` and `Quit` calls `PM_Shutdown`.
- **Port debug views (`PORTDEBUG.BM`, new, NOT part of the original):**
  - Start with `WOLF3D.exe /mapview`. It shows the maps from above (walls in their texture color, doors, floors, objects, the player start), the wall pages, and the sprite pages decoded from the `t_compshape` format.
  - It writes `MAPCHECK.TXT` with checksums of all maps.
  - The original debug views can't be used yet: `ShapeTest` needs the scalers (6d/6e), and `ViewMap` is disabled (`#if 0`).
- **Fix found by the user:** the page tables were declared as fixed-size arrays (`Dim Shared PMPageOffset(0)`), so the `ReDim` in `PML_OpenPageFile` stopped with "Duplicate definition". Resizable shared arrays are declared with `ReDim Shared`.
- **Tested:**
  - The checksums of both planes of all 60 maps match an independent Python decoder of GAMEMAPS.WL6 (0 mismatches). The RLEW tag is &HABCD, and every map has exactly one player start.
  - Screenshots: E1M1 ("Wolf1 Map1") has its familiar layout, with 22 doors and 182 objects; wall page 3 is the gray stone wall (106 wall pages); sprite 50 is the standing guard, matching `SPR_GRD_S_1` = 50 from the generated `WL_SPR.BI`.
