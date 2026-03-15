# AquaTubes - Project Documentation

## Project Overview

**AquaTubes** is a pipe puzzle game built with the **Defold game engine**. Players must arrange rotating pipe tiles on an isometric grid to connect water flow from a source (tank) to a destination.

- **Game Type:** Puzzle game with isometric 30-degree perspective
- **Structure:** 6 worlds × 20 levels each (120 total levels)
- **Display:** 600×900 pixels (mobile-friendly)
- **Grid Size:** 9×9 tiles for gameplay, 20×20 for level editor
- **Tile System:** 40+ unique pipe sprites with configurable rotation/placement

---

## Game Mechanics

### Core Gameplay
1. **Isometric Grid System:** Uses a 30-degree perspective for visual depth
   - Grid coordinates: (x, y) with z-depth for layering
   - Tile width: 100px, Height: ~57.7px (calculated using tan(30°))
   
2. **Pipe System:**
   - Each pipe has a type ID (1-111, with special ranges: 1-13, 30-39, 101-111)
   - Fixed pipes (t > 20): Non-random starting positions
   - Random pipes (t < 12): Scrambled at level start
   - Pipes can be placed and rotated to solve the puzzle

3. **Level Completion:**
   - Player must match exact pipe type in exact position
   - Function: `check_level_completed()` validates board against solution
   - Errors counted: wrong type or missing pipes = failure

4. **Visual Animations:**
   - Pipes drop from above with gravity and bounce effect
   - Bounce sequence: fall → bounce up → settle
   - Each pipe has ~0.1s stagger delay for cascade effect
   - Sound effects on placement and completion

---

## Architecture & Key Systems

### 1. Configuration System (`scripts/config.lua`)
Central configuration hub for all game parameters:

```lua
C.SCREEN_WIDTH = 600
C.SCREEN_HEIGHT = 900
C.GRID_WIDTH = 9          -- Gameplay grid
C.GRID_HEIGHT = 9
C.GRID_WIDTH_EDIT = 20    -- Editor grid
C.GRID_HEIGHT_EDIT = 20
C.TILE_WIDTH = 100
C.TILE_HEIGHT = 58        -- Calculated: 100/sqrt(3)
C.ORIGIN_X, C.ORIGIN_Y    -- Grid center position (calculated)
C.BANNED_CELLS_SET        -- 12 cells forbidden for pipe placement (corners/edges)
C.WORLD_COUNT = 6
C.LEVEL_COUNT = 20
C.STARTING_PIPES_RIGHT_SIDE -- List of pipe types that flow from right
```

**Key Functions:**
- `calculate_iso_height_for_30_degrees(tile_width)` - Calculates proper isometric height
- `calculate_iso_height_rounded(tile_width)` - Rounded version for pixel-perfect alignment

### 2. Manager System (`scripts/manager.lua`)
Global game state and scene management:

```lua
M.sound_on                 -- Audio toggle state
M.current_world = 1        -- Currently selected world
M.current_level = 1        -- Currently selected level
M.SCENES = {MENU, LEVELS, LEVEL}
M.current_scene            -- Active scene
M.progress = {worlds = {}} -- Per-world completion tracking: {[world_num] = levels_completed}
```

**Responsibilities:**
- Tracks game state across scenes
- Manages sound toggle and scene transitions
- Persists player progress (can save/load)

### 3. Coordinate System (`scripts/basics.lua`)
Handles conversion between screen space, isometric space, and world space:

**Key Functions:**
- `iso_to_world(iso_x, iso_y, z)` - Converts grid coordinates to screen pixels
- `screen_to_iso(screen_x, screen_y)` - Converts mouse input to grid coordinates (gameplay)
- `screen_to_iso_edit(screen_x, screen_y)` - Same but for 20×20 editor grid
- `get_z_for_cell(iso_x, iso_y)` - Returns z-depth for proper layering (back-to-front)

**Algorithm:** Uses diamond/rhombus distortion matrix for 30° isometric projection

### 4. Pipe Management (`scripts/basics.lua`)
Handles pipe creation, placement, and animation:

