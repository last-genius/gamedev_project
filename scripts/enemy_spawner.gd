extends Spatial

export(Dictionary) var ship_models
export var enemy_number = 2
export(Rect2) var rect_spawn
export(SpatialMaterial) var sail_material
onready var terrain: NavigationMeshInstance = $"%Terrain"
var enemy_ships: Array
var enemy_script = preload("res://scripts/enemy.gd")
var area_script = preload("res://scripts/new_area.gd")

func _ready() -> void:
	# warning-ignore:return_value_discarded
	terrain.connect("navmesh_ready", self, "spawn")
	

func spawn():
	for _i in range(enemy_number):
		for key in ship_models.keys():
			var random_location: Vector3 = Vector3.ZERO
			random_location.x = MainLoader.random.randi_range(rect_spawn.position.x, rect_spawn.position.x + rect_spawn.size.x)
			random_location.z = MainLoader.random.randi_range(rect_spawn.position.y, rect_spawn.position.y + rect_spawn.size.y)
			
			# Get a legal point on the navmesh closest to the random location
			var spawn_point = NavigationServer.map_get_closest_point(terrain.map, random_location)
			print("Spawning ", key, " at ", random_location, " | ", spawn_point)
			
			# TODO: Check if the location is legal
			# (there are no other enemies or the player in the radius)
			
			spawn_model(ship_models[key], spawn_point)


func spawn_model(model: PackedScene, coords: Vector3):
	var new_model = model.instance()
	add_child(new_model)
	
	# Set up the enemy parameters
	new_model.global_translation = coords
	new_model.name = "Enemy"
	new_model.set_script(enemy_script)
	new_model.terrain = terrain
	new_model.start_pathfinding()
	
	var detection_area = new_model.get_node("DetectionArea")
	detection_area.setup()
	
	# Change enemy's sail colors
	for sail in ["sail_back", "sail_middle", "sail_front"]:
		var sail_model: MeshInstance = new_model.get_node("model/" + sail)
		if sail_model != null and is_instance_valid(sail_model):
			sail_model.material_override = sail_material
	
	# TODO: Set up enemy combat params class
	
	# Add an area to detect collisions
	var new_area = Area.new()
	new_area.set_script(area_script)
	new_area.add_to_group("enemies")
	new_model.add_child(new_area)
	var big_col = new_model.get_node("CollisionShape")
	new_model.remove_child(big_col)
	var col = new_model.get_node("SmallCollisionShape")
	new_model.remove_child(col)
	new_area.add_child(col)
	
	enemy_ships.append(new_model)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
