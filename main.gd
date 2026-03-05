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
var body_texture: Texture2D = preload("res://assets/snake_body.png")
var tail_texture: Texture2D = preload("res://assets/snake_tail.png")

# --- Game state ---
var snake_body: Array[Vector2i] = []
var prev_snake_body: Array[Vector2i] = []
var direction: Vector2i = Vector2i.RIGHT
var next_direction: Vector2i = Vector2i.RIGHT
var food_pos: Vector2i = Vector2i.ZERO
var score: int = 0
var high_score: int = 0
var game_over: bool = false
var awaiting_start: bool = true
var paused: bool = false
var tick_timer: float = 0.0
var current_tick_speed: float = TICK_SPEED # Dynamic tick speed (M4.2)
var obstacles: Array[Vector2i] = []

# --- Node pooling (M6.1) ---
var snake_sprites: Array[Sprite2D] = []
var food_sprite: Sprite2D = null
var head_sprite: Sprite2D = null
var obstacle_sprites: Array[Sprite2D] = []

# --- Audio ---
var sfx_eat: AudioStreamPlayer = null
var sfx_game_over: AudioStreamPlayer = null

# --- Difficulty config (M7) ---
var difficulty_settings := {
    "Easy": {"tick": 0.14, "obstacles": 2},
    "Normal": {"tick": 0.12, "obstacles": 4},
    "Hard": {"tick": 0.10, "obstacles": 8}
}
var selected_difficulty: String = "Normal"

# --- Node references ---
@onready var snake_layer: Node2D = $SnakeLayer
@onready var food_layer: Node2D = $FoodLayer
@onready var obstacle_layer: Node2D = $ObstacleLayer
@onready var score_label: Label = $UI/ScoreLabel
@onready var high_score_label: Label = $UI/HighScoreLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var pause_label: Label = $UI/PauseLabel
@onready var start_menu: Control = $UI/StartMenu
@onready var start_button: Button = $UI/StartMenu/Panel/VBoxContainer/StartButton
@onready var quit_button: Button = $UI/StartMenu/Panel/VBoxContainer/QuitButton
@onready var difficulty_option: OptionButton = $UI/StartMenu/Panel/VBoxContainer/DifficultyOption


# --- Initialization ---
func _ready() -> void:
	# Ensure pause input exists
	_ensure_action("pause", [KEY_P, KEY_ESCAPE])

	# Populate difficulty selector
	_setup_difficulty_options()

	# Load persistent high score
	load_high_score()
	update_score_label()

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

	# Audio beeps for feedback (M7 sound effects)
	sfx_eat = _create_beep_player()
	sfx_game_over = _create_beep_player()

	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	show_start_menu()


func start_game() -> void:
	awaiting_start = false
	paused = false
	# Reset state
	score = 0
	game_over = false
	tick_timer = 0.0
	direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT
	var selected_index := difficulty_option.get_selected()
	if selected_index < 0 and difficulty_option.get_item_count() > 0:
		selected_index = 0
	selected_difficulty = difficulty_option.get_item_text(selected_index) if selected_index >= 0 else "Normal"
	var difficulty_cfg: Dictionary = difficulty_settings.get(selected_difficulty, {"tick": TICK_SPEED, "obstacles": 0})
	current_tick_speed = float(difficulty_cfg.get("tick", TICK_SPEED)) # Reset speed (M4.2)
	start_menu.visible = false
	pause_label.visible = false

	# Initialize snake at center of grid, length 3, facing right
	var center := Vector2i(GRID_SIZE / 2, GRID_SIZE / 2)
	snake_body = [
		center, # head at (10,10)
		center + Vector2i.LEFT, # body at (9,10)
		center + Vector2i.LEFT * 2, # tail at (8,10)
	]
	prev_snake_body = snake_body.duplicate()
	obstacles.clear()
	generate_obstacles(int(difficulty_cfg.get("obstacles", 0)))

	# Spawn first food
	spawn_food()

	# Update UI
	update_score_label()
	game_over_label.visible = false

	# Draw initial state
	draw_game(0.0)


func show_start_menu() -> void:
	awaiting_start = true
	start_menu.visible = true
	if not game_over:
		game_over_label.visible = false
		update_score_label()