**Functions:**
- `place_pipe(t, iso_x, iso_y)` - Instantly places pipe at grid position
- `bounce_pipe(t, iso_x, iso_y, delay)` - Creates pipe with drop/bounce animation
  - Falls from 800px above
  - Bounces with decreasing amplitude
  - Plays "clac" sound on landing
- `place_random_pipes(level_table)` - Randomizes pipe positions (except fixed ones)
- `get_random_pipes(level_table)` - Generates randomized layout respecting banned cells
- `delete_all_pipes(board_table)` - Clears the board

**Factory System:**
- Uses Defold factories: `#pipe_{t}_factory` for each type
- Sprites: `sprites/pipes/pipe_{t}.go` (game objects)

### 5. Grid & Utility (`scripts/grid.lua`, `scripts/basics.lua`)
Helper functions:

**Grid:**
- `draw_grid()` - Visualizes isometric grid (debug)
- `draw_tile(x, y)` - Draws single diamond tile outline

**Utilities:**
- `get_cell_by_coords(table, x, y)` - Finds pipe at position
- `delete_cell_by_coords(table, x, y)` - Removes pipe from list
- `get_random_number(min, max)` - RNG with bounds

---

## File Structure Map

### Scenes (Collections)
```
main/main.collection          -- Bootstrap, initializes game
menu/                          -- Main menu scene
├── menu.collection
├── menu.gui
└── menu.gui_script

level_selector/                -- World & level selection
├── level_selector.collection
├── level_selector.gui
└── level_selector.gui_script

level/                          -- Main gameplay scene
├── level.collection
├── level.gui
├── level.gui_script
└── level.script (main logic)

level_editor/                  -- Level design tool
├── level_editor.collection
├── level_editor.gui
├── level_editor.gui_script
└── level_editor.script
```

### Scripts
```
scripts/
├── config.lua                 -- Global constants & configuration
├── manager.lua                -- Game state & scene management
├── basics.lua                 -- Core utilities (coordinates, pipes, validation)
├── grid.lua                   -- Isometric grid rendering
├── levels.lua                 -- Level data definitions (generated or loaded)
├── progress_manager.script    -- Defold script for persistence

input/
└── game.input_binding         -- Input mappings (mouse, keyboard, touch)
```

### Assets
```
assets/
├── img/
│   ├── pipes/               -- 40+ pipe sprite PNGs (pipe_1-13, 30-39, 101-111)
│   ├── confetti/            -- 3 celebration particle sprites
│   ├── ui/                  -- UI buttons and icons (13 images)
│   ├── background.png       -- Main background
│   ├── foreground.png       -- Overlay elements
│   ├── tank.png             -- Water tank sprite
│   ├── frame_*.png          -- UI frame borders
│   └── grid_marker.png
│
├── sound/
│   ├── theme_1.ogg, theme_2.ogg    -- Background music (looping)
│   ├── clac_1.ogg, clac_2.ogg, clac_3.ogg -- Pipe placement sounds
│   ├── pick.ogg             -- Selection sound
│   ├── enter.ogg            -- Menu selection
│   ├── block.ogg            -- Invalid action
│   └── win.ogg              -- Level completion
│
└── fonts/
    ├── arcade.font          -- Retro bitmap font (Press Start 2P)
    ├── text48.font          -- Standard font
    └── PressStart2P-vaV7.ttf
```

### Sprites (Game Objects)
```
sprites/
├── pipes/pipe_{t}.go        -- 40+ pipe game objects (type ID = t)
├── scenario/
│   ├── background.go
│   ├── background_tile.go
│   ├── background_menu.go
│   ├── foreground.go
│   ├── frame.sprite
│   ├── tank.go             -- Water source
│   ├── done.go             -- Completion marker
│   ├── hover_tile.go       -- Mouse highlight
│   └── tanque.go
│
├── *.atlas                  -- Image atlas files for optimization
│   ├── sprites.atlas
│   ├── pipes.atlas
│   ├── ui.atlas
│   └── confetti.atlas
│
└── confetti/
    ├── confetti.go
    ├── confetti.particlefx -- Particle effect definition
    └── confetti.script

main.script                   -- Entry point, scene manager, theme music
```

