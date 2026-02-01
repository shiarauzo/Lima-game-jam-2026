extends Control

var dragging: TextureRect = null
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	for piece in $PuzzlePieces.get_children():
		piece.mouse_filter = Control.MOUSE_FILTER_STOP

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_stop_drag()
	elif event is InputEventMouseMotion and dragging:
		dragging.position = event.position - drag_offset

func _start_drag(mouse_pos: Vector2) -> void:
	var pieces = $PuzzlePieces.get_children()
	pieces.reverse()
	for piece in pieces:
		if piece.get_global_rect().has_point(mouse_pos):
			dragging = piece
			drag_offset = mouse_pos - piece.position
			$PuzzlePieces.move_child(piece, -1)
			break

func _stop_drag() -> void:
	dragging = null
