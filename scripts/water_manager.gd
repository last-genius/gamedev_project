tool
extends Spatial


var water_tile = preload("res://scenes/WaterTile.tscn")
export var tile_size = 20
export var radius = 1
onready var player: KinematicBody = $"../PlayerSpawner"

var tiles = {}
var prev_tile = null


func _process(_delta):
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
				
		#print("\n\n Tiles currently: ", tiles)
	
	for pos in new_tiles:
		add_neighbor_textures(pos)


func add_neighbor_textures(position):
	var node = tiles[position].get_node("SimulationViewport/ColorRect")
	
	var left_viewport = tiles.get(position - Vector2(tile_size, 0.0))
	var top_viewport = tiles.get(position + Vector2(0.0, tile_size))
	var right_viewport = tiles.get(position + Vector2(tile_size, 0.0))
	var bottom_viewport = tiles.get(position - Vector2(0.0, tile_size))
	
	var neighbors = [
		["left_texture", left_viewport],
		["top_texture", top_viewport],
		["right_texture", right_viewport],
		["bottom_texture", bottom_viewport],
	]
	
	print("Setting node neighbors for position ", position, ":")
	for neighbor in neighbors:
		if neighbor[1] != null:
			node.material.set_shader_param(neighbor[0], neighbor[1].get_node("SimulationViewport").get_texture())
		print("\t", neighbor[0], ": ", node.material.get_shader_param(neighbor[0]))


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
	
	# If the player has moved into a new tile
	if center != prev_tile:
		prev_tile = center
		
		# Then calculate the neighboring tiles
		#print(position, center)
		for i in range(-radius, radius + 1):
			for j in range(-radius, radius + 1):
				neighbors.append((center + Vector2(i, j)) * tile_size)
	
	# TODO: convert to more consistent metrics (array of ints?)
	return neighbors
