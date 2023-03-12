extends Panel

func _process(_delta: float):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			_on_ContinueButton_button_down()
		else:	
			_on_PauseButton_button_down()


func _on_PauseButton_button_down() -> void:
	visible = true
	get_tree().paused = true


func _on_ContinueButton_button_down() -> void:
	visible = false
	get_tree().paused = false


func _on_ExitButton_button_down() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
