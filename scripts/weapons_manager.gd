class_name WeaponsManager
extends Spatial


export(PackedScene) var cannonball_model
export(Curve3D) var new_curve
export(Array, Curve3D) var curves_arr

onready var weapons_arr: Array = get_children()
var weapons_num := 3 setget _add_weapon
var current_weapon


func change_weapons(new_weapon):
	print("SPAWNING WEAPON %s | %s" % [new_weapon, weapons_num])
	current_weapon = new_weapon
	for i in range(0, weapons_num):
		_spawn_weapon(i)
		
	for i in range(weapons_num, weapons_arr.size()):
		_spawn_weapon(i, true)


func _add_weapon(new_num: int):
	print("ADD WEAPON %s" % [new_num])
	if current_weapon != null:
		_spawn_weapon(new_num - 1)
	weapons_num = new_num


func _spawn_weapon(index: int, to_remove = false):
	# Remove the previous weapon
	var spawn_point: Spatial = weapons_arr[index]
	var point_children = spawn_point.get_children()
	if point_children.size() > 0:
		spawn_point.remove_child(point_children[0])
	
	# Spawn the new weapon
	if !to_remove:
		var spawned = current_weapon.instance()
		spawn_point.add_child(spawned)
		spawned.global_translation = spawn_point.global_translation


func calculate_curves():
	curves_arr.clear()
	# For each cannon, add a trajectory curve out of it
	for i in range(0, weapons_num):
		var cannon = weapons_arr[i] 
		if cannon.is_in_group("weapons"):
			new_curve.clear_points()

			var p0 = cannon.global_translation
			var p1 = cannon.global_translation - 4*cannon.global_transform.basis.z + 2*Vector3.UP
			var p2 = cannon.global_translation - 14*cannon.global_transform.basis.z - 2*Vector3.UP
			var p3 = cannon.global_translation - 10*cannon.global_transform.basis.z + Vector3.UP
			new_curve.add_point(p0, Vector3.ZERO, p1 - p0)
			new_curve.add_point(p2, p3-p2, Vector3.ZERO)
			
			curves_arr.append(new_curve.duplicate())
		
	return curves_arr


func shoot(group_name: String):
	calculate_curves()
	curves_arr = curves_arr.duplicate()
	
	for curve in curves_arr:
		var new_ball = cannonball_model.instance()
		new_ball.add_area_group(group_name + "_projectiles")
		new_ball.curve = curve
		new_ball.connect("finished_curve", self, "kill_cannonball")
		add_child(new_ball)


func kill_cannonball(instance):
	instance.queue_free()
