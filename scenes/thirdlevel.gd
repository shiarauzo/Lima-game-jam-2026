extends Control

const TILE_SIZE := 100
const GRID_GAP := 4
const GRID_STEP := TILE_SIZE + GRID_GAP

var tiles: Array[Control] = []
var grid_positions: Array[Vector2] = []
var tile_grid_index: Array[int] = []  # Which grid position each tile is at

var dragging_tile: Control = null
var drag_offset := Vector2.ZERO
var drag_start_index := -1

@onready var puzzle_container := $PuzzleContainer

func _ready() -> void:
	setup_grid_positions()
	setup_tiles()
	shuffle_tiles()

func setup_grid_positions() -> void:
	for row in range(4):
		for col in range(4):
			grid_positions.append(Vector2(col * GRID_STEP, row * GRID_STEP))

func setup_tiles() -> void:
	for i in range(16):
		var tile = puzzle_container.get_node("Tile" + str(i + 1))
		tiles.append(tile)
		tile_grid_index.append(i)
		tile.gui_input.connect(_on_tile_gui_input.bind(tile, i))

func shuffle_tiles() -> void:
	var indices := range(16)
	indices.shuffle()

	for i in range(16):
		var new_index: int = indices[i]
		tile_grid_index[i] = new_index
		tiles[i].position = grid_positions[new_index]

func _on_tile_gui_input(event: InputEvent, tile: Control, tile_index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(tile, tile_index, event.position)
			else:
				end_drag()
	elif event is InputEventMouseMotion and dragging_tile == tile:
		update_drag()

func start_drag(tile: Control, tile_index: int, local_pos: Vector2) -> void:
	dragging_tile = tile
	drag_offset = local_pos
	drag_start_index = tile_grid_index[tile_index]
	tile.z_index = 10

func update_drag() -> void:
	if dragging_tile:
		var mouse_pos: Vector2 = puzzle_container.get_local_mouse_position()
		dragging_tile.position = mouse_pos - drag_offset

func end_drag() -> void:
	if not dragging_tile:
		return

	var dragged_tile_index := tiles.find(dragging_tile)
	var target_grid_index := find_closest_grid_position()

	if target_grid_index != drag_start_index:
		var other_tile_index := find_tile_at_grid_index(target_grid_index)
		if other_tile_index != -1:
			swap_tiles(dragged_tile_index, other_tile_index)
		else:
			tile_grid_index[dragged_tile_index] = target_grid_index
			dragging_tile.position = grid_positions[target_grid_index]
	else:
		dragging_tile.position = grid_positions[drag_start_index]

	dragging_tile.z_index = 0
	dragging_tile = null
	drag_start_index = -1

	check_win()

func find_closest_grid_position() -> int:
	var tile_center := dragging_tile.position + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	var closest_index := 0
	var closest_distance := tile_center.distance_to(grid_positions[0] + Vector2(TILE_SIZE / 2, TILE_SIZE / 2))

	for i in range(1, 16):
		var grid_center := grid_positions[i] + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
		var distance := tile_center.distance_to(grid_center)
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i

	return closest_index

func find_tile_at_grid_index(grid_index: int) -> int:
	for i in range(16):
		if tile_grid_index[i] == grid_index and tiles[i] != dragging_tile:
			return i
	return -1

func swap_tiles(tile_a_index: int, tile_b_index: int) -> void:
	var grid_a := tile_grid_index[tile_a_index]
	var grid_b := tile_grid_index[tile_b_index]

	tile_grid_index[tile_a_index] = grid_b
	tile_grid_index[tile_b_index] = grid_a

	tiles[tile_a_index].position = grid_positions[grid_b]
	tiles[tile_b_index].position = grid_positions[grid_a]

func check_win() -> void:
	for i in range(16):
		if tile_grid_index[i] != i:
			return

	print("Puzzle completado!")
