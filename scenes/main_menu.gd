extends Control

func _on_open_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/secondlevel.tscn")

func _on_close_pressed() -> void:
	get_tree().quit()
