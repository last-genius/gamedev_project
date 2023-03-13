extends CanvasLayer

onready var terrain = $"%Terrain"
onready var camera = $"%Camera"


func _ready():
	get_tree().paused = true


func _on_StartButton_pressed() -> void:
	terrain.setup_navserver()
	visible = false
	get_tree().paused = false
	$"%PlayerSpawner".set_physics_process(false)
	$"../HUD".visible = true
	
	# Put the camera in place with a smooth transition
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	var target_pos = Transform(camera.global_transform.basis, camera._get_pos_with_offset())
	tween.tween_property(camera, "global_transform",
		target_pos.looking_at(camera._get_look_target(), Vector3.UP), 3)
	tween.tween_callback(camera, "set_physics_process", [true])
	tween.tween_callback($"%PlayerSpawner", "set_physics_process", [true])
	tween.tween_callback($"%PlayerSpawner/WaterManager", "change_radius", [0])
