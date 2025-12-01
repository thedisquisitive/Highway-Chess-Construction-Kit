# Battering Ram - Setup Guide

Complete guide to implementing the Battering Ram custom piece.

---

## Overview

The **Battering Ram** is a powerful piece that can only move forward (no retreat!), attacking diagonally like a pawn but without special moves. Features complete animation handling for all game events.

---

## Quick Stats

| Property | Value |
|----------|-------|
| **Movement** | 1 square forward only |
| **Attack** | Diagonal forward (left/right) |
| **Special** | No retreat, no double-jump, no promotion |
| **Animations** | 8 states (default, move, attack, hitbycar, drowning, burning, death, captured) |

---

## Step 1: Create Sprites in Theme Studio

### Required Animation States

You need to create 8 animation states for the battering ram:

#### 1. **default** (Idle)
- **Purpose:** Standing still, waiting
- **Frames:** 1-4 (can be static or subtle breathing)
- **Loop:** Yes
- **Example:** Ram standing upright

#### 2. **move** (Moving Forward)
- **Purpose:** Walking/rolling forward
- **Frames:** 4-8
- **Loop:** Yes
- **Example:** Wheels turning, ram advancing

#### 3. **attack** (Special Attack)
- **Purpose:** **CRITICAL!** Smashing into enemy piece
- **Frames:** 6-12
- **Loop:** No (plays once)
- **Example:** Ram lunges forward, impact frame, recoil

#### 4. **hitbycar** (Vehicle Collision)
- **Purpose:** Hit by car hazard
- **Frames:** 4-8
- **Loop:** No
- **Example:** Impact, pieces flying, destruction

#### 5. **drowning** (Water Hazard)
- **Purpose:** Sinking in water
- **Frames:** 6-10
- **Loop:** No
- **Example:** Sinking, bubbles, disappear

#### 6. **burning** (Fire Hazard)
- **Purpose:** On fire
- **Frames:** 6-12
- **Loop:** Yes (until death)
- **Example:** Flames consuming ram, smoke

#### 7. **death** (Generic Death)
- **Purpose:** Explosions, traps, generic destruction
- **Frames:** 4-8
- **Loop:** No
- **Example:** Explosion, fragments, fade out

#### 8. **captured** (Captured by Enemy)
- **Purpose:** When enemy piece attacks this ram
- **Frames:** 4-6
- **Loop:** No
- **Example:** Breaking apart, defeated pose

---

## Step 2: Setup in Theme Studio

### Object Metadata

1. **File → Import PNG** (or draw your sprites)
2. **Metadata Tab:**
   - Object ID: `piece.battering_ram`
   - Label: `Battering Ram`
   - Category: `piece` ← **CRITICAL!**
   - Sprite Size: Your sprite dimensions (e.g., 128x128)

3. **Piece Settings** (appears when category = piece):
   - Movement Type: `custom` ← **CRITICAL!**
   - Piece Color: `white` or `black`

4. **Animation Tab:**
   - Check "Animated"
   - Set frames and FPS for each state
   - Create separate objects for each animation state OR use animation state field

### Creating Animation States

**Option A: Multiple Objects (Recommended)**
- Create 8 separate objects: `piece.battering_ram.default`, `piece.battering_ram.attack`, etc.
- Each has its own sprite strip
- Script switches between them

**Option B: Single Object with States**
- One object: `piece.battering_ram`
- Set animation state field for each export
- Theme Studio loads appropriate strip per state

---

## Step 3: Attach Script

### In Theme Studio:

1. Go to **Script Tab**
2. Copy the contents of `battering_ram.lua`
3. **Script File:** Leave blank (auto-named) or set to `battering_ram.lua`
4. **Export Object**

Script will be saved to: `themes/your_theme/scripts/battering_ram.lua`

### Verify objects.json:

```json
{
  "id": "piece.battering_ram",
  "label": "Battering Ram",
  "category": "piece",
  "sprite": "art/piece_battering_ram.png",
  "movementType": "custom",
  "pieceColor": "white",
  "script": "scripts/battering_ram.lua",
  "animation": {
    "spriteStrip": "art/piece_battering_ram_strip.png",
    "frameWidth": 128,
    "frameHeight": 128,
    "frameCount": 8,
    "fps": 8,
    "loop": true,
    "animState": "default"
  }
}
```

---

## Step 4: Test in Unity

### Place on Board

1. Load theme pack in Unity test scene
2. Spawn battering ram: `spawnObject("piece.battering_ram", 3, 1)`
3. Set initial position

### Test Movement

**Valid Moves (as White, starting at 3,1):**
- Forward: `(3, 2)` ✓
- Diagonal attack (if enemy at): `(2, 2)` or `(4, 2)` ✓
- Backward: `(3, 0)` ✗ BLOCKED
- Sideways: `(2, 1)` or `(4, 1)` ✗ BLOCKED

