You are an experienced **Godot 4 game developer**. Your task is to build a **complete playable Snake game in Godot 4 using GDScript**.

Follow these instructions strictly.

GOAL
Create a minimal but clean Snake game that runs immediately when the project opens.

TECH REQUIREMENTS

* Engine: Godot 4.x
* Language: GDScript
* Game style: Grid-based movement (no physics engine)
* Grid size: 20x20
* Cell size: 24 pixels
* Game tick speed: 0.12 seconds
* Window size: 480x480

SCENE STRUCTURE

Main.tscn

Node2D (Main)

* Node2D (SnakeLayer)
* Node2D (FoodLayer)
* CanvasLayer (UI)

  * Label (ScoreLabel)
  * Label (GameOverLabel)

GAME RULES

Snake starts with length 3.

Snake moves one grid cell every tick.

Controls:

* W / Arrow Up → Up
* S / Arrow Down → Down
* A / Arrow Left → Left
* D / Arrow Right → Right

Snake cannot instantly reverse direction.

Food spawns randomly on a grid cell that is not occupied by the snake.

When snake eats food:

* snake length increases
* score increases
* new food spawns

Game ends if:

* snake hits wall
* snake hits itself

When game over:

* show "Game Over"
* allow restart when player presses R

DATA STRUCTURE

Snake body should be stored as:
Array[Vector2i]

Example:
snake_body = [
Vector2i(10,10),
Vector2i(9,10),
Vector2i(8,10)
]

Each tick:

1. Calculate new head
2. Insert head at index 0
3. Remove tail unless food eaten

RENDERING

Render snake segments as colored squares using ColorRect nodes.

Snake color: green
Food color: red

Nodes should be created under:
SnakeLayer
FoodLayer

DELIVERABLES

Provide the following:

1. Folder structure
2. Scene setup instructions
3. Full GDScript code for Main.gd
4. Explanation of main logic
5. Instructions to run the game

CODE QUALITY

* Use clear variable names
* Use constants for grid size and speed
* Comment key sections
* Keep everything inside one script for simplicity

Do not introduce unnecessary architecture.

OUTPUT FORMAT

Respond in this order:

1. Project structure
2. Scene creation steps
3. Full script
4. Explanation of how the snake movement works
5. Optional improvements
