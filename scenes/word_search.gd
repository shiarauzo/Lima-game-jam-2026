extends Control
signal completed   # avisar cuando termine

"""func start_game():
	print("Sopa iniciada")
	# aquí generas la grilla, habilitas input, etc.

func finish_game():
	print("Sopa terminada")
	emit_signal("completed")"""
	

@export var rows := 6
@export var cols := 7

var grid := []
var words := ["FREUD", "FRIEDA", "JAVIER"]


var grid_letters := []

var DIRECTIONS = [
	Vector2i(1, 0),   # →
	Vector2i(0, 1),   # ↓
	Vector2i(1, 1),   # ↘
	Vector2i(-1, 1)   # ↙
] 


var selected_letters := []
var current_word := ""
var found_words := []

func start_game():
	visible = true
	_init_grid()
	_place_all_words()
	_fill_random_letters()
	_build_grid()
	print("🟩 Sopa iniciada")


func _init_grid():
	grid_letters.clear()
	for i in rows * cols:
		grid_letters.append("")


func _place_all_words():
	for word in words:
		var placed := false
		var attempts := 0

		while not placed and attempts < 100:
			placed = _place_word(word)
			attempts += 1

		if not placed:
			push_warning("No se pudo colocar: " + word)

func _place_word(word: String) -> bool:
	var directions := DIRECTIONS.duplicate()
	directions.shuffle()

	for dir in directions:
		var start_row: int = randi_range(0, rows - 1)
		var start_col: int = randi_range(0, cols - 1)

		var fits := true

		# Verificar
		for i in range(word.length()):
			var r: int = start_row + dir.y * i
			var c: int = start_col + dir.x * i

			if r < 0 or r >= rows or c < 0 or c >= cols:
				fits = false
				break

			var index: int = r * cols + c
			var letter := word.substr(i, 1)

			if grid_letters[index] != "" and grid_letters[index] != letter:
				fits = false
				break

		if not fits:
			continue

		# Colocar
		for i in range(word.length()):
			var r: int = start_row + dir.y * i
			var c: int = start_col + dir.x * i
			grid_letters[r * cols + c] = word.substr(i, 1)

		return true

	return false



func _fill_random_letters():
	for i in grid_letters.size():
		if grid_letters[i] == "":
			grid_letters[i] = _random_letter()


func _build_grid():
	for child in $Grid.get_children():
		child.queue_free()

	$Grid.columns = cols

	for letter in grid_letters:
		var btn := Button.new()
		btn.text = letter
		btn.custom_minimum_size = Vector2(40, 40)
		btn.pressed.connect(_on_letter_pressed.bind(btn))
		$Grid.add_child(btn)

func _on_letter_pressed(btn: Button):
	if btn in selected_letters:
		return

	selected_letters.append(btn)
	current_word += btn.text
	btn.modulate = Color(0.6, 0.9, 1.0)

	print("Palabra actual:", current_word)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_check_word()
		

func _check_word():
	if current_word in words and current_word not in found_words:
		print("✔ Correcto:", current_word)
		found_words.append(current_word)

		for btn in selected_letters:
			btn.modulate = Color(0.5, 1.0, 0.5)
	else:
		print("✖ Incorrecto:", current_word)
		for btn in selected_letters:
			btn.modulate = Color.WHITE

	selected_letters.clear()
	current_word = ""

	if found_words.size() == words.size():
		finish_game()

func _random_letter() -> String:
	return char(randi_range(65, 90))

func finish_game():
	print("✅ Sopa completada")
	visible = false  
	emit_signal("completed")
	
