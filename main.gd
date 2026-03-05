extends Node2D

# Main script for the Snake game.
# Scene structure:
#   Main (Node2D)
#   ├── Background (TextureRect)  — bg.png grid background (M5.2)
#   ├── SnakeLayer (Node2D)
#   ├── FoodLayer (Node2D)
#   └── UI (CanvasLayer)
#       ├── ScoreLabel (Label)
#       └── GameOverLabel (Label)

# --- Constants ---
const GRID_SIZE: int = 20 # 20x20 grid
const CELL_SIZE: int = 24 # Each cell is 24 pixels
const TICK_SPEED: float = 0.12 # Base seconds between each movement tick
const MIN_TICK_SPEED: float = 0.05 # Minimum tick speed (M4.2)
const SPEED_INCREMENT: int = 5 # Food count interval for speed increase (M4.2)
const SPEED_REDUCTION: float = 0.01 # Tick reduction per interval (M4.2)

# --- Assets (SPEC §19) ---
var food_texture: Texture2D = preload("res://assets/apple.png")
var head_texture: Texture2D = preload("res://assets/snake_head.png")

# --- Game state ---
var snake_body: Array[Vector2i] = []
var direction: Vector2i = Vector2i.RIGHT
var next_direction: Vector2i = Vector2i.RIGHT
var food_pos: Vector2i = Vector2i.ZERO
var score: int = 0
var game_over: bool = false
var tick_timer: float = 0.0
var current_tick_speed: float = TICK_SPEED # Dynamic tick speed (M4.2)

# --- Node pooling (M6.1) ---
var snake_rects: Array[ColorRect] = []
var food_sprite: Sprite2D = null
var head_sprite: Sprite2D = null

# --- Node references ---
@onready var snake_layer: Node2D = $SnakeLayer
@onready var food_layer: Node2D = $FoodLayer
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_label: Label = $UI/GameOverLabel


# --- Initialization ---
func _ready() -> void:
	# Create the persistent food sprite (M6.1)
	food_sprite = Sprite2D.new()
	food_sprite.texture = food_texture
	if food_texture:
		var tex_size := food_texture.get_size()
		food_sprite.scale = Vector2(CELL_SIZE / tex_size.x, CELL_SIZE / tex_size.y)
	food_layer.add_child(food_sprite)

	# Create the persistent head sprite (M5.1)
	head_sprite = Sprite2D.new()
	head_sprite.texture = head_texture
	if head_texture:
		var tex_size := head_texture.get_size()
		head_sprite.scale = Vector2(CELL_SIZE / tex_size.x, CELL_SIZE / tex_size.y)
	head_sprite.z_index = 1 # Render above body segments
	snake_layer.add_child(head_sprite)

	start_game()


func start_game() -> void:
	# Reset state
	score = 0
	game_over = false
	tick_timer = 0.0
	direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT
	current_tick_speed = TICK_SPEED # Reset speed (M4.2)

	# Initialize snake at center of grid, length 3, facing right
	var center := Vector2i(GRID_SIZE / 2, GRID_SIZE / 2)
	snake_body = [
		center, # head at (10,10)
		center + Vector2i.LEFT, # body at (9,10)
		center + Vector2i.LEFT * 2, # tail at (8,10)
	]

	# Spawn first food
	spawn_food()

	# Update UI
	score_label.text = "Score: 0"
	game_over_label.visible = false

	# Draw initial state
	draw_game()


# --- Main loop ---
func _process(delta: float) -> void:
	if game_over:
		# Allow restart with R (M3.4)
		if Input.is_key_pressed(KEY_R):
			start_game()
		return

	# Handle directional input (M4.1 — buffered input)
	handle_input()

	# Accumulate time and move on each tick (M6.2 — deterministic subtraction)
	tick_timer += delta
	if tick_timer >= current_tick_speed:
		tick_timer -= current_tick_speed
		move_snake()


# --- Input handling (M4.1) ---
func handle_input() -> void:
	# Use is_action_just_pressed for responsive buffered input
	# Reject 180° reversal by checking current direction
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("move_up"):
		if direction != Vector2i.DOWN:
			next_direction = Vector2i.UP
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("move_down"):
		if direction != Vector2i.UP:
			next_direction = Vector2i.DOWN
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("move_left"):
		if direction != Vector2i.RIGHT:
			next_direction = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("move_right"):
		if direction != Vector2i.LEFT:
			next_direction = Vector2i.RIGHT


