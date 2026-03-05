extends Node2D

# --- Constants ---
const GRID_SIZE: int = 20 # 20x20 grid
const CELL_SIZE: int = 24 # Each cell is 24 pixels
const TICK_SPEED: float = 0.12 # Seconds between each move

# --- Game state ---
var snake_body: Array[Vector2i] = []
var direction: Vector2i = Vector2i.RIGHT
var next_direction: Vector2i = Vector2i.RIGHT
var food_pos: Vector2i = Vector2i.ZERO
var score: int = 0
var game_over: bool = false
var tick_timer: float = 0.0

# --- Node references ---
@onready var snake_layer: Node2D = $SnakeLayer
@onready var food_layer: Node2D = $FoodLayer
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_label: Label = $UI/GameOverLabel


func _ready() -> void:
	start_game()


func start_game() -> void:
	# Reset state
	score = 0
	game_over = false
	tick_timer = 0.0
	direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT

	# Initialize snake at center of grid, length 3, facing right
	var center := Vector2i(GRID_SIZE / 2, GRID_SIZE / 2)
	snake_body = [
		center,
		center + Vector2i.LEFT,
		center + Vector2i.LEFT * 2,
	]

	# Spawn first food
	spawn_food()

	# Update UI
	score_label.text = "Score: 0"
	game_over_label.visible = false

	# Draw initial state
	draw_game()


func _process(delta: float) -> void:
	if game_over:
		# Allow restart with R
		if Input.is_action_just_pressed("ui_text_submit") or Input.is_key_pressed(KEY_R):
			start_game()
		return

	# Handle directional input
	handle_input()

	# Accumulate time and move on each tick
	tick_timer += delta
	if tick_timer >= TICK_SPEED:
		tick_timer -= TICK_SPEED
		move_snake()


# --- Input handling ---
func handle_input() -> void:
	# Read input and buffer as next_direction (prevents 180° reversal)
	if Input.is_action_just_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		if direction != Vector2i.DOWN:
			next_direction = Vector2i.UP
	elif Input.is_action_just_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		if direction != Vector2i.UP:
			next_direction = Vector2i.DOWN
	elif Input.is_action_just_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		if direction != Vector2i.RIGHT:
			next_direction = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		if direction != Vector2i.LEFT:
			next_direction = Vector2i.RIGHT


# --- Core game logic ---
func move_snake() -> void:
	# Apply buffered direction
	direction = next_direction

	# Calculate new head position
	var new_head: Vector2i = snake_body[0] + direction

	# Check wall collision
	if new_head.x < 0 or new_head.x >= GRID_SIZE or new_head.y < 0 or new_head.y >= GRID_SIZE:
		trigger_game_over()
		return

	# Check self collision (skip tail since it will move)
	if new_head in snake_body:
		trigger_game_over()
		return

	# Insert new head
	snake_body.insert(0, new_head)

	# Check if food was eaten
	if new_head == food_pos:
		score += 1
		score_label.text = "Score: " + str(score)
		spawn_food()
	else:
		# Remove tail (snake doesn't grow)
		snake_body.pop_back()

	# Redraw the game
	draw_game()


# --- Food spawning ---
func spawn_food() -> void:
	# Collect all free cells
	var free_cells: Array[Vector2i] = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell := Vector2i(x, y)
			if cell not in snake_body:
				free_cells.append(cell)

	# Pick a random free cell
	if free_cells.size() > 0:
		food_pos = free_cells[randi() % free_cells.size()]


# --- Rendering ---
func draw_game() -> void:
	# Clear previous frame
	_clear_children(snake_layer)
	_clear_children(food_layer)

	# Draw snake segments as green squares
	for segment in snake_body:
		var rect := ColorRect.new()
		rect.size = Vector2(CELL_SIZE, CELL_SIZE)
		rect.position = Vector2(segment.x * CELL_SIZE, segment.y * CELL_SIZE)
		rect.color = Color.GREEN
		snake_layer.add_child(rect)

	# Draw food as a red square
	var food_rect := ColorRect.new()
	food_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	food_rect.position = Vector2(food_pos.x * CELL_SIZE, food_pos.y * CELL_SIZE)
	food_rect.color = Color.RED
	food_layer.add_child(food_rect)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


# --- Game over ---
func trigger_game_over() -> void:
	game_over = true
	game_over_label.text = "Game Over!\nScore: " + str(score) + "\nPress R to restart"
	game_over_label.visible = true
