extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	summon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func summon():
	var set_false_again = false
	$CPUParticles3D.speed_scale = 5
	if $Area3D.has_overlapping_bodies():
		GlobalData.player_instance.shooting = true
		set_false_again = true
	await get_tree().create_timer(1).timeout
	$CPUParticles3D.explosiveness = 1
	$CPUParticles3D.one_shot = true
	$CPUParticles3D.emitting = true
	$CPUParticles3D2.emitting = true
	if set_false_again:
		GlobalData.player_instance.shooting = false
	
	var new_child = preload("res://scenes/practice_target.tscn").instantiate()
	get_parent().add_child(new_child)
	new_child.global_position = global_position - Vector3(0, 1.6, 0)
	var tween = create_tween()
	tween.tween_property(new_child, "global_position", Vector3(global_position.x, global_position.y + 1.6, global_position.z), 1)
	await get_tree().create_timer(1).timeout
	$CPUParticles3D.speed_scale = 1
	$CPUParticles3D.explosiveness = 0
	$CPUParticles3D.one_shot = false
	$CPUParticles3D.emitting = true
	await get_tree().create_timer(4).timeout
	summon()
