tool
extends Spatial


var water_tile = preload("res://scenes/WaterTile.tscn")
export var tile_size = 145
export var radius = 1 setget change_radius
onready var player: KinematicBody = $"%PlayerSpawner"

var tiles = {}
var prev_tile = null


func change_radius(new_radius):
	radius = new_radius
	var player_pos = get_player_position()
	var new_tiles = get_neighboring_tiles(player_pos)
	
	if !new_tiles.empty():
		#print("Spawning new water tiles\n\tposition: ", player_pos, "\n\ttiles: ", new_tiles)
		for pos in new_tiles:
			if !(pos in tiles):
				tiles[pos] = water_tile.instance()
				add_child(tiles[pos])
				change_position(tiles[pos], pos)
				
		for pos in tiles.keys():
			if !(pos in new_tiles):
				tiles[pos].queue_free()
				tiles.erase(pos)
				pass


func _ready():
	change_radius(radius)


func change_position(tile, position):
	tile.global_translation.x = position.x
	tile.global_translation.z = position.y
	var col_viewport = tile.get_node("CollisionViewport/Camera")
	col_viewport.global_translation.x = position.x
	col_viewport.global_translation.z = position.y


func get_player_position():
	if player == null:
		return Vector2.ZERO
	else:
		return Vector2(player.global_translation.x, player.global_translation.z)


func get_neighboring_tiles(position: Vector2):
	var neighbors = []
	
	# Calculate the tile the player is positioned in currently
	var center = (position / tile_size).abs().floor() * position.sign()
	center.x += 1.0*sign(position.x) if (fmod(abs(position.x), tile_size) > (tile_size/2)) else 0.0
	center.y += 1.0*sign(position.y) if (fmod(abs(position.y), tile_size) > (tile_size/2)) else 0.0
	
	# Then calculate the neighboring tiles
	for i in range(-radius, radius + 1):
		for j in range(-radius, radius + 1):
			neighbors.append((center + Vector2(i, j)) * tile_size)

	# TODO: convert to more consistent metrics (array of ints?)
	return neighbors
