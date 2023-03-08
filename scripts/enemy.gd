class_name Enemy
extends Spatial

signal died

var terrain: NavigationMeshInstance
var max_health := 20
var health := max_health
var speed := 6.0
var interpolation_rate := 8
var rotation_rate := 2.1
var req_rotation := 35
var path = []

const FRAMES_BETWEEN_UPDATES := 60
var _frame_counter = 0

enum STATES {TRAVELLING, FIGHTING, DYING}
var current_state = STATES.TRAVELLING
var player_body: KinematicBody
var circle_point: Vector3


func start_pathfinding():
	set_physics_process(true)
	circle_point = _generate_random_circle_point(10.0)


func _generate_random_location(center: Vector2, radius: float):
	var random_location: Vector3 = Vector3.ZERO
	random_location.x = rand_range(center.x - radius, center.x + radius)
	random_location.z = rand_range(center.y - radius, center.y + radius)
	return random_location
	

func _generate_random_circle_point(radius: float):
	var random_location: Vector3 = Vector3.ZERO
	random_location.x = radius * cos(rand_range(0, 2 * PI))
	random_location.z = radius * sin(rand_range(0, 2 * PI))
	return random_location


func _physics_process(delta: float):
	var direction := Vector3.ZERO
	var velocity := delta * speed
	
	if current_state == STATES.DYING:
		return
	elif current_state == STATES.TRAVELLING:
		if path.size() == 0:
			var random_location = _generate_random_location(Vector2(global_translation.x,global_translation.z), 100)
			var target_point = NavigationServer.map_get_closest_point(terrain.map, random_location)
			path = NavigationServer.map_get_path(terrain.map, global_translation, target_point, true)
			print("started the path to random location ", target_point)
	elif current_state == STATES.FIGHTING:
		if _frame_counter == 0:
			path = NavigationServer.map_get_path(terrain.map, global_translation, player_body.global_translation + circle_point, true)
		_frame_counter = wrapi(_frame_counter + 1, 0, FRAMES_BETWEEN_UPDATES)
	
	if path.size() > 0:
		var destination = path[0]
		direction = destination - global_translation
		
		if velocity > direction.length():
			velocity = direction.length()
			path.remove(0)
		
		# Interpolate to the new rotation
		direction = direction.normalized()
		
		if direction.length() > 0.01:
			var a := Quat(global_transform.basis)
			var b := Quat(global_transform.looking_at(global_translation + direction, Vector3.UP).basis)
			global_transform.basis = Basis(a.slerp(b, rotation_rate * delta))
			
			# Increase movement intensity as we get closer to the right rotation
			var movement_intensity: float = pow(abs((clamp(rad2deg(a.angle_to(b)), 0, req_rotation) / req_rotation) - 1), 2)
			
			# Only move if we have < req_rotation to go
			if movement_intensity > 0.01:
				direction *= movement_intensity
				
				global_translation += direction * velocity


func take_hit(area):
	if area.is_in_group("projectiles"):
		var damage = area.get_parent().damage
		print("took ", damage, " damage")
		
		health -= damage
		if health <= 0:
			process_death()
		else:
			if !$HealthBar.visible:
				$HealthBar.visible = true
			$HealthBar.update_health(health, max_health)


func process_death():
	$HealthBar.visible = false
	current_state = STATES.DYING
	emit_signal("died")
	
	# Play the death animation
	$StylizedExplosion.visible = true
	# warning-ignore:return_value_discarded
	$StylizedExplosion/AnimationPlayer.connect("animation_finished", self, "drowning_animation")
	$StylizedExplosion/AnimationPlayer.play("Explosion")
	$model.visible = false
	$ship_wreck.visible = true


func drowning_animation(_anim_name):
	$StylizedExplosion.visible = false
	# warning-ignore:return_value_discarded
	$AnimationPlayer.connect("animation_finished", self, "complete_death")
	$AnimationPlayer.play("drowning")


func complete_death(_anim_name):
	queue_free()


func player_detected(body: Node):
	if body.is_in_group("player"):
		current_state = STATES.FIGHTING
		player_body = body
