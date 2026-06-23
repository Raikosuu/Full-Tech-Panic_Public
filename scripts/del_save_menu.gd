extends Panel
signal save_deleted

func _on_delete_button_pressed() -> void:
	GameState.delete_save()
	hide()
	save_deleted.emit()

	
func _on_close_button_pressed() -> void:
	hide()