# Fallback: catch WASD via _unhandled_key_input for reliable buffering (M4.1)
func _unhandled_key_input(event: InputEvent) -> void:
	if game_over or not event.is_pressed():
		return

	var key_event := event as InputEventKey
	if key_event == null:
		return

	match key_event.keycode:
		KEY_W:
			if direction != Vector2i.DOWN:
				next_direction = Vector2i.UP
		KEY_S:
			if direction != Vector2i.UP:
				next_direction = Vector2i.DOWN
		KEY_A:
			if direction != Vector2i.RIGHT:
				next_direction = Vector2i.LEFT
		KEY_D:
			if direction != Vector2i.LEFT:
				next_direction = Vector2i.RIGHT


# --- Core movement logic ---
func move_snake() -> void:
	# Apply buffered direction
	direction = next_direction

	# Calculate new head position
	var new_head: Vector2i = snake_body[0] + direction

	# Check wall collision (M3.1)
	if new_head.x < 0 or new_head.x >= GRID_SIZE or new_head.y < 0 or new_head.y >= GRID_SIZE:
		trigger_game_over()
		return

	# Check self collision (M3.2)
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

		# Increase speed every SPEED_INCREMENT food (M4.2)
		if score % SPEED_INCREMENT == 0:
			current_tick_speed = maxf(current_tick_speed - SPEED_REDUCTION, MIN_TICK_SPEED)

		# Visual feedback — flash head white (M4.3)
		draw_game()
		_flash_head()
	else:
		# Remove tail — snake doesn't grow
		snake_body.pop_back()
		draw_game()


# --- Visual feedback (M4.3) ---
func _flash_head() -> void:
	if head_sprite:
		var tween := create_tween()
		tween.tween_property(head_sprite, "modulate", Color(2, 2, 2, 1), 0.05)
		tween.tween_property(head_sprite, "modulate", Color.WHITE, 0.10)


# --- Food spawning ---
func spawn_food() -> void:
	# Collect all free cells not occupied by the snake
	var free_cells: Array[Vector2i] = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell := Vector2i(x, y)
			if cell not in snake_body:
				free_cells.append(cell)

	# Pick a random free cell
	if free_cells.size() > 0:
		food_pos = free_cells[randi() % free_cells.size()]


# --- Rendering with node pooling (M6.1) ---
func draw_game() -> void:
	# Body segments need rects for indices 1+ (head uses sprite)
	var body_count := snake_body.size() - 1 # exclude head

	# Grow the pool if we need more rects
	while snake_rects.size() < body_count:
		var rect := ColorRect.new()
		rect.size = Vector2(CELL_SIZE, CELL_SIZE)
		rect.color = Color.GREEN
		snake_layer.add_child(rect)
		snake_rects.append(rect)

	# Position body rects (index 1+ of snake_body)
	for i in range(body_count):
		var rect := snake_rects[i]
		var seg := snake_body[i + 1]
		rect.position = Vector2(seg.x * CELL_SIZE, seg.y * CELL_SIZE)
		rect.color = Color.GREEN
		rect.visible = true

	# Hide unused rects
	for i in range(body_count, snake_rects.size()):
		snake_rects[i].visible = false

	# Position head sprite (M5.1)
	var head_pos := snake_body[0]
	head_sprite.position = Vector2(
		head_pos.x * CELL_SIZE + CELL_SIZE / 2.0,
		head_pos.y * CELL_SIZE + CELL_SIZE / 2.0
	)
	head_sprite.rotation = _direction_to_rotation(direction)

	# Update food position (reuse persistent sprite)
	food_sprite.position = Vector2(
		food_pos.x * CELL_SIZE + CELL_SIZE / 2.0,
		food_pos.y * CELL_SIZE + CELL_SIZE / 2.0
	)


# Map direction vector to rotation angle (sprite faces RIGHT by default)
func _direction_to_rotation(dir: Vector2i) -> float:
	match dir:
		Vector2i.RIGHT:
			return 0.0
		Vector2i.DOWN:
			return PI / 2.0
		Vector2i.LEFT:
			return PI
		Vector2i.UP:
			return -PI / 2.0
		_:
			return 0.0


# --- Game over ---
func trigger_game_over() -> void:
	game_over = true
	game_over_label.text = "Game Over!\nScore: " + str(score) + "\nPress R to restart"
	game_over_label.visible = true
