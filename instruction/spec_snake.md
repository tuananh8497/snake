# SPEC_SNAKE.md

Game Specification – Snake Prototype

This document defines the authoritative gameplay rules and technical constraints for the Snake game prototype.

The goal is to implement a **simple, deterministic, grid-based Snake game in Godot 4**.

This specification must be followed by any AI agent modifying the project.

---

# 1. Game Overview

Snake is a classic arcade game where the player controls a snake that moves continuously across a grid.

The player must collect food to grow longer while avoiding collisions with walls and the snake’s own body.

The game ends when the snake collides with a wall or itself.

---

# 2. Technology Constraints

Engine: Godot 4.x
Language: GDScript

The implementation must:

• use deterministic grid movement
• avoid physics engine usage
• keep the prototype simple and readable
• minimise unnecessary architecture

---

# 3. Window and Grid

Window size: 1000 × 1050 pixels

Grid size: 20 × 20 cells

Cell size: 24 pixels

Each logical grid cell corresponds to one rendered square.

All movement must occur **exactly one grid cell at a time**.

---

# 4. Scene Structure

Main scene:

Node2D (Main)

Children:

Node2D (SnakeLayer)
Node2D (FoodLayer)

CanvasLayer (UI)

* Label (ScoreLabel)
* Label (GameOverLabel)

Responsibilities:

SnakeLayer → renders snake body segments
FoodLayer → renders food object
UI → score display and game over message

---

# 5. Snake Data Model

The snake body must be stored as:

Array[Vector2i]

Example:

snake_body = [
Vector2i(10,10),
Vector2i(9,10),
Vector2i(8,10)
]

The first element is the **head**.

Movement logic operates on this array.

---

# 6. Snake Initial State

Initial position:

Head at grid position:

Vector2i(10,10)

Initial length:

3 segments

Initial direction:

RIGHT

Initial score:

0

Game state:

RUNNING

---

# 7. Movement System

The snake moves automatically at a fixed interval.

Movement tick:

0.12 seconds

Movement algorithm:

1. Calculate new head position using direction
2. Insert new head at index 0
3. Remove last element of snake body unless food was eaten

Movement must be **grid-aligned and deterministic**.

---

# 8. Controls

Keyboard input:

Up: W or Arrow Up
Down: S or Arrow Down
Left: A or Arrow Left
Right: D or Arrow Right

Rules:

• direction changes apply on next tick
• the snake cannot reverse direction instantly

Example:

If moving RIGHT → LEFT input is ignored.

---

# 9. Food System

Food occupies one grid cell.

Food spawn rules:

• must spawn inside grid boundaries
• must not overlap the snake body

When snake head reaches the food position:

Effects:

• snake length increases by one
• score increases by 1
• new food spawns

Food rendering:

Red square

---

# 10. Collision Rules

The game ends if either condition occurs.

Wall collision:

Snake head moves outside the grid boundaries.

Self collision:

Snake head position matches any body segment.

Result:

Game state changes to:

GAME_OVER

---

# 11. Game Over Behaviour

When GAME_OVER occurs:

• snake stops moving
• GameOverLabel becomes visible
• player can restart game

Restart input:

Key R

Restart behaviour:

• snake resets to initial state
• score resets to zero
• new food spawns
• game state returns to RUNNING

---

# 12. Rendering Rules

Snake segments:

Green squares

Food:

Red square

Each segment is rendered using either:

ColorRect
or
Sprite2D

Rendering must match grid alignment.

---

# 13. Game States

The game must support two states.

RUNNING
GAME_OVER

State transitions:

RUNNING → GAME_OVER when collision occurs

GAME_OVER → RUNNING when player presses R

---

# 14. Score System

Score increases by:

1 point per food eaten.

ScoreLabel displays:

Score: X

Example:

Score: 5

---

# 15. Determinism Requirements

The game must behave deterministically.

This means:

• movement always occurs on the tick interval
• grid positions remain integers
• no floating-point drift

---

# 16. Definition of Done (Prototype)

The Snake prototype is considered complete when:

• the game launches without errors
• snake moves every 0.12 seconds
• player can control direction
• snake grows when food is eaten
• food never spawns on the snake
• collisions trigger game over
• restart key resets the game
• score updates correctly

---

# 17. Non-Goals for Prototype

The following features are intentionally excluded:

• sound effects
• animations
• menus
• high score persistence
• mobile controls

These may be added in later milestones.

---

# 18. Future Extension Points

Potential improvements after prototype:

• speed increase over time
• animated sprites
• sound effects
• pause state
• difficulty modes
• obstacles or portals

These features must not be implemented unless explicitly requested.

---

# 19. Asset Usage

Game assets are stored in the project folder:

`/assets`

The AI agent must use assets from this folder when rendering game elements.

Directory structure:

assets/
apple.png
bg.png

Rules

• Do not generate placeholder assets if suitable assets exist in `/assets`.
• Do not rename files inside the assets folder.
• Use relative paths when loading assets in Godot scripts.
• Do not move or delete assets unless explicitly instructed.

Expected Usage

Food sprite → assets/apple.png
Grid background → assets/bg.png
Snake Head → assets/snake_head.png
Snake Body → assets/snake_body.png
Snake Tail → assets/snake_tail.png

---
End of Specification
