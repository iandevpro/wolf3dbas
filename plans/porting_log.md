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
Commit `2eb471c`.

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

## 2026-10-28: Step 6c, play screen and level setup
Commit dd1a23e.

- **What works:** New Game → episode → difficulty now enters the game: the play border and status bar (floor, score, lives, BJ's face, health, ammo, weapon), the level music, and "Get Psyched!" with its progress bar. The 3D window stays black until 6d. For now Esc leaves the game and returns to the title loop.
- **`WL_GAME.BM`:**
  - `GameLoop` (with the level-completed, died and victory cases kept as TODOs for 6f-6h), `SetupGameLevel`, `ScanInfoPlane`, `DrawPlayScreen`, `ClearMemory`.
  - `ScanInfoPlane` has a `$If SPEAR` / `$Else` pair, each with its own complete `Select Case` (WL6 bosses and ghosts in one, Spear bosses in the other). This was the user's request; a `$If` between `Case` lines confuses QB64.
  - The enemy groups, the same in both versions, are in `ScanSpawnEnemy`. `ScanSpawnTile` replaces the C case fall-through from the hard / medium enemy tiles down to the easy ones.
- **`WL_PLAY.BM` (new):** `InitActorList`, `GetNewActor`, `RemoveObj` on the index-linked object list; `StopMusic`; `StartLevelMusic`; a temporary `PlayLoop` (fade in, wait for Esc, `playstate = ex_abort`).
  - `GameLoop` ends the game on `ex_abort` until the real play loop exists.
- **`WL_PLAY.BI`:** the play loop globals, and `songs()` (the music of each map), generated from WL_PLAY.C.
- **`WL_ACT1.BI` / `WL_ACT1.BM` (new):** `InitStaticList`, `InitDoorList`, `SpawnDoor` (doors are `doornum Or &H80` in `actorat()` and `tilemap()`, below `OBJ_BASE`), `InitAreas`, `ConnectAreas`, `RecursiveConnect`, door and area globals. `SpawnStatic` is a stub (6e).
- **`WL_AGENT.BM` (new):** the status bar (`StatusDrawPic`, `DrawFace`, `LatchNumber`, `DrawHealth`, `DrawLevel`, `DrawLives`, `DrawScore`, `DrawWeapon`, `DrawKeys`, `DrawAmmo`) and `SpawnPlayer`.
- **`WL_ACT2.BM` (new):** the enemy spawn entry points as stubs (6g / 6h).
- **`WL_INTER.BM`:** `PreloadGraphics` ("Get Psyched!"), `PreloadUpdate`, `ClearSplitVWB`.
- **`ID_VH.BM`:**
  - `LatchDrawPic`: latches were pictures copied into video memory; here they are cached pictures, and x is in 8-pixel units.
  - `LoadLatchMem` caches them; `InitGame` calls it.
- **`ID_PM.BM`:** `PM_Preload` only shows the progress, since the pages are already in memory. It updates every 16 pages.
- **`DemoLoop`** calls the real `GameLoop`; the temporary block from 5b is gone.
- **Renames:**
  - `StartMusic` became `StartLevelMusic` (it clashed with the `STARTMUSIC` chunk constant).
  - `ScanSpawnTile`'s parameter `base` became `basetile` (BASE is a keyword).
- **Fixes found while testing:**
  - `Erase` freed `tilemap()` instead of zeroing it, and the next access stopped with "Subscript out of range" (WL_GAME.BM line 245). All `Erase` uses in the new code are clearing loops now.
  - `SpawnPlayer` stored the raw floor tile as the area number; the C code relies on `Thrust(0, 0)` to subtract `AREATILE` before `InitAreas`. Until `Thrust` arrives (6d), `SpawnPlayer` does that part itself.
- **Tested:** scripted key presses and screenshots: New Game → "Get Psyched!" → play screen with the correct status bar → Esc back to the title. The level music wasn't checked by ear.

## 2026-10-28: Step 6d, raycaster and player movement
Commit 0d0fba1.

- **What works:** the 3D view. Walls with their light and dark sides, doors (drawn closed until 6f), and the level's ceiling color with the gray floor. Walking and turning with the arrow keys, Alt to strafe, Shift to run, and wall collision with the "hit wall" sound. Esc opens the menu and "Back to Game" returns to the level. End Game (menu or F7) works. The MLI and BAT cheat messages work, and so do the pause key and the F1-F10 shortcuts.
- **`WL_DRAW.BI` / `WL_DRAW.BM` (new):**
  - `AsmRefresh` is a port of the WL_DR_A.ASM ray caster. It uses labels and GoTo, following the asm's control flow, with the same 16.16 fixed-point steps and intercepts. It calls `HitVertWall`, `HitHorizWall`, `HitVertDoor`, `HitHorizDoor`, `HitVertPWall` and `HitHorizPWall`.
  - Also here: `CalcHeight`, `ScalePost`, `VGAClearScreen`, `WallRefresh`, `CalcTics`, `ThreeDRefresh`, and `FizzleFade`, which uses a copy of the old view because there is only one screen page.
  - Exact C integer semantics: `Wrap32`, `Add32` and `Mul32` for the wrapping 32-bit arithmetic, and `SarL` / `HiWord` for arithmetic shifts. `FixedByFrac` moved here from WOLF3D.BAS.
  - Drawing goes straight into the Screen 13 page via `_MemImage(0)`. The page flip is `_Display`.
- **`WL_SCALE.BI` / `WL_SCALE.BM` (new):** `SetupScaling` and `BuildCompScale`. The original generated machine code for each wall height. Here each height gets a table of source texel and screen rows (`scalersrc`, `scalertop`, `scalerbottom`), and `ScalePost` loops over that table. The rows, texels and clipping match the generated code.
- **`WL_STATE.BI` / `WL_STATE.BM` (new):** the state table. `statetype` pointers became indices into `states()`, where 0 = NULL. Think and action routines are IDs dispatched by `CallStateRoutine`. So far only `s_player` / `T_Player` exist.
- **`WL_PLAY.BM`:**
  - The real `PlayLoop`, `PollControls`, `PollKeyboardButtons`, `PollMouseButtons`, `PollKeyboardMove`, `CheckKeys` and `DoActor`.
  - An actor's NULL state is now 0 instead of -1.
- **`WL_AGENT.BM`:** `ControlMovement`, `Thrust`, `ClipMove`, `TryMove`, `T_Player`, `UpdateFace`, `CheckWeaponChange`, `GiveWeapon`, `GiveAmmo`, and `VictoryTile` (BJ's victory run comes in 6h). `SpawnPlayer` now calls the real `Thrust 0, 0`.
- **`WL_GAME.BM`:**
  - New: `DrawPlayBorderSides`, `DrawAllPlayBorder`, `DrawAllPlayBorderSides`.
  - The temporary `ex_abort` exit in `GameLoop` is gone.
  - `ex_died` takes a life and restarts the level, or ends the game when no lives are left. The death sequence itself is 6g.
- **`WL_MENU.BM`:**
  - The real `CP_EndGame`.
  - All of `CP_CheckQuick`: F7 end game, F8 / F9 quick save and load through the 5c menus, and F10 quit. The quick paths go through `CP_QuickReturn`, and the random quit question is in `CP_ConfirmQuit`.
- **`WOLF3D.BAS`:** faithful `BuildTables` and `CalcProjection` (C truncation and the float math as in the original). `SetViewSize` computes where the view sits on the screen and calls `SetupScaling`. `InitGame` calls `InitStates`.
- **Fixes found while testing:**
  - QB64 operator precedence: `*` binds tighter than `\`. So `a \ 2 * 80` means `a \ 160`, unlike C, where it means `(a / 2) * 80`. This put the view at row 0 (`screenofs` was 10 instead of 1610) and skipped the floor loop. Fixed both, and searched the code for other `\ x *` and `Mod x *` cases; there are none.
  - `tileglobal` / `mindist` clashed with the `TILEGLOBAL` / `MINDIST` constants (names are case-insensitive); the constants are used directly.
  - A `Const` can't contain `Chr$`, so `STR_LGC` gets its newline and quote where it's used.
- **Tested:** scripted key holds and screenshots. The E1M1 start view faces the door, and walking up to it fills the view. Turned left and right, walked into walls (collision and sliding along walls work), saw the light and dark wall sides at corners. Esc → menu → Back to Game, then F7 → Y → back to the title.
- **Not done yet:**
  - Not yet compared side by side with DOSBox-X from the same spots.
  - Walking speed and frame rate not yet measured.
  - Still TODO: mouse motion turning, joystick, demo playback and recording (6j), and the debug keys.

## 2026-10-28: Step 6e, sprites, items and the weapon on screen
Commit 1bcecec.

- **What works:**
  - The static objects of the levels show up: ceiling lights, tables, lamps, skeletons, food, ammo and treasure. They are sorted back to front, and hidden behind walls column by column.
  - The pistol is drawn at the bottom of the view.
  - Walking over a bonus item picks it up: the status bar updates, the sound plays and the screen flashes yellow-white.
  - The game now runs at 70 fps (one tic per frame) instead of about 16 fps.
- **`WL_SCALE.BM`:**
  - `ScaleShape`, `SimpleScaleShape` and `ScaleLine` draw the compiled sprite format (`t_compshape`) column by column.
  - The scaler tables now also record, for each texel, its width in pixels (`t_compscale` width[]) and its clipped screen rows, which stand in for the compiled code.
  - `ScaleShape` follows the C loops exactly. That includes the multi-pixel column clipping against `wallheight()`, and the "rest of the shape is gone" exits.
- **`WL_DRAW.BM`:** `TransformActor`, `TransformTile` (bonus pickup distance), `CalcRotate`, `DrawScaleds` (statics, then actors seen in any of the 9 tiles around them), and `DrawPlayerWeapon`. The asm `idiv` height uses the 16-bit quotient like the original.
- **`WL_ACT1`:**
  - The `statinfo[]` table, with `$If SPEAR` variants.
  - `SpawnStatic`: blocking statics set `actorat` to 1, and treasures count toward the level total.
  - `PlaceItemType`, for items that enemies drop (6g).
- **`WL_AGENT.BM`:**
  - `GetBonus`, `HealSelf`, `GivePoints` (extra life every 40000), `GiveExtraMan`, `GiveKey`.
  - The Spear-only 25-clip case is in `GetAmmoBox`, because a `$If` can't go between `Case` lines.
- **`WL_PLAY.BM`:**
  - Palette shifts: `InitRedShifts` (computed on the 6-bit VGA values like the original), `ClearPaletteShifts`, `StartBonusFlash`, `StartDamageFlash`, `UpdatePaletteShifts`, `FinishPaletteShifts`. `InitGame` calls `InitRedShifts`.
  - The play loop now calls the palette updates.
- **`WOLF3D.BAS`:** `dirangle()` is filled in; it was declared but never set.
- **Fixes found while testing:**
  - **Frame rate:** `TimeCount` advanced only when audio was generated, and audio is generated in bursts each time the sound device drains its buffer (about every 60 ms). So `CalcTics` saw jumps of about 4 tics, and the game ran at about 16 fps. Now `SDL_TimeCountService` counts `TimeCount` at 70 Hz from the clock, called from the same `ON TIMER` event. Music and AdLib effects stay clocked by samples. Rendering a frame takes well under a millisecond.
  - **`DoActor`:** C's `&&` short-circuits, so `areabyplayer[ob->areanumber]` is only read for inactive actors; QB64's `And` always reads it. With noclip inside a wall, the player's area number is negative, and the game stopped with "Subscript out of range". This is now a nested `If`.
- **Tested:**
  - With temporary noclip (doors open only in 6f), walked into E1M1's first corridor and room: ceiling lights, a skeleton, dog food, the clip and cell doors all appear in place.
  - Walked over the clip: ammo went from 8 to 16, and the flash starts the next frame and lasts 18 tics (checked with a temporary log).
  - The start view shows the pistol. Esc → Back to Game and F7 → Y still work.
- **Not done yet:**
  - Enemies are still stubs, so `DrawScaleds`' actor part and `CalcRotate` haven't run yet (6g).
  - Firing and weapon frames (`Cmd_Fire`, `T_Attack`) are 6g.
  - The death cam picture is 6h.

## 2026-10-28: Step 6f, doors, push walls and the level exit
Commit 7d5bc38.

- **What works:**
  - **Use (Space):** opens and closes doors. Doors slide open, connect their areas, close by themselves after about 4 seconds (300 tics), and reopen if something is in the way. Locked doors need their key and play the "no way" sound otherwise.
  - **Push walls:** they slide two tiles and count as a found secret.
  - **Elevator:** the switch flips, the "level done" sound plays, and the intermission follows: "floor completed", time, par, the time bonus, and the kill / secret / treasure ratios with their sounds and 100% bonuses. BJ breathes while the counts run.
  - **Next level:** a key press goes on to the next floor. The secret elevator and the return from the secret level are implemented too, but untested.
- **`WL_ACT1.BM`:** `OpenDoor`, `CloseDoor`, `OperateDoor`, `DoorOpen`, `DoorOpening`, `DoorClosing`, `MoveDoors`, `PushWall`, `MovePWalls`.
  - `CloseDoor` checks the actors next to the door through `actorat()`. C read `check->x` from any non-zero value, even a wall or static number, which pointed at random memory. Here only real objects can keep a door open.
- **`WL_AGENT.BM`:** `Cmd_Use`, which `T_Player` now calls.
- **`WL_PLAY.BM`:** `PlayLoop` calls `MoveDoors` and `MovePWalls`.
- **`WL_INTER.BI` / `WL_INTER.BM`:**
  - `LevelCompleted` with `parTimes[]` (WL6 and Spear tables), `LevelRatios()`, and `BJ_Breathe`.
  - `WritePic` is the C `Write`, renamed because WRITE is a QB64 keyword.
  - The repeated ratio code is in `RatioCount` and `RatioEnd`. The C `goto done` is an exit from a one-pass loop.
- **`WL_GAME.BM`:**
  - `GameLoop` runs the intermission, then picks the next map in `NextLevelMap` (`ElevatorBackTo()` for WL6, the secret level numbers for Spear).
  - `PlaySoundLocTile` / `PlaySoundLocGlobal` only play the sound for now; the left / right volume of digitized sounds comes in 6i.
- **`ID_VL.BM`:** `VL_WaitVBL` waits the given number of 70Hz retraces; it ignored the count before. The fades wait one retrace per step at 70 instead of 60 per second, as on the VGA.
- **Tested:**
  - Without noclip: opened E1M1's first door, walked through, and saw it close behind me. Esc → Back to Game still works.
  - With temporary noclip and the player's tile shown in the window title (both removed), strafed to the push wall at (30,22). It slid two tiles, and the secret count went to 1.
  - Then went on to the elevator at (25,47) and pressed Use facing the switch. The intermission showed "floor 1 completed", time 00:20, par 01:30, bonus 35000 (70 s left × 500), and a secret ratio of 20% (1 of 5 push walls). A key press started floor 2 at E1M2's start with score 35000.
  - An earlier run finished in 5 s: bonus 42500, and the extra life at 40000 raised lives to 4.
- **Not done yet:**
  - Kill ratios stay 0% until there are enemies (6g).
  - The secret elevator isn't tested.
  - Door sounds aren't positioned (6i).
  - `PicturePause` (a debug key) isn't ported.

## 2026-10-29: Step 6g, enemies and combat
Commit ddbca98.

- **What works:**
  - **Enemies:** guards, officers, SS, dogs and mutants are spawned with their difficulty's hit points. They stand or patrol, notice the player (by sight, by noise, or when ambushing), shout, chase, open doors, dodge, and shoot or bite. They show pain frames and die with their death animation and scream. Enemies drop clips (an SS drops the machine gun if you don't have it yet), and the kill counts toward the score and the kill ratio.
  - **Player weapons:** Ctrl fires the knife, pistol, machine gun or chain gun, with their frames, ammo use and auto-fire. With no ammo left, the knife comes out.
  - **Taking damage:** the red flash and the face update. In baby mode you take 1/4 of the damage.
  - **Death:** the view turns to face the killer, fizzles to red, and you lose a life. With no lives left: fade, the high-score table with name entry, and back to the title.
- **State table:**
  - `WL_STATE.BI` and `InitStates` / `CallStateRoutine` in `WL_STATE.BM` are generated by `tools/gen_states.py` from the C initializers (`python tools/gen_states.py`; it keeps the hand-written tables after the marker line in WL_STATE.BI): 441 states and 35 routines, with the C `#ifdef SPEAR` blocks as `$If`.
  - Spear-only states exist as ids in WL6 too.
  - The 23 boss and Spear routines dispatch to nothing yet (6h).
- **`WL_STATE.BM`:** all of WL_STATE.C:
  - spawning and movement: `SpawnNewObj`, `NewState`, `TryWalk` (CHECKDIAG / CHECKSIDE as functions), `SelectDodgeDir`, `SelectChaseDir` (including the C loop `north..west` that only tries north, northwest and west), `SelectRunDir`, `MoveObj`;
  - items and damage: `DropItem`, `KillActor`, `DamageActor`;
  - sight: `CheckLine` (16-bit int sums wrapped like C), `CheckSight`, `FirstSighting`, `SightPlayer`.
  - The boss cases are in their own subs with `$If SPEAR` / `$Else`.
- **`WL_ACT2.BM`:** `SpawnStand` (ambush tiles), `SpawnPatrol`, `SpawnDeadGuard`, `A_DeathScream`, `T_Stand`, `T_Chase`, `T_DogChase`, `T_Path` / `SelectPathDir`, `T_Shoot`, `T_Bite`. Also `T_Ghosts`, `T_Projectile` and `A_Smoke`, ready for 6h. The bosses are still stubs.
- **`WL_AGENT.BM`:** `TakeDamage`, `Cmd_Fire`, `KnifeAttack`, `GunAttack`, `T_Attack` (with `attackinfo[][]`), and `VictorySpin`. `T_Player` now fires.
- **`WL_GAME.BM`:**
  - `Died`: the turn toward the killer uses `_Atan2` in Single precision. The red fizzle goes through `FadeViewToRed`.
  - `GameLoop`: game over leads to `CheckHighScore`.
  - `PlaySoundLocActor` added.
  - The `died` variable became `diedflag`, because it clashed with the `Died` sub.
- **`WL_INTER.BM`:** `CheckHighScore` with `US_LineInput` name entry.
- **Fixes found while testing:**
  - **Enemies were invisible but could be heard** (found by the user). `SpotSeen` returned the raw `spotvis` value 1, and `If Not seen` treated it as unseen, because `Not 1` = -2 is true. So the neighbour-tile checks reset `seen` to FALSE. `SpotSeen` now returns TRUE / FALSE.
  - **All enemies had 0 hit points.** The `starthitpoints` table was read with `Val` from a space-separated string, but QB64's `Val` skips spaces. Each number is now cut out with `Mid$` first.
  - Both pitfalls are added to the QB64 notes.
- **Tested:**
  - Using a temporary readout of the player's position in the window title (removed): opened the doors to E1M1's lit room south of the start. The guard there is visible, shoots (health 90% → 80%), takes hits, shows his death animation and dies (score +100, kill 1/20).
  - Firing uses ammo.
  - With a temporary start at 1 health, 0 lives and 50000 points: the guard killed me, the view fizzled to red, then the high-score table took the name "TESTER" at 50000 and the game returned to the title.
- **Not done yet:**
  - Not compared side by side with DOSBox-X: enemy reaction times, hit rates and damage are only ported, not measured.
  - Officers, SS, dogs and mutants are untested in play; E1M1 only has guards.
  - The death cam and the bosses are 6h.

## 2026-10-29: Step 6h, bosses, the death cam and the episode end
Commit b0d89a3.

- **What works:**
  - **The WL6 bosses:**
    - Hans and Gretel.
    - Schabbs, who runs away and throws syringes.
    - Otto Giftmacher and General Fettgesicht, who fire rockets with smoke and explosions.
    - Mecha Hitler, who turns into the real Hitler.
    - The fake Hitlers, with flames.
    - The ghosts.
  - **The death cam:** after Schabbs, Otto, Fettgesicht and Hitler, the play area fizzles, "Let's see that again!" appears, and the death replays from a fresh camera position with the flashing DeathCam sign. Then the episode ends.
  - **The episode end:** the exit tile starts BJ's victory run (spin, run, jump, "yeah"), followed by `Victory` ("you win!", total time, the time verification code, average ratios), then `EndText`, then the high scores.
- **`WL_ACT2.BM`:**
  - The bosses: `SpawnBoss`, `SpawnGretel`, `SpawnSchabbs`, `SpawnGift`, `SpawnFat`, `SpawnFakeHitler`, `SpawnHitler`, `A_HitlerMorph`.
  - Their routines: `T_Schabb`, `T_Gift` and `T_Fat` (one shared chase, `T_ThrowerChase`), `T_SchabbThrow`, `T_GiftThrow`, `T_FakeFire`, `T_Fake`, `A_MechaSound`, `A_Slurpie`.
  - `SpawnGhosts`.
  - BJ's victory run: `SpawnBJVictory`, `T_BJRun`, `T_BJJump`, `T_BJYell`, `T_BJDone`.
  - The death cam: `CheckPosition`, `A_StartDeathCam`.
  - The death pause before the death cam is 140 tics with digitized sound, 5 without (`BossDeathTime`). As in C, `SpawnFakeHitler` changes the real Hitler's state.
  - All of this is WL6-only code inside `$If SPEAR = UNDEFINED`. The `$Else` side has empty routines, and the Spear actors (trans, uber, will, death knight, angel, spectre) are not ported.
- **`tools/gen_states.py`:** the newly ported routines are in `PORTED`. 8 routines (all Spear) still dispatch to nothing.
- **`WL_AGENT.BM`:** `VictoryTile` calls `SpawnBJVictory`.
- **`WL_DRAW.BM`:** `DrawPlayerWeapon` shows the DeathCam picture (`TimeCount And 32`).
- **`WL_GAME.BM`:**
  - `ex_victorious` now runs `Victory`, then `CheckHighScore`.
  - `FadeViewToRed` became `FizzleToBar`, which can fill any area with any color (used by `Died` and `A_StartDeathCam`).
- **`WL_INTER.BM`:** `Victory`, including the Spear BJ collapse. `EndSpear` is still TODO.
- **Tested:** with temporary test code (all removed): a `WOLFMAP` environment variable picked the start map, god mode and the chain gun were on, a `WOLFBOSS` variable put another boss in Hans's place on E1M9, and the window title showed the angle to the nearest enemy so the test script could aim.
  - **Hans** attacks, dies and drops the gold key. The locked exit door opens, the exit tile starts BJ's run and jump, and the "you win!" screen shows total time 00:00 with code KKA (correct for 00:00).
  - **Schabbs** runs away and throws syringes that hit. Killing him gives the death cam with "Let's see that again!" and the replay.
  - **Mecha Hitler** breaks open, and the real Hitler comes out (2 kills, score 10000). Then the death cam with the DeathCam sign, and the victory screen.
  - **Fettgesicht's rockets** hit, then his death cam plays.
  - **The fake Hitler** dies (score 2000) without a death cam, as in the original.
  - **Testing notes** (both found by the user): I fired while a door had closed again, and earlier fired without aiming while Mecha Hitler stepped aside. Test scripts now fire from inside the doorway and aim first.
- **Not done yet:**
  - Gretel, Otto and the ghosts are untested in play (same code paths as the tested bosses).
  - The Spear actors and `EndSpear` are not ported.
  - `US_RndT` still uses QB64's `Rnd`; the original's random table comes in 6j.

## 2026-10-30: Step 6i, digitized sounds
Commit 7f29afe.

- **What works:**
  - **The digitized sounds** (guard shouts, doors, guns, death screams, boss voices) play from the VSWAP sound pages, the way a Sound Blaster Pro played them. They are mixed with the OPL2 music and the AdLib effects in the same `_SndRaw` stream.
  - **Positioning:** positioned sounds get their left / right volume from where they are relative to the player, and the volumes follow the player while the sound plays (`UpdateSoundLoc`).
  - **The Sound menu** offers "Sound Blaster" for digitized sound, and a new game selects it, like the original's default with a Sound Blaster and no config file.
- **`ID_SD.BI` / `ID_SD.BM`:**
  - **Setup:** `SDL_SetupDigi` reads the sound list (page, length) from the last VSWAP page. That gives 46 sounds in WL6.
  - **Playback:** `SD_PlayDigitized`, `SD_StopDigitized`, `SDL_DigitizedDone`, `SD_SetPosition`, `SD_PositionSound`, `SD_SetDigiDevice` (Sound Blaster present, Sound Source not), and `SD_Poll` (empty: `SD_PumpAudio` feeds the segments).
  - **`SD_PlaySound`** now plays the digitized version first when `DigiMap` has one, with the position and priority logic of the C code. As in the original, `SD_SoundPlaying` only reports AdLib sounds.
  - **The sample rate** is the Sound Blaster DAC rate, 1000000 / (256 − 114) = 7042 Hz.
  - **Resampling:** `SD_PumpAudio` resamples by sample-and-hold, like the DAC, and mixes with gain `SD_DIGIGAIN`. The output is stereo now.
  - **The SB Pro mixer volume** (15 − position per channel) is approximated as 8 steps of 4 dB.
- **`WL_GAME.BI` (new):** the `lefttable` / `righttable` position tables, generated from WL_GAME.C, plus `globalsoundx`, `globalsoundy`, `leftchannel` and `rightchannel`.
- **`WL_GAME.BM`:**
  - `SetSoundLoc`, the real `PlaySoundLocGlobal`, and `UpdateSoundLoc`, which `PlayLoop` calls each frame.
  - `ClearMemory` stops the digitized sound.
- **`WOLF3D.BAS`:** `InitDigiMap` (the WL6 and Spear `wolfdigimap[]` tables). `InitGame` selects the Sound Blaster.
- **Tested** with temporary code (removed) that recorded the exact mixed output to a WAV file and logged digitized starts and stops. Then I compared the recording with the VSWAP samples in Python:
  - **The door opening sound (digi 3)** matches over its whole 1.4 s with gain 0.69 on both channels, i.e. full volume. That's correct, since the door was straight ahead and close (position 0 / 0). The match holds to the end, so the 7042 Hz rate is right.
  - **The pistol (digi 5)** starts at full volume. 13 tics later a guard who heard the shot shouts "Halt!" (digi 0, at position 8 / 8, far away), which replaces it, as in the original.
  - **The Sound menu** shows the Sound Blaster row selected, and the Sound Source row greyed out.
- **Not done yet:**
  - Not compared by ear with DOSBox-X; the recording (rec.wav) was made for that.
  - The SB Pro mixer volume steps are an approximation.
  - PC speaker sounds (`sdm_PC`, `sds_PC`) are still not ported.

## 2026-10-30: Step 6j, demos
Commit 26f9f95.

- **What works:** the attract loop plays the four demos after the title, credits and high scores, in turn. A key press during a demo goes to the menu ("Back to Demo"). The demos play back exactly: the original demos were recorded until the player died, and each one ends with BJ dying on its very last input frame. The results are identical run after run:

  | Demo | Floor | Ends at frame | Score | Kills |
  |---|---|---|---|---|
  | 0 | 38 | 2077 / 2077 | 3900 | 15 |
  | 1 | 44 | 5701 / 5701 | 13600 | 51 |
  | 2 | 57 | 3424 / 3424 | 7100 | 27 |
  | 3 | 32 | 4972 / 4972 | 5600 | 21 |

- **`ID_US.BI` / `ID_US_1.BM`:**
  - The original 256-entry random table from ID_US_A.ASM, with `US_RndT` stepping through it.
  - `US_InitRndT FALSE` (demos) starts at index 0. With randomize it takes the hundredths of the clock, like the DOS time call.
- **`WL_PLAY.BM` `PollControls`:**
  - During demo playback (and recording) each frame takes exactly `DEMOTICS` (4) tics.
  - The commands are read from the demo chunk: a button byte, then the x and y moves as signed bytes. When the data ends, `playstate = ex_completed`.
- **`WL_GAME.BM`:** `PlayDemo`, using the T_DEMO0..3 graphics chunks (DEMOSEXTERN). It takes the map from the demo's first byte, plays hard difficulty, and ends at the demo's length.
- **`WOLF3D.BAS` `DemoLoop`:** plays `LastDemo Mod 4`, leaves for the menu on `ex_abort`, and restarts the intro music otherwise. The temporary fade from 5b is gone.
- **Fix found while testing: demo 1 played differently from run to run.**
  - `UpdateFace` skips its `US_RndT` call while `GETGATLINGSND` plays. The AdLib effects advanced with the audio generation, which runs up to 0.1 s ahead in bursts, so whether the sound was still playing on a given frame varied, and the random sequence drifted.
  - The effects now run with `TimeCount`, two steps per tic, as in the original timer interrupt (`SDL_TimeCountService`; ticks wait while `sdLock` is set). After that, demo 1 gave the same result 3 times in a row.
- **Tested:**
  - The attract loop with no input, with screenshots: demo 0 and demo 1 play.
  - With a temporary switch that played one demo and logged its end state (removed): all four demos, at least twice each, with the results in the table above.
  - A key during a demo opens the menu.
- **Not done yet:**
  - `RecordDemo` / `FinishDemoRecord` (Tab with the "goobers" parameter) are not ported.
  - Not compared on screen with DOSBox-X. The end-of-data deaths are strong evidence; the end scores above can be checked there.

## 2026-10-30: Step 6k, config and save games
Not committed yet.

- **What works:** settings and high scores survive a restart through CONFIG.WL6. The Save / Load Game menus save and load real games, F8 / F9 quick save and load work, and a save game from the DOS version is refused with a message. That completes step 6: the WL6 game is fully playable.
- **`ReadConfig` / `WriteConfig` (WOLF3D.BAS):**
  - The original CONFIG.WL6 layout: 7 high scores of 66 bytes, then 16-bit ints for the sound / music / digitized modes, mouse and joystick settings, the key and button bindings, the view size and the mouse sensitivity.
  - `InitGame` calls `ReadConfig`, then loads the sounds of the configured sound mode and applies the configured view size.
  - With a config, "Read This!" goes back to normal colour and the cursor starts on New Game, as in the original. With no config, the hardware defaults apply (AdLib, Sound Blaster, view size 15).
  - `Quit` writes the config on a normal exit, once it has been read.
- **`SaveTheGame` / `LoadTheGame` (WOLF3D.BAS):** replace the 5c stubs.
  - **What is saved,** in the original order: gamestate, the level ratios, tilemap, actorat, the area connections, every actor in list order with an end marker, the statics, the doors, and the push wall. The checksum (`DoChecksum`, 32-bit wrap) covers the same parts as in C.
  - **Loading:** the level is set up again before the saved state goes over it. Actors are re-created with `GetNewActor`, keeping their new links.
  - **Not compatible with DOS saves:** the DOS saves store near pointers (each actor's state and its list links) that mean nothing to the port. So the port's saves start with a `WQB1` signature after the 32-byte name. A file without it, like the DOS save, gets "This save game was not made by this version of the game", and nothing is loaded. Through the menu you go back to the save list; through F9 the current game continues.
  - The free disk space check is left out.
- **`WL_MENU.BM`:** quick load now redraws the status bar, as in C.
- **`ID_IN.BI`:** `joystickprogressive`, so the config keeps that setting (the joystick itself is not ported).
- **Tested** (CONFIG.WL6 and the save files were backed up first, and the config was restored afterwards):
  - **Reading the config:** the CONFIG.WL6 in the source tree is the original DOS config, and its 522 bytes match the layout exactly. It has sound, music and digitized sound off, and view size 19. The game started with the larger view and "Read This!" in normal colour.
  - **Writing it back:** quitting through the menu wrote a config byte-identical to the original. Turning sound effects to AdLib in the Sound menu and quitting changed exactly one byte (offset 462 → 2).
  - **Saving and loading:** saved to slot 3 ("PORT TEST", 21275 bytes). Then, in a new run, loading it put me back where I saved.
  - **Quick keys:** F9 with nothing quick-saved yet opened the load menu. F8 quick-saved, and the next F9 asked "Load Game called "PORT TEST"?" and loaded it.
  - **The DOS save** in slot 0 (SAVEGAM0.WL6, 1992) is refused with the message.
- **Not done yet:**
  - The WL_DEBUG keys (Tab + letter with the "goobers" parameter) are not ported.
  - The ORDERSCREEN / ERRORSCREEN text screens on exit are not ported.
  - Note that the original config in the source tree turns all sound off. Delete CONFIG.WL6, or turn sound on in the Sound menu, to hear the game.
