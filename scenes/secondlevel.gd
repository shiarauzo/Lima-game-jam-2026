extends Control

var dragging: TextureRect = null
var drag_offset: Vector2 = Vector2.ZERO
var original_positions: Dictionary = {}

# Piezas inactivas que muestran mensaje (hasta que el puzzle esté completo)
var inactive_pieces = ["Retazo1B", "Retazo1C", "Retazo1D"]

# Piezas requeridas para completar el puzzle
var required_pieces = ["Retazo3", "Retazo4", "Retazo1A", "Retazo2"]

# Estado del puzzle
var puzzle_complete: bool = false

# Contador de retazos colocados y texturas de cartas
var replacement_count: int = 0
var carta_textures = [
	"res://assets/carta/carta22.png",
	"res://assets/carta/carta33.png",
	"res://assets/carta/carta44.png"
]

# Textos de las cartas
var carta_texts = [
	"Sé que muchas cosas te impiden hacerme una visita, pero ¿acaso no sería precisamente mi boda la mejor oportunidad de echar por la borda tu injustificado autoexilio, al menos por una vez?",
	"Sé que muchas cosas te impiden hacerme una visita, pero ¿acaso no sería precisamente mi boda la mejor oportunidad de echar por la borda tu injustificado autoexilio, al menos por una vez?\nAunque nos veíamos a diario en el negocio, comíamos juntos y platicábamos todas las noches, algo en ti me desconcertaba, incluso cambiabas el relato de tu vida con cada persona que conocías. Por eso ahora me cuestiono incluso nuestra amistad.",
	"Sé que muchas cosas te impiden hacerme una visita, pero ¿acaso no sería precisamente mi boda la mejor oportunidad de echar por la borda tu injustificado autoexilio, al menos por una vez?\nAunque nos veíamos a diario en el negocio, comíamos juntos y platicábamos todas las noches, algo en ti me desconcertaba, incluso cambiabas el relato de tu vida con cada persona que conocías. Por eso ahora me cuestiono incluso nuestra amistad.\nTras quedarme al cuidado de mi padre, solo tú te quedaste conmigo. Te aprecio mucho, por lo que me gustaría que vinieras a mi boda.\nJavier Woremasks"
]

@onready var carta_reference: TextureRect = $CartaReference
@onready var carta_text: Label = $CartaReference/CartaText

# Conexiones válidas: pieza -> {dirección: pieza_que_conecta}
var valid_connections = {
	"Retazo3": {"right": "Retazo4"},
	"Retazo4": {"left": "Retazo3", "right": "Retazo1A"},
	"Retazo1A": {"left": "Retazo4"},
	"Retazo2": {"top_of": ["Retazo3", "Retazo4", "Retazo1A"]}
}

# Grupos de piezas conectadas
var connected_groups: Array = []

# Distancia para hacer snap
var snap_distance: float = 50.0

# Tamaño de las piezas (distancia entre piezas al conectarse)
var piece_size: float = 50.0

@onready var message_label: Label = $MessageLabel

func _ready() -> void:
	for piece in $PuzzlePieces.get_children():
		piece.mouse_filter = Control.MOUSE_FILTER_STOP
		original_positions[piece.name] = piece.position

	message_label.text = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_stop_drag()
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - drag_offset - dragging.position
		_move_piece_with_group(dragging, delta)
		drag_offset = event.position - dragging.position

func _start_drag(mouse_pos: Vector2) -> void:
	var pieces = $PuzzlePieces.get_children()
	pieces.reverse()
	for piece in pieces:
		if piece.get_global_rect().has_point(mouse_pos):
			# Verificar si es una pieza inactiva
			if piece.name in inactive_pieces:
				if not puzzle_complete:
					_show_message("Parece que esta pieza es importante, pero todavía no.")
					return
				# Si puzzle completo, permitir arrastrar

			dragging = piece
			drag_offset = mouse_pos - piece.position
			$PuzzlePieces.move_child(piece, -1)
			_hide_message()
			break

