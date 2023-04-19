extends Area

func setup():
	var parent = get_parent()
	if parent is Enemy:
		# warning-ignore:return_value_discarded
		self.connect("body_entered", parent, "player_detected")
		# warning-ignore:return_value_discarded
		parent.connect("died", self, "death_disable")
	

func death_disable(_past_location):
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
