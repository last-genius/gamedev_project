extends KinematicBody

export var interpolation_rate = 8
export var rotation_rate = 5

export var shift_speed = 14
export var speed = 9

export var req_rotation = 35

var velocity = Vector3.ZERO
var camera: Camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_node("/root/Main/Camera Pivot/Camera")


func _physics_process(delta):
	var direction = Vector3.ZERO
	var cam_basis = camera.global_transform.basis
	var a: Quat
	var b: Quat
	
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction += input_vector.x * cam_basis.x
	direction += input_vector.y * cam_basis.z
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
		# Determine new target position
		var new_position = global_translation + Vector3(direction.x, 0.0, direction.z)
		
		# Interpolate to the new rotation
		a = Quat(global_transform.basis)
		b = Quat(global_transform.looking_at(new_position, Vector3.UP).basis)
		global_transform.basis = Basis(a.slerp(b, rotation_rate * delta))
		
		# Increase movement intensity as we get closer to the right rotation
		var movement_intensity: float = pow(abs((clamp(rad2deg(a.angle_to(b)), 0, req_rotation) / req_rotation) - 1), 2)
		
		# Only move if we have < req_rotation to go
		if movement_intensity > 0.01:
			direction *= movement_intensity
			print(rad2deg(a.angle_to(b)), " | ", movement_intensity)
			if Input.is_action_pressed("sprint"):
				direction *= shift_speed
			else:
				direction *= speed
			
			velocity.x = direction.x
			velocity.z = direction.z
			
			if movement_intensity > 0.99:
				var interpolated = velocity.linear_interpolate(direction, interpolation_rate * delta)
				velocity.x = interpolated.x
				velocity.z = interpolated.z
			
			velocity = move_and_slide(velocity, Vector3.UP)