# --- Main loop ---
func _process(delta: float) -> void:
	if awaiting_start:
		return

	if Input.is_action_just_pressed("pause"):
		toggle_pause()

	if game_over:
		return

	if paused:
		return

	# Handle directional input (M4.1 — buffered input)
	handle_input()

	# Accumulate time and move on each tick (M6.2 — deterministic subtraction)
	tick_timer += delta
	var moved := false
	while tick_timer >= current_tick_speed:
		tick_timer -= current_tick_speed
		move_snake()
		moved = true

	var progress := tick_timer / current_tick_speed
	if moved and food_sprite:
		# Ensure visuals start at the new grid positions before smoothing
		draw_game(0.0)
	else:
		draw_game(progress)


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
	if awaiting_start or game_over or not event.is_pressed():
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
	prev_snake_body = snake_body.duplicate()
	# Apply buffered direction
	direction = next_direction

	# Calculate new head position
	var new_head: Vector2i = snake_body[0] + direction

	# Check wall collision (M3.1)
	if new_head.x < 0 or new_head.x >= GRID_SIZE or new_head.y < 0 or new_head.y >= GRID_SIZE:
		trigger_game_over()
		return

	# Check obstacle collision (M7)
	if new_head in obstacles:
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
		if score > high_score:
			high_score = score
			save_high_score()
		update_score_label()
		spawn_food()

		# Increase speed every SPEED_INCREMENT food (M4.2)
		if score % SPEED_INCREMENT == 0:
			current_tick_speed = maxf(current_tick_speed - SPEED_REDUCTION, MIN_TICK_SPEED)

		# Visual feedback — flash head white (M4.3)
		_flash_head()
		_play_beep(sfx_eat, 720.0, 0.1, 0.35)
	else:
		# Remove tail — snake doesn't grow
		snake_body.pop_back()


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
			if cell not in snake_body and cell not in obstacles:
				free_cells.append(cell)

	# Pick a random free cell
	if free_cells.size() > 0:
		food_pos = free_cells[randi() % free_cells.size()]


# --- Rendering with node pooling (M6.1) ---
func draw_game(progress: float = 1.0) -> void:
	progress = clampf(progress, 0.0, 1.0)
	# Body segments need sprites for indices 1+ (head uses its own sprite)
	var body_count := snake_body.size() - 1 # exclude head

	# Grow the pool if we need more sprites
	while snake_sprites.size() < body_count:
		var sprite := Sprite2D.new()
		sprite.z_index = 0
		snake_layer.add_child(sprite)
		snake_sprites.append(sprite)

	# Position body sprites (index 1+ of snake_body)
	for i in range(body_count):
		var sprite := snake_sprites[i]
		var seg := snake_body[i + 1]
		var start := _get_prev_segment_position(i + 1)
		var pixel_start := Vector2(start) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
		var pixel_target := Vector2(seg) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
		sprite.position = pixel_start.lerp(pixel_target, progress)
		
		# Determine texture and rotation
		var is_tail: bool = (i == body_count - 1)
		
		# Find direction to the NEXT segment closer to the head
		# i + 1 is current seg, i is the segment ahead of it
		var dir_to_next := snake_body[i] - seg
		
		if is_tail:
			sprite.texture = tail_texture
			# scale texture
			if tail_texture:
				var tex_size := tail_texture.get_size()
				sprite.scale = Vector2(CELL_SIZE / tex_size.x, CELL_SIZE / tex_size.y)
			sprite.rotation = _direction_to_rotation(dir_to_next)
		else:
			sprite.texture = body_texture
			# scale texture
			if body_texture:
				var tex_size := body_texture.get_size()
				sprite.scale = Vector2(CELL_SIZE / tex_size.x, CELL_SIZE / tex_size.y)
			# body_texture natively points UP/DOWN. 
			# We rotate 90 deg (PI/2) for left/right movement, 0 for up/down.
			if dir_to_next.x != 0:
				sprite.rotation = PI / 2.0
			else:
				sprite.rotation = 0.0
			
		sprite.visible = true

	# Hide unused sprites
	for i in range(body_count, snake_sprites.size()):
		snake_sprites[i].visible = false

	# Position head sprite (M5.1)
	var head_pos := snake_body[0]
	var head_start := _get_prev_segment_position(0)
	var pixel_head_start := Vector2(head_start) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
	var pixel_head_target := Vector2(head_pos) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
	head_sprite.position = pixel_head_start.lerp(pixel_head_target, progress)
	head_sprite.rotation = _direction_to_rotation(direction)

	# Update food position (reuse persistent sprite)
	food_sprite.position = Vector2(
		food_pos.x * CELL_SIZE + CELL_SIZE / 2.0,
		food_pos.y * CELL_SIZE + CELL_SIZE / 2.0
	)

	# Draw obstacles
	draw_obstacles()


