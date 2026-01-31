extends Control

@onready var play_button = $VBoxContainer/Play
@onready var options_modal = $OptionsModal

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/firstlevel.tscn")

func _on_options_pressed() -> void:
	options_modal.popup_centered()

func _on_options_modal_close_requested() -> void:
	options_modal.hide()

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_close_pressed() -> void:
	get_tree().quit()
