extends Spatial

onready var texture_progress: TextureProgress = $"%TextureProgress"

export (float, 0, 1, 0.05) var caution_zone = 0.5
export (float, 0, 1, 0.05) var danger_zone = 0.2

func update_health(health, max_health):
	if health < max_health * danger_zone:
		texture_progress.tint_progress = Color.red
	elif health < max_health * caution_zone:
		texture_progress.tint_progress = Color.yellow
	else:
		texture_progress.tint_progress = Color.green
	
	texture_progress.value = health
	texture_progress.max_value = max_health
