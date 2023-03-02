extends Spatial

onready var in_game_draw: Control = $"%InGameDraw"
export var reload_time = 3.0
export(PackedScene) var cannonball_model

#var cannon_positions: Spatial
var curves_arr = []
var last_fire_time = 0.0


func _unhandled_input(event):
	var current_time = Time.get_unix_time_from_system()
	if event.is_action_pressed("fire") and (current_time - last_fire_time) > reload_time:
		last_fire_time = current_time
		
		#cannon_positions = get_node_or_null("../../PlayerSpawner/Player/CannonPositions")
		in_game_draw.refresh_curves()
		curves_arr = in_game_draw.curves_arr.duplicate()
		
		for curve in curves_arr:
			var new_ball = cannonball_model.instance()
			new_ball.curve = curve
			new_ball.connect("finished_curve", self, "kill_cannonball")
			add_child(new_ball)


func kill_cannonball(instance):
	instance.queue_free()
