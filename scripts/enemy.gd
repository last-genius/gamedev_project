extends Spatial

var health = 50

func _ready():
	$Area.connect("area_entered", self, "take_hit")
	
	
func take_hit(area):
	print("took ", area.damage, " damage")
