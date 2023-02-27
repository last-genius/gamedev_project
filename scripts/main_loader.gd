# An autoloader script that changes scenes through a loading screen
extends Node

var loader
var current_scene
var time_max = 100 # msec
var loading_bar = preload("res://scenes/loading_bar.tscn")


func _ready():
	var root = get_tree().get_root()
	# Since we've been autoloaded into the scene, the actual scene
	# is going to be the last one in the tree
	current_scene = root.get_child(root.get_child_count() -1)
	
	# Add the loading bar scene, hide it by default
	loading_bar = loading_bar.instance()
	self.add_child(loading_bar)
	loading_bar = loading_bar.get_node("ProgressBar")
	loading_bar.visible = false


func show_loading(percent):
	loading_bar.value = percent
	print(percent)
	if !loading_bar.visible:
		loading_bar.visible = true


func hide_loading():
	loading_bar.visible = false


func change_scene(path):
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		show_loading("Error!")
		return
	set_process(true)
	
	current_scene.queue_free() # Get rid of the old scene.


func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	show_loading(progress)


func _process(_delta):
	if loader == null:
		set_process(false)
		return

	# Poll the interactive loader as many times as we can this frame, update progress
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			current_scene = resource.instance()
			get_node("/root").add_child(current_scene)
			hide_loading()
			break
		elif err == OK:
			update_progress()
		else:
			show_loading("Error!")
			loader = null
			break
