extends CharacterBody3D

const SPEED = 6.0
const SPRINT_SPEED_DELTA = 3.0
const JUMP_VELOCITY = 4.5

const DEFAULT_FOV = 75

var sprinting : bool = false

var camera_offset_x : float = 0.0
var camera_offset_y : float = 0.0

var camera_time : float = 0.0

var camera_offset_scale : float = 1.0

var desired_camera_rotation_x : float = 0
var desired_camera_rotation_y : float = 0

var previous_camera_rotation_x : float = 0
var previous_camera_rotation_y : float = 0

var shoot_timeout : float = 0
@onready var camera : Camera3D = $Camera3D

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	GlobalData.player_instance = self
	global_position = %Spawnpoint_player.global_position
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED + (direction.x * SPRINT_SPEED_DELTA * int(sprinting)), 0.3)
		velocity.z = lerp(velocity.z, direction.z * SPEED + (direction.z * SPRINT_SPEED_DELTA * int(sprinting)), 0.3)
	else:
		velocity.x *= 0.8
		velocity.z *= 0.8
	
	camera.rotation.x = lerp(previous_camera_rotation_x, desired_camera_rotation_x, 0.3)
	rotation.y = lerp(previous_camera_rotation_y, desired_camera_rotation_y, 0.3)
	
	desired_camera_rotation_x = clamp(desired_camera_rotation_x, -0.5 * PI, 0.5 * PI)
	
	previous_camera_rotation_x = camera.rotation.x
	previous_camera_rotation_y = rotation.y
	
	# shooting mechanic
	if Input.is_action_pressed("left_mb"):
		if shoot_timeout <= 0:
			shoot_timeout = 0.04
			var positron_projectile = load("res://scenes/positron.tscn").instantiate()
			positron_projectile.get_node("hit_detect").monitoring = false
			positron_projectile.global_position = global_position
			get_parent().add_child(positron_projectile)
			await get_tree().create_timer(0.08).timeout #kleine delay om zeker te weten dat ie uit de buurt van de player is
			positron_projectile.get_node("hit_detect").monitoring = true
		else:
			shoot_timeout -= delta
		
		# ik heb zoveel mogelijk code in de positron zelf gezet zodat het gemakkelijker te vinden en aan te passen is
	
	move_and_slide()



func _input(event):
	if event is InputEventMouseMotion:
		desired_camera_rotation_x += event.relative.y / -2000*PI
		desired_camera_rotation_y += event.relative.x / -2000*PI

	if event.is_action("sprint"):
		if event.is_pressed():
			sprinting = true
		else:
			sprinting = false
