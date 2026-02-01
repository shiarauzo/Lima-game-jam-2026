extends Control

var dragging: TextureRect = null
var drag_offset: Vector2 = Vector2.ZERO
var original_positions: Dictionary = {}

# Piezas inactivas que muestran mensaje
var inactive_pieces = ["Retazo1B", "Retazo1C", "Retazo1D"]

# Conexiones válidas: pieza -> {dirección: pieza_que_conecta}
# right = la otra pieza va a la derecha
# left = la otra pieza va a la izquierda
# bottom = la otra pieza va abajo
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

# Tamaño de las piezas
var piece_size: float = 100.0

@onready var message_label: Label = $MessageLabel

func _ready() -> void:
	# Guardar posiciones originales y configurar mouse filter
	for piece in $PuzzlePieces.get_children():
		piece.mouse_filter = Control.MOUSE_FILTER_STOP
		original_positions[piece.name] = piece.position

	# Ocultar mensaje al inicio
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
				_show_message("Parece que esta pieza es importante, pero todavía no.")
				return

			dragging = piece
			drag_offset = mouse_pos - piece.position
			$PuzzlePieces.move_child(piece, -1)
			_hide_message()
			break

func _stop_drag() -> void:
	if dragging == null:
		return

	var snapped = _try_snap(dragging)

	if not snapped:
		# Verificar si está cerca de alguna pieza pero no es conexión válida
		var nearby_piece = _get_nearby_piece(dragging)
		if nearby_piece != null:
			# Hay una pieza cerca pero no es válida, volver a posición original
			_return_to_original(dragging)

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

			var distance = piece.position.distance_to(target.position)

			# Calcular posición esperada según la dirección
			var expected_pos = _get_expected_position(piece, target, direction)
			var actual_distance = piece.position.distance_to(expected_pos)

			if actual_distance < snap_distance:
				# Hacer snap
				piece.position = expected_pos
				piece.rotation = 0
				target.rotation = 0
				_add_to_group(piece, target)
				return true

	return false

func _get_expected_position(piece: TextureRect, target: TextureRect, direction: String) -> Vector2:
	match direction:
		"right":
			# piece va a la izquierda de target
			return Vector2(target.position.x - piece_size, target.position.y)
		"left":
			# piece va a la derecha de target
			return Vector2(target.position.x + piece_size, target.position.y)
		"top_of":
			# piece va debajo de target
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
		# Mover todo el grupo a sus posiciones originales
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
			# Fusionar grupos
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
		# Crear nuevo grupo
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

func _show_message(msg: String) -> void:
	message_label.text = msg
	# Ocultar después de 3 segundos
	await get_tree().create_timer(3.0).timeout
	if message_label.text == msg:
		message_label.text = ""

func _hide_message() -> void:
	message_label.text = ""
