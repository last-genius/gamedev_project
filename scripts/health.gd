class_name Health
extends Node

signal health_updated

export var max_health := 20
export var enemy_group: String = "player"
var health := max_health


func take_hit(area):
	if area.is_in_group(enemy_group + "_projectiles"):
		area.get_parent().explode()
		var damage = area.get_parent().damage
		print("took ", damage, " damage")
		
		health -= damage
		if health <= 0:
			get_parent().process_death()
		else:
			emit_signal("health_updated", health, max_health)
