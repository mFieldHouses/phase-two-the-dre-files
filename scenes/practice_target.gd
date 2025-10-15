extends Enemy

var death_animation := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	speed = 5
	#$model.mesh = $model.mesh.duplicate(true)
	
func _physics_process(delta: float) -> void:
	$Sprite3D.look_at(GlobalData.player_instance.global_position)
	if death_animation == false:
		match movement_state:
			MovementState.IDLE:
				idle()
			MovementState.WAITING_TO_MOVE:
				wait_to_move(delta)
			MovementState.MOVE:
				move()
	velocity += get_gravity() * delta
	move_and_slide()

func idle():
	velocity = Vector3.ZERO
	idle_wait_time = randf_range(0, 0.5)
	idle_timer_count = idle_wait_time
	movement_state = MovementState.WAITING_TO_MOVE

func wait_to_move(delta):
	idle_timer_count -= delta
	if idle_timer_count <= 0.0:
		var target = get_new_target_location()
		navigation_agent_3d.target_position = target
		movement_state = MovementState.MOVE
	
func get_new_target_location():
	var offset_x = randf_range(5, 40) * (-1 if randf() < 0.5 else 1)
	var offset_z = randf_range(5, 40) * (-1 if randf() < 0.5 else 1)
	
	if global_position.z + offset_z < -60:
		offset_z = 10
	if global_position.x + offset_x < 28:
		offset_x = 10
	if global_position.z + offset_z > -34:
		offset_z = -10
	if global_position.x + offset_x> 67:
		offset_x = -10
	speed = randf_range(1.0, 7.0)
	return global_transform.origin + Vector3(offset_x, 0, offset_z)
	
func move():
	var current_position = global_transform.origin
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed


func _on_navigation_agent_3d_target_reached() -> void:
	movement_state = MovementState.IDLE

func death():
	
	var tween = create_tween()
	tween.tween_property($Sprite3D, "modulate", Color(1, 1, 1, 0), 1)
	
	
	death_animation = true
	velocity = -GlobalData.player_instance.camera.global_transform.basis.z * 10
	$Sprite3D.scale = Vector3(0.3, 0.3, 0.3)
	for number in range(100):
		$Sprite3D.scale = Vector3(0.3, sin(float(number)/1.5)*0.3, 0.3)
		await get_tree().create_timer(0.01).timeout
	var new_enemy = load("res://scenes/practice_target.tscn").instantiate()
	new_enemy.position = position
	get_parent().add_child(new_enemy)
	var new_enemy2 = load("res://scenes/practice_target.tscn").instantiate()
	new_enemy2.position = position
	get_parent().add_child(new_enemy2)
	queue_free()