# Helper to fetch previous grid position for interpolation
func _get_prev_segment_position(index: int) -> Vector2i:
	if prev_snake_body.is_empty():
		return snake_body[index]

	if index == 0:
		return prev_snake_body[0]

	var prev_index := index - 1
	if prev_index < prev_snake_body.size():
		return prev_snake_body[prev_index]

	return snake_body[index]


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
	game_over_label.text = "Game Over!\nScore: " + str(score)
	game_over_label.visible = true
	_play_beep(sfx_game_over, 220.0, 0.25, 0.35)
	show_start_menu()
	paused = false


# --- UI callbacks ---
func _on_start_pressed() -> void:
	start_game()


func _on_quit_pressed() -> void:
	get_tree().quit()


# --- Difficulty helpers ---
func _setup_difficulty_options() -> void:
	if difficulty_option == null:
		return
	difficulty_option.clear()
	for name in ["Easy", "Normal", "Hard"]:
		difficulty_option.add_item(name)
	if difficulty_settings.has("Normal"):
		difficulty_option.select(1) # Default to Normal
	selected_difficulty = "Normal"


# --- Pause state ---
func toggle_pause() -> void:
	if awaiting_start or game_over:
		return
	paused = not paused
	pause_label.visible = paused


# --- Obstacles (M7) ---
func generate_obstacles(count: int) -> void:
	obstacles.clear()
	var occupied := snake_body.duplicate()
	var attempts := 0
	while obstacles.size() < count and attempts < 400:
		attempts += 1
		var cell := Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)
		if cell in occupied:
			continue
		obstacles.append(cell)
		occupied.append(cell)


func draw_obstacles() -> void:
	while obstacle_sprites.size() < obstacles.size():
		var sprite := Sprite2D.new()
		sprite.texture = body_texture
		if body_texture:
			var tex_size := body_texture.get_size()
			sprite.scale = Vector2(CELL_SIZE / tex_size.x, CELL_SIZE / tex_size.y)
		sprite.modulate = Color(0.25, 0.25, 0.25)
		obstacle_layer.add_child(sprite)
		obstacle_sprites.append(sprite)

	for i in range(obstacles.size()):
		var sprite := obstacle_sprites[i]
		sprite.position = Vector2(obstacles[i]) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
		sprite.visible = true

	for i in range(obstacles.size(), obstacle_sprites.size()):
		obstacle_sprites[i].visible = false


# --- High score persistence (M7) ---
func update_score_label() -> void:
	score_label.text = "Score: %d (Best: %d)" % [score, high_score]
	if high_score_label:
		high_score_label.text = "Best: " + str(high_score)


func load_high_score() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://snake_save.cfg")
	if err == OK:
		high_score = int(cfg.get_value("scores", "high_score", 0))
	else:
		high_score = 0


func save_high_score() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("scores", "high_score", high_score)
	cfg.save("user://snake_save.cfg")


# --- Audio helpers (M7) ---
func _create_beep_player() -> AudioStreamPlayer:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.25
	var player := AudioStreamPlayer.new()
	player.stream = generator
	add_child(player)
	return player


func _play_beep(player: AudioStreamPlayer, frequency: float, duration: float, volume: float) -> void:
	if player == null or player.stream == null:
		return
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	playback.clear_buffer()
	var generator := player.stream as AudioStreamGenerator
	var mix_rate := generator.mix_rate
	var frame_count := int(mix_rate * duration)
	for i in range(frame_count):
		var t := float(i) / float(mix_rate)
		var sample := sin(TAU * frequency * t) * volume
		playback.push_frame(Vector2(sample, sample))
	player.play()


# --- Input helpers ---
func _ensure_action(action_name: String, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key in keys:
		var ev := InputEventKey.new()
		ev.keycode = key
		if not InputMap.action_has_event(action_name, ev):
			InputMap.action_add_event(action_name, ev)
