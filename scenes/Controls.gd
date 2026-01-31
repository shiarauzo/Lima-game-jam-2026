extends Control
@onready var right_btn = $RightButton
@onready var left_btn = $LeftButton

@onready var cam = get_node("/root/FirstLevel/Camera2D")
var move_distance := 200
var move_time := 0.4
var tween: Tween

func _ready():
	right_btn.pressed.connect(_on_Right_pressed)
	left_btn.pressed.connect(_on_Left_pressed)


func _on_Right_pressed():
	_move_camera(Vector2(move_distance, 0))




func _on_Left_pressed():
	_move_camera(Vector2(-move_distance, 0))
	print("IZQUIERDA")
	print("Cam pos antes:", cam.global_position)
	_move_camera(Vector2(-move_distance, 0))

func _move_camera(offset: Vector2):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		cam,
		"global_position",
		cam.global_position + offset,
		move_time
	)
func _readya():
	print(cam)
	
