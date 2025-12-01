# 🖤 Highway Chess - Lua Scripting API Reference 🖤

Complete guide to scripting custom behaviors for theme objects.

---

## Table of Contents

1. [Overview](#overview)
2. [Object Lifecycle Events](#object-lifecycle-events)
3. [Movement System](#movement-system)
4. [Built-in Functions](#built-in-functions)
5. [Object Properties](#object-properties)
6. [Board Query Functions](#board-query-functions)
7. [Animation Control](#animation-control)
8. [Examples](#examples)

---

## Overview

Every theme object (tile, hazard, piece, prop) can have a Lua script that defines its behavior. Scripts are executed by the Unity game engine using MoonSharp.

**Script Location:** `themes/your_theme/scripts/your_script.lua`

**Assigned To Objects Via:**
- `objects.json`: `"script": "scripts/car_movement.lua"`
- Theme Studio: Script tab

---

## Object Lifecycle Events

These functions are automatically called by the game engine at specific times.

### `onInit()`

Called once when the object is spawned/placed on the board.

**Use For:** Initial setup, variable initialization, state setup

```lua
function onInit()
    print("Object initialized at position: " .. self.x .. ", " .. self.y)
    self.speed = 2.0
    self.direction = 1
end
```

---

### `onUpdate(dt)`

Called every frame while the object exists.

**Parameters:**
- `dt` (number) - Delta time since last frame (in seconds)

**Use For:** Movement, animation, timers, game logic

```lua
function onUpdate(dt)
    -- Move right at 2 units per second
    self.x = self.x + (2.0 * dt)
    
    -- Check boundaries
    if self.x > 8 then
        self.x = 0  -- Wrap around
    end
end
```

---

### `onCollision(other)`

Called when this object collides with another object.

**Parameters:**
- `other` (table) - The other object involved in collision
  - `other.id` - Object's theme ID
  - `other.category` - "tile", "hazard", "piece", "prop", "ui"
  - `other.x`, `other.y` - Position
  - `other.pieceColor` - For pieces: "white", "black", "neutral"

**Use For:** Damage, triggers, interactions

```lua
function onCollision(other)
    if other.category == "piece" then
        print("Hit a " .. other.pieceColor .. " piece!")
        destroyPiece(other)
    end
end
```

---

### `onDestroy()`

Called when the object is removed from the board.

**Use For:** Cleanup, spawn effects, final actions

```lua
function onDestroy()
    print("Object destroyed!")
    spawnEffect("explosion", self.x, self.y)
end
```

---

## Movement System

For objects with category `"piece"`, movement can be customized.

### Predefined Movement Types

Set in `objects.json` via `"movementType"`:

| Type | Pattern | Description |
|------|---------|-------------|
| `"knight"` | L-shape | 2 squares + 1 perpendicular |
| `"rook"` | Lines | Horizontal/vertical unlimited |
| `"bishop"` | Diagonals | Diagonal unlimited |
| `"queen"` | Lines + Diagonals | Rook + Bishop combined |
| `"king"` | 1 Square | Any direction, 1 square |
| `"pawn"` | Forward | 1-2 forward, diagonal capture |
| `"custom"` | Script-defined | Use `onMove()` function |

---

### `onMove(fromX, fromY, toX, toY)`

**Only called for pieces with `movementType = "custom"`**

Called when the player attempts to move this piece.

**Parameters:**
- `fromX`, `fromY` (int) - Current position
- `toX`, `toY` (int) - Target position

**Returns:**
- `true` - Allow the move
- `false` - Reject the move
- `table` - List of valid target positions: `{ {x=2, y=3}, {x=4, y=5} }`

**Use For:** Custom movement patterns, teleportation, special abilities

```lua
-- Example: Teleporting Knight (can teleport to any square)
function onMove(fromX, fromY, toX, toY)
    local distance = math.abs(toX - fromX) + math.abs(toY - fromY)
    
    if distance <= 3 then
        return true  -- Allow teleport within 3 squares
    else
        return false  -- Too far
    end
end
```

```lua
-- Example: Return valid move list
function onMove(fromX, fromY, toX, toY)
    -- Only allow moving to corners
    local validMoves = {
        {x = 0, y = 0},
        {x = 7, y = 0},
        {x = 0, y = 7},
        {x = 7, y = 7}
    }
    return validMoves
end
```

---

### `getValidMoves(x, y)`

**Optional function** - Called to highlight valid moves for this piece.

**Parameters:**
- `x`, `y` (int) - Current position

**Returns:**
- `table` - List of valid positions: `{ {x=2, y=3}, {x=4, y=5} }`

**Use For:** Custom movement highlighting, context-aware moves

```lua
function getValidMoves(x, y)
    local moves = {}
    
    -- Cross pattern (+ shape)
    table.insert(moves, {x = x+1, y = y})
    table.insert(moves, {x = x-1, y = y})
    table.insert(moves, {x = x, y = y+1})
    table.insert(moves, {x = x, y = y-1})
    
    return moves
end
```

---

## Built-in Functions

These functions are provided by the game engine and available in all scripts.

### Board Queries

#### `getTile(x, y)`

Get the tile at a specific position.

**Returns:** `table` or `nil`
- `tile.id` - Theme object ID
- `tile.category` - Object category
- `tile.walkable` - If pieces can move through

```lua
local tile = getTile(3, 4)
if tile and tile.category == "hazard" then
    print("Danger ahead!")
end
```

---

#### `getPiece(x, y)`

Get the piece at a specific position.

**Returns:** `table` or `nil`
- `piece.id` - Theme object ID
- `piece.pieceColor` - "white", "black", "neutral"
- `piece.movementType` - Movement pattern

```lua
local piece = getPiece(5, 5)
if piece and piece.pieceColor == "white" then
    print("White piece found!")
end
```

---

#### `isInBounds(x, y)`

Check if coordinates are within the board.

**Returns:** `boolean`

```lua
if isInBounds(10, 10) then
    print("Valid position")
else
    print("Out of bounds!")
end
```

---

#### `getBoardSize()`

Get current board dimensions.

**Returns:** `width, height` (int, int)

```lua
local w, h = getBoardSize()
print("Board is " .. w .. "x" .. h)
```

---

### Object Manipulation

#### `spawnObject(objectId, x, y)`

Spawn a new object on the board.

**Parameters:**
- `objectId` (string) - Theme object ID (e.g., "hazard.fire")
- `x`, `y` (int) - Position

```lua
-- Spawn fire at position
spawnObject("hazard.fire", 3, 3)
```

---

#### `destroyObject(x, y)`

Destroy an object at a position.

**Parameters:**
- `x`, `y` (int) - Position

```lua
destroyObject(4, 4)  -- Remove object at (4,4)
```

---

#### `moveObject(fromX, fromY, toX, toY)`

Move an object from one position to another.

**Parameters:**
- `fromX`, `fromY` (int) - Current position
- `toX`, `toY` (int) - Target position

**Returns:** `boolean` - Success

```lua
if moveObject(2, 2, 3, 3) then
    print("Object moved!")
end
```

---

#### `destroyPiece(piece)`

Destroy a specific piece (from collision).

**Parameters:**
- `piece` (table) - Piece object from `onCollision(other)`

```lua
function onCollision(other)
    if other.category == "piece" then
        destroyPiece(other)  -- Kill the piece
    end
end
```

---

### Effects & Feedback

#### `playSound(soundId)`

Play a sound effect.

**Parameters:**
- `soundId` (string) - Sound ID from theme

```lua
playSound("car_honk")
```

---

#### `spawnEffect(effectId, x, y)`

Spawn a visual effect.

**Parameters:**
- `effectId` (string) - Effect ID from theme
- `x`, `y` (number) - World position

```lua
spawnEffect("explosion", self.x, self.y)
```

---

#### `showMessage(text, duration)`

Display a message to the player.

**Parameters:**
- `text` (string) - Message text
- `duration` (number) - Seconds to display (optional, default 2.0)

```lua
showMessage("You stepped on a trap!", 3.0)
```

---

## Object Properties

Access properties of `self` (the current object).

### Available Properties

| Property | Type | Description |
|----------|------|-------------|
| `self.id` | string | Theme object ID |
| `self.category` | string | "tile", "hazard", "piece", "prop", "ui" |
| `self.x` | number | X position (can be modified) |
| `self.y` | number | Y position (can be modified) |
| `self.movementType` | string | Movement pattern (pieces only) |
| `self.pieceColor` | string | "white", "black", "neutral" (pieces only) |
| `self.animState` | string | Current animation state |

### Custom Properties

You can add your own properties:

```lua
function onInit()
    self.speed = 3.0
    self.health = 100
    self.isActive = true
end

function onUpdate(dt)
    if self.isActive then
        self.x = self.x + (self.speed * dt)
    end
end
```

---

## Animation Control

### `setAnimationState(state)`

Change the animation state.

**Parameters:**
- `state` (string) - Animation state name

**Available States:**
- `"default"` - Default/idle
- `"move"` - Movement
- `"attack"` - Attack
- `"hitbycar"` - Hit by vehicle
- `"drowning"` - In water
- `"burning"` - On fire
- `"frozen"` - Frozen
- `"shocked"` - Electrocuted
- `"death"` - Death animation
- `"celebrate"` - Victory
- Custom states defined in theme

```lua
function onCollision(other)
    if other.id == "hazard.car" then
        setAnimationState("hitbycar")
        wait(1.0)
        destroyPiece(self)
    end
end
```

---

## Examples

### Example 1: Moving Car Hazard

```lua
-- Car that moves horizontally and kills pieces

function onInit()
    self.speed = 2.0
    self.direction = 1  -- 1 = right, -1 = left
end

function onUpdate(dt)
    -- Move horizontally
    self.x = self.x + (self.speed * self.direction * dt)
    
    -- Bounce at edges
    local width, height = getBoardSize()
    if self.x > width - 1 then
        self.direction = -1
    elseif self.x < 0 then
        self.direction = 1
    end
end

function onCollision(other)
    if other.category == "piece" then
        destroyPiece(other)
        playSound("car_crash")
        spawnEffect("explosion", other.x, other.y)
    end
end
```

---

### Example 2: Teleporting Knight

```lua
-- Knight that can teleport anywhere within 3 squares

function onMove(fromX, fromY, toX, toY)
    -- Calculate Manhattan distance
    local distance = math.abs(toX - fromX) + math.abs(toY - fromY)
    
    if distance <= 3 then
        spawnEffect("teleport", fromX, fromY)
        spawnEffect("teleport", toX, toY)
        playSound("whoosh")
        return true
    else
        showMessage("Too far to teleport!", 1.5)
        return false
    end
end

function getValidMoves(x, y)
    local moves = {}
    local width, height = getBoardSize()
    
    -- Add all positions within 3 squares
    for dx = -3, 3 do
        for dy = -3, 3 do
            local distance = math.abs(dx) + math.abs(dy)
            if distance > 0 and distance <= 3 then
                local newX = x + dx
                local newY = y + dy
                if isInBounds(newX, newY) then
                    table.insert(moves, {x = newX, y = newY})
                end
            end
        end
    end
    
    return moves
end
```

---

### Example 3: Spreading Fire Hazard

```lua
-- Fire that spreads to adjacent tiles

function onInit()
    self.spreadTimer = 0
    self.spreadDelay = 2.0  -- Spread every 2 seconds
end

function onUpdate(dt)
    self.spreadTimer = self.spreadTimer + dt
    
    if self.spreadTimer >= self.spreadDelay then
        self.spreadTimer = 0
        spreadFire()
    end
end

function spreadFire()
    -- Try to spread to adjacent tiles
    local directions = {
        {x = 1, y = 0},
        {x = -1, y = 0},
        {x = 0, y = 1},
        {x = 0, y = -1}
    }
    
    for _, dir in ipairs(directions) do
        local newX = self.x + dir.x
        local newY = self.y + dir.y
        
        if isInBounds(newX, newY) then
            local tile = getTile(newX, newY)
            if tile and tile.id ~= "hazard.fire" then
                spawnObject("hazard.fire", newX, newY)
            end
        end
    end
end

function onCollision(other)
    if other.category == "piece" then
        setAnimationState("burning")  -- Piece animation
        wait(1.0)
        destroyPiece(other)
    end
end
```

---

### Example 4: Bouncing Pawn

```lua
-- Pawn that bounces back when hitting obstacles

function onMove(fromX, fromY, toX, toY)
    -- Check if target has an obstacle
    local tile = getTile(toX, toY)
    
    if tile and tile.category == "hazard" then
        -- Bounce back
        local bounceX = fromX - (toX - fromX)
        local bounceY = fromY - (toY - fromY)
        
        if isInBounds(bounceX, bounceY) then
            moveObject(fromX, fromY, bounceX, bounceY)
            playSound("bounce")
            showMessage("Bounced!", 1.0)
        end
        
        return false  -- Don't allow original move
    end
    
    return true  -- Allow move
end
```

---

### Example 5: Timed Trap Tile

```lua
-- Tile that activates after 3 seconds

function onInit()
    self.timer = 0
    self.isActive = false
    self.activateTime = 3.0
end

function onUpdate(dt)
    if not self.isActive then
        self.timer = self.timer + dt
        
        if self.timer >= self.activateTime then
            self.isActive = true
            setAnimationState("active")
            playSound("trap_activate")
        end
    end
end

function onCollision(other)
    if self.isActive and other.category == "piece" then
        destroyPiece(other)
        spawnEffect("trap_snap", self.x, self.y)
        self.isActive = false  -- Single use
    end
end
```

---

## Best Practices

### Performance

- Avoid heavy calculations in `onUpdate()` if possible
- Use timers to limit expensive operations
- Cache board size instead of calling `getBoardSize()` every frame

```lua
function onInit()
    self.boardWidth, self.boardHeight = getBoardSize()  -- Cache it
end
```

---

### Debugging

Use `print()` to log information:

```lua
function onUpdate(dt)
    print("Position: " .. self.x .. ", " .. self.y)
    print("Delta time: " .. dt)
end
```

---

### State Management

Use custom properties for complex state:

```lua
function onInit()
    self.state = "idle"  -- "idle", "moving", "attacking"
    self.stateTimer = 0
end

function onUpdate(dt)
    if self.state == "moving" then
        -- Movement logic
    elseif self.state == "attacking" then
        -- Attack logic
    end
end
```

---

## Next Steps

- **Test scripts** in Unity test scene
- **Create script library** for common behaviors
- **Share scripts** with modding community
- **Debug tools** coming soon!

---

*May your scripts flow through the darkness with elegant logic...* 🖤⚡💀
