# Step 7: Spear of Destiny (plan, 2026-10-31)

Step 7 adds Spear of Destiny. It covers the retail game (`*.SOD`, 21 maps) and the demo (`*.SDM`, 2 maps), next to the existing Wolfenstein builds (`*.WL6`, and `*.WL1` v1.0). It also reworks how the four versions share the code.

## What the data and the C code give

Unlike the v1.0 shareware files, the Spear data fits the headers in `origsrc`:

| | SOD (Sep 1992) | SDM (Aug/Sep 1992) | WL6 (for comparison) |
|---|---|---|---|
| Graphics chunks | 169 = GFXV_SOD.H | 133 = GFXV_SDM.H | 149 |
| Sound chunks | 267 = AUDIOSOD.H (81 sounds) | 267, AUDIOSDM.H = AUDIOSOD.H | 288 |
| VSWAP: walls / sprites / sound pages | 134 / 421 / 111 | same counts | 106 / 436 / 121 |
| Digitized sounds | 40 | 40 | 46 |
| Maps | 21 (MAPSSOD.H) | 2 | 60 |
| Demos | T_DEMO0-3 | T_DEMO0 only | T_DEMO0-3 |

The sprite enum of WL_DEF.H with `SPEAR` defined has 421 entries, the same as the VSWAP files.

The C code builds each version with its own version header:
- SODVER.H: `SPEAR`, `CARMACIZED`.
- SDMVER.H: the same, plus `SPEARDEMO`.
- Neither defines `GOODTIMES`, so the retail build runs `CopyProtection`.

**The Spear-only C code:**

| Where | Lines | Contents |
|---|---|---|
| WL_ACT2.C 1174-1975 | ~800 | Trans Grosse, Übermutant, Wilhelm, Death Knight, Angel of Death, spectres; their states, missiles (`SPR_HROCKET`, sparks), `A_Victory`... |
| WL_INTER.C `EndSpear` | ~250 | the ending: BJ collapse, end screens, the id guys |
| WL_INTER.C `CopyProtection` | ~230 | the manual quiz of the retail version |
| WL_MENU.C | 60 `#ifdef`s | lump caching, new game without episodes, easter egg, Spear menu art |
| WL_INTER.C, WL_MAIN.C, WL_GAME.C, WL_AGENT.C, WL_ACT1.C, WL_PLAY.C, WL_DRAW.C, WL_STATE.C | ~100 `#ifdef`s | title, high scores, level end, secret floors, the spear pickup, statics, songs, ceilings |

**What the port has:**
- About 90 `$If SPEAR` blocks, copied from C but never compiled.
- The Spear digitized sound map.
- The Spear-only states as ids, without their routines.
- The `ID_HEADS.BI` includes for Spear, commented out.

About 20 WL6-only sound names and 13 picture names are used in shared code. The compiler will find them, and each one gets the `$If` that C has.

## Decisions to make first

1. **One build per version** (recommended), as the C code and the WL1 build do. Two new entry files:
   - `SPEAR.BAS` sets `$Let SPEAR`.
   - `SPEARDEMO.BAS` sets `$Let SPEAR` and `$Let SPEARDEMO`.

   Each includes WOLF3D.BAS, as WOLF1.BAS does. That gives four exes: WOLF3D, WOLF1, SPEAR, SPEARDEMO.

   *The alternative, one exe that picks the version at run time:* about 1,000 constants (pictures, sounds, sprites, lumps, map names) would become variables set at start-up, and every C `#ifdef SPEAR` would become a run-time `If`. That's a large rework, it moves away from the C code, and constants that size arrays or appear in `$If` can't become variables at all. Not recommended.
