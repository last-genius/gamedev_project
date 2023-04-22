class_name Health
extends Node

signal health_updated

export var max_health := 20
export var enemy_group: String = "player"
var health := max_health


func board_death():
	health = 0
	emit_signal("health_updated", health, max_health)
	get_parent().process_death(false)


func take_hit(area):
	if area.is_in_group(enemy_group + "_projectiles"):
		area.get_parent().explode()
		var damage = area.get_parent().damage
		print("took %s damage out of %s from %s" % [damage, max_health, enemy_group])
		
		health -= damage
		emit_signal("health_updated", health, max_health)
		if health <= 0:
			get_parent().process_death()
