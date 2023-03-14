extends Node

export var texture_progress_path: NodePath
onready var texture_progress: TextureProgress = get_node(texture_progress_path)
export var health_node_path: NodePath = "../../PlayerSpawner/Health"
onready var health_node: Node = get_node(health_node_path)

export (float, 0, 1, 0.05) var caution_zone = 0.5
export (float, 0, 1, 0.05) var danger_zone = 0.2


func _ready():
# warning-ignore:return_value_discarded
	health_node.connect("health_updated", self, "update_health")


func update_health(health, max_health):
	if !texture_progress.visible:
		texture_progress.visible = true

	if health < max_health * danger_zone:
		texture_progress.tint_progress = Color.red
	elif health < max_health * caution_zone:
		texture_progress.tint_progress = Color.yellow
	else:
		texture_progress.tint_progress = Color.green
	
	texture_progress.value = health
	texture_progress.max_value = max_health
