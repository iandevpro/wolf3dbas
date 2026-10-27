# Wolf3D QB64 port: roadmap after PG13 (2026-10-25)

The order follows the original `DemoLoop` (origsrc/WL_MAIN.C:1411), so each step makes the next visible thing in the real startup sequence work. Check each step against the original running in DOSBox-X (`C:\Games\DOSBox-X\dosbox-x.exe`, then `cd C:\WOLF3D`, `wolf3d.exe`).

## Where we are
- **Done:** signon, NonShareware, intro music (OPL2 emulator, see `qb64_opl2_emulator_fee1c44b.plan.md`), PG13, title and credits, fonts and US_Print, high scores, AdLib sound effects (`SD_PlaySound`).
- **Next in the original:** the `while (1)` loop: title, credits, high scores, a demo, and on a key press the main menu (`US_ControlPanel`), then `GameLoop`.
- **Temporary:** the `DemoLoop` attract loop shows title, credits and high scores (no demo yet). A key press quits, because the control panel isn't ported yet.

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

### 5. Main menu — next (`US_ControlPanel`, origsrc/WL_MENU.C, about 4000 lines)
- Input first: a `Keyboard()` scancode state array built from `_KeyDown`/`_KeyHit`, plus `IN_ReadControl`, `IN_Ack` and `IN_ClearKeysDown` (ID_IN.BM).
- Then the main menu and cursor, followed by the sub-menus: sound, control, view size, episode and difficulty select, quit. Load/save can wait.

### 6. The game (largest)
- Map loading: `CA_CacheMap` with Carmack and RLEW decompression.
- The VSWAP page manager (`PM_*`): walls, sprites, digitized sounds.
- The raycaster (`WL_DRAW`), sprite scaling (`WL_SCALE`) and status bar.
- The game loop (`WL_PLAY`), plus actors and player (`WL_ACT1`, `WL_ACT2`, `WL_STATE`, `WL_AGENT`).
- Demo playback (`PlayDemo`) comes last, since it depends on the game loop.

## Cross-cutting decisions
- **Back buffer:** before the menu or the game, draw into an offscreen 8-bit image and have `VW_UpdateScreen` copy it to the screen with `_PutImage` + `_Display`. That avoids tearing and gives `VW_UpdateScreen` its real job; it becomes required once the renderer exists.
- **`$Debug` in WOLF3D.BAS:** it makes the OPL2 emulator about 5x slower (2.7x realtime instead of 13.8x). Turn it off once the renderer starts.
- **Busy-wait loops:** replace the `Do: Loop Until InKey$ <> ""` loops (100% CPU) with `IN_Ack` (using `_Limit`) as each one gets ported.
