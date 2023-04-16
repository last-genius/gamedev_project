tool
extends "res://scripts/player_controller.gd"

export(Dictionary) var ship_models
onready var selected_model = ship_models.keys()[0]

var area_script = preload("res://scripts/new_area.gd")
var child_model


func _ready() -> void:
	# Add the default model
	add_character_model(selected_model)


func replace_character_model(new_model):
	# Save the child's position before removing it
	child_model.queue_free()
	var col = get_node_or_null("CollisionShape")
	if col != null and is_instance_valid(col):
		col.queue_free()
		
	var area = get_node_or_null("Area")
	if area != null and is_instance_valid(area):
		area.queue_free()
	
	# Spawn the new model at the needed coordinates
	add_character_model(new_model)


func add_character_model(new_model):
	print("The player selected: ", new_model)
	child_model = ship_models[new_model].instance()
	add_child(child_model)
	
	#var healthbar = child_model.get_node_or_null("HealthBar")
	#if healthbar != null and is_instance_valid(healthbar):
	#	child_model.remove_child(healthbar)
	
	# Hack around the fact that KinematicBody needs to have
	# an immediate child as CollisionShape
	var new_area = Area.new()
	new_area.name = "Area"
	new_area.set_script(area_script)
	add_child(new_area)
	
	var small_col = child_model.get_node_or_null("SmallCollisionShape")
	if small_col != null and is_instance_valid(small_col):
		child_model.remove_child(small_col)
	new_area.add_child(small_col)
	var col = child_model.get_node("CollisionShape")
	child_model.remove_child(col)
	add_child(col)


func _on_HUD_model_changed(new_model) -> void:
	selected_model = new_model
	replace_character_model(new_model)
	
	

# A function to enable selection of the current model
# from the dictionary in the inspector
# ? Might not work now since I've changed this script from 'tool'
func _get_property_list() -> Array:
	return [
		{
			name = "selected_model",
			type = TYPE_STRING,
			hint = PROPERTY_HINT_ENUM,
			hint_string = PoolStringArray(ship_models.keys()).join(","),
			usage = PROPERTY_USAGE_DEFAULT,
		},
	]
