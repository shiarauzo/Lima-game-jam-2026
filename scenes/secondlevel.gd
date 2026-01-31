extends Control

func _on_object1_pressed() -> void:
	$Object1.queue_free()

func _on_object2_pressed() -> void:
	$Object2.queue_free()

func _on_object3_pressed() -> void:
	$Object3.queue_free()

func _on_object4_pressed() -> void:
	$Object4.queue_free()
