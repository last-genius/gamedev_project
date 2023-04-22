extends Spatial

signal weapons_updated

onready var hud: CanvasLayer = $"%HUD"
onready var in_game_draw: Control = $"%InGameDraw"
onready var reload_timer: Timer = $"%ReloadTimer"

export var reload_time := 3.0
var all_weapons = {
	"short_cannon": [preload("res://items/weapons/short_cannon.tres"), preload("res://items/weapons/short_cannon.tscn")],
	"long_cannon": [preload("res://items/weapons/long_cannon.tres"), preload("res://items/weapons/long_cannon.tscn")]
}
onready var weapons_manager: WeaponsManager
onready var current_weapons := [all_weapons["short_cannon"]]
var selected_weapon: int = 0


func _ready():
	# warning-ignore:return_value_discarded
	hud.connect("ready", self, "_setup_weapons")
	Events.connect("stat_changed", self, "_on_stat_change")
	

func _on_stat_change(stat_name, value):
	if stat_name in all_weapons:
		print("PLAYER WEAPON stat '%s' to %s" % [stat_name, value])
		_change_weapon_number(value)
		
		if value == 1:
			print("APPENDING %s %s" % [stat_name, value])
			current_weapons.append(all_weapons[stat_name])
			emit_signal("weapons_updated", current_weapons, selected_weapon)


func _setup_weapons():
	_on_HUD_weapon_changed(0)
	emit_signal("weapons_updated", current_weapons, selected_weapon)


func _on_HUD_weapon_changed(index: int) -> void:
	selected_weapon = index
	weapons_manager = get_node_or_null("../Player/WeaponsManager")
	_change_weapon_number(Events.stats[all_weapons.keys()[index]])
	weapons_manager.change_weapons(current_weapons[selected_weapon][1])


func _change_weapon_number(value):
	weapons_manager.weapons_num = value


# Handle possible attacks and restart the reload timers
func _process(_delta):
	if Input.is_action_pressed("fire") and reload_timer.is_stopped():
		reload_timer.start(reload_time)
		weapons_manager.shoot("player")
	elif Input.is_action_pressed("board") and Events.boardable != null:
		print("Boarding pressed %s\n\tPlayer crew strength: %s | Enemy crew strength: %s" % [Events.boardable, Events.stats.crew, Events.boardable.stats.crew])
		# There is a possibility for both to die if they have equal crew strengths ;)
		if Events.stats.crew >= Events.boardable.stats.crew:
			Events.boardable.health.board_death()
		if Events.stats.crew <= Events.boardable.stats.crew:
			get_node("../Health").board_death()
			
		Input.action_release("board")

