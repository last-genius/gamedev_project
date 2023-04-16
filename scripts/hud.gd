extends CanvasLayer

signal model_changed
signal weapon_changed

onready var spawner = $"../PlayerSpawner"
onready var combat_sys = spawner.get_node("CombatSystem")
onready var reload_timer: Timer = combat_sys.get_node("ReloadTimer")
onready var weapon_selection: OptionButton = $"%WeaponSelection"
onready var reload_progress: TextureProgress = $"%ReloadProgress"
onready var fire_button: Button = $"%FireButton"
onready var death_panel: Panel = $DeathPanel

onready var health_label: Label = $HealthLabel
onready var crew_label: Label = $CrewLabel
onready var speed_label: Label = $SpeedLabel
onready var gold_label: Label = $GoldLabel
onready var wood_label: Label = $WoodLabel
onready var stats = {"health": health_label, "crew": crew_label, 
			"speed": speed_label, "gold": gold_label, "wood": wood_label}

var fire_button_disabled = false


func _ready() -> void:
	combat_sys.connect("weapons_updated", self, "update_weapons")
	# warning-ignore:return_value_discarded
	reload_timer.connect("timeout", self, "finish_reload")
	spawner.connect("died", death_panel, "reveal")
	Events.connect("stat_changed", self, "on_stats_change")
	
	for stat in Events.stats:
		on_stats_change(stat, Events.stats[stat])


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
			weapon_selection.select(i)


func _on_OptionButton_item_selected(index: int) -> void:
	emit_signal("model_changed", spawner.ship_models.keys()[index])


func _on_WeaponSelection_item_selected(index: int) -> void:
	emit_signal("weapon_changed", index)


func _on_FireButton_button_down() -> void:
	Input.action_press("fire")
	

func on_stats_change(stat_name: String, value: int):
	stats[stat_name].text = str(value)
	

func finish_reload():
	Input.action_release("fire")
	fire_button.text = "Fire!"

