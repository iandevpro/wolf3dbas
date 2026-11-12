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
Commit 4a7657f.

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

## 2026-10-31: Formatting with the QB64 IDE (tools/ide_format.py)

Commit 606996a.

- **Why:** the IDE formats only code it can parse. A .BI / .BM opened alone isn't a complete program, so the IDE stops at the first name from another file (red lines) and leaves the rest of the file unformatted.
- **`tools/ide_format.py`:**
  - `merge` builds one complete program in `%TEMP%\wolf3d-ide-format\WOLF3D_ALL.BAS`: WOLF3D.BAS with every include inlined once, at its first active occurrence, between `'@@IDEFMT` marker comments. It evaluates `$Let` / `$If` to know which includes are active.
  - `ide` runs `tools/ide_roundtrip.ps1`: it opens the program in the IDE, presses Ctrl+End, then saves (Alt, F, S) and exits (Alt, F, X).
  - `split` cuts the formatted program back into its files and writes only the ones that changed.
  - `python tools/ide_format.py` runs all three steps (about 70 s).
- **Result:** 22 files were reformatted. The changes:
  - `$EndIf` became `$End If`, and the inactive `$If` branches (mostly Spear of Destiny) were re-indented. The IDE also flattens the `Case` bodies in those branches.
  - Keyword and identifier case: `as` became `As`, `_CONTINUE` became `_Continue`, and `True`/`False` became `TRUE`/`FALSE`.
  - The `()` was dropped from `Dim x() As ...` (these arrays are ReDim'd later).
  - A second pass changed nothing, so the formatting is stable.
- **IDE bug:** the formatter drops a unary minus before a hex literal (`-&H7FFF&` becomes `&H7FFF&`). It hit `CheckLine` in WL_STATE.BM, which now uses decimal `-32767`.
- **Tested:** merge and split with no IDE pass reproduce all 47 files unchanged, and the merged program passes `qb64 -z`. After formatting, the game compiles and plays into E1M1.

## 2026-10-31: Naming fixes from the code review

Commit a0dad74.

- **Renamed names that differ from another name only by case** (QB64 names are case-insensitive, so one hid the other). The C name stays in a comment:
  - In WL_TEXT.BI, the `LEFTMARGIN` / `RIGHTMARGIN` constants became `TEXTLEFTMARGIN` / `TEXTRIGHTMARGIN`, because of the `leftmargin()` / `rightmargin()` arrays. This follows `TEXTBACKCOLOR`.
  - In WL_SCALE.BM, the `SetupScaling` parameter `maxscaleheight` became `scaleheight` (`MAXSCALEHEIGHT`).
  - In ID_CA.BM, the `CA_RLEWexpand` parameter `rlewtag` became `tag` (the `RLEWtag` global).
  - In WL_MENU, `lastmusic_gbl` became `menulastmusic` (C: `static int lastmusic`, which clashes with `LASTMUSIC`).
- **`VW_Bar`** (ID_VH.BM): its parameters were untyped (Single); they are now `As Integer`, like `VL_Bar`.
- **Removed** the stray `Const SPANISH = 0` from WL_INTER.BI. The `$If SPANISH` checks test a `$Let`, not this constant.
- **The `PROFILE` block in `CA_Startup`** (inactive) still had C code; it is now QB64 (`Open ... For Output`).
- **Kept as they are:**
  - `_MEM` and `_UNSIGNED _BYTE` (in `_MemPut ... As`) are the IDE's own case; it changes `_Mem` back.
  - Fields named like keywords (`kill`, `name`, `width`) compile and match C.
  - `CTRL_MOUSE` etc. (C: `MOUSE`, `JOYSTICK`): the prefix avoids clashes.
- **`tools/ide_format.py`:** its work folder is now `tempfile.gettempdir()`. When `TEMP` was not set (Git Bash), it fell back to the source tree.
- **Tested:** it compiles; `tools/ide_format.py` leaves the edits as they are; E1M1 plays, and the F1 help text is laid out within its margins.

## 2026-10-31: Compiler warnings

Commit da6cb69.

- **What reports them:** the IDE's warnings window (on the merged program of `tools/ide_format.py`), and `qb64 -x -w WOLF3D.BAS`, which prints them with the real file names and lines.
- **Fixed (9):**
  - `MAXTICS` / `DEMOTICS` were defined both in ID_HEADS.BI (where C has them, in ID_HEADS.H) and in WL_DRAW.BI; I removed the WL_DRAW.BI copy.
  - Unused locals were removed: `rndp` (ID_US.BI), `i` (`DrawCtlScreen`), `played` (`A_DeathScream`; the boss part has its own), `w` / `h` (`FizzleFade`), and `done` / `skipLoop` (`DemoLoop`).
- **Kept (16), on purpose:**
  - Parameters that keep the C signatures: `CAL_OptimizeNodes` huffTable, `CAL_HuffExpand` screenhack, the `MM_` stubs, `IN_ReadControl` player, `A_Slurpie` / `T_BJDone` ob.
  - C globals of parts that aren't ported:
    - `compatability`: the US_Startup parameters.
    - `updateptr`, `uwidthtable` and `blockstarts`: the update blocks.
    - `headeroffsets`.
    - `profilehandle`: the PROFILE build.
    - `singlestep`: the debug keys.
- **Tested:** it compiles.

## 2026-10-31: Update blocks removed

Commit 4b0d229.

- **What they were:** the original marked the 16x16 tiles each drawing touched (`VW_MarkUpdateBlock`). `VW_UpdateScreen` then copied only those tiles to the visible page.
- **Why they aren't needed:** the port draws into one buffer and always shows the whole screen.
- **Removed from ID_HEADS.BI** (a comment there explains why):
  - the constants `PORTTILESWIDE`, `PORTTILESHIGH`, `UPDATEWIDE`, `UPDATEHIGH` and `UPDATETERMINATE`
  - the variables `updateptr`, `uwidthtable` and `blockstarts`
- **ID_VH.BM / ID_CA.BM:**
  - The `If TRUE Then` in `VWB_Bar` and `VWB_Hlin` (in place of `If VW_MarkUpdateBlock(...)`) is removed.
  - The `TODO - port VW_MarkUpdateBlock` comments now quote the C call and say why it isn't needed.
- **Tested:**
  - It compiles, with 13 warnings left (16 before).
  - `tools/ide_format.py` changes nothing.
  - The title screen and the Load Game menu (bars and box lines) draw correctly.

## 2026-10-31: Mouse motion

Commit 8d040d2.

- **How QB64 reports it:** `_MouseMovementX/Y` gives raw relative counts, like the DOS driver's mickeys. A test program got exactly the counts sent with `mouse_event`. They keep counting when the pointer is at or past the window edge, and `_MouseMove` adds no motion of its own.
- **ID_IN (the DOS mouse driver counters):**
  - **`INL_MouseService`** reads every waiting `_MouseInput` message. `IN_ClearKeysDown` and `IN_MouseButtons` now call it instead of throwing the messages away, so no motion is lost. It adds the motion to two things:
    - the delta of `Mouse(MDelta)`
    - the virtual cursor of `Mouse(3)` / `Mouse(4)`. It is clamped to 0-639 x 0-199, with one mickey per pixel across and two per pixel down, the driver's defaults.
  - **`INL_GetMouseDelta`** is `Mouse(MDelta)`. While the window has focus it also puts the real pointer back in the middle of the window, so a click can't land outside it during play.
  - **`IN_ClearMouseDelta`** ("Clear accumulated mouse movement"), **`IN_GetMousePos`** (`Mouse(3)`) and **`IN_SetMousePos`** (`Mouse(4)`).
  - **`IN_Startup`** puts the virtual cursor in the middle (like `MReset`) and hides the pointer over the window (`_MouseHide`); the game draws no pointer.
- **WL_PLAY.BM:**
  - `PollMouseMove` as in C: `controlx += dx*10/(13-mouseadjustment)` and `controly += dy*20/(13-mouseadjustment)`. So the mouse sensitivity setting now works.
  - `PollControls` calls it when the mouse is enabled. Demo playback returns before it, as in C.
- **WL_MENU.BM:**
  - `ReadAnyControl` reads the virtual cursor: past `CENTER ± SENSITIVE` (120 ± 60) it returns that direction and centres the cursor again, as in C.
  - The control panel setup and the mouse enable toggle centre it too.
- **Clearing the motion:** "Clear accumulated mouse movement" is now done in the 3 places in WL_PLAY, in the quick save/load return (WL_MENU) and in the help screens (WL_TEXT).
- **Tested** with motion sent by `mouse_event` (the window brought to the front first):
  - In E1M1, 300 counts right turned right, 600 left turned back past the start, and moving the mouse up walked forward.
  - In the main menu, 150 counts down moved the cursor one item at a time. A temporary log of the virtual cursor showed the centring and the threshold working as in C. Motion left over after a step still counts, so the 150 counts up only reached 60, one short of `< 60`.
- **Not done:**
  - Not compared by hand with DOSBox-X (how far one mouse movement turns).
  - The `ctrl_Mouse` control type of `IN_ReadControl` (WL6 always uses the keyboard there).

## 2026-10-31: Shareware support (*.WL1, v1.0 data)

Commit e19c2a3.

- **The data is v1.0 shareware** (May 5, 1992), older than this v1.4 source:
  - There is no GAMEMAPS.WL1: the maps are in MAPTEMP.WL1, not Carmack-compressed.
  - `GFXV_WL1.H` (made May 3, 1992) fits the 136 pictures, but not the chunks after them.
  - `AUDIOWL1.H` (April 28, 1992, 69 sounds) does not fit the audio at all.
  - The sprites and the demos differ from v1.4 too.

  Everything below was worked out by comparing the files with the WL6 ones.
- **The build:** `qb64 -x WOLF1.BAS` builds the shareware version (WOLF1.exe). WOLF1.BAS sets `UPLOAD` (the shareware game, as in WOLF1VER.H) and `APOGEE_1_0` (the v1.0 data), then includes WOLF3D.BAS. WOLF3D.BAS still builds the full version.
  - The chunk numbers are constants, so each build reads only its own files: the WL6 build no longer falls back to *.WL1, and its message points to WOLF1.BAS. The C code also needed one build per version.
  - VERSION.BI defines `CARMACIZED` only without `APOGEE_1_0`.
- **Maps** (ID_CA.BM): the path without `CARMACIZED` (the old TODO) is RLEW only, starting after the length word, as in C.
- **Graphics:** `GFXV_WL1.BI` is generated from GFXV_WL1.H for the pictures 3-138.
  - The chunks after the pictures, as they are in VGAHEAD.WL1 (148 chunks): the 8x8 tiles (139), ORDERSCREEN and ERRORSCREEN (140, 141), T_HELPART (142), one T_ENDART1 (143), and T_DEMO0-3 (144-147).
  - ID_HEADS.BI includes it with `APOGEE_1_0`.
  - **Pictures v1.0 lacks:**
    - `C_TIMECODEPIC`: not cached. The time code that uses it is already left out with `UPLOAD`, as in C.
    - `L_APOSTROPHEPIC`: skipped in `Write`, but the space is kept.
    - `C_NAMEPIC`, `C_LEVELPIC`, `C_SCOREPIC`: the high-score headings are left out.
    - The joystick pictures are not used.
- **Sounds** (AUDIOWL6.BI):
  - AUDIOT.WL1 has the first 73 sounds of the WL6 list, with the same numbers and sizes, and the same 27 music slots. So `NUMSOUNDS` is 73 and `NUMSNDCHUNKS` is 246.
  - The `START*` constants are now computed from `NUMSOUNDS`.
  - `SD_PlaySound` ignores sounds from `NUMSOUNDS` up.
- **Digitized sounds:** VSWAP.WL1 has WL6's digitized sounds 0-33. So the v1.0 build maps the "other episodes" entries up to 33 as well as the UPLOAD ones.
- **Sprites** (WL_SPR.BI): VSWAP.WL1 has the WL6 sprite list in the same order (matched by content), with these differences:
  - `SPR_DEATHCAM` is missing; the death cam came later and is only used by the episode 2-6 bosses.
  - The 47 sprites before `SPR_BJ_W1` are missing (Giftmacher, rockets, Gretel, Fat Face).
  - The other episodes' monsters are empty pages.

  So the constants subtract `SPRV10SHIFT1` (1, from `SPR_STAT_0` on) and `SPRV10SHIFT2` (48, from `SPR_BJ_W1` on), which are 0 in the WL6 build.
- **Demos** (PollControls):
  - The v1.0 demos are 4 bytes a frame: buttons, x, y (per tic), and that frame's tics as recorded (1-10). Each demo's length is exactly 4 + 4n, and keyboard values (±35, ±70) occur at 3-4 tics.
  - So a frame takes its own tics instead of `DEMOTICS`.
  - The end check is `>=`.
- **CheckForEpisodes** (WL_MENU.BM): in the WL6 build it now also sets `NewEmenu(2..10).active = 1`, as C does. Before, episodes 2-6 were drawn in the "not available" colour.
- **Variables used by only one build** (`expanded`, `i`, `c0`/`c1`, `secretmap`) are declared inside their `$If` blocks, so neither build warns about them. Both builds have the same 13 warnings.
- **Tested with WOLF1.exe:**
  - The sign-on, title, credits, high scores (no headings, plain level numbers as with UPLOAD) and main menu all work.
  - "Read This!" shows the v1.0 help, 35 pages with its pictures.
  - In the episode menu, episodes 2-6 are greyed out and give the "order this episode from Apogee" message.
  - E1M1 plays with v1.0's textures and "LEVEL" status bar. The statics, guards and pistol sprites are right, and firing works.
  - The demos play (map 4, the "Demo" sprite, guards) but **don't stay in sync**. A per-frame log of demo 0 showed the movement in sync (the door at (7,3) is reached and used on frame 18) until the first fight; then the player takes much more damage than the recording expects and dies.
    - The difficulty is not the cause: none of the four difficulties keeps any demo in sync.
    - v1.0's combat or random number use differs from v1.4, and its code is not available.
- **WL6 unchanged:**
  - Demos 0, 2 and 3 end as in the 6j table (3900/15, 7100/27, 5600/21), played with fast-forward.
  - Demo 1 (13600/51, frame 5701) has to be played in real time: `UpdateFace` skips its `US_RndT` calls while `GETGATLINGSND` is playing, so playing faster than the sound changes the random sequence.
- **Not done:**
  - The demo sync for v1.0.
  - The end of the shareware episode was not played through.
  - The level-end screen was not seen.

## 2026-11-01: Step 7a, groundwork for Spear of Destiny

Commit 0bf4d63. Plan: `plans/step7_spear.plan.md` (decisions 1, 3 and 4 done here: one build per version, TEDLEVEL, `/demotest`).

- **Four builds:**
  - `WOLF3D.BAS`: WL6.
  - `WOLF1.BAS`: WL1 v1.0.
  - `SPEAR.BAS` (new): `$Let SPEAR`, like SODVER.H.
  - `SPEARDEMO.BAS` (new): `SPEAR` + `SPEARDEMO`, like SDMVER.H. SDM is the Spear of Destiny demo; there was no Spear shareware.

  Each of the entry files includes WOLF3D.BAS.
- **Headers:**
  - `tools/gen_headers.py` writes GFXV_*.BI, AUDIO*.BI and MAPS*.BI from the origsrc headers for WL6, SOD and SDM. The SOD and SDM headers fit their data: 169 / 133 graphics chunks, 267 sound chunks, 421 sprites.
  - It also writes the v1.0 shareware files: `GFXV_WL1.BI`, and a new `AUDIOWL1.BI` that holds the 73-sound counts which were an `$If` in AUDIOWL6.BI.
  - The regenerated WL6 files have the same constants as the hand-converted ones.
  - `ID_HEADS.BI` picks them as ID_HEADS.H does.
- **Sprite numbers:** `tools/gen_sprites.py` writes `WL_SPR.BI` from the WL_DEF.H enum, with one numbered list per game (421 Spear sprites, 436 Wolfenstein sprites) and the v1.0 shifts.
  - This fixes `MACHINEGUNATK3`, which has no `SPR_` in C: the v1.0 shift had missed it. Nothing uses it by name.
- **Spear tables, from C:** `songs()` (WL_PLAY.BI) and `vgaCeiling()` (WL_DRAW.BI).
  - The statinfo arrays grew to 0-53: Spear has 4 more statics. The Spear build stopped with "Subscript out of range" before.
- **CheckForEpisodes:** *.SOD / *.SDM with the C messages; each build looks only for its own files.
- **What the Spear builds needed to compile,** each as in C:
  - `CP_ReadThis` and `DrawNewEpisode` are Wolfenstein only. The Read This `Case` keeps its line and puts the `$If` inside, since a `$If` between `Case` lines breaks `Select Case`.
  - `C_HOWTOUGHPIC` in `DrawNewGame`.
  - `DrawFace`: the god mode face, and `MUTANTBJPIC` for Wolfenstein only.
  - WL_TEXT.BI / WL_TEXT.BM are left out of the Spear builds. Spear has no help screens, and its ending is EndSpear; the page layout uses pictures that only Wolfenstein has.
  - **Stubs, ported later:**
    - `SpawnTrans`, `SpawnUber`, `SpawnWill`, `SpawnDeath`, `SpawnAngel` and `SpawnSpectre` (7e).
    - `CopyProtection` (7g).
- **TEDLEVEL** (ID_US_1.BM `US_Startup`, `US_CheckParm`; WOLF3D.BAS `DemoLoop`), as in ID_US_1.C / WL_MAIN.C:
  - `TEDLEVEL n` starts straight in map n (Wolfenstein: episode n\10, map n mod 10), with an optional `baby` / `easy` / `normal` / `hard`, and quits after the game.
  - `NOWAIT` skips the sign-on waits.
  - `COMP` / `NOCOMP` set `compatability`, which removes that warning.
  - `US_Startup` runs before the sign-on screen here (in C, after CA_Startup), so that `NOWAIT` skips the port's sign-on waits.
- **`/demotest`** (PORTDEBUG.BM `PortDemoTest`): plays all the demos in real time, writes each one's end state to DEMOTEST.TXT (gitignored), and quits without writing the config.
- **`tools/ide_format.py`** formats every build (WOLF3D, WOLF1, SPEAR, SPEARDEMO). Each line comes from a build that compiles it, so the Spear code is now really formatted instead of flattened. Two passes in a row change nothing.
- **Tested:**
  - All four builds compile. WOLF3D and WOLF1 have 12 warnings. SPEAR and SPEARDEMO have more, from the stub parameters, the empty WL6 boss routines and the single SDM demo.
  - **WL6 demos** (`/demotest nowait`): 3900/15, 13600/51, 7100/27, 5600/21, each to the last frame. These are the 6j results, so the WL6 game is unchanged.
  - **WOLF1:** `TEDLEVEL 0 baby nowait` starts in E1M1 as before.
  - **SPEAR:**
    - It runs to the sign-on, PC-13 and the menu, still without the Spear art (7b/7c); "Read This!" is gone.
    - `TEDLEVEL 0 baby nowait` plays Tunnels 1, with Spear walls and statics.
    - **SOD demos:** maps 1, 3, 5, 12; 2900/13, 1000/10, 3000/12, 7300/13. Each ends in a death on the last frame of its data (1954, 2242, 2353, 2569), as the WL6 demos do when they play back exactly. So these demos only need the ported enemies.
  - **SPEARDEMO:** `TEDLEVEL 0` plays Tunnels 1, and its one demo ends like SOD demo 0 (death on frame 1954).
- **The sign-on screen and palette per build** (found when you ran the Spear exes in another directory: "Path not found"):
  - **The cause:** `SignonScreen` opened `OBJ\signon.bin` at run time. The original builds linked SIGNON.OBJ and GAMEPAL.OBJ into the exe, so this affected all four builds.
  - **`tools/extract_exe_data.py`** unpacks an original exe (LZEXE 0.91) and finds the palette: 768 bytes of 6-bit values starting with the standard colours 0-2. The 64000-byte sign-on screen is right before it, as GAMEPAL.OBJ followed SIGNON.OBJ in the link. From SPEAR-ORIG.EXE and SPEAR-DEMO-ORIG.EXE it wrote `OBJ/signon_sod.bin`, `OBJ/signon_sdm.bin` (the same screen with "DEMO") and `OBJ/gamepal_sod.bin` / `_sdm.bin`. The two palettes are identical; Spear differs from WL6 in the colours 166 and 167 (purple in WL6, dark green in Spear).
  - **`tools/gen_signon.py`** writes:
    - `GAMEPAL.BAS`, with the WL6 palette (unchanged) and the Spear palette under `$If SPEAR`;
    - `SIGNON_WL6.BAS` / `SIGNON_SOD.BAS` / `SIGNON_SDM.BAS`, the screen as text, two letters per byte.
  - WOLF3D.BAS includes the build's files. WOLF1 keeps the WL6 screen: there is no v1.0 exe to take one from.
  - **Tested:** SPEAR.exe and SPEARDEMO.exe, each run from a directory with only its data files, show their own sign-on screens and go on to the hardware bars. WOLF3D still shows the Wolfenstein one. The formatter changes nothing.
  - The original exes are gitignored (`*.EXE`). The extracted Spear files and SIGNON_SOD.BAS / SIGNON_SDM.BAS hold data from them.
- **The v1.0 shareware sign-on** (from WOLF3D-SHARE-ORIG.EXE, May 5, 1992, LZEXE 0.91):
  - In this exe the screen follows the palette instead of preceding it, so `extract_exe_data.py` now takes the side that looks like a picture: pixels equal to their left neighbour, and not mostly zeros (zero-filled data follows the Spear palette). The Spear screens it extracts are unchanged.
  - The v1.0 screen has the Apogee logo where v1.4 has the GT one. Its palette is the same as WL6's.
  - `SIGNON_WL1.BAS` is included with `APOGEE_1_0`.
  - **Tested:** WOLF1.exe, run from a directory with only the *.WL1 files, shows the Apogee sign-on.
- **Spear menus** (reported: New Game did not start, no "Options" picture, an empty quit box). These are menu items of 7c, done now because they blocked using the Spear builds:
  - **Lump caching:** all the Spear lump caching of WL_MENU.C is ported (the TODOs before). The Spear menu pictures are in lumps that each menu caches and frees, and an uncached picture draws nothing.
    - `SetupControlPanel` / `CleanupControlPanel`: BACKDROP.
    - `US_ControlPanel`: OPTIONS around the main menu.
    - `CP_Sound`: SOUND. `CP_Control`: CONTROL. `CP_LoadGame` / `CP_SaveGame`: LOADSAVE.
    - `CP_ViewScores`, and the quick save/load keys of `CP_CheckQuick`: BACKDROP.
  - **`ClearMScreen`** draws `C_BACKDROPPIC` for Spear (it drew nothing before).
  - **`CP_NewGame`** for Spear: no episode menu (episode 0), NEWGAME around the difficulty menu, as in C.
  - **`endStrings`** for Spear: ENDSTR1-9 of F_SPEAR.H.
  - **`DrawHighScores`** for Spear: the backdrop and the full-screen `HIGHSCORESPIC` (HIGHSCORES_LUMP).
  - **Tested in SPEAR (and New Game in SPEARDEMO):**
    - The main menu shows the Options picture on the blue backdrop.
    - New Game: "How tough are you?" (picture), then Tunnels 1.
    - Sound, Control and Load Game have their pictures.
    - View Scores shows the Spear high scores.
    - Esc gives a Spear quit question.
    - Inactive menu items are drawn in DEACTIVE (0x9B) on BKGDCOLOR (0x9D), dim blue on blue, as the Spear colours are.
  - **Left for 7b/7c:** the I+D easter egg, which needs a palette from the graphics file, like the Spear title.

## 2026-11-01: Step 7b, Spear start-up and screens

Commit a5f4051.

- **`VL_ChunkToPalette`** (ID_VL.BM): converts a palette stored in a graphics chunk (768 bytes of 6-bit values: TITLEPALETTE, IDGUYSPALETTE, END1-9PALETTE) into a palette array for `VL_FadeIn`. The C code passed the cached chunk itself, as in `VL_FadeIn(0,255,grsegs[TITLEPALETTE],30)`.
- **The Spear title** (DemoLoop): TITLE1PIC and TITLE2PIC (two half screens), faded in with TITLEPALETTE, as in WL_MAIN.C.
- **The Spear sign-on:** C's Spear `FinishSignon` has no "Press a key" and waits 3 seconds (`if (!NoWait) VW_WaitVBL(3*70)`). The port's two key waits are now Wolfenstein only. WL6 is unchanged; the port's first key wait, before the hardware bars, is not in C.
- **PG-13, credits and high scores** needed nothing more: PG13 and the credits are the same in C, and the high scores were done in 7a.
- **The I+D easter egg** (left over from 7c), as in US_ControlPanel:
  - the id guys picture with IDGUYSPALETTE and XJAZNAZI_MUS;
  - then the backdrop and Options lumps again.
  - As in C, it is checked after HandleMenu returns, which clears the keys. So I+D must still be held after leaving a menu item: hold them while leaving a submenu, where the keyboard's auto-repeat sets them again during the fade. Esc on the main menu checks almost at once.
- **Fix, reported** ("the second View Scores, I+D: SPEAR quit"): the palette arrays of the easter egg and the title were declared with `Dim` inside the loops. In QB64, a `Dim` of an array that runs a second time is runtime error 10, "Duplicate definition" (confirmed with a test program; plain variables are fine). The error screen's "press any key" was dismissed by the held keys, so the game seemed to quit.
  - Both arrays are now declared at the top of the routine, under `$If SPEAR` (the easter egg's only without SPEARDEMO), so neither build gets a new warning.
  - The title would have crashed too, the second time round the attract loop.
- **Tested:**
  - **SPEAR attract loop with no keys:** Spear sign-on with the hardware bars, then after 3 seconds PG-13, the Spear title in its palette, the Spear credits (FormGen as distributor), the high scores, and the demo. After the demo the title shows a second time.
  - **SPEARDEMO:** its sign-on, the title with "Demo", and its demo on floor 2.
  - **Easter egg:** three times in a row, with I+D held while leaving the Sound menu.
  - **WL6:** the sign-on, the NonShareware notice and the title as before.
  - Warnings: 12 / 12 / 38 / 40 (WOLF3D / WOLF1 / SPEAR / SPEARDEMO). The formatter changes nothing.

## 2026-11-02: Step 7d, Spear levels with the existing enemies

Commit ae1c3d8.

- **Already ported** (the C Spear blocks of WL_GAME, WL_AGENT, WL_ACT1, WL_PLAY, WL_DRAW and WL_STATE were checked one by one):
  - ScanInfoPlane's statics 23-74, with the truck and the spear;
  - the statinfo entries;
  - the bo_25clip and bo_spear pickups;
  - the "ouch" face and the god mode face;
  - the Spear songs, ceilings and par times;
  - the secret floors (NextLevelMap: map 3 to 18 and map 11 to 19, then back to 4 and 12);
  - the boss and secret level end screens;
  - the victory fade.
- **Now ported:**
  - **DrawLevel:** the Angel of Death's map 20 shows as floor 18.
  - **GameLoop:**
    - the key of map 20 ("give them the key allways");
    - after taking the spear (spearflag): GETSPEARSND (with digitized sound, about 2 seconds), then map 20, with the player where the spear was, and PlayLoop again. In C this was a `goto startplayloop`; here it is a loop while spearflag. As in C, that path does not redraw the floor number or the keys.
    - SPEARDEMO ends after its map 1, with the high scores.
  - **LevelCompleted:** SPEARDEMO's "This concludes your demo of Spear of Destiny!..." message.
  - **Thrust:** moving zeroes funnyticount.
  - **PlayLoop:** after 30 seconds without moving, BJ's waiting face (BJWAITING1PIC + US_RndT And 1).
  - **CheckKeys:** the Tab-G-F10 god mode cheat ("God mode ON" / "OFF").
- **Left for 7e:** the cases of the Spear enemies in KillActor, FirstSighting, the spawns and the death screams.
- **Tested** with a temporary `/testexit N` hook (it ended the level after 2 seconds with playstate N; 99 = the spear taken; removed):
  - **The spear on map 16:** the map changes to the Angel of Death's arena.
  - **TEDLEVEL 20:** floor 18 with the gold key.
  - **The secret exit of map 3:** "floor 4 completed", a time bonus of 104000 ((210 - 2 s) * 500), then map 18 (floor 19).
  - **Ending map 18:** "secret tunnel area completed!" with 15000, then map 4 (floor 5).
  - **SPEARDEMO, ending map 1:** the end-of-demo message, then the high score entry.
  - **The waiting face** appeared about 30 s into play, sampled every 0.3 s; a temporary log showed funnyticount counting 70 a second.
  - **Tab-G-F10:** "God mode ON". The test held the keys briefly: held with auto-repeat, each repeat acknowledges the message and toggles god mode again, which is the same in C.
  - **Demos:** the SOD demos and the WL6 demos end exactly as before.
  - **Builds:** 12 / 12 / 38 / 40 warnings. The formatter changes nothing.

## 2026-11-02: Step 7e, the Spear enemies and bosses

Commit d1138bf.

- **Already ported earlier**, in steps 6g/6h, as the `$Else` branches of the boss cases:
  - the Spear cases of KillActor (points, death states, the key), FirstSighting (the sight sounds and speeds) and A_DeathScream;
  - the hrocket smoke and explosion in A_Smoke / T_Projectile, and the spark and hrocket damage.
- **Now ported (WL_ACT2.C 1174-1975),** at the end of WL_ACT2.BM:
  - **The spawns:** SpawnTrans, SpawnUber, SpawnWill, SpawnDeath, SpawnAngel, SpawnSpectre.
    - Unlike the Wolfenstein bosses, they keep the speed and direction from SpawnNewObj.
    - With digitized sound, they lengthen a death state as in C: trans 105, uber 70, will 70, death 105, angel 105.
  - **T_UShoot:** T_Shoot, plus 10 damage when the player is within one tile.
  - **T_Will:** the chase of T_Gift, attacking with the state of the class (will, angel, death knight). It uses the T_ThrowerChase of the Wolfenstein bosses.
  - **T_Launch:** a rocket (an hrocket for the death knight, a spark for the angel) aimed at the player. The death knight also shoots, and aims 4 angles to one side and then the other (on s_deathshoot2, and otherwise).
  - **The angel's routines:** A_Breathing, A_Victory (ex_victorious), A_StartAttack, A_Relaunch (three attacks, then tired), and Spear's own A_Slurpie.
  - **A_Dormant:** a spectre comes back when nothing is in its way. C's `goto moveok` is an If here.
- **Shared helpers:** AngleToPlayer, SpawnProjectile and T_ThrowerChase moved out of the Wolfenstein-only block, so Spear uses them too. SpawnProjectileAngle takes a given angle, which T_Launch needs.
- **The Wolfenstein builds** get empty stubs of the 8 new routines, as Spear has empty stubs of the Wolfenstein ones. Their unused `ob` parameters are 8 new warnings (12 to 20).
- **tools/gen_states.py:**
  - The 8 routines were added to PORTED, so the state dispatcher calls them; nothing is left unported.
  - It now finds the final `$End If` of WL_STATE.BM in either spelling. Since the IDE formatting (`$EndIf` became `$End If`) it had failed.
  - Regenerating WL_STATE.BM changed only the dispatcher.
- **Where the Spear actors are** (from a decoder of GAMEMAPS.SOD):
  - trans on map 4, wilhelm on map 9, the ubermutant on map 15, the death knight on map 17;
  - the angel and 37 spectres on map 20;
  - none on the demo maps (1, 3, 5, 12) or in SDM.
- **Tested** with a temporary `/testboss N` hook (removed). After 2 s it turned god mode on, made the Spear actors see the player (FirstSighting), put the player 3 tiles from the boss facing it, and after N s killed the boss (DamageActor). Every 1.5 s screenshots:
  - **Trans:** fires both guns, comes closer, dies, drops the key, 5000 points.
  - **Wilhelm:** fires rockets (a hit flashes the screen red and explodes), then the same death, key and points.
  - **Ubermutant:** fires, comes to melee range, and the same death, key and points.
  - **Death knight:** rockets with their own smoke (hrocket), and the same death, key and points.
  - **Angel of Death:** green sparks while the spectres come. When it is killed, its death ends in the green fade-out of ex_victorious; the ending is 7f.
  - Not seen on screen: a spectre fading and coming back (A_Dormant), and the tired angel (A_Relaunch / A_Breathing).
  - **Demos:** the SOD demos (no Spear actors on their maps) and the WL6 demos end exactly as before.
  - **Builds:** 20 / 20 / 28 / 30 warnings (WOLF3D / WOLF1 / SPEAR / SPEARDEMO). The formatter changes nothing.

## 2026-11-02: Step 7f, the end of Spear of Destiny

Commit 39b01fc.

- **Already there:** the Spear parts of Victory (ported in 6h): BJ's collapse (BJCOLLAPSE1-4PIC to XTHEEND_MUS) and the victory screen.
- **Now ported (WL_INTER.C 35-98):**
  - **EndScreen:** a full-screen picture, faded in with its own palette chunk (VL_ChunkToPalette, see 7b), until a key. Its C parameters `palette` and `screen` are QB64 keywords, so they are renamed.
  - **EndSpear:**
    - the story screen (ENDSCREEN11PIC);
    - the debt scene (ENDSCREEN3PIC) with STR_ENDGAME1-4 of F_SPEAR.H in fontcolor 0xD0, each pair for up to 10 seconds or a key ("by able" as in the original);
    - ENDSCREEN4-9PIC and THE END (ENDSCREEN12PIC), each with its END*PALETTE;
    - then Save Game becomes inactive.
  - Victory calls EndSpear where C does (the TODO before).
- **Tested** with a temporary `/testkill N` hook (removed) that killed the Angel of Death on map 20 after N s:
  - The test also had to make the angel active. An inactive actor in an area not connected to the player's does not run its states (DoActor, as in C), so its death never went on.
  - The whole ending ran in order: the green fade, BJ's collapse, "you win!" with the time and averages, the story, the two messages, "But that's another story...", the Spear of Destiny title, "A Game by id", "Distributed by FormGen", the beta testers, "Thanks for playing...", THE END, then the high scores.
  - Builds: 20 / 20 / 28 / 30 warnings as before. The formatter changes nothing.

## 2026-11-03: Step 7g, copy protection

Commit 91652bb.

- **Ported (WL_INTER.C 1315-1716),** in the retail Spear build only (not SPEARDEMO, as in C). DemoLoop already called the empty stub.
  - **CopyProStr$(table, i):** the C string tables (CopyProFailedStrs, BackDoorStrs, GoodBoyStrs, bossstrs, WordStr/WordCorrect, MemberStr/MemberCorrect, DosMessages, MiscTitle/MiscStr/MiscCorrect) and the F_SPEAR.H strings, by name and index. The empty C entries return "".
  - **BackDoor%:** "a spoon?", "bite me!", "joshua", "pelt" and "snoops" always pass, with their own reply in the box.
  - **CopyProSubMatch%:** the C loops of the boss and staff questions. The answer passes when it is found, case insensitive, anywhere in the correct string and is longer than 3 (bosses) or 2 (staff) characters. That is why "UBERMUTANTUBER MUTANT" and "john carmackjohn romero" are one string each.
  - **CopyProtection:** the backdrop, COPYPROT_LUMP, COPYPRO_MUS and up to three questions of the four kinds (debriefing, check yer manual, staff, misc); the same question is not asked twice. A wrong answer shows a random reply with NOWAYSND for 3 seconds.
  - **Success:** BONUS1UPSND, then it frees the lump and the sounds of the sound mode, as C does (US_ControlPanel loads them again).
  - **Three wrong answers:** a random DOS message, through `Quit` (C: ShutdownId, text mode, printf, exit(1)). The local variable is `msgtext`, because `message` is the name of WL_MENU's Message sub.
- **CA_LoadAllSounds** returned early when the sound mode had not changed. It now only skips freeing the sounds then, and always caches them in again. CA_CacheAudioChunk skips cached chunks. Without this, the menu sounds after the quiz would be uncached (SD_PlaySound quits on an uncached sound).
- **Tested in SPEAR.exe:**
  - One wrong answer, then "joshua": the Professor Falken reply, then the PC-13 screen.
  - Three wrong answers: the game quits with "What's a nice user like you doin' at a DOS prompt like this?".
  - A right answer, with a temporary hook (removed) that forced the "Might engineer some software?" question: "Romero" passes.
  - With AdLib sound effects (no config, so the hardware default): the quiz, then the menus with their sounds, then a new game.
  - Demos: SOD 2900/13, 1000/10, 3000/12, 7300/13 and WL6 3900/15, 13600/51, 7100/27, 5600/21, as before.
  - Builds: 20 / 20 / 28 / 30 warnings as before. The formatter changes nothing.
- **Turned off** at the user's request: the CopyProtection call in DemoLoop (WOLF3D.BAS) is commented out, so SPEAR starts without the quiz. The quiz code stays in WL_INTER.BM.

## 2026-11-03: Step 7h, the demo version and the exit screens

Committed as "Step 7h: the Spear of Destiny demo version and the exit screens" (this commit).

- **Checked:** every `SPEARDEMO` block of the C code against the port.
  - Already ported in earlier steps:
    - the digitized sounds the demo doesn't have (InitDigiMap);
    - the I+D easter egg (not in the demo);
    - the *.SDM files (CheckForEpisodes);
    - the one demo (PlayDemo 0, T_DEMO0);
    - the end after map 1 with its message (7d);
    - no copy protection.
  - DoJukebox (holding M at start-up; not in the demo) is not ported in any build. It's a separate item, not part of 7h.
- **Quit, the exit screens (WL_MAIN.C Quit),** for every build:
  - **A normal quit** shows ORDERSCREEN, and **an error** shows the top 7 lines of ERRORSCREEN with the message in its box (C: gotoxy(10,4), puts).
  - The chunks are BSAVE dumps of the DOS text memory: a 7 byte header, then a character and an attribute per cell. ShowTextScreen copies them into an 80x25 QB64 text screen, whose _MemImage has the same layout as 0xb800.
  - PutTextChars writes the error without changing the attributes, as puts does, so it takes the colors of the box.
  - DOS leaves the screen at the prompt; the window waits for a key before closing.
  - The chunk is cached before the shutdown. A Quit before the graphics file is open, or a second Quit while caching it, keeps the old plain text message.
  - Quit now also calls ClearMemory, as C does.
  - **ShutdownId** (new) shuts down the managers. CopyProtection uses it for its DOS message instead of Quit, which would now show ERRORSCREEN; C prints the message on a plain screen.
- **/mapview and /demotest** end with ShutdownId and System: no config and no order screen, so a test run still exits by itself.
- **Tested:**
  - **The order screen:** quitting from the menu shows each build's own screen. SDM shows "SPECIAL DEMO ... We hope you've enjoyed this demo"; SOD shows the registration card text; WL6 shows "Thanks for playing"; WL1 shows the Apogee order form. A key closes the window.
  - **The error screen:** a temporary `Quit` in the start-up (removed) showed "Spear of Destiny Error!" with the message in white on red.
  - **SPEARDEMO:** with a temporary hook that ended each level after 2 s (removed), New Game went through floor 1 and floor 2 (no "Get Psyched!" in between), then "This concludes your demo of Spear of Destiny!...".
  - **Demos:** SDM 2900/13; SOD 2900/13, 1000/10, 3000/12, 7300/13; WL6 3900/15, 13600/51, 7100/27, 5600/21, as before. Each /demotest run exits by itself (code 0).
  - **Builds:** 20 / 20 / 28 / 30 warnings as before. The formatter changes nothing.

## 2026-11-04: Clearing out stale TODOs

Commit 167cb43.

- **ID_CA.BM:** the C alternatives for headers linked into the exe are gone. These were the `$If MAPHEADERLINKED / GRHEADERLINKED / AUDIOHEADERLINKED` branches, with their TODOs and placeholder code, such as a 4096-byte dummy map header.
  - No version header of the original (VERSION.H, SODVER.H, SDMVER.H, WOLF1VER.H...) defines them, so only the code that reads the files was ever compiled.
  - That code is unchanged, one level less indented. A note at the top of the file says why the alternatives are not ported.
  - The "TODO: Implement audio file opening" comment was above code that already opens the file, so it is removed.
- **ID_MM.BM is deleted.** It held empty stubs of MM_FreePtr, MM_SetLock and MM_BombOnError with TODOs; memory is managed by _MEM blocks and arrays.
  - The only callers were in StartCPMusic (WL_MENU.BM): MM_BombOnError around the music caching (CA_CacheAudioChunk already returns without the chunk if it fails), and MM_SetLock on the music. They are removed, with a comment, and so is their tempPtr variable.
  - The 4 unused stub parameters were warnings: now 16 / 16 / 24 / 26 (WOLF3D / WOLF1 / SPEAR / SPEARDEMO).
- **WOLF3D.BAS, the main program:** the commented-out "main game loop" with its TODO and the shutdown code after DemoLoop are gone. DemoLoop never returns (it quits), so they never ran.
  - Now `Quit "Demo loop exited???"` follows it, as at the end of C's main.
- **Left:** the TODOs that are features, not stale: NonShareware (SignonScreen) and RecordDemo (DemoLoop).
- **Tested:**
  - **Demos:** SDM 2900/13; SOD 2900/13, 1000/10, 3000/12, 7300/13; WL6 3900/15, 13600/51, 7100/27, 5600/21, as before.
  - **WOLF1:** it starts, the menu music plays through StartCPMusic, and Quit shows the order screen.
  - All four builds compile; the formatter changes nothing.

## 2026-11-04: PC speaker sounds

Commit 1c4ab9a.

- **Ported (ID_SD.C, ID_SD_A.ASM):** the PC speaker sound effects, the "PC Speaker" choice of the sound menu. Until now that mode was silent.
  - **SDL_PCPlaySound / SDL_PCStopSound / SDL_ShutPC:** the same as C. A PCSound chunk is SoundCommon (length, priority), then one byte per 140 Hz step from offset 6.
  - **SDL_PCService:** the PC part of DOFX (ID_SD_A.ASM), run every effects tick before the AdLib part. A byte that differs from the last one sets the PIT divisor `s * 60` (pcSoundLookup), or turns the speaker off for 0. At the end of the sound it stops it (SDL_SoundFinished).
  - **SD_PlaySound, SD_SoundPlaying, SD_StopSound, SD_SetSoundMode** (SDL_ShutPC when the mode changes) and **SD_Shutdown** have their PC cases.
- **The speaker:** C programmed PIT channel 2 and the gate on port 61h. Here SDL_PCSpeaker turns the divisor into a frequency (1193182 / divisor Hz), and SD_PumpAudio mixes a square wave into the output (SD_PCGAIN 0.2).
  - Each sample is the square wave averaged over the sample. The integral of the square wave is a triangle, so this costs two lookups. It keeps the high notes (up to ~19.9 kHz for s = 1) from aliasing.
- **Not ported:** the digitized sounds on the PC speaker (sds_PC). No menu selects them; the digitized sound choices are None, Sound Source and Sound Blaster.
- **Tested** in WOLF3D with a temporary hook (removed) that logged each byte the service played and dumped the speaker samples. The test selected PC Speaker in the menu, moved the menu cursor, and started a game.
  - The bytes played match four PC sound chunks of AUDIOT.WL6 exactly (chunks 4, 5, 32 and 39).
  - The tones in the dump are within 0.05% (median) of 1193182 / (s * 60). The samples stay within -1..1; the first try was off by a factor of 2 and reached ±2.
  - The game ran in PC speaker mode.
  - **Demos:** SOD 2900/13, 1000/10, 3000/12, 7300/13 and WL6 3900/15, 13600/51, 7100/27, 5600/21, as before.
    - SDM ended as before (2900/13, frame 1954) in 3 of 5 runs. The other 2 were aborted (playstate ex_abort at frames 226 and 1672).
    - A demo aborts on any key or mouse button (IN_CheckAck), and the test window stays on top, so input on the desktop during the run stops it. These were aborts, not desyncs; the PC speaker code doesn't read input.
  - **Builds:** 16 / 16 / 24 / 26 warnings as before. The formatter changes nothing.

## 2026-11-04: Demo recording

Commit 5120d75.

- **Ported (WL_GAME.C 900-1030, WL_PLAY.C PollControls, WL_MAIN.C DemoLoop):**
  - **The trigger:** DemoLoop calls RecordDemo instead of the control panel when Tab is held as the title loop ends and the game was started with `goobers` (Spear: `debugmode`). MS_CheckParm (new, WOLF3D.BAS) checks the parameter, ignoring case and any - / \ in front.
  - **RecordDemo** asks "Demo which level(1-10):", then starts that map on hard (Wolfenstein: episode level / 10, map level mod 10; Spear: map level). It records PlayLoop, then FinishDemoRecord.
  - **StartDemoRecord** sets up an 8192-byte demobuffer (MAXDEMOSIZE). The header is the level byte and room for the length.
  - **PollControls** writes each frame: the buttons byte and controlx / controly per tic. While recording, a frame takes DEMOTICS like playback. A full buffer quits with "Demo buffer overflowed!".
    - The WL1 (APOGEE_1_0) build writes v1.0's 4th byte, the tics of the frame. Its playback reads that byte only while playing back.
  - **FinishDemoRecord** writes the length (bytes 1-2), asks "Demo number (0-9):", and writes DEMO?.ext (CA_WriteFile, new). As in C, the screen is faded out at that point, so the prompt is not visible.
  - GameLoop's `If demorecord And playstate <> ex_warped Then FinishDemoRecord`, as in C (only RecordDemo sets demorecord).
  - **Helpers the port didn't have:**
    - CenterWindow (WL_PLAY.C, centred in the 320x160 view);
    - US_DrawWindow and US_ClearWindow (ID_US_1.C);
    - VWB_DrawTile8 (the 8x8 frame tiles of the STARTTILE8 chunk: 64 bytes a tile, 4 planes);
    - CA_LoadFile (new).
- **The demo buffer:** PlayDemo and PollControls read from `demobuffer` (a _MEM) instead of grsegsMem(demochunk). It is the T_DEMO chunk as before, or a loaded file.
- **/playdemo N** (port debug option, PORTDEBUG.BM): plays a recorded DEMO N.ext from a file, as C did without DEMOSEXTERN, and writes the end state to DEMOTEST.TXT like /demotest. The game itself still plays only the T_DEMO chunks, as the original did.
- **Tested** in WOLF3D (`goobers`):
  - **Recording:** Tab held while the title loop ended brought up the level prompt over the faded title; level 1 then played with the Demo sprite. The test walked, turned and fired 4 shots.
  - **Ending it:** Esc while recording opens the menu as outside a game (ingame is not set, as in C). New Game ended the recording, and "5" wrote DEMO5.WL6: 574 bytes, a 4-byte header and 190 frames.
  - **Playback:** `/playdemo 5` played it to the end of its data (frame 574 of 574). The player ended where the recording did (x 2071048, y 3698684, angle 339) with 4 rounds left, in two runs, logged by temporary hooks (removed).
  - The Tab repeats that start the recorder also typed tab characters into the level prompt in the test. A real key release wouldn't.
- **Not tested:** recording in SPEAR (`debugmode`) and WL1 (the 4-byte frames).
  - **Demos:** SDM 2900/13; SOD 2900/13, 1000/10, 3000/12, 7300/13; WL6 3900/15, 13600/51, 7100/27, 5600/21, as before (now read through demobuffer).
  - **Builds:** 16 / 16 / 24 / 25 warnings. SPEARDEMO has one fewer: PlayDemo's demonumber is now used there too, for the file name. The formatter changes nothing.

### How to record and save a demo

1. Start the game with the developer parameter: `WOLF3D.exe goobers` (WOLF1 too); SPEAR and SPEARDEMO use `debugmode`. Not with `nowait`, which skips the title loop.
2. Hold Tab while the title screen or the demos are showing. The key repeat ends the title loop, and DemoLoop then sees Tab down and calls RecordDemo instead of the menu. A quick tap is not enough; hold it until "Demo which level(1-10):" appears.
3. Let go of Tab before typing; while held it types tab characters into the prompt (Backspace removes them). Type the level and press Enter.
   - Wolfenstein: 1-10 are the maps of episode 1 (11 = episode 2 map 1, and so on).
   - Spear: the map.
   - The game is on hard, with the "Demo" sprite on screen.
4. Play. Keep it under about 2.5 minutes: the buffer is 8192 bytes (3 bytes a frame of 4 tics), and when it is full the game quits with "Demo buffer overflowed!" and nothing is saved.
5. End the recording:
   - die (all the original demos end with a death), or
   - press Esc and choose New Game (episode, difficulty). Esc opens the menu as outside a game, as in C, so there's no End Game.
6. The screen goes black (faded out, as in C), but "Demo number (0-9):" is waiting. Type a digit and press Enter.
   - It writes `DEMO<n>.<ext>` (DEMO5.WL6 / .SOD / .SDM / .WL1) in the game directory.
   - Esc cancels without saving.
   - After New Game, that new game starts next.

**To watch it:** `WOLF3D.exe /playdemo 5` (a port option; the game itself only plays the built-in T_DEMO chunks). It plays DEMO5.WL6, writes how it ended to DEMOTEST.TXT, and exits.

## 2026-11-05: The debug keys (WL_DEBUG.C) and PicturePause

Commit 13ce04a.

- **Ported: WL_DEBUG.BM (new, WL_DEBUG.C).** ViewMap / OverheadRefresh are left out, as they are `#if 0` in the original.
  - **Opening the debug keys** (CheckKeys, WL_PLAY.C): Backspace + LShift + Alt, with `goobers` on the command line (Spear: `debugmode`). It shows "Debugging keys are now available!" and sets DebugOk.
  - **DebugKeys:** Tab + key, once DebugOk is set.
    - **B:** border color (VW_ColorBorder only keeps the value: a window has no overscan border).
    - **C:** count the objects.
    - **E:** end the level (quit with TEDLEVEL).
    - **F:** the player's x / y / angle.
    - **G:** god mode.
    - **H:** hurt yourself.
    - **I:** free items (100000 points, health, the next weapon, 50 ammo).
    - **M:** memory info, shown as n/a: the port has no memory manager.
    - **N:** no clipping, Spear only. Read before the ElseIf chain, as a `$If` inside the chain breaks it.
    - **P:** PicturePause.
    - **Q:** quit.
    - **S:** slow motion.
    - **T:** ShapeTest.
    - **V:** extra VBLs (0-8).
    - **W:** warp to a level (1-10, Spear 1-21).
    - **X:** "Extra stuff!".
  - **PlayLoop's debug aids:** slow motion waits 14 VBLs a frame, and extravbls adds VBLs.
  - **ShapeTest** browses the VSWAP pages with the arrows and W / S / D / I, as in C.
    - The port has no paging, so a page shows its file offset and length instead of the XMS / EMS / main pages and the last hit.
    - A wall is drawn unscaled (64x64), and a sprite with SimpleScaleShape 32 rows lower, as in C.
    - The sound pages show the sound and segment number and the waveform, and the info page shows the totals.
  - **PicturePause:** waits for a key with the screen frozen (for a screen grab). Enter shows the frame with the game palette (C switched to mode 13h). The next key then quits with the order screen; any other key goes on.
    - Called by Tab + P in the menus (MouseSensitivity, CP_ChangeView, HandleMenu; Confirm and the help text with `goobers` only, as in C), and by P on the intermission screens (Wolfenstein only).
  - **Helpers:** IN_ClearKey and VW_ColorBorder, kept in vgabordercolor. The constant BORDERCOLOR has the same name in QB64's case-insensitive names.
- **Tested** in WOLF3D (`goobers nowait`, New Game):
  - The unlock message appeared.
  - **Tab + F, I, C, T, W and S:**
    - F: X 1933312, Y 3768320, A 0.
    - I: "Free items!" with the chaingun and 99 ammo.
    - C: 121 statics, 22 doors, 21 actors, 7 active.
    - T: wall pages 0 and 1 drawn; S jumped to page 106, the first sprite (the Demo sprite).
    - W: warp to 3 went to floor 3.
    - S: "Slow motion ON".
  - **Tab + P (PicturePause):** froze the screen. Enter showed the frame, and a key quit to the order screen.
  - Keys held over several frames repeat, as with the typematic in DOS. A held Tab + I gave the items 7 times, and a held Tab typed tab characters into the warp prompt.
  - **Demos:** SDM 2900/13; SOD 2900/13, 1000/10, 3000/12, 7300/13; WL6 3900/15, 13600/51, 7100/27, 5600/21, as before. The first WL6 run had 3 aborts from desktop input; the rerun matched.
  - **Builds:** 15 / 15 / 23 / 24 warnings (WOLF3D / WOLF1 / SPEAR / SPEARDEMO): one fewer each, as singlestep and noclip are now used. The formatter changes nothing after formatting the new file.
- **Fixed after your test: Tab + H crashed when it killed BJ** ("Subscript out of range", WL_GAME.BM Died).
  - TakeDamage (16, NULL) leaves killerobj NULL (-1 here). Died then swings BJ around to face objlist(killerobj).
  - C read whatever was at address 0 there; the port indexed objlist(-1). Died now skips the swing when there is no attacker.
  - **Tested:** Tab + H pressed 7 times took health 100 to 4 to 0, then the red fizzle; a life was lost (3 to 2) and the level restarted.
  - H clears the keys (IN_ClearKeysDown, as in C), so Tab must be pressed again for each hit.

## 2026-11-05: The jukebox

Committed as "The jukebox (DoJukebox)" (this commit).

- **Ported: DoJukebox (WL_MAIN.C)**, "Robert's Jukebox", in all builds but SPEARDEMO (as in C).
  - **Wolfenstein:** 18 songs, shown 6 at a time. The page is picked by the hundredths of the time (_dos_gettime); WL1 (UPLOAD) always shows the first page.
  - **Spear:** 9 songs.
  - Enter plays a song and highlights it (active 2); Esc leaves. The screen uses the control panel's backdrop, stripes and window. The title keeps C's `WindowY = 320` (sic: WindowW was meant).
- **The call:** in InitGame after LoadLatchMem.
  - C checked Keyboard[sc_M] there, else IntroScreen. The port showed IntroScreen earlier, in SignonScreen.
  - IN_Startup has just cleared the keys. In DOS the typematic repeat of a held M set Keyboard[sc_M] again at once; here the check also asks `_KeyDown` whether M is held.
- **Bug found by your test** (pressing M quit the game): DoJukebox's local `songs()` clashed with the shared `songs()` of WL_PLAY.BI (the level music), runtime error 10 "Duplicate definition". The held M dismissed the error screen. The local array is now `jukesongs()`.
- **Tested** with a temporary `dbgjukebox` parameter (removed) that opened the jukebox without keys, checked with screenshots only:
  - WOLF3D showed the second page ("Nazi Anthem" ... "Ultimate Conquest"); SPEAR showed its 9 songs.
  - Playing songs and holding M at start-up were left for you to check by hand. The test script's key presses can land in another window while the game starts.
  - **Builds:** 15 / 15 / 23 / 24 warnings as before. The formatter changes nothing.

## 2026-11-05: Joystick and Gravis GamePad

Commit 030d11b.

- **The joysticks are QB64 game controllers** (`_DEVICES`). Joystick 1 / 2 (`joystickport` 0 / 1) are the first and second `[CONTROLLER]` devices.
  - The stick is the controller's first two axes, and the buttons are its buttons 1-4.
  - INL_JoyService reads the waiting input of a controller (`_DeviceInput`, then `_Axis` / `_Button`) into the last-state arrays.
- **Ported (ID_IN.C):** IN_GetJoyAbs, INL_GetJoyDelta, INL_GetJoyButtons, IN_GetJoyButtonsDB, IN_JoyButtons, INL_SetJoyScale, IN_SetupJoy, INL_StartJoy, and the detection in IN_Startup (with the `nojoys` parameter).
  - **The axes:** the game port measured the stick as timing counts. IN_GetJoyAbs turns an axis (-1 to 1) into the count 0 to JOYCOUNTS (1000). So INL_StartJoy's auto-setup (center x 2), the calibration and C's threshold / scale arithmetic work unchanged.
  - **The buttons:** IN_JoyButtons gives the four lines of the port. Bits 0-1 are the buttons of joystick 1, and bits 2-3 those of joystick 2, or buttons 3-4 of the first controller (the Gravis GamePad used all four lines).
  - IN_StartAck / IN_CheckAck count the joystick buttons too, as in C.
- **WL_PLAY.BM:** PollJoystickButtons and PollJoystickMove, called by PollControls when joystickenabled.
  - Progressive mode keeps the original's `controlx` for a stick pushed down (sic).
- **WL_MENU.BM:**
  - CalibrateJoystick: upper left + button 0, then lower right + button 1, Esc to leave. WL1 v1.0 has no C_JOY1PIC / C_JOY2PIC, so it shows the text only.
  - "Joystick enabled" in the control menu calibrates and stays off if that's cancelled.
  - ReadAnyControl reads the joystick when the mouse didn't move or click (mouseactive, as in C).
  - The joystick menu items were already ported and stay inactive without a controller (JoysPresent).
- **The start-up screen** (IntroScreen) lights JOYSTICK, as C does for JoysPresent[0] || JoysPresent[1].
  - The port shows IntroScreen before IN_Startup, so it looks for a `[CONTROLLER]` device directly (not with `nojoys`).
  - The box was never drawn before ("not present in our simplified version").
- **Tested** with a Thrustmaster T.Flight Hotas X (`_DEVICES`: `[CONTROLLER][[NAME][T.Flight Hotas X]]`, 12 buttons, 7 axes):
  - **A logging program** (outside the game) read the stick on axes 1 / 2, from -1 to 1 in every corner (rest about -0.01), and buttons 1 and 2.
  - **The logic,** with a temporary hook (removed) that set the axes and buttons directly:
    - IN_SetupJoy 0..1000 gives the thresholds 167 / 833 and multipliers 196, as C would.
    - An axis of -1 / -0.8 / -0.6..0.6 / 0.8 / 1 gives -127 / -51 / 0 / 51 / 127, y the same.
    - Buttons 1-4 give the bits 1, 2, 4, 8.
  - **At start-up** (a temporary log, removed): joystick 1 is device 3, centred (500 / 500), so JoysPresent(0) is TRUE and a saved "Joystick enabled" stays on.
  - **The Control screen** shows Joystick Enabled checked after your calibration; SPEAR shows the JOYSTICK light at start-up.
  - **Bugs found by your tests:**
    - **The calibration** seemed to pass, but "Joystick enabled" stayed off. `If Not CalibrateJoystick Then joystickenabled = 0`: the function returns 1 as in C, and QB64's Not is bitwise, so `Not 1` is -2, which is true. Now `If CalibrateJoystick = 0`.
    - **The same 0/1 trap** is fixed in PollJoystickButtons (`joystickport <> 0 And joypadenabled = 0`) and ReadAnyControl (`joystickenabled <> 0 And mouseactive = 0`), which only worked by chance.
    - **God mode, the same kind of bug:** godmode is toggled 0/1 (Tab + G, Spear's Tab-G-F10, `godmode Xor 1` as C's `^= 1`). So TakeDamage's `If Not godmode` was still true with god mode ON, and BJ took damage. Now `If godmode = 0` (both checks).
    - **The JOYSTICK light** on the start-up screen was off (see above).
  - **Buttons b2 / b3 in Customize controls** are recognised only with "Gravis GamePad Enabled", as in C. Without it ReadAnyControl gives a joystick buttons 0 and 1 only (a 2-button joystick).
- **A note for gamepads:** PollJoystickMove moves only past a delta of 64, about 85% of the stick's travel. That is fine pushed straight. A round-gated modern stick pushed diagonally reaches only ~71% on each axis, so it moves along one axis or not at all; the old joysticks had square gates.
- **Demos** (with the Hotas connected): SDM 2900/13; SOD 2900/13, 1000/10, 3000/12, 7300/13; WL6 3900/15, 13600/51, 7100/27, 5600/21, as before. An earlier run had aborts from input while the joystick was being connected.
- **Builds:** 15 / 15 / 23 / 24 warnings as before. The formatter changes nothing.

## 2026-11-08: NonShareware, a stale TODO

Commit 5f90f4e.

- NonShareware (WL_INTER.C 1272) was already ported (WL_INTER.BM): the "Attention / This game is NOT shareware" screen.
  - DemoLoop calls it unless NOWAIT, only in WL6 (not UPLOAD, GOODTIMES, SPEAR or JAPAN), as in WL_MAIN.C 1463.
- SignonScreen still had "TODO - other calls in NonShareware" and a commented-out call. C's SignonScreen doesn't call it, so both lines are removed. WOLF3D.BAS has no TODO left.
- **The sign-on, now as in C** (WL_MAIN.C SignonScreen / InitGame / FinishSignon):
  - **SignonScreen** only draws the picture. The port's own `_Delay 1`, the key wait before IntroScreen (WL6 / WL1) and the waits after it are gone.
  - **IntroScreen** (the memory bars and hardware lights) comes after ReadConfig, in the Else of the jukebox check (`M ? DoJukebox : IntroScreen`).
    - The JOYSTICK light is now `JoysPresent(0) Or JoysPresent(1)`, as in C: IN_Startup has run by then.
  - **FinishSignon (new)** ends InitGame.
    - Wolfenstein: "Press a key" (14 on 4) on a bar of the top left pixel's color, IN_Ack unless NOWAIT, then "Working..." (10 on 4).
    - Spear: the 3 second wait, unless NOWAIT.
  - **Tested** (screenshots only):
    - WL6 and WL1 show the bars and lights with "Press a key", without a key before. The JOYSTICK light is off with the controller unplugged.
    - SPEAR keeps "One moment..." and goes on to the PC-13 screen after 3 seconds.
    - WL6 with NOWAIT goes straight to the menu.
    - The SDM /demotest still ends 2900/13 at frame 1954.
    - Builds: 15 / 15 / 23 / 24 warnings as before. The formatter changes nothing.

## 2026-11-08: WOLFS14, the v1.4 shareware build

Commit 413bc0b.

- **Why:** the shareware on archive.org (wolf3dsw.zip, "Wolfenstein 3D (Shareware, v1.4)") is v1.4. WOLF1.BAS reads only the v1.0 data.
  - VGAHEAD.WL1 is 471 bytes (156 chunks) in v1.4, against 447 bytes (148 chunks) in v1.0.
  - VGAGRAPH is 326568 against 295394 bytes, and VSWAP 742912 against 707072.
  - One exe for both is not practical: the chunk numbers are compile-time Consts.
- **WOLFS14.BAS (new):** `$Let UPLOAD = 1`, without APOGEE_1_0, so the code follows the C source, which is v1.4. WOLF1.BAS stays for v1.0.
- **The data, analysed** from the zip's *.WL1 files (unpacked into wolfs14/, gitignored):
  - **Graphics:** no header in origsrc fits (GFXV_WL1.H says 556 chunks). The picture table (chunk 0, 144 pictures) is the GFXV_WL6.H list with two changes:
    - the help pictures are the 18 of GFXV_WL1.H (3-20), plus a 256x144 Spear of Destiny advert at 21. Page 23 of the help text shows it (`^G16,16,21`); the port names it H_SPEARADPIC.
    - so everything after them is 12 higher: C_OPTIONSPIC 22, KNIFEPIC 103, GETPSYCHEDPIC 146.
    - Then the 8x8 tiles (147), ORDERSCREEN / ERRORSCREEN (148-149, 4008 bytes each), T_HELPART (150, `^PAGE 1`), T_DEMO0-3 (151-154) and T_ENDART1 (155): 156 chunks.
  - **Sounds:** AUDIOHED.WL1 is 1156 bytes, the 288 chunks of AUDIOHED.WL6, so AUDIOWL6.BI.
  - **Sprites:** VSWAP.WL1 has the layout of VSWAP.WL6 (663 chunks, sprites from 106, sounds from 542), so the WL6 sprite numbers, without the v1.0 shifts.
- **tools/gen_headers.py** writes GFXV_S14.BI from GFXV_WL6.H with those fixes (S14_*); the other generated files are unchanged.
- **ID_HEADS.BI:** UPLOAD without APOGEE_1_0 includes GFXV_S14.BI and AUDIOWL6.BI.
- **The UPLOAD code paths** follow C:
  - the death screams;
  - the time and score codes, which are left out;
  - the first jukebox page;
  - the episode check;
  - the digitized sounds of the other episodes, which are not mapped.

  The v1.0 special cases stay behind APOGEE_1_0.
- **tools/ide_format.py** formats WOLFS14.BAS as a fifth build.
- **Tested** in wolfs14/ (WOLFS14.exe copied there):
  - **/demotest:** demos 1-3 (maps 2, 4, 6) end exactly on their last frame (2000/20 at 3856, 2500/13 at 2017, 1500/7 at 1903), so the game stays in sync.
    - **Demo 0 (map 0) desyncs:** BJ dies at frame 3169 of 3460, with 1600/16, 97 frames early.
    - It is the same with sound off, the PC speaker or AdLib, so it is not UpdateFace's GETGATLINGSND check.
    - Screenshots every 6 s show a normal fight to the end, with no wall running. The difference is not found yet.
  - **Screens:** the sign-on ("Press a key", the lights), PC-13, the title, the menu, the help text (pg 1 of 41 with its border pictures), E1M1 (`tedlevel 0`), and the v1.4 order screen on Quit (with the Hint Book).
  - **Builds:** WOLFS14 has 15 warnings; the other four are unchanged (15 / 15 / 23 / 24). The formatter changes nothing (64 files, two passes).

## 2026-11-10: The start scripts startbin and startsrc

Commit a64de6e (the CRLF .gitattributes: dae1787).

- **Two scripts in the repository root,** each a `.bat` to double-click and a `.ps1` with the logic. The `.bat` runs `powershell -NoProfile -ExecutionPolicy Bypass -File` and pauses on an error.
  - They install next to themselves, into `wolfs14\` (and `qb64\`, `wolf3dbas\` for startsrc). So a run inside the checkout never overwrites the v1.0 *.WL1 files of the root; those folders are gitignored.
  - A step whose result is there is skipped. With the exe and all 8 *.WL1 files there, the script starts the game at once.
  - A status line per step (OK / skipped / FAILED and why), then "All steps went OK." and the game starts, or the number of failed steps and exit code 1.
  - **Downloads:** `curl.exe -L -f --retry 2` (it follows the archive.org redirect), with Invoke-WebRequest (TLS 1.2) as the fallback.
  - **The shareware:** only the *.WL1 files of wolf3dsw.zip are unpacked (.NET ZipFile), not its DOS WOLF3D.EXE; the zip is deleted afterwards.
  - **Invoke-Native** runs curl, git, tar, 7zr and qb64. In PowerShell 5.1, with `$ErrorActionPreference = 'Stop'`, their stderr output (git's "Cloning into...") would stop the script.
- **startbin:** WOLFS14.exe from `-ReleaseUrl`. Its default is the placeholder `https://github.com/iandevpro/wolf3dbas/releases/download/<TAG>/WOLFS14.exe`, which is reported as FAILED until it's filled in. Then the shareware, then the game.
- **startsrc:**
  - **The source:** run in a checkout, it uses it. Else `git clone --depth 1` over HTTPS, then over SSH (`git@github.com:...`), then the zip of main.
    - The clones can't prompt (GIT_TERMINAL_PROMPT=0, GCM_INTERACTIVE=never, no credential helper, ssh BatchMode), so a clone that needs a password fails at once instead of waiting.
    - A failed clone's folder is removed.
  - **QB64 2.1:** the .7z unpacked with Windows' own `System32	ar.exe` (Git's tar reads "C:" as a host), else with 7zr.exe from 7-zip.org.
  - **Compile:** `qb64 -x WOLFS14.BAS -o wolfs14\WOLFS14.exe`.
- **Tested** in empty folders under the job's temp dir:
  - **startbin:**
    - with the placeholder: FAILED with the message, and the data was still downloaded and unpacked;
    - with a `file:///` URL in place of the release: the exe was downloaded, the data skipped, and the game started;
    - again: it started at once.
  - **startsrc:**
    - **The first run** got QB64 (Git's tar failed there and the 7zr fallback unpacked it, which led to the System32 tar), and the data.
      - Its HTTPS clone of the private repository waited for a GitHub sign-in until it was stopped. That led to the no-prompt settings.
    - **The second run** (HTTPS failing at once, then SSH) cloned, compiled in 83 s and started the game.
    - **The third run** started it at once.
- **The repository is private:** HTTPS clones, the source zip and release downloads need it public. Until then startsrc works over SSH for an account with access, and startbin needs the exe hosted publicly.

## 2026-11-10: The QB64 sources in basicsrc/

Commit 68f4425.

- **`git mv`** of the 64 `*.BAS / *.BI / *.BM` files from the root into `basicsrc/`; git sees them as renames.
  - The includes are bare file names (`'$INCLUDE: 'WL_DEF.BI'`), relative to the including file, so they work unchanged.
  - The data files, `origsrc/`, `tools/` and `plans/` stay where they are.
  - `OBJ/` (the original SIGNON.OBJ / GAMEPAL.OBJ, their dumps, the .bin files extracted from the exes, and the old converters hex2bin / PALETTE) moved too, to `basicsrc/OBJ/`: 16 files, git mv.
- **The tools:**
  - **The generators** write their files into `basicsrc/` (a BASICSRC / B path) and still read `origsrc/` and `OBJ/`: gen_headers (`GFXV_*`, `AUDIO*`, `MAPS*.BI`), gen_sprites (`WL_SPR.BI`), gen_states (`WL_STATE.BI/BM`) and gen_signon (`GAMEPAL.BAS`, `SIGNON_*.BAS`).
  - **ide_format.py** reads and writes the files in `basicsrc/`.
  - **func-qb64.sh** greps `basicsrc/*.B*`.
  - **extract_exe_data.py** writes, and **gen_signon.py** reads, `basicsrc/OBJ/`. The generated GAMEPAL.BAS and SIGNON_*.BAS name it in their header comment, the only line that changed in them.
- **Where the exes go:**
  - QB64 writes the exe next to the source (`basicsrc/X.exe`), and a QB64 program runs in the folder of its exe. Such an exe doesn't find the data files in the root: run from the root, it ended at once without a word.
  - So the exes stay in the root: `qb64 -x basicsrc/X.BAS -o <absolute path>/X.exe`. A relative `-o` is taken from the source folder (`-o ../X.exe` tried to write C:\X.exe).
  - The **Makefile** (WSL) now builds all five exes that way into the root (`make`), with `wslpath -w` for the absolute path. It is not tested here.
- **startsrc.ps1:** a checkout is recognised by `basicsrc\WOLF3D.BAS`, and it compiles `basicsrc\WOLFS14.BAS` (the exe goes to `wolfs14\` with an absolute `-o`, as before).
- **Tested:**
  - extract_exe_data.py rewrote the six .bin files from the original exes byte for byte. The generators rewrite their files unchanged (gen_signon apart from the comment); gen_sprites / gen_states differ only in CRLF, which git stores as LF anyway.
  - The formatter reads basicsrc/ and changes nothing (64 files).
  - All five builds compile from `basicsrc/` with 15 / 15 / 15 / 23 / 24 warnings, as before.
  - SPEARDEMO built into the root with an absolute `-o` plays its demo as before (2900/13 at frame 1954).
  - startsrc in a test folder with the new layout compiled `basicsrc\WOLFS14.BAS` into `wolfs14\` and started the game.

## 2026-11-10: Shareware demo 0 ends early in the original too

Commit 66484d1.

- **The question** (see the WOLFS14 entry): in WOLFS14, shareware v1.4 demo 0 (map 0) ends with BJ's death at frame 3169 of its 3460 bytes, while demos 1-3 end exactly at their data's end.
- **The original, for comparison:** the v1.4 shareware WOLF3D.EXE from wolf3dsw.zip, run in DOSBox-X (`C:\Games\DOSBox-X`).
  - It ran from a folder of its own in the job's temp dir, with a config of its own: surface output, so that PrintWindow screenshots work, and `autotype -w 5 space` for "Press a key". So no key went through Windows.
  - Screenshots were taken every 0.45 s through the title loop and demo 0.
- **The result: the same death in DOS.** The last game frames show 1600 points, 23% health and ammo 45 down to 42. Then the guard in front fires, the screen flashes red, and the demo fades to the title.
  - That's the port's end: a 56 hit at frame 3169, with 41-42 ammo.
  - The timing matches, about 61 s into the demo in DOS against 60.3 s (3169 bytes) in the port.
  - So the original v1.4 exe doesn't play demo 0 to its end either: the demo was recorded with an earlier version and doesn't stay in sync in v1.4. The port is right; nothing to fix.
- **How it was narrowed down,** with temporary hooks (removed) that logged each frame's state and each damage, item, kill and pushwall:
  - every hit BJ takes up to frame 2767 (-36, -60, -5, -7, -4, -1) matches the DOS health readings (64, 40, 35, then 23%), and each damage value comes from the random table;
  - only demo 0 moves a pushwall (frame 1336). C's CheckLine reads doorposition[] past its end for a moved pushwall tile (0xc0); the port blocks the line there. Making the tile transparent didn't change demo 0, and that test was removed.
- **Seen on the way:** the original v1.4 shareware sign-on shows the Apogee logo, while WOLFS14 shows the WL6 sign-on picture (the "G" logo). Its SIGNON.OBJ data is in its exe, as with the other versions (tools/extract_exe_data.py). Not done yet.

## 2026-11-11: The v1.4 shareware sign-on (WOLFS14)

Commit b8e5002.

- **Why:** WOLFS14 showed the WL6 sign-on (the "G" logo). The original v1.4 shareware shows the Apogee logo and "v1.4", as seen in DOSBox-X.
- **The source:** its SIGNON.OBJ data is in the WOLF3D.EXE of wolf3dsw.zip (LZEXE 0.91, 287040 bytes unpacked). The exe is not in the repository; take it from the zip.
- **tools/extract_exe_data.py:**
  - Here the screen is not next to the palette: the palette is at 239242, the screen at 138080, with 37162 bytes of other data between them.
  - The "64000 bytes before the palette" rule took the wrong block, starting partway down the picture.
  - The tool now first looks for rows of the WL6 sign-on (signon.bin: rows 100, 150 and 190, 10 rows each); this sign-on has the same panels and differs in 40 rows, the logos.
  - When they are not found (the Spear and v1.0 pictures differ), it uses the palette rule as before.
  - `python -I tools/extract_exe_data.py <WOLF3D.EXE of wolf3dsw.zip> s14` writes basicsrc/OBJ/signon_s14.bin and gamepal_s14.bin. That palette is the WL6 one.
  - Rerunning it for SPEAR-ORIG, SPEAR-DEMO-ORIG and WOLF3D-SHARE-ORIG gives the same files, byte for byte.
- **tools/gen_signon.py** writes SIGNON_S14.BAS, and checks that the wl1 and s14 palettes are still the WL6 one (GAMEPAL.BAS serves them).
- **WOLF3D.BAS:** UPLOAD without APOGEE_1_0 (WOLFS14) includes SIGNON_S14.BAS.
- **Tested:**
  - The extracted screen, rendered with the palette, is the DOSBox-X sign-on: Apogee logo, v1.4.
  - WOLFS14 shows it at start-up. A temporary `dbgsig` hook (removed) held the screen, because the test script's Alt tap counts as "Press a key".
  - All five builds compile with 15 / 15 / 15 / 23 / 24 warnings, as before; the formatter changes nothing (65 files).

## 2026-11-11: The early helper scripts and lists in misc_old_tools/

Commit e66768b.

- **Moved (git mv)** from the root into `misc_old_tools/`: TODO.txt, cfuncs.txt, cfuncs_uniq.txt, func-c.sh, func-qb64.sh, mymake.sh, parse-format-qb64-error.awk, qb64subfuncs.txt. Nothing else in the repository used them.
- **The scripts** now change to the repository root themselves (`cd "$(dirname "$0")/.."`), so they run from anywhere, and write their lists into misc_old_tools/.
  - Their shebangs are fixed: `#/usr/bin/env bash` (no `!`) in func-c.sh and func-qb64.sh, and `#!/bin/env bash` in mymake.sh, are now `#!/usr/bin/env bash`.
  - func-c.sh also writes cfuncs_uniq.txt: it was the sorted, unique names of cfuncs.txt, made by hand.
  - mymake.sh is the nvim `makeprg` (see the comments in the awk file): the editor setting is now `./misc_old_tools/mymake.sh`.
- **The lists, refreshed:**
  - cfuncs.txt (572 lines) and cfuncs_uniq.txt (555), with Universal Ctags in WSL, are the same as before, since origsrc did not change.
  - qb64subfuncs.txt now has 575 lines (it had 46, from May 2025) with the basicsrc/ paths.
  - TODO.txt marks the items that are done since. Left: the Japanese version headers (not planned) and OPL2 rhythm mode (Wolf3D's music doesn't use it).
- **For reference:** 407 of the 555 C functions have a QB64 Sub or Function of the same name. The other 148 are mostly the memory manager and the XMS/EMS paging (MM_*, MML_*, PML_*), the debug and editor helpers, and old drawing code, which are not ported on purpose.

## 2026-11-11: README.md and a demo GIF

Not committed yet.

- **README.md** for GitHub:
  - what the port is, with links to id-Software/wolf3d and QB64;
  - the three ways to play the v1.4 shareware: by hand with the release exe, startbin, startsrc;
  - the builds and how to build them (an absolute `-o`);
  - the controls (from buttonscan: Right Shift runs), the folders, and the credits.
- **docs/wolf3dbas-demo.gif** (900x639, 85 frames at 100 ms, 3.6 MB):
  - WOLFS14 playing demo 0 (8.5 s from its fade-in on: the door, the corridor, the first guard), in a window in front of the QB64 IDE with basicsrc/WL_DRAW.BM.
  - The IDE screenshot is cropped above its status bar: opened alone, WL_DRAW.BM shows a compile error there, as its includes are missing.
  - The game frames were taken with PrintWindow ten times a second. The window frame and shadow are drawn by the compositing script (PIL); no keys were sent.