**Valid Moves (as Black, starting at 3,6):**
- Forward: `(3, 5)` ✓
- Diagonal attack (if enemy at): `(2, 5)` or `(4, 5)` ✓
- Backward: `(3, 7)` ✗ BLOCKED
- Sideways: `(2, 6)` or `(4, 6)` ✗ BLOCKED

### Test Hazards

Spawn hazards and move ram into them:

```lua
-- Test car collision
spawnObject("hazard.car", 3, 2)
-- Move ram to (3,2) → "hitbycar" animation + destruction

-- Test water
spawnObject("hazard.water", 3, 2)
-- Move ram to (3,2) → "drowning" animation + destruction

-- Test fire
spawnObject("hazard.fire", 3, 2)
-- Move ram to (3,2) → "burning" animation + destruction
```

### Test Attack

```lua
-- Spawn enemy piece
spawnObject("piece.knight", 2, 2, "black")

-- Move white battering ram from (3,1) to (2,2)
-- → "attack" animation plays
-- → Target plays "captured" animation
-- → Enemy destroyed
```

---

## Movement Behavior Details

### Forward Movement
- Can move **1 square forward only**
- Cannot move backward (EVER!)
- Cannot move sideways
- Cannot jump over pieces
- Direction based on piece color:
  - White: Up (+Y direction)
  - Black: Down (-Y direction)

### Diagonal Attack
- Can attack **diagonally forward** (left or right)
- Must have enemy piece at target
- Cannot attack friendly pieces
- Cannot attack empty squares diagonally
- Plays special **attack** animation

---

## Animation Triggers

| Event | Animation | Sound | Effect | Duration |
|-------|-----------|-------|--------|----------|
| **Moving** | `move` | - | - | Instant |
| **Attacking** | `attack` | `battering_ram_smash` | `impact` | 0.5s |
| **Hit by Car** | `hitbycar` | `car_crash` | `explosion` | 1.0s |
| **Drowning** | `drowning` | `splash` | `water_splash` | 1.5s |
| **Burning** | `burning` | `fire_roar` | `flames` | 1.5s |
| **Explosion** | `death` | `explosion` | `explosion` | 0.8s |
| **Being Captured** | `captured` | - | - | Applied to target |

---

## Sound Effects Needed

Create/assign these sound IDs in your theme:

- `battering_ram_smash` - Attack sound (heavy impact)
- `car_crash` - Vehicle collision
- `splash` - Water entry
- `fire_roar` - Fire burning
- `explosion` - Generic explosion
- `hurt` - Generic damage

---

## Visual Effects Needed

Create/assign these effect IDs:

- `impact` - Attack impact effect
- `explosion` - Explosion burst
- `water_splash` - Water splash
- `flames` - Fire effect
- `piece_vanish` - Generic piece removal

---

## Customization Ideas

### Make It Stronger
```lua
-- Allow 2 squares forward
if math.abs(dx) == 0 and math.abs(dy) <= 2 * self.forwardDir then
    -- Check path is clear
    return true
end
```

### Add Knockback
```lua
-- When attacking, push enemy back 1 square
function onMove(fromX, fromY, toX, toY)
    -- ... existing attack code ...
    
    -- Knockback
    local knockbackX = toX + (toX - fromX)
    local knockbackY = toY + (toY - fromY)
    if isInBounds(knockbackX, knockbackY) then
        moveObject(toX, toY, knockbackX, knockbackY)
    end
end
```

### Unstoppable Ram
```lua
-- Ram can break through obstacles
function onCollision(other)
    if other.category == "prop" then
        destroyObject(other.x, other.y)
        playSound("wood_break")
    end
end
```

---

## Troubleshooting

**Problem:** Piece won't move
- Check `movementType = "custom"` in objects.json
- Verify script is attached correctly
- Check console for Lua errors

**Problem:** Animations don't play
- Verify all 8 animation states exist
- Check `animState` names match exactly
- Ensure `setAnimationState()` is implemented in Unity

**Problem:** Can move backward
- Check `self.forwardDir` is set correctly in `onInit()`
- Verify `dy == self.forwardDir` check in `onMove()`

**Problem:** Can attack friendly pieces
- Check `targetPiece.pieceColor ~= self.pieceColor` comparison
- Ensure piece color is set correctly

---

## Complete File Checklist

- [ ] `battering_ram.lua` script file
- [ ] 8 animation sprite strips (or 8 separate sprites)
- [ ] objects.json entry with `movementType: "custom"`
- [ ] Sound effects assigned
- [ ] Visual effects created
- [ ] Tested in Unity

---
