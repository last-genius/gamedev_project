extends Area

func setup():
	# warning-ignore:return_value_discarded
	self.connect("area_entered", self, "area_entered")
	# warning-ignore:return_value_discarded
	self.connect("area_exited", self, "area_exited")
	

func area_entered(area):
	if area.is_in_group("enemies"):
		print("enemies entered the boarding area")
		Events.boardable = area.get_parent()
		Events.emit_signal("board_reveal", true)
	

func area_exited(area):
	if area.is_in_group("enemies"):
		print("enemies exited the boarding area")
		Events.boardable = null
		Events.emit_signal("board_reveal", false)