func _stop_drag() -> void:
	if dragging == null:
		return

	var piece_name = str(dragging.name)

	# Si es una pieza de reemplazo y el puzzle está completo
	if piece_name in inactive_pieces and puzzle_complete:
		var retazo1a = $PuzzlePieces.get_node_or_null("Retazo1A")
		if retazo1a != null:
			var distance = dragging.position.distance_to(retazo1a.position)
			if distance < snap_distance:
				# Reemplazar Retazo1A
				dragging.position = retazo1a.position
				dragging.rotation = 0
				retazo1a.visible = false
				# Agregar la nueva pieza al grupo
				var group = _get_group_for_piece(retazo1a)
				if group != null:
					group.append(dragging)
				# Cambiar imagen de la carta
				_change_carta_image()
				# Remover de piezas inactivas para que no se pueda volver a usar
				inactive_pieces.erase(piece_name)
				dragging = null
				return

		# Si no se colocó sobre Retazo1A, volver a posición original
		_return_to_original(dragging)
		dragging = null
		return

	var snapped = _try_snap(dragging)

	if not snapped:
		var nearby_piece = _get_nearby_piece(dragging)
		if nearby_piece != null:
			_return_to_original(dragging)

	# Verificar si el puzzle está completo
	_check_puzzle_complete()

	dragging = null

func _try_snap(piece: TextureRect) -> bool:
	var piece_name = piece.name

	if piece_name not in valid_connections:
		return false

	var connections = valid_connections[piece_name]

	for direction in connections:
		var target_names = connections[direction]
		if target_names is String:
			target_names = [target_names]

		for target_name in target_names:
			var target = $PuzzlePieces.get_node_or_null(target_name)
			if target == null:
				continue

			var expected_pos = _get_expected_position(piece, target, direction)
			var actual_distance = piece.position.distance_to(expected_pos)

			if actual_distance < snap_distance:
				piece.position = expected_pos
				piece.rotation = 0
				target.rotation = 0
				_add_to_group(piece, target)
				return true

	return false

func _get_expected_position(piece: TextureRect, target: TextureRect, direction: String) -> Vector2:
	match direction:
		"right":
			return Vector2(target.position.x - piece_size, target.position.y)
		"left":
			return Vector2(target.position.x + piece_size, target.position.y)
		"top_of":
			return Vector2(target.position.x, target.position.y + piece_size)
		_:
			return piece.position

func _get_nearby_piece(piece: TextureRect) -> TextureRect:
	for other in $PuzzlePieces.get_children():
		if other == piece:
			continue
		if other.name in inactive_pieces:
			continue

		var distance = piece.position.distance_to(other.position)
		if distance < snap_distance * 1.5:
			return other

	return null

func _return_to_original(piece: TextureRect) -> void:
	var group = _get_group_for_piece(piece)
	if group != null:
		for p in group:
			if p.name in original_positions:
				p.position = original_positions[p.name]
	else:
		if piece.name in original_positions:
			piece.position = original_positions[piece.name]

func _add_to_group(piece1: TextureRect, piece2: TextureRect) -> void:
	var group1 = _get_group_for_piece(piece1)
	var group2 = _get_group_for_piece(piece2)

	if group1 != null and group2 != null:
		if group1 != group2:
			for p in group2:
				if p not in group1:
					group1.append(p)
			connected_groups.erase(group2)
	elif group1 != null:
		if piece2 not in group1:
			group1.append(piece2)
	elif group2 != null:
		if piece1 not in group2:
			group2.append(piece1)
	else:
		connected_groups.append([piece1, piece2])

func _get_group_for_piece(piece: TextureRect):
	for group in connected_groups:
		if piece in group:
			return group
	return null

func _move_piece_with_group(piece: TextureRect, delta: Vector2) -> void:
	var group = _get_group_for_piece(piece)
	if group != null:
		for p in group:
			p.position += delta
	else:
		piece.position += delta

func _check_puzzle_complete() -> void:
	if puzzle_complete:
		return

	# Verificar que todas las piezas requeridas estén en el mismo grupo
	var first_piece = $PuzzlePieces.get_node_or_null(required_pieces[0])
	if first_piece == null:
		return

	var group = _get_group_for_piece(first_piece)
	if group == null:
		return

	for piece_name in required_pieces:
		var piece = $PuzzlePieces.get_node_or_null(piece_name)
		if piece == null or piece not in group:
			return

	puzzle_complete = true
	_show_message("¡Puzzle completo! Ahora puedes usar las otras piezas.")

func _show_message(msg: String) -> void:
	message_label.text = msg
	await get_tree().create_timer(3.0).timeout
	if message_label.text == msg:
		message_label.text = ""

func _hide_message() -> void:
	message_label.text = ""

func _change_carta_image() -> void:
	if replacement_count < carta_textures.size():
		var new_texture = load(carta_textures[replacement_count])
		carta_reference.texture = new_texture
		carta_text.text = carta_texts[replacement_count]
		replacement_count += 1
