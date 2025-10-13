extends Enemy



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	speed = 10
func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			_on_idle()
		State.WAITING_TO_MOVE:
			_on_waiting_to_move(delta)
		State.MOVE:
			_on_move()
	velocity += get_gravity() * delta
	move_and_slide()


func _on_idle():
	velocity = Vector3.ZERO
	idle_timer_count = idle_wait_time
	state = State.WAITING_TO_MOVE

func _on_waiting_to_move(delta):
	idle_timer_count -= delta
	if idle_timer_count <= 0.0:
		var target = get_new_target_location()
		navigation_agent_3d.target_position = target
		state = State.MOVE
	
func get_new_target_location():
	var offset_x = randf_range(0.5, 20) * (-1 if randf() < 0.5 else 1)
	var offset_z = randf_range(0.5, 20) * (-1 if randf() < 0.5 else 1)
	return global_transform.origin + Vector3(offset_x, 0, offset_z)
	
func _on_move():
	var current_position = global_transform.origin
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed


func _on_navigation_agent_3d_target_reached() -> void:
	state = State.IDLE
