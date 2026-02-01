extends Node2D

@onready var sprite := $Sprite2D
@onready var dadlabel := $DadLabel
@onready var sonlabel := $SonLabel
@onready var background := $Background
func _ready():
	dadlabel.visible = false
	sonlabel.visible = false
	await get_tree().create_timer(0.8).timeout
	move_up()
	await get_tree().create_timer(3).timeout
	move_down()
	
	await wait(0.4)
	play_dialog(dadlabel,DadDialog)
	
	await play_dialog(sonlabel,SonDialog)
	

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
	"""	background.texture = preload("res://Sprites 7/Segunda-escena.png")"""
	background.texture = preload("res://Sprites 7/Segunda-escena.png")
	background.expand = true
	background.stretch_mode = TextureRect.STRETCH_SCALE
	
	"""waza padre"""
	
	
	
var DadDialog := [
	"Hola...",
	"Creo que esto está funcionando.",
	"Unity ya no parece tan fácil 😅",
	"Ok, sigamos."
]

var dialog_index := 0

var SonDialog := [
	"Papá...",
	"¿Qué estás haciendo?",
	"Eso se ve raro.",
	"Bueno..."
]




# ─────────────────────────────
# ─────────────────────────────

func play_dialog(label: Label, dialog: Array):
	
	
	
	label.visible = true
	
	
	background.texture = preload("res://Sprites 7/Tercera-escena.png")
	background.expand = true
	background.stretch_mode = TextureRect.STRETCH_SCALE
	
	dialog_index = 0
	var index := 0   # ← LOCAL
	while dialog_index < dialog.size():
		label.text = dialog[dialog_index]
		dialog_index += 1
		await wait(2.0)

	label.visible = false
	
	

	

func wait(time: float):
	await get_tree().create_timer(time).timeout
"""waza ijo"""
