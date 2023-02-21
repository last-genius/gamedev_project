extends Camera

var player: KinematicBody
export var offset = Vector3(5, 5, 5)
export var camera_speed = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("/root/Main/PlayerSpawner").get_child(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
"""
func _physics_process(delta: float) -> void:
	var target_position = player.global_translation + offset
	var smoothed_position = global_translation.linear_interpolate(target_position, camera_speed * delta)
	
	look_at_from_position(smoothed_position, player.global_translation, Vector3.UP)
"""
