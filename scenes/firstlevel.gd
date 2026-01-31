extends Control

@onready var card_modal = $CardModal

func _on_card_pressed() -> void:
	card_modal.popup_centered()

func _on_card_modal_close_requested() -> void:
	card_modal.hide()