2. **Copy protection in SOD:** port `CopyProtection` and run it as the retail game did (recommended, it's ~230 lines). The alternative is a `GOODTIMES` build that skips it, as the C code allows; the plan can port it and still offer that switch.
3. **TEDLEVEL:** port the `TEDLEVEL n` parameter of ID_US_1.C / WL_MAIN.C, which starts straight in map n. It's how the original was tested, and it's the only practical way to reach the bosses of maps 4, 9, 15, 17 and 20 here (the debug keys aren't ported).
4. **Demo test switch:** make the demo check permanent, as a port debug option like `/mapview`, for example `WOLF3D.exe /demotest`. It plays the demos in real time and writes each one's end state (playstate, score, kills, health, frame) to a file. Until now it has been added by hand and removed again.

## Rework of the existing version support (7a)

1. **Header generator** `tools/gen_headers.py`. It writes `GFXV_*.BI`, `AUDIO*.BI` and `MAPS*.BI` from the `origsrc` headers for WL6, SOD and SDM, in the layout of the current files. It also writes `GFXV_WL1.BI` with the v1.0 fixes, which were produced by a throwaway script in the shareware step.
   - It replaces the hand-converted GFXV_WL6.BI, AUDIOWL6.BI and MAPSWL6.BI; the generated output is checked to give the same constants.
   - `AUDIOWL6.BI`'s v1.0 `NUMSOUNDS` override moves into the generator.
2. **`ID_HEADS.BI`** picks the headers as ID_HEADS.H does: SPEAR / SPEARDEMO / APOGEE_1_0 / default.
3. **Sprite numbers** come from a generator, `tools/gen_sprites.py`, reading WL_DEF.H. It writes `WL_SPR.BI` with the `#ifdef SPEAR` parts as `$If` blocks, and keeps the v1.0 shifts.
4. **Per-version tables** get their Spear parts, taken from C:
   - `vgaCeiling` (WL_DRAW.BI)
   - `songs[]` (WL_PLAY.BI)
   - `statinfo` (WL_ACT1.BI, partly done)
   - the high score defaults
   - `endStrings`
5. **`CheckForEpisodes`:** *.SOD / *.SDM, with the C messages ("NO SPEAR OF DESTINY DATA FILES TO BE FOUND!").
6. **`tools/ide_format.py` for all builds.** It merges and formats once per entry file (WOLF3D, WOLF1, SPEAR, SPEARDEMO). Then, for each line, it keeps the result from a build in which that line is compiled. The IDE keeps one output line per input line, so the lines match up.
   - Without this, the IDE only re-indents the Spear code and flattens its loop and `Case` bodies, as happened to the v1.0 blocks.
   - Lines no build compiles (JAPAN, SPANISH...) keep the current behaviour.

## Sub-steps

### 7a. Groundwork — DONE 2026-11-01
- Decisions 1, 3 and 4.
- The rework items above.
- Compile all four builds, with stubs for the Spear routines not ported yet, so SPEAR.BAS compiles from the start.
- **Result:** see the porting log. The SOD demos and the SDM demo already play to the end of their data: they only use the ported enemies.
- **Test:**
  - The WL6 demos give the 6j end states. Demo 1 must run in real time; see the shareware log entry.
  - WOLF1 still starts and plays.
  - SPEAR and SPEARDEMO compile and reach the sign-on screen.
  - The formatter is stable for all four builds.

### 7b. Start-up and screens — DONE 2026-11-01
- Title (`TITLE1PIC` / `TITLE2PIC` with `TITLEPALETTE`).
- The PG-13 and credits screens.
- High scores with the Spear backdrop lumps and font 1.
- The Spear `NonShareware` path.
- **Test:** the attract loop of SPEAR and SPEARDEMO up to the first demo.

### 7c. Menus — DONE (in 7a: the lump caching, new game, quit strings, high scores; in 7b: the easter egg)
- The Spear menu art: `BACKDROP_LUMP`, `CONTROL_LUMP`, `OPTIONS_LUMP`, `SOUND_LUMP`, `NEWGAME_LUMP`, `LOADSAVE_LUMP`.
- New game without episode selection.
- The I+D easter egg (`EASTEREGG_LUMP`).
- Spear music, and save/load to `SAVEGAM?.SOD`.
- **Test:** every menu screen in both Spear builds.

### 7d. Levels with the existing enemies
- `ScanInfoPlane` with the Spear objects and statics (the spear `bo_spear`, the new statics).
- The Spear ceilings and songs.
- `LevelCompleted` for Spear: floor names, and the secret floors 18 and 19 reached from maps 4 and 9 (WL_GAME.C 1388-1414).
- The map 20 key.
- The Spear `GetBonus` items: the spear (`GETSPEARSND`) and the ammo box.
- **Test:**
  - Tunnels 1 (SOD and SDM) plays: guards, SS, dogs, officers, doors, statics, pickups.
  - Then level end and the next map.
  - With TEDLEVEL, a secret floor.

### 7e. Spear enemies and bosses
- Port WL_ACT2.C 1174-1975: spawns, think and action routines, missiles.
- Add them to `tools/gen_states.py` (the `PORTED` list) and the state dispatcher.
- The Spear `A_DeathScream` cases.
- **Test:**
  - The SOD demos and the SDM demo play to the end of their data. There is no DOSBox-X reference for Spear here (only the data files, no SPEAR.EXE). A demo that ends right where its data ends, with no stuck movement, is strong evidence, as for the WL6 demos.
  - With TEDLEVEL, fight each boss: 4 Trans Grosse, 9 Wilhelm, 15 Übermutant, 17 Death Knight, 20 Angel of Death. Spectres are in the castle maps.

### 7f. The ending
- `EndSpear`: the Angel of Death's death, taking the spear, the end screens (`ENDSCREEN*`, `BJCOLLAPSE*`, `IDGUYS*`, `ENDPICPIC`) and the end music.
- The victory and high score entry.
- **Test:** with TEDLEVEL 20, beat the Angel and watch the whole ending.

### 7g. Copy protection (decision 2)
- `CopyProtection` (WL_INTER.C 1485-1716): the boss, staff and word questions with `COPYPROT_LUMP`, the three tries, the `COPYPRO_MUS` music, and the quit on failure.
- **Test:**
  - A wrong answer three times quits.
  - Right answers (from the C tables) start the game.

### 7h. The demo version (SPEARDEMO)
- The 2 maps.
- "Get Psyched!" skipped on map 1, and the end of the demo after map 1 (WL_GAME.C 1338, WL_INTER.C 906/924).
- One demo.
- No copy protection.
- The order screen.
- **Test:** play through both maps to the end-of-demo message.

## Risks

- **Name clashes:** new Spear names may clash with existing identifiers, since QB64 names are case-insensitive (see the memory notes). Each clash gets a renamed constant with the C name in a comment, as before.
- **Unverified C paths:** the Spear `$If` blocks copied earlier were never compiled. They may hold untranslated C and need checking line by line against the C code.
- **Build times:** four builds of 7-60 s each. The test runs build only what changed.
- **No reference for checking against:** no SPEAR.EXE in the source tree. Behaviour is checked against the C code, the demos, and what the screens show.

Each sub-step gets a porting log entry and is committed on its own branch when you say "commit".
