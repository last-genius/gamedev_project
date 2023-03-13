extends Camera

export var offset = Vector3(10, 20, 10)
export var camera_speed = 12.0
onready var player: KinematicBody = $"%PlayerSpawner"


func _ready():
	set_physics_process(false)


func _get_pos_with_offset() -> Vector3:
	return player.global_translation + offset
	

func _get_look_target() -> Vector3:
	return player.global_translation


func _physics_process(_delta: float) -> void:
	#var smoothed_position = global_translation.linear_interpolate(target_position, camera_speed * delta)
	look_at_from_position(_get_pos_with_offset(), _get_look_target(), Vector3.UP)

