extends Enemy

var death_animation := false
var dying := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var texture = preload("res://assets/textures/signal-2025-10-16-1708232.png")
	hp = max_hp
	speed = 5
	match randi() % 10 + 1:
		1: 
			$Sprite3D.texture = texture
			$Sprite3D.scale = Vector3(0.2,0.2,0.2)
	
	
	#$model.mesh = $model.mesh.duplicate(true)
	
func _physics_process(delta: float) -> void:
	#$Sprite3D.look_at(GlobalData.player_instance.global_position)
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
	if idle_timer_count <= 0:
		var target = get_new_target_location()
		navigation_agent_3d.target_position = target
		movement_state = MovementState.MOVE
	
func get_new_target_location():
	var offset_x : float
	var offset_z : float
	var goal_x : float
	var goal_z : float
	if randf_range(0.0, 1.0) > 0.5:
		offset_x = randf_range(5, 20) * (-1 if randf() < 0.5 else 1)
		offset_z = randf_range(5, 20) * (-1 if randf() < 0.5 else 1)
		if global_position.z + offset_z < -55:
			offset_z = 5
		if global_position.x + offset_x < 25:
			offset_x = 5
		if global_position.z + offset_z > -35:
			offset_z = -5
		if global_position.x + offset_x > 63:
			offset_x = -5
		speed = randf_range(6.0, 7.0)
		return global_transform.origin + Vector3(offset_x, 0, offset_z)
		
	else:
		var distances_to_fishes : Array
		for child in GlobalData.throwables.get_children_of_type("RigidBody3D"):
			distances_to_fishes.append(child.global_position - global_position)
		goal_x = distances_to_fishes.pick_random().x + global_position.x
		goal_z = distances_to_fishes.pick_random().z + global_position.z
		#print(distances_to_fishes)
		#print(goal_x, goal_z)
		return Vector3(goal_x, 0, goal_z)

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false
	
func move():
	var current_position = global_position
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed
	#print(next_position - current_position)

func _on_navigation_agent_3d_target_reached() -> void:
	var found_fish := false
	var all_target_positions : Array[Vector3]
	var check_if_fish_in_range : Vector3
	for child in GlobalData.throwables.get_children_of_type("RigidBody3D"):
		check_if_fish_in_range = child.global_position - global_position
		if abs(check_if_fish_in_range.length()) < 2:
			for NPC in GlobalData.Enemies.get_children_of_type("CharacterBody3D"):
				all_target_positions.append(NPC.global_position - global_position)
			all_target_positions.erase(Vector3.ZERO)
			child.throw_fish(self, all_target_positions.pick_random())
			found_fish = true
	
	if found_fish == false:
		movement_state = MovementState.IDLE
	else:
		await get_tree().create_timer(1).timeout
		movement_state = MovementState.IDLE
	
	










func death():
	if dying == false:
		dying = true
		var tween = create_tween()
		tween.tween_property($Sprite3D, "modulate", Color(1, 1, 1, 0), 1)
		death_animation = true
		velocity = -GlobalData.player_instance.camera.global_transform.basis.z * 10
		$Sprite3D.scale = Vector3(0.3, 0.3, 0.3)
		for number in range(100):
			$Sprite3D.scale = Vector3(0.3, sin(float(number)/1.5)*0.3, 0.3)
			await get_tree().create_timer(0.01).timeout
		for number in range(2):
			var new_enemy = preload("res://scenes/practice_target.tscn").instantiate()
			new_enemy.position = position
			get_parent().add_child(new_enemy)
			queue_free()
