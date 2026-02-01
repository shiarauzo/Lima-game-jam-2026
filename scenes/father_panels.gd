extends Node2D

@onready var sprite := $Sprite2D
@onready var label := $Label

func _ready():
	label.visible = false
	await get_tree().create_timer(0.8).timeout
	move_up()
	await get_tree().create_timer(3).timeout
	move_down()
	
	await wait(0.4)

	await iniciar_dialogo()

func move_up():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"position",
		sprite.position + Vector2(0, -80),
		0.9
	)

func move_down():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"position",
		sprite.position + Vector2(0, 360),
		2
	)
	
	
	"""waza"""
	
	
	
var dialog := [
	"Hola...",
	"Creo que esto está funcionando.",
	"Unity ya no parece tan fácil 😅",
	"Ok, sigamos."
]

var dialog_index := 0


# ─────────────────────────────


func iniciar_dialogo():
	label.visible = true
	dialog_index = 0

	while dialog_index < dialog.size():
		label.text = dialog[dialog_index]
		dialog_index += 1
		await wait(2.0)

	label.visible = false

# ─────────────────────────────

func wait(time: float):
	await get_tree().create_timer(time).timeout