### Level Data
```
levels/
├── world_1.lua              -- Level definitions for world 1
├── world_2.lua
├── world_3.lua
├── world_4.lua
├── world_5.lua
└── world_6.lua

Format: Each file returns a Lua table of levels
Example: { [1] = {{x=1, y=2, t=5}, {x=3, y=4, t=7}, ...}, [2] = {...}, ... }
```

---

## Level Data Structure

Each level is defined as a table of pipe definitions:

```lua
{
  {x=0, y=4, t=30},      -- Pipe type 30 at grid position (0,4) - FIXED
  {x=4, y=0, t=7},       -- Pipe type 7 at (4,0) - RANDOM (t < 12)
  {x=8, y=4, t=102},     -- Pipe type 102 at (8,4) - FIXED (t > 20)
  {x=4, y=8, t=9},       -- Pipe type 9 - RANDOM
}
```

**Pipe Types:**
- **1-13:** Standard pipes (corners, T-junctions, straights)
- **30-39:** Variants/alternates
- **101-111:** Special pipes (endpoints, tanks, flow control)

**Position Rules:**
- **t < 12:** Random position (scrambled each level start)
- **t > 20:** Fixed position (doesn't randomize)
- **Others:** Maintain original position

---

## Key Scenes & Message System

### Main Entry Point (`main/main.script`)
```lua
init()
  ├── Load input focus
  ├── Play theme music
  └── Load initial scene (menu or level_editor)

on_message()
  ├── proxy_loaded → Enable scene
  ├── change_scene → Switch between menu/levels/level
  ├── sound_toggle → Mute/unmute
  └── theme_play/stop → Music control
```

### Level Scene (`level/level.script`)
**Responsibilities:**
- Handle mouse input (click pipes)
- Validate and rotate clicked pipes
- Check level completion
- Show completion UI
- Persist progress to manager

**Message Handlers:**
- `on_input()` - Process mouse clicks, convert screen→iso
- `load/unload` - Initialize/cleanup level
- Custom messages for pipe interactions

---

## Banned Cells

12 cells are permanently forbidden for pipe placement (prevents clutter at corners):

```
Top-left corner: (0,6), (0,7), (0,8), (1,7), (1,8), (2,8)
Top-right corner: (6,0), (7,0), (7,1), (8,0), (8,1), (8,2)
```

These cells are pre-loaded in `C.BANNED_CELLS_SET` during randomization.

---

## Defold Engine Details

- **Version:** Defold (free open-source engine)
- **Platform:** Web (HTML5), iOS, Android
- **Language:** Lua (game logic) + Defold script format
- **Build System:** `game.project` - Bootstrap: `/main/main.collectionc`

**Resource Limits (from game.project):**
- Max collections: 80
- Max factories: 1000
- Max sprites: 1000
- Max particles: 1024 emitters

---

## Quick Reference: Important Constants

| Constant | Value | Usage |
|----------|-------|-------|
| `SCREEN_WIDTH` | 600 | Display width |
| `SCREEN_HEIGHT` | 900 | Display height |
| `GRID_WIDTH` | 9 | Gameplay grid width |
| `GRID_HEIGHT` | 9 | Gameplay grid height |
| `TILE_WIDTH` | 100 | Isometric tile width (px) |
| `TILE_HEIGHT` | 58 | Isometric tile height (px) |
| `WORLD_COUNT` | 6 | Number of worlds |
| `LEVEL_COUNT` | 20 | Levels per world |

---

## Future Development Notes

- **EDIT_MODE flag** in `main/main.script` allows loading level editor
- **Sound toggle** persists during gameplay (`M.sound_on`)
- **Progress persistence** uses `M.progress.worlds` table (can be extended for save/load)
- **Coordinate system** is fully isometric-aware and can support larger grids (editor uses 20×20)
- **Pipe types 1-13** are the main gameplay pipes; 30+ are variants
- **Animation system** uses Defold's `go.animate()` for smooth transitions

---

**Document Version:** 1.0  
**Last Updated:** 2026-03-14  
**Project:** AquaTubes (Defold Game)
