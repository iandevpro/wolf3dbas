# Wolf3D QB64 port: roadmap after PG13 (2026-10-25)

The order follows the original `DemoLoop` (origsrc/WL_MAIN.C:1411), so each step makes the next visible thing in the real startup sequence work. Check each step against the original running in DOSBox-X (`C:\Games\DOSBox-X\dosbox-x.exe`, then `cd C:\WOLF3D`, `wolf3d.exe`).

## Where we are
- **Done:** signon, NonShareware, intro music (OPL2 emulator, see `qb64_opl2_emulator_fee1c44b.plan.md`), PG13, title and credits, fonts and US_Print, high scores, AdLib sound effects (`SD_PlaySound`), all menus (5a-5c), help screens.
- **Next in the original:** the `while (1)` loop: title, credits, high scores, a demo, and on a key press the main menu (`US_ControlPanel`), then `GameLoop`.
- **Temporary:** the `DemoLoop` attract loop shows title, credits and high scores (no demo yet). A key press opens the main menu.

## Steps

### 1. Title and credits screens — DONE 2026-10-26
- Port `CA_CacheScreen` (origsrc/ID_CA.C:1381). It decompresses a full 320x200 planar picture; reuse `CAL_HuffExpand` (ID_CA.BM) and `VL_PlanarMemToScreen` (ID_VL.BM).
- Port the attract-loop skeleton of `DemoLoop`: TITLEPIC for 15 s, then CREDITSPIC for 10 s, each with `VW_FadeIn`/`VW_FadeOut`. `IN_UserInput(TickBase * n)` breaks out on a key press.
- Remove the temporary key wait in WOLF3D.BAS.

### 2. Fonts and text output — DONE 2026-10-26
- Load the font chunks (`STARTFONT`): height, `location[256]`, `width[256]`.
- Port `VW_DrawPropString`, `US_Print`, `US_CPrint`, `SETFONTCOLOR` and the `PrintX`/`PrintY`/`WindowX`/`WindowW` state.
- Then fix `NonShareware` (WL_INTER.BM):
  - remove the debug `Do: Loop Until InKey$` wait;
  - turn the opening `VW_FadeOut` back on;
  - print the "Attention" text, then `VW_UpdateScreen`, `VW_FadeIn` and `IN_Ack`.

### 3. High scores screen — DONE 2026-10-26 (default scores; loading them from CONFIG.WL6 waits for ReadConfig)
- Port `DrawHighScores` with the default score table, the `L_*` number and letter pictures, and the text from step 2.
- After this, the attract loop is complete except for demos.

### 4. AdLib sound effects — DONE 2026-10-26 (PC speaker and digitized sounds still TODO)
- Port `SD_PlaySound` for AdLib (`SDL_ALPlaySound`, `SDL_AlSetFXInst`): the instrument goes on OPL2 channel 0.
- Service the effect from `SD_PumpAudio`, which already counts samples. The original rate is TickBase * 2, i.e. 140 Hz.
- Digitized sounds (from VSWAP) come later, with the page manager in step 6.

### 5. Main menu — DONE 2026-10-27 (`US_ControlPanel`, origsrc/WL_MENU.C, about 4000 lines)
- **5a — DONE 2026-10-26:** input layer and main menu.
  - ID_IN: `Keyboard()` scan codes from `_KeyHit` via `INL_KeyService` on `ON TIMER`, plus `IN_ReadControl`, `IN_Startup`/`IN_Shutdown` and `TimeCount` (70 Hz, from the audio pump).
  - WL_MENU: `HandleMenu` with the gun cursor, `DrawMenu`, `DrawWindow`, `Message`, `Confirm`, `US_ControlPanel`, `DrawMainMenu`, View Scores, Quit, Back to Demo.
  - `DemoLoop` opens the control panel on a key press; `Quit` exits.
  - Mouse: buttons only, motion TODO. Joystick TODO.
- **5b — DONE 2026-10-27:** sub-menus New Game (episode, difficulty), Sound, Control (mouse sensitivity, customize controls), Change View. Still empty: Load Game, Read This.
- **5c — DONE 2026-10-27:** Load/Save menus (`LoadTheGame` / `SaveTheGame` are stubs until the game exists), Read This (`HelpScreens`, WL_TEXT.C).

### 6. The game (largest) — DONE 2026-10-30 (WL6; the Spear actors, demo recording, PC speaker sounds and the debug keys are not ported)
Planned in sub-steps 6a-6k in `step6_game.plan.md`: groundwork, map and VSWAP data, play screen and level setup, raycaster and movement, sprites and items, doors and level exit, enemies, bosses, digitized sounds, demos, config and save/load.

### After step 6 — DONE 2026-10-31
- The IDE formatting tool (`tools/ide_format.py`).
- Naming fixes, warnings, and removing the update blocks.
- Mouse motion.
- The shareware build for the v1.0 `*.WL1` data (`WOLF1.BAS`).

### 7. Spear of Destiny — PLANNED 2026-10-31
Planned in sub-steps 7a-7h in `step7_spear.plan.md`:
- 7a (DONE 2026-11-01): one build per version (`SPEAR.BAS`, `SPEARDEMO.BAS`), with generated headers and sprite numbers, TEDLEVEL, and the formatter for all builds.
- 7b-7d: screens, menus (both DONE 2026-11-01), and levels with the existing enemies (DONE 2026-11-02).
- 7e: the Spear enemies and bosses (DONE 2026-11-02).
- 7f: the ending.
- 7g: copy protection.
- 7h: the demo version.

## Cross-cutting decisions
- **Back buffer:** before the menu or the game, draw into an offscreen 8-bit image and have `VW_UpdateScreen` copy it to the screen with `_PutImage` + `_Display`. That avoids tearing and gives `VW_UpdateScreen` its real job; it becomes required once the renderer exists.
- **`$Debug` in WOLF3D.BAS:** it makes the OPL2 emulator about 5x slower (2.7x realtime instead of 13.8x). Turn it off once the renderer starts.
- **Busy-wait loops:** replace the `Do: Loop Until InKey$ <> ""` loops (100% CPU) with `IN_Ack` (using `_Limit`) as each one gets ported.
