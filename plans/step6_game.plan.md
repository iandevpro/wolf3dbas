# Step 6: the game (plan, 2026-10-27)

Step 6 ports the game itself: from "New Game" in the menu to walking, fighting and finishing levels, plus the demos in the attract loop. The original code involved is about 20,000 lines of C and assembly:

| Module | Lines | Contents |
|---|---|---|
| WL_ACT2.C | 3872 | enemy state tables, enemies, bosses, projectiles |
| ID_CA.C (rest) | | `CA_CacheMap` |
| ID_PM.C | 1199 | VSWAP page manager |
| WL_DRAW.C + WL_DR_A.ASM | 1403 + 739 | raycaster |
| WL_SCALE.C | 733 | wall and sprite scaling |
| WL_PLAY.C | 1472 | game loop, controls, object list, palette flashes |
| WL_GAME.C | 1484 | level setup, play screen, `GameLoop`, demos |
| WL_AGENT.C | 1421 | player, weapons, status bar |
| WL_STATE.C | 1480 | actor movement, sight, damage |
| WL_ACT1.C | 900 | static objects, doors, push walls |
| WL_INTER.C (rest) | | intermission, victory, high score entry |
| WL_MAIN.C (rest) | | config, save/load, digitized sound map |

Each sub-step below ends with something visible to test against the original in DOSBox-X, and gets a porting log entry.

## Decisions to make first

1. **Replace the early drafts.** `WL_GAME.BM` (except `DrawPlayBorder`), `WL_RENDER.BAS`, `WL_GRAPH.BAS`, `WL_INPUT.BAS` / `WL_INPUT.BI`, and the invented types in `WL_DEF.BI` (`GameStateType`, `ActorType`, `WallType`, `DoorType`, `walls()`, ...) don't follow the original code. Replace them with ports of the WL_DEF.H structures; the old files stay in git history.
2. **Display model.** Switch to manual display: `VW_UpdateScreen` calls `_Display`, which is its real job in the original (show the finished frame). Without it, QB64's automatic display can show half-drawn 3D frames.
   - Every ported screen already calls `VW_UpdateScreen`.
   - Palette changes (fades, flashes) also need a `_Display`.
   - The signon and intro screens, which don't call `VW_UpdateScreen`, need one added.
3. **Speed.**
   - Remove `$Debug` from WOLF3D.BAS before the raycaster; it makes compiled code about 5x slower.
   - Put `$Checking:Off` around the hot loops (ray casting, column scaling, sprite drawing), as already done in OPL2.BM.
4. **Pointers become indices.**
   - The object list (`objlist`, with `new`, `obj`, `player`, `lastobj`), `statobjlist` and `doorobjlist` become arrays with index links.
   - `actorat[x][y]` keeps the C meaning (0 = empty, 1-255 = wall tile, otherwise an object) by storing objects as `OBJ_BASE + index`.
   - States (`statetype`, ~900 of them in WL_ACT2.C) become a table with the next state as an index, and `think` / `action` as routine IDs dispatched by `Select Case`, as done for the menus.
5. **Exact integer math.**
   - Positions are 16.16 fixed point (`Long`). Multiplications go through `_Integer64` (`FixedByFrac`).
   - C `unsigned` / `word` arithmetic that wraps gets `And &HFFFF`.
   - Shifts of negative values use floor division, not `_SHR`.
   - This matters most for the demos, which only play back correctly if the game logic gives exactly the original results.

## Sub-steps

### 6a. Groundwork — DONE 2026-10-28
- Make decisions 1-3 above.
- Port the WL_DEF.H game structures and constants: `objtype`, `statobj_t`, `doorobj_t`, `gametype`, `statetype`, the enums (`classtype`, `activetype`, `dirtype`, `exit_t`, weapons, sprite numbers `SPR_*`), and `MAPSWL6.BI` from MAPSWL6.H.
- Add the fixed-point helpers.
- **Test:** title, menus, help and fades all still look and behave as now.

### 6b. Map and VSWAP data — DONE 2026-10-28
- `CA_CacheMap` (ID_CA.C) with `CAL_CarmackExpand` and `CA_RLEWexpand`; map headers and names from MAPHEAD.WL6 / GAMEMAPS.WL6.
- `PM_Startup` / `PM_GetPage` (ID_PM.C): load VSWAP.WL6 (1.5 MB) into one `_MEM` block. That gives the page offset table, the wall pages (64x64, stored in columns), the sprite pages (`t_compshape`) and the digitized sound pages, with no paging needed.
- **Test:** a temporary debug view that draws E1M1's wall plane from above, and shows wall and sprite pages on screen. Compare map names ("Wolf1 Map1"...) and tile counts with what the files contain.

### 6c. Play screen and level setup — DONE 2026-10-28
- `GameLoop` skeleton.
- `DrawPlayScreen` with the status bar: `LatchDrawPic` (latches were pictures preloaded into video memory, here they are cached pictures), `DrawFace`, `DrawHealth`, `DrawLives`, `DrawLevel`, `DrawAmmo`, `DrawKeys`, `DrawWeapon`, `DrawScore`.
- `SetupGameLevel`: `tilemap`, `actorat`, doors, `ScanInfoPlane` (player start and static objects first; enemies are spawned but stay inactive).
- `PreloadGraphics` ("Get Psyched!") and `StartMusic` for the level.
- Replace the temporary block in `DemoLoop` with the real `GameLoop` call.
- **Test:** New Game shows "Get Psyched!", then the border and status bar with the level music, as in DOSBox-X.

