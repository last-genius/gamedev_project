extends Camera

var player
export var offset = Vector3(5, 12, 5)
export var camera_speed = 5.0


func _ready() -> void:
	player = get_node("/root/Main/PlayerSpawner")


func _physics_process(delta: float) -> void:
	var target_position = player.global_translation + offset
	#var smoothed_position = global_translation.linear_interpolate(target_position, camera_speed * delta)
	look_at_from_position(target_position, player.global_translation, Vector3.UP)

