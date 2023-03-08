extends Control

onready var player = $"%PlayerSpawner"
onready var camera: Camera = $"%Camera"
export(Curve2D) var curve
export(Array, Curve3D) var curves_arr

var cannons: Spatial = null


func refresh_curves():
	if cannons == null or !is_instance_valid(cannons):
		cannons = get_node_or_null("../../PlayerSpawner/Player/WeaponsManager")
		
	if cannons != null and is_instance_valid(cannons):
		curves_arr = cannons.calculate_curves()


func _process(_delta):
	update()


func _draw():
	"""
	# Draw movement direction
	var color = Color(0, 1, 0)
	var start = camera.unproject_position(player.global_translation)
	var end = camera.unproject_position(player.global_translation - 2*player.global_transform.basis.z)
	draw_line(start, end, color, 8)
	draw_triangle(end, start.direction_to(end), 16, color)
	"""
	
	# Draw cannon trajectories
	if Input.is_action_pressed("aim"):
		refresh_curves()
		#$ImmediateGeometry.clear()
		
		for curve3d in curves_arr:
			"""
			var pts3d = curve3d.get_baked_points()
			$ImmediateGeometry.begin(Mesh.PRIMITIVE_LINES)
			$ImmediateGeometry.set_color(Color(0, 0, 1))
			for pt in pts3d:
				$ImmediateGeometry.add_vertex(pt)
			$ImmediateGeometry.end()
			"""

			curve.clear_points()
			var color = Color(1, 0, 0)
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
	#elif Input.is_action_just_released("aim"):
	#	$ImmediateGeometry.clear()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("screenshot"):
		var current_time = Time.get_unix_time_from_system()
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		var path = "user://screenshot" + String(current_time) + ".png"
		print(path)
		image.save_png(path)


func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
