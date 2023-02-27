extends Control

onready var player = $"../../PlayerSpawner"
onready var camera: Camera = $"../../Camera Pivot/Camera"
export(Curve2D) var curve
export(Curve3D) var new_curve
export(Array, Curve3D) var curves_arr

var cannons: Spatial = null


func _process(_delta):
	update()


func refresh_curves():
	curves_arr.clear()
	
	if cannons == null:
		cannons = get_node_or_null("../../PlayerSpawner/Player/CannonPositions")
		
	if cannons != null:
		# For each cannon, add a trajectory curve out of it
		for cannon in cannons.get_children():
			new_curve.clear_points()

			var p0 = cannon.global_translation
			var p1 = cannon.global_translation - 4*cannon.global_transform.basis.z + 2*Vector3.UP
			var p2 = cannon.global_translation - 5*cannon.global_transform.basis.z - Vector3.UP
			var p3 = cannon.global_translation - 4*cannon.global_transform.basis.z + Vector3.UP
			new_curve.add_point(p0, Vector3.ZERO, p1 - p0)
			new_curve.add_point(p2, p3-p2, Vector3.ZERO)
			
			curves_arr.append(new_curve.duplicate())


func _draw():
	var color = Color(0, 1, 0)
	var start = camera.unproject_position(player.global_translation)
	var end = camera.unproject_position(player.global_translation - 2*player.global_transform.basis.z)
	draw_line(start, end, color, 8)
	draw_triangle(end, start.direction_to(end), 16, color)
	
	# Draw cannon trajectories
	if Input.is_action_pressed("aim"):
		refresh_curves()
		for curve3d in curves_arr:
			curve.clear_points()
			
			color = Color(1, 0, 0)
			# Translate the 3D trajectory curve into 2D camera space
			var p0 = camera.unproject_position(curve3d.get_point_position(0))
			var p1 = camera.unproject_position(curve3d.get_point_position(0) + curve3d.get_point_out(0))
			var p2 = camera.unproject_position(curve3d.get_point_position(1))
			var p3 = camera.unproject_position(curve3d.get_point_position(1) + curve3d.get_point_in(1))
			curve.add_point(p0, Vector2.ZERO, p1-p0)
			curve.add_point(p2, p3-p2, Vector2.ZERO)
			
			var pts = curve.tessellate()
			for i in len(pts)-1:
				draw_line(pts[i], pts[i+1], color, 8)
			draw_triangle(pts[-1], pts[-2].direction_to(pts[-1]), 16, color)


func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
