extends Node2D

@onready var sprite := $Sprite2D
@onready var dadlabel := $Globe_dad/DadLabel
@onready var sonlabel := $Globe_son/SonLabel
@onready var background := $Background
@onready var globe_son := $Globe_son
@onready var globe_dad := $Globe_dad
@onready var word_search := $WordSearch
@onready var continue_button := $ContinueButton

func _ready():
	"""dadlabel.visible = false
	sonlabel.visible = false"""
	globe_dad.visible = false
	globe_son.visible = false
	word_search.visible = false
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	await get_tree().create_timer(0.8).timeout
	move_up()
	await get_tree().create_timer(3).timeout


	await wait(2)

	move_down()

	await play_ping_pong_dialog(
	dadlabel,
	DadDialog,
	globe_dad,
	sonlabel,
	SonDialog,
	globe_son
)

	await start_word_search()

"""# 👇 AHORA SÍ, EN SECUENCIA REAL
	await play_dialog(dadlabel, DadDialog, globe_dad)
	await wait(1.5)
	await play_dialog(sonlabel, SonDialog, globe_son)

	# 👇 SOLO DESPUÉS DE LOS DIÁLOGOS
	await start_word_search()"""


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

	sprite.texture = preload("res://Sprites 7/Mano vaciaB.png")
	"""sprite.expand = true"""
	"""sprite.stretch_mode = TextureRect.STRETCH_SCALE"""

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"position",
		sprite.position + Vector2(0, 360),
		4
	)
	"""	background.texture = preload("res://Sprites 7/Segunda-escena.png")"""
	background.texture = preload("res://Sprites 7/Segunda-escena.png")
	background.expand = true
	background.stretch_mode = TextureRect.STRETCH_SCALE

	"""waza padre"""



var DadDialog := [
	"...",
	"...| ¡NO!| Quieres acabar conmigo, lo sé...| ¡Y luego quedarte con el negocio!| A ese amigo lo conozco antes que tú.| ¡Lo quiero como a un hijo!|",
	"Ah...| Entonces te disculpas, Me hablas de un amigo, le construyes una identidad, ¡Años con ese amigo!| ¡¿Quién miente?!| ¡¿Cuál es su nombre!?|"

]

var dialog_index := 0

var SonDialog := [
	"Esta es la carta que le enviaré a mi amigo, ya te hablé de él. Solo quería informarte.|",
	"¡¿?!| Perdóname padre.| ¿Qué debo hacer por tu perdón?|" ,

]




# ─────────────────────────────
# ─────────────────────────────

func play_dialog(label: Label, dialog: Array, globeType: Sprite2D):



	label.visible = true
	globeType.visible = true

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

func start_word_search():

	globe_dad.visible = false
	globe_son.visible = false
	word_search.start_game()
	await word_search.completed
	continue_button.visible = true

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/fin.tscn")



func play_ping_pong_dialog(
	dad_label: Label,
	dad_dialog: Array,
	dad_globe: Node2D,
	son_label: Label,
	son_dialog: Array,
	son_globe: Node2D
) -> void:

	background.texture = preload("res://Sprites 7/Tercera-escena.png")
	background.expand = true
	background.stretch_mode = TextureRect.STRETCH_SCALE

	dad_label.visible = false
	son_label.visible = false
	dad_globe.visible = false
	son_globe.visible = false

	var max_lines: int = max(dad_dialog.size(), son_dialog.size())

	for i in range(max_lines):
		if i < dad_dialog.size():
			son_label.visible = false
			son_globe.visible = false

			dad_globe.visible = true
			dad_label.visible = true

			var dad_parts := split_dialog_by_pause(dad_dialog[i])
			for part in dad_parts:
				dad_label.text = part
				await wait(1.4)

	# 👦 HIJO
		if i < son_dialog.size():
			dad_label.visible = false
			dad_globe.visible = false

			son_globe.visible = true
			son_label.visible = true

			var son_parts := split_dialog_by_pause(son_dialog[i])
			for part in son_parts:
				son_label.text = part
				await wait(1.4)

	# 🧹 limpiar al final
	dad_label.visible = false
	son_label.visible = false
	dad_globe.visible = false
	son_globe.visible = false




func split_dialog_by_pause(text: String) -> Array:
	var parts := []
	var current := ""

	for char in text:

		# ⛔ NO mostramos el separador
		if char == "|":
			parts.append(current.strip_edges())
			current = ""
			continue

		current += char

		# pausas normales por puntuación
		if char in [  ","]:
			parts.append(current.strip_edges())
			current = ""

	if current.strip_edges() != "":
		parts.append(current.strip_edges())

	return parts
