class_name Weapon
extends Spatial


export(Resource) var stats

func _to_string():
	return "Weapon<%s>" % [stats.weapon_name]
