class_name Enemy
extends Spatial

signal died

onready var reload_timer: SceneTreeTimer
export var reload_time := 3.0
var weapons_manager: Spatial

var terrain: NavigationMeshInstance
var speed := 6.0
var interpolation_rate := 8
var rotation_rate := 0.2
var path = []

const FRAMES_BETWEEN_UPDATES := 60
var _frame_counter = 0

enum STATES {TRAVELLING, FIGHTING, DYING}
var current_state = STATES.TRAVELLING
var player_body: KinematicBody
var circle_point: Vector3

var stats := {}


func start_pathfinding():
	$Health.max_health = stats["health"]
	$Health.health = stats["health"]
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
	
	# Simple AI behavior
	if current_state == STATES.DYING:
		return
	elif current_state == STATES.TRAVELLING:
		# Make up a random location to go to if we haven't yet encountered the player
		if path.size() == 0:
			var random_location = _generate_random_location(Vector2(global_translation.x,global_translation.z), 100)
			var target_point = NavigationServer.map_get_closest_point(terrain.map, random_location)
			path = NavigationServer.map_get_path(terrain.map, global_translation, target_point, true)
			print("started the path to random location ", target_point)
	elif current_state == STATES.FIGHTING:
		# Shoot every X frames
		if _frame_counter == 0:
			shoot()
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
				
			global_translation += direction * velocity


# A sequence of death animations and cleanup:
# 1. `process_death` - explosion
# 2. `drowning_animation` - drowning below the surface
# 3. `complete_death` - remove the enemy node
func process_death():
	$HealthBar.visible = false
	current_state = STATES.DYING
	emit_signal("died")
	Events.emit_signal("enemy_killed", stats, true)
	
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


# Connected to the body_entered signal on the child area
func player_detected(body: Node):
	if body.is_in_group("player"):
		current_state = STATES.FIGHTING
		player_body = body


func shoot():
	if reload_timer == null or reload_timer.get_time_left() <= 0.0:
		reload_timer = get_tree().create_timer(reload_time)
			
		weapons_manager = get_node_or_null("WeaponsManager")
		weapons_manager.shoot("enemy")
