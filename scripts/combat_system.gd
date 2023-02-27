extends Spatial

export(PackedScene) var cannonball_model
#var cannon_positions: Spatial
var curves_arr = []
onready var in_game_draw: Control = $"../../HUD/InGameDraw"

func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		#cannon_positions = get_node_or_null("../../PlayerSpawner/Player/CannonPositions")
		in_game_draw.refresh_curves()
		curves_arr = in_game_draw.curves_arr.duplicate()
		
		for curve in curves_arr:
			var new_ball = cannonball_model.instance()
			new_ball.curve = curve
			new_ball.connect("animation_finished", self, "kill_cannonball")
			add_child(new_ball)


func kill_cannonball(instance):
	instance.queue_free()
