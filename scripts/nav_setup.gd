extends NavigationMeshInstance

signal navmesh_ready

var map: RID


func _ready():
	# Use call deferred to make sure the entire SceneTree Nodes are setup
	# else yield on 'physics_frame' in a _ready() might get stuck
	call_deferred("setup_navserver")


func setup_navserver():
	map = NavigationServer.map_create()
	NavigationServer.map_set_up(map, Vector3.UP)
	NavigationServer.map_set_active(map, true)

	var region = NavigationServer.region_create()
	NavigationServer.region_set_transform(region, Transform())
	NavigationServer.region_set_map(region, map)

	NavigationServer.region_set_navmesh(region, navmesh)

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	emit_signal("navmesh_ready")
