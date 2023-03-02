extends Spatial

signal finished_curve

export var damage = 3.0
export(Curve3D) var curve
export var total_time = 0.5
var t = 0.0
var had_collision: bool = false


func _ready() -> void:
	set_as_toplevel(true)
	$StylizedExplosion/AnimationPlayer.connect("animation_finished", self, "finished_curve")


func _physics_process(delta):
	if !had_collision:
		t += delta
		global_translation = curve.interpolate_baked(t / total_time * curve.get_baked_length(), true)
		if t >= total_time:
			finished_curve()


func finished_curve(_anim_name="Explosion"):
	emit_signal("finished_curve", self)


func _on_Area_area_entered(area: Area) -> void:
	if (area.is_in_group("enemies")):
		had_collision = true
		print("Exploding on impact with ", area)
		
		$StylizedExplosion.visible = true
		$StylizedExplosion/AnimationPlayer.play("Explosion")
		$cannonBall.visible = false
