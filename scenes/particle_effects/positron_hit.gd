extends CPUParticles3D

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	emitting = false
	await get_tree().create_timer(lifetime).timeout
	queue_free()
