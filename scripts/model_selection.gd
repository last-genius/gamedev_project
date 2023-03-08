extends BaseButton


func _gui_input(event):
	if event.is_action_pressed("fire"):
		accept_event()
