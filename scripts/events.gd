extends Node

# warning-ignore:unused_signal
signal enemy_killed(stats, was_destroyed)
signal stat_changed(stat_name, value)
# warning-ignore:unused_signal
signal board_reveal(show)


var boardable: Enemy
var stats = {"health": 20, "crew": 10, 
			"speed": 10, "gold": 0, "wood": 0}

func _ready():
	# warning-ignore:return_value_discarded
	connect("enemy_killed", self, "enemy_killed")
	# warning-ignore:return_value_discarded
	connect("stat_changed", self, "on_stats_change")


func enemy_killed(enemy_stats: Dictionary, was_destroyed: bool):
	if !was_destroyed:
		emit_signal("stat_changed", "wood", stats.wood + enemy_stats.wood)
	
	emit_signal("stat_changed", "gold", stats.gold + enemy_stats.gold)
	

func on_stats_change(stat_name: String, value: int):
	Events.stats[stat_name] = value
