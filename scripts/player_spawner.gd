tool
extends Spatial

export(Array, PackedScene) var ship_models
export var selected_model: int = 0

func _ready() -> void:
	var player_model = ship_models[selected_model].instance()
	add_child(player_model)
