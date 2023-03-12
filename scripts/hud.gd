extends CanvasLayer

signal model_changed
signal weapon_changed

onready var spawner = $"../PlayerSpawner"
onready var combat_sys = spawner.get_node("CombatSystem")
onready var reload_timer: Timer = combat_sys.get_node("ReloadTimer")
onready var option_button: OptionButton = $"%OptionButton"
onready var weapon_selection: OptionButton = $"%WeaponSelection"
onready var reload_progress: TextureProgress = $"%ReloadProgress"
onready var fire_button: Button = $"%FireButton"
var fire_button_disabled = false


func _ready() -> void:
	combat_sys.connect("weapons_updated", self, "update_weapons")
	# warning-ignore:return_value_discarded
	reload_timer.connect("timeout", self, "finish_reload")

	# Fill up the option button with the ship models
	print("Models to select from: ", spawner.ship_models)	
	var keys = spawner.ship_models.keys()
	
	for i in keys.size():
		var model = keys[i]
		option_button.add_item(model, i)
		
		if model == spawner.selected_model:
			option_button.select(i)	


func _process(_delta: float):
	var value: float
	if reload_timer.is_stopped():
		fire_button_disabled = false
		value = 1.0
	else:
		value = 1 - reload_timer.get_time_left() / reload_timer.get_wait_time()
		if value < 1.0 and !fire_button_disabled:
			fire_button_disabled = true
			fire_button.text = "..."
		
	reload_progress.value = value


func update_weapons(weapons: Array, selected_weapon: int):
	print("updating weapons", weapons)
	for i in weapons.size():
		var weapon = weapons[i]
		weapon_selection.add_icon_item(weapon.icon, weapon.name, i)
		
		if i == selected_weapon:
			option_button.select(i)


func _on_OptionButton_item_selected(index: int) -> void:
	emit_signal("model_changed", spawner.ship_models.keys()[index])


func _on_WeaponSelection_item_selected(index: int) -> void:
	emit_signal("weapon_changed", index)


func _on_FireButton_button_down() -> void:
	Input.action_press("fire")
	

func finish_reload():
	Input.action_release("fire")
	fire_button.text = "Fire!"

