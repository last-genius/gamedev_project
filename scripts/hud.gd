extends CanvasLayer

signal model_changed
signal weapon_changed

onready var spawner = $"../PlayerSpawner"
onready var combat_sys = spawner.get_node("CombatSystem")
onready var reload_timer: Timer = combat_sys.get_node("ReloadTimer")
onready var weapon_selection: OptionButton = $"%WeaponSelection"
onready var reload_progress: TextureProgress = $"%ReloadProgress"
onready var fire_button: Button = $"%FireButton"
onready var board_button: Button = $"%BoardButton"
onready var board_label: RichTextLabel = $BoardLabel
onready var board_rect: ColorRect = $BoardRect
onready var death_panel: Panel = $DeathPanel

onready var health_label: Label = $HealthLabel
onready var crew_label: Label = $CrewLabel
onready var speed_label: Label = $SpeedLabel
onready var gold_label: Label = $GoldLabel
onready var wood_label: Label = $WoodLabel
onready var stats = {"health": health_label, "crew": crew_label, 
			"speed": speed_label, "gold": gold_label, "wood": wood_label}

onready var health_icon: Sprite = $HealthIcon
onready var crew_icon: Sprite = $CrewIcon
onready var speed_icon: Sprite = $SpeedIcon
onready var gold_icon: Sprite = $GoldIcon
onready var wood_icon: Sprite = $WoodIcon
onready var stats_icons = {"health": health_icon, "crew": crew_icon, 
			"speed": speed_icon, "gold": gold_icon, "wood": wood_icon}

var fire_button_disabled = false


func _ready() -> void:
	combat_sys.connect("weapons_updated", self, "update_weapons")
	# warning-ignore:return_value_discarded
	reload_timer.connect("timeout", self, "finish_reload")
	spawner.connect("died", death_panel, "reveal")
	# warning-ignore:return_value_discarded
	Events.connect("stat_changed", self, "on_stats_change")
	# warning-ignore:return_value_discarded
	Events.connect("board_reveal", self, "board_reveal")
	
	board_button.visible = false
	board_label.visible = false
	board_rect.visible = false
	
	for stat in Events.stats:
		on_stats_change(stat, Events.stats[stat], false)


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


func finish_reload():
	Input.action_release("fire")
	fire_button.text = "Fire!"


func _on_BoardButton_button_down() -> void:
	print("BOARD ", Events.boardable)
	Input.action_press("board")
	

func board_reveal(show):
	if show:
		board_button.visible = true
		board_rect.visible = true
		board_label.visible = true
		board_label.bbcode_text = "[color=green]%s[/color][color=#984936] vs. [/color][color=red]%s[/color]" % [Events.stats.crew, Events.boardable.stats.crew]
	else:
		board_button.visible = false
		board_rect.visible = false
		board_label.visible = false


func on_stats_change(stat_name: String, value: int, change_color=true):
	stats[stat_name].text = str(value)
	if change_color:
		stats_icons[stat_name].modulate = Color.green
		stats[stat_name].add_color_override("font_color", Color.green)
		yield(get_tree().create_timer(2.0), "timeout")
	stats_icons[stat_name].modulate = Color("#984936")
	stats[stat_name].add_color_override("font_color", Color("#984936"))

