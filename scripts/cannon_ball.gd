extends Spatial

signal animation_finished

export(Curve3D) var curve
var t = 0.0
export var total_time = 0.5

func _ready() -> void:
	# Play an explosion animation?
	pass

func _physics_process(delta):
	t += delta
	global_translation = curve.interpolate_baked(t / total_time * curve.get_baked_length(), true)
	if t >= total_time:
		emit_signal("animation_finished", self)
