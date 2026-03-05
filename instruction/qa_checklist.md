# QA_CHECKLIST.md

Quality Assurance Checklist – Snake Prototype

This checklist defines verification steps that must be executed after each implementation task.

The AI agent must run through this checklist during the **Self Verification** phase defined in `AGENT_CONTRACT.md`.

Each check should be reported as:

✔ PASS
✖ FAIL
⚠ NOT APPLICABLE

---

# 1. Project Startup

Verify the project launches correctly.

Checks

• The Godot project opens without errors.
• Main scene loads automatically.
• No missing script references.
• No missing node references.

Expected Result

The game launches and displays the Snake playfield.

---

# 2. Scene Structure

Verify the main scene matches the specification.

Required Node Tree

Node2D (Main)

Node2D (SnakeLayer)
Node2D (FoodLayer)

CanvasLayer (UI)

* Label (ScoreLabel)
* Label (GameOverLabel)

Checks

• All required nodes exist.
• Node names match the specification.
• UI labels are accessible from the script.

---

# 3. Grid System

Verify the grid configuration.

Checks

• Window resolution is 480 × 480.
• Grid size is 20 × 20.
• Cell size is 24 pixels.
• All rendered objects align perfectly with the grid.

Expected Result

Snake segments and food appear snapped to grid positions.

---

# 4. Snake Initialization

Verify the initial snake state.

Checks

• Snake length is 3.
• Head starts at (10,10).
• Initial direction is RIGHT.
• Snake body uses `Array[Vector2i]`.

Expected Result

Snake appears centered with correct orientation.

---

# 5. Movement System

Verify automatic movement.

Checks

• Snake moves automatically every 0.12 seconds.
• Movement advances exactly one grid cell.
• Snake body updates correctly when moving.

Edge Cases

• Movement continues without player input.
• Movement remains aligned with grid.

---

# 6. Input Controls

Verify player controls.

Checks

• W / Arrow Up moves snake upward.
• S / Arrow Down moves snake downward.
• A / Arrow Left moves snake left.
• D / Arrow Right moves snake right.

Rules

• Reverse direction is ignored.
• Direction changes apply on next movement tick.

Expected Result

Snake responds correctly and cannot instantly reverse.

---

# 7. Food System

Verify food spawning and consumption.

Checks

• Food spawns within grid boundaries.
• Food never spawns on the snake body.
• Food appears aligned to grid cells.

When Snake Eats Food

• Snake grows by one segment.
• Score increases by 1.
• New food spawns.

Expected Result

Food cycle repeats correctly.

---

# 8. Score System

Verify score tracking.

Checks

• Score starts at 0.
• Score increases when food is eaten.
• ScoreLabel updates immediately.

Example Display

Score: 5

---

# 9. Collision System

Verify collision behaviour.

Wall Collision

• Snake hitting wall triggers game over.
• Snake movement stops.

Self Collision

• Snake colliding with its body triggers game over.

Expected Result

Game state changes to GAME_OVER.

---

# 10. Game Over Behaviour

Verify post-failure behaviour.

Checks

• GameOverLabel becomes visible.
• Snake stops moving.
• Score remains visible.

Expected Result

Player clearly sees game over state.

---

# 11. Restart System

Verify restart functionality.

Checks

Press R

Expected Result

• Snake resets to initial position.
• Snake length resets to 3.
• Score resets to 0.
• Food respawns.
• Game state returns to RUNNING.

---

# 12. Rendering Stability

Verify visual correctness.

Checks

• Snake segments do not flicker.
• Snake segments remain aligned to grid.
• Food renders correctly.
• UI text remains readable.

---

# 13. Node Stability

Verify node management.

Checks

• Restarting game does not duplicate snake nodes.
• Scene node count remains stable.
• No orphan nodes appear in scene tree.

Expected Result

Scene remains clean after multiple restarts.

---

# 14. Deterministic Behaviour

Verify consistent game logic.

Checks

• Snake movement remains consistent across runs.
• Grid coordinates remain integers.
• No floating-point drift occurs.

Expected Result

Game behaves identically each run.

---

# 15. Performance Sanity Check

Verify prototype performance.

Checks

• Game runs smoothly at default tick rate.
• No noticeable lag when snake grows longer.

Expected Result

Prototype runs smoothly on standard hardware.

---

# 16. QA Report Format

During verification the agent must produce a summary like:

QA Results

✔ Project Startup
✔ Scene Structure
✔ Grid System
✔ Snake Initialization
✔ Movement System
✔ Input Controls
✔ Food System
✔ Score System
✔ Collision System
✔ Restart System

Issues

None

or

Issue Found

Food occasionally spawns on snake body.

---

End of QA Checklist
