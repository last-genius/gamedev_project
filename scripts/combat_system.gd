extends Spatial

signal weapons_updated

onready var hud: CanvasLayer = $"%HUD"
onready var in_game_draw: Control = $"%InGameDraw"
onready var reload_timer: Timer = $"%ReloadTimer"
export var reload_time := 3.0
export(Array) var all_weapons

var weapons_manager: Spatial = null
var current_weapons: Array
var selected_weapon: int = 1
var curves_arr = []
var last_fire_time = 0.0


func _ready():
	# warning-ignore:return_value_discarded
	hud.connect("ready", self, "setup_weapons")
	
	
func setup_weapons():
	# TODO: unlock weapons as we go
	current_weapons = all_weapons
	emit_signal("weapons_updated", current_weapons, selected_weapon)


func _on_HUD_weapon_changed(index: int) -> void:
	selected_weapon = index


func _process(_delta):
	if Input.is_action_pressed("fire") and reload_timer.is_stopped():
		reload_timer.start(reload_time)
		
		weapons_manager = get_node_or_null("../Player/WeaponsManager")
		weapons_manager.shoot("player")
	elif Input.is_action_pressed("board") and Events.boardable != null:
		print("Player crew strength: ", Events.stats.crew, " | Enemy crew strength: ", Events.boardable.stats.crew)
		# There is a possibility for both to die if they have equal crew strengths ;)
		if Events.stats.crew >= Events.boardable.stats.crew:
			Events.boardable.health.board_death()
		if Events.stats.crew <= Events.boardable.stats.crew:
			get_node("../Health").board_death()
			
		Input.action_release("board")

