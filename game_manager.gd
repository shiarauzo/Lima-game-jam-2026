extends Node

@export var overlay_path: NodePath
@export var game_over_label_path: NodePath
@export var restart_button_path: NodePath

@onready var overlay = get_node(overlay_path)
@onready var game_over_label = get_node(game_over_label_path)
@onready var restart_button = get_node(restart_button_path)

func play_final():
	fade_to_light()

func fade_to_light():
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 2.0)
	tween.finished.connect(show_game_over)

func show_game_over():
	game_over_label.visible = true
	restart_button.visible = true


func _ready():
	print("GameManager listo")
	play_final()
