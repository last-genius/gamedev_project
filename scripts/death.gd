extends Panel


func reveal():
	get_tree().paused = true
	visible = true


func _on_ExitButton_button_down() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_RestartButton_button_down() -> void:
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
