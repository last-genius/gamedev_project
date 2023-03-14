extends Spatial

export(PackedScene) var cannonball_model
export(Curve3D) var new_curve
export(Array, Curve3D) var curves_arr


func calculate_curves():
	curves_arr.clear()
	# For each cannon, add a trajectory curve out of it
	for cannon in get_children():
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
