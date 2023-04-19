extends Panel


func reveal():
	get_tree().paused = true
	visible = true


func _on_ExitButton_button_down() -> void:
	get_tree().paused = false
	visible = false

