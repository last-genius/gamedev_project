extends KinematicBody

signal died(past_location)

export var interpolation_rate := 8
export var rotation_rate := 0.2

export var shift_speed := 20
export var speed := 14

var velocity := Vector3.ZERO
onready var camera: Camera = $"%Camera"

func _enter_tree():
	for input in ["move_left", "move_right", "move_forward", "move_back"]:
		if not InputMap.has_action(input):
			InputMap.add_action(input)


func _physics_process(delta):
	var direction := Vector3.ZERO
	var cam_basis := camera.global_transform.basis
	var a: Quat
	var b: Quat
	
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
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
		
		# Reset height
		if abs(global_translation.y) > 0.001:
			global_translation.y = 0
			
		# Speed us up if we are sprinting
		if Input.is_action_pressed("sprint"):
			direction *= shift_speed
		else:
			direction *= speed
		
		velocity.x = direction.x
		velocity.z = direction.z
		
		var interpolated := velocity.linear_interpolate(direction, interpolation_rate * delta)
		velocity.x = interpolated.x
		velocity.z = interpolated.z
		
		var _collision_info := move_and_collide(velocity * delta)
			
			#if collision_info:
			#	velocity = velocity.bounce(collision_info.normal)
	
	#sim_tex.material.set_shader_param("col_position", Vector2(global_translation.x, global_translation.z)/10)
	#print(sim_tex.material.get_shader_param("col_position"))


func process_death():
	emit_signal("died", global_translation)
	print("Player died...")
