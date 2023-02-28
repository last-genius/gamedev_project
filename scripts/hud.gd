extends CanvasLayer

signal model_changed

onready var spawner = $"%PlayerSpawner"
onready var option_button: OptionButton = $OptionButton


func _ready() -> void:
	# Fill up the option button with the ship models
	print(spawner.ship_models)	
	var keys = spawner.ship_models.keys()
	
	for i in keys.size():
		var model = keys[i]
		option_button.add_item(model)
		
		if model == spawner.selected_model:
			option_button.select(i)


func _on_OptionButton_item_selected(index: int) -> void:
	emit_signal("model_changed", spawner.ship_models.keys()[index])
