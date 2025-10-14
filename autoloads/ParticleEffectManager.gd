extends Node

func positron_hit(global_pos: Vector3, root_node : Node) -> void:
	var _new_emitter : CPUParticles3D = preload("res://scenes/particle_effects/positron_hit.tscn").instantiate()
	
	root_node.add_child(_new_emitter)
	_new_emitter.global_position = global_pos
