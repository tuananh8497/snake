# AGENT_CONTRACT.md

AI Development Contract for the Snake Game Project

This document defines the behavioural rules and execution framework that any AI agent must follow when contributing to this repository.

The goal is to ensure deterministic, predictable, and safe development iterations.

---

# 1. Project Context

The agent is contributing to a **Godot 4 game project** implementing a grid-based Snake game.

The authoritative specification of the game is located in:

`SPEC_SNAKE.md`

The agent must treat that file as the **single source of truth** for gameplay behaviour.

If there is any conflict between this file and other instructions, follow:

1. SPEC_SNAKE.md
2. AGENT_CONTRACT.md
3. Task prompt instructions

---

# 2. Agent Responsibilities

The agent acts as a **software engineer implementing tasks** within the defined scope.

The agent must:

• implement features described in the task scope
• modify only relevant files
• keep the project compiling and runnable
• explain changes clearly

The agent must NOT:

• introduce new architecture unless requested
• refactor unrelated systems
• rename nodes, scripts, or folders without instruction
• change gameplay rules defined in SPEC_SNAKE.md

---

# 3. Agent Execution Cycle

Every execution must follow this cycle.

## Step 1 — Scope Confirmation

Restate the requested task in 1–2 sentences.

Example:

Scope: Implement food spawning logic that prevents spawning on the snake body.

---

## Step 2 — Plan

Provide a short plan (maximum 8 steps) describing how the task will be implemented.

Example:

1. Add function `spawn_food()`
2. Randomly select grid position
3. Check against snake body array
4. Repeat until valid
5. Render food node
6. Update food position variable

---

## Step 3 — Implementation

Modify or create code necessary to complete the task.

Rules:

• Only change files relevant to the task
• Preserve existing functionality
• Use clear variable names
• Comment important logic sections

---

## Step 4 — Self Verification

Run through the QA checklist defined in:

`QA_CHECKLIST.md`

Report which checks pass or fail.

Example:

QA results:

✔ Snake movement still works
✔ Food spawns correctly
✔ Food never overlaps snake
✔ Game restart still works

---

## Step 5 — Change Report

Provide a structured report of the changes.

Required format:

Files Modified:

* scripts/main.gd

Files Created:

* none

Summary:
Implemented food spawning logic that avoids snake body cells.

Next Recommended Task:
Add snake growth when food is consumed.

---

# 4. Scope Control

The agent must never expand scope beyond the requested milestone.

If additional improvements are discovered, the agent should report them under:

"Suggested Improvements"

but must not implement them without approval.

---

# 5. Coding Rules

Language: GDScript
Engine: Godot 4.x

Rules:

• keep code simple and readable
• avoid over-engineering
• prefer deterministic grid logic over physics
• use constants for grid size and tick rate

Example constants:

GRID_SIZE = 20
CELL_SIZE = 24
MOVE_INTERVAL = 0.12

---

# 6. Change Safety Rules

The agent must ensure the game remains playable after each change.

Do NOT:

• break the main scene
• remove required nodes
• introduce dependency on plugins

If a breaking change is required, explain it before implementation.

---

# 7. Allowed Refactors

Refactors are only allowed if:

• they reduce bugs
• they simplify logic
• they do not change gameplay behaviour

Major architectural changes require explicit approval.

---

# 8. Output Format

Every agent response must contain the following sections:

Scope
Plan
Implementation
QA Verification
Change Report
Suggested Improvements

---

# 9. Error Handling

If the agent encounters missing information:

1. Make a reasonable assumption
2. State the assumption clearly
3. Continue implementation

Example:

Assumption: Snake segments are rendered using ColorRect nodes.

---

# 10. Development Philosophy

This project prioritises:

1. Playable prototypes
2. Small iterative improvements
3. Clear logic over complexity

The agent should favour **incremental improvements** rather than large rewrites.

# 11. Asset Validation Rule

Before using an asset in the game:

1. Check the asset dimensions
2. Confirm the sprite fills the frame
3. Confirm alignment with grid cell size

If the asset has excessive padding,
the agent must crop or normalize it before use.
---

End of Contract
