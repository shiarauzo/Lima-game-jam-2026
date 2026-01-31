extends Control

@onready var card_modal = $CardModal

func _on_card_pressed() -> void:
	print("Card pressed")
	card_modal.show()

func _on_card_modal_close_requested() -> void:
	card_modal.hide()
