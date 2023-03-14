extends Area

func _ready():
# warning-ignore:return_value_discarded
	self.connect("area_entered", get_parent().get_node("Health"), "take_hit")
# warning-ignore:return_value_discarded
	get_parent().connect("died", self, "death_disable")
	

func death_disable():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
