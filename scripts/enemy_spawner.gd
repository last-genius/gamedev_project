extends Spatial

var ship_model = preload("res://assets/ship_models/PirateShip.tscn")
var enemy_script = preload("res://scripts/enemy.gd")
var area_script = preload("res://scripts/new_area.gd")
var long_cannon = preload("res://items/weapons/long_cannon.tscn")

export(int) var enemy_number = 2
export(int) var spawn_radius
export(SpatialMaterial) var sail_material

onready var terrain: NavigationMeshInstance = $"%Terrain"
var enemy_ships: Array
var difficulty := 1


func _ready() -> void:
	# warning-ignore:return_value_discarded
	terrain.connect("navmesh_ready", self, "initial_spawn")
	

func initial_spawn():
	for _i in range(enemy_number):
		spawn()


func death_spawn(past_location):
	difficulty += 1
	spawn(past_location)
	

func spawn(past_location := Vector3.ZERO):
	var random_location := past_location
	random_location.x += MainLoader.random.randi_range(50, spawn_radius) * ((MainLoader.random.randi_range(0, 1) * 2)-1)
	random_location.z += MainLoader.random.randi_range(50, spawn_radius) * ((MainLoader.random.randi_range(0, 1) * 2)-1)
	
	# Get a legal point on the navmesh closest to the random location
	var spawn_point = NavigationServer.map_get_closest_point(terrain.map, random_location)
	print("ENEMY SPAWN at %s | %s | difficulty: %s" % [random_location, spawn_point, difficulty])
	
	# TODO: Check if the location is legal
	# (there are no other enemies or the player in the radius)
	
	spawn_model(ship_model, spawn_point)


func spawn_model(model: PackedScene, coords: Vector3):
	var new_model: Spatial = model.instance()
	add_child(new_model)
	
	# Set up the enemy parameters
	new_model.global_translation = coords
	new_model.name = "Enemy"
	new_model.set_script(enemy_script)
	new_model.terrain = terrain
	new_model.connect("died", self, "death_spawn")
	
	var detection_area = new_model.get_node("DetectionArea")
	detection_area.setup()
	
	# Change enemy's sail colors
	for sail in ["sail_back", "sail_middle", "sail_front"]:
		var sail_model: MeshInstance = new_model.get_node("model/" + sail)
		if sail_model != null and is_instance_valid(sail_model):
			sail_model.material_override = sail_material
	
	# TODO: Set up enemy combat params class
	var stats = {"health": 5 + difficulty, "crew": 4 + difficulty,
			"speed": 10 + (difficulty * 0.5), "gold": difficulty, "wood": difficulty}
	new_model.stats = stats.duplicate(true)
	new_model.default_weapon = long_cannon
	new_model.start_pathfinding()
	
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
