class_name WeaponStats
extends Resource


export(Texture) var icon
export(String) var weapon_name
export(String) var nice_name

export var reload_time: float
export var damage: float
export var distance: float


func _to_string():
	return "WeaponStats<%s>" % [weapon_name]
