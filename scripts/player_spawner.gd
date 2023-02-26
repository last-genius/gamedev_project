extends "res://scripts/player_controller.gd"

export var ship_models: Dictionary
var selected_model
var child_model


func _ready() -> void:
	# Add the default model
	if !selected_model:
		selected_model = ship_models.keys()[0]
	add_character_model(selected_model)


# A function to enable selection of the current model
# from the dictionary in the inspector
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


func replace_character_model(new_model):
	# Save the child's position before removing it
	child_model.queue_free()
	
	# Spawn the new model at the needed coordinates
	add_character_model(new_model)

func add_character_model(new_model):
	print("The player selected: ", selected_model)
	child_model = ship_models[new_model].instance()
	add_child(child_model)
		
	# Hack around the fact that KinematicBody needs to have
	# an immediate child as CollisionShape
	var col = child_model.get_node("CollisionShape")
	$CollisionShape.shape = col.shape
	$CollisionShape.transform = col.transform
	col.queue_free()


func _on_HUD_model_changed(new_model) -> void:
	selected_model = new_model
	replace_character_model(new_model)