### 6d. Raycaster and player movement — DONE 2026-10-28 (mouse motion and demo input still TODO)
- WL_DRAW: `ThreeDRefresh`, `WallRefresh`, the ray caster (`AsmRefresh` from WL_DR_A.ASM, ported to QB64 using the C `Hit*` routines next to it), `ScalePost` wall columns, floor and ceiling colors, `CalcTics`.
- Scaling: the original generated machine code per wall height (`SetupScaling`). Replace it with plain column loops over precomputed step tables.
- WL_PLAY / WL_AGENT movement: `PlayLoop`, `PollControls` (keyboard, mouse buttons, mouse motion), `ControlMovement`, `Thrust`, `ClipMove`, `CheckKeys` (Esc opens the menu with "Back to Game").
- **Test:** walk around E1M1. The views should match DOSBox-X from the same spots, and walking speed should match. Check the frame rate.

### 6e. Sprites, items and weapons on screen — DONE 2026-10-28
- WL_SCALE `ScaleShape` and `SimpleScaleShape`; WL_DRAW `DrawScaleds` (visible statics and actors, `spotvis`) and `DrawPlayerWeapon`.
- WL_ACT1 statics (`SpawnStatic`, `PlaceItemType`); WL_AGENT `GetBonus` and the status bar updates; `StartBonusFlash` / palette shifts.
- **Test:** see lamps, tables and items in E1M1; picking up food, ammo and treasure updates the status bar and flashes.

### 6f. Doors, push walls and level exit — DONE 2026-10-28
- WL_ACT1 doors (`OpenDoor`, `CloseDoor`, `MoveDoors`, area connection) and push walls; WL_AGENT `Cmd_Use`.
- The elevator switch; WL_INTER `LevelCompleted` (intermission with ratios and bonus), the next level, the secret level.
- **Test:** open doors, find a secret wall, finish E1M1 and see the intermission, start E1M2.

### 6g. Enemies and combat — DONE 2026-10-29
- WL_STATE: `SpawnNewObj`, `NewState`, `TryWalk`, `SelectChaseDir`, `MoveObj`, `CheckLine`, `SightPlayer`, `DamageActor`, `KillActor`.
- WL_ACT2 states and routines for guards, officers, SS, dogs and mutants.
- WL_AGENT weapons (`KnifeAttack`, `GunAttack`, weapon frames); player damage (`TakeDamage`, `StartDamageFlash`), `Died`, game over and `CheckHighScore` (name entry with `US_LineInput`).
- **Test:** fight through E1M1 against DOSBox-X: enemy reactions, sounds, damage, death and game over.

### 6h. Bosses and the rest of WL_ACT2 — DONE 2026-10-29 (WL6; the Spear actors are not ported)
- Bosses and their projectiles (Hans, Schabbs and syringes, Hitler and the mech, Otto, Gretel, General Fettgesicht), ghosts, fake Hitler.
- `Victory` and `EndText` (end articles, already ported in 5c) after the episode boss.
- **Test:** boss levels of each episode (using save games or a debug warp).

### 6i. Digitized sounds — DONE 2026-10-30
- `InitDigiMap` / `DigiMap` (WL_MAIN.C), sounds from the VSWAP sound pages, `SD_PlayDigitized` mixed into `SD_PumpAudio` (8-bit samples at about 7 kHz, resampled), positional left/right volume (`PlaySoundLocTile`, `UpdateSoundLoc`).
- Enable the digitized sound rows in the Sound menu (Sound Blaster).
- **Test:** guard shouts, doors and guns sound like DOSBox-X with a Sound Blaster.

### 6j. Demos — DONE 2026-10-30 (RecordDemo not ported)
- The original 256-entry random table for `US_RndT` (ID_US_A.ASM). `PlayDemo` with the `T_DEMO0..3` chunks, demo input in `IN_ReadControl`; `RecordDemo` is optional.
- Remove the temporary `VW_FadeOut` from the attract loop.
- **Test:** the attract loop plays the 4 demos, and each one plays out the same as in DOSBox-X (a wrong integer result makes the demo drift).

### 6k. Config, save and load, in-game keys — DONE 2026-10-30 (WL_DEBUG keys not ported; DOS save games can't be loaded)
- `ReadConfig` / `WriteConfig` (CONFIG.WL6: scores, sound, controls, view size); this also replaces the defaults set in `InitGame`, `IN_Startup` and ID_US.BI.
- `SaveTheGame` / `LoadTheGame` (replace the 5c stubs), quick save and load (F8/F9), `CP_CheckQuick` (F7 end game, F10 quit), `CP_EndGame`, pause.
- Optional: WL_DEBUG keys (Tab + letters with the "goobers" parameter) for testing.
- **Test:** settings and high scores survive a restart; save in E1M1, quit, load and continue. Check whether a save made by the original DOS game loads too (the file layout would need to match exactly).

## Risks
- **Speed:** QB64 per-pixel `_MemPut` in the column loops. Fallback: build each column in a QB64 array and copy it with `_MemCopy`, or write whole rows.
- **Demo determinism (6j):** needs bit-exact integer behaviour everywhere in the game logic. It is the strictest test of the whole port, so expect fixes in earlier modules.
- **Code size:** WL_ACT2.C alone is ~3900 lines of mostly data (state tables). It's mechanical but long; it may help to generate the state table from the C source with a script.
