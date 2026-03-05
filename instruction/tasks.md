# TASKS.md

Development Roadmap – Snake Game Prototype

This document defines the ordered tasks and milestones for implementing the Snake game described in `SPEC_SNAKE.md`.

AI agents must execute tasks **in milestone order** and must not skip milestones unless explicitly instructed.

Each task contains acceptance criteria that must be satisfied before moving forward.

---

# Milestone 1 — Core Game Loop

Goal: Create a playable Snake prototype with basic movement.

Tasks:

### M1.1 Create Base Scene

Create the main Godot scene with the required node structure.

Acceptance Criteria

• Main scene loads without errors
• Scene tree matches specification in SPEC_SNAKE.md
• UI labels exist but may be empty

---

### M1.2 Implement Grid System

Add constants and logic for the game grid.

Acceptance Criteria

• Grid size is 20×20
• Cell size is 24 pixels
• Window size is 480×480
• Grid coordinates use `Vector2i`

---

### M1.3 Implement Snake Data Model

Create the snake body array and initial state.

Acceptance Criteria

• Snake length is 3
• Snake starts at (10,10)
• Direction starts as RIGHT
• Snake body stored as `Array[Vector2i]`

---

### M1.4 Implement Movement Tick

Add timer-driven movement logic.

Acceptance Criteria

• Snake moves every 0.12 seconds
• Movement advances exactly one grid cell
• Snake body updates correctly

---

### M1.5 Implement Player Controls

Add keyboard input to control snake direction.

Acceptance Criteria

• W / Arrow Up → Up
• S / Arrow Down → Down
• A / Arrow Left → Left
• D / Arrow Right → Right

Rules

• Direction changes apply on next tick
• Reverse direction is ignored

---

### M1.6 Render Snake

Display snake segments on screen.

Acceptance Criteria

• Each snake segment renders as a square
• Segments appear aligned to grid
• Snake updates visually when moving

---

# Milestone 2 — Food and Growth

Goal: Introduce the main gameplay loop of eating food.

---

### M2.1 Implement Food Spawn

Create food object that appears on the grid.

Acceptance Criteria

• Food spawns within grid boundaries
• Food never spawns on snake body

---

### M2.2 Implement Eating Logic

Detect when snake reaches food.

Acceptance Criteria

• Snake grows by one segment
• Score increases by 1
• New food spawns immediately

---

### M2.3 Implement Score Display

Update UI score label.

Acceptance Criteria

• ScoreLabel displays: "Score: X"
• Score updates immediately after food is eaten

---

# Milestone 3 — Collision System

Goal: Detect failure conditions.

---

### M3.1 Wall Collision

Detect collision with grid boundaries.

Acceptance Criteria

• Snake hitting wall triggers game over
• Movement stops

---

### M3.2 Self Collision

Detect collision with snake body.

Acceptance Criteria

• Head colliding with body triggers game over
• Movement stops

---

### M3.3 Game Over State

Display game over message.

Acceptance Criteria

• GameOverLabel becomes visible
• Snake stops moving

---

### M3.4 Restart Mechanic

Allow player to restart game.

Acceptance Criteria

• Pressing R resets snake
• Score resets to zero
• Food respawns
• Game state returns to RUNNING

---

# Milestone 4 — Game Feel Improvements

Goal: Improve responsiveness and gameplay feel.

---

### M4.1 Input Buffering

Queue direction input to apply on next movement tick.

Acceptance Criteria

• Rapid input changes remain responsive
• No frame-perfect input requirement

---

### M4.2 Speed Increase

Increase game speed gradually.

Acceptance Criteria

• Movement interval decreases slightly after eating food
• Speed increase is gradual and controlled

Example

Every 5 food items reduce tick by 0.01 seconds.

---

### M4.3 Visual Feedback

Add simple visual feedback when food is eaten.

Acceptance Criteria

• Snake briefly scales or flashes when food is eaten
• Effect lasts less than 0.2 seconds

---

# Milestone 5 — Presentation

Goal: Improve visual clarity.

---

### M5.1 Replace Squares with Sprites

Replace ColorRect rendering with sprites.

Acceptance Criteria

• Snake uses sprite texture
• Food uses sprite texture
• Assets are aligned to grid

---

### M5.2 Add Background Grid

Render faint grid lines behind gameplay.

Acceptance Criteria

• Grid aligns with game cells
• Grid improves visual readability

---

### M5.3 Improve UI

Polish score and game over display.

Acceptance Criteria

• Score is clearly visible
• Game over message is centered

---

# Milestone 6 — Quality Improvements

Goal: Stabilise the game.

---

### M6.1 Prevent Node Leaks

Ensure nodes are reused or cleaned properly.

Acceptance Criteria

• Restart does not duplicate snake nodes
• Scene node count remains stable

---

### M6.2 Deterministic Behaviour

Ensure consistent game behaviour.

Acceptance Criteria

• All movement uses grid positions
• No floating-point drift occurs

---

# Milestone 7 — Optional Extensions

These features are optional and should only be implemented after the core prototype is stable.

Possible tasks

• Pause state
• High score tracking
• Sound effects
• Difficulty modes
• Obstacles or portals

These features must not be implemented unless explicitly requested.

---

End of Task Roadmap
