extends CharacterBody3D

const SPEED = 6.0 #default walking speed
const SPRINT_SPEED_DELTA = 4.0 #value to be added to SPEED when the player is sprinting
const JUMP_VELOCITY = 4.5

const DEFAULT_FOV = 75
const SPRINTING_FOV = 100

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
var shooting : bool = false
@onready var camera : Camera3D = $Camera3D

var camera_position := 0
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
	
	$Camera3D/PositronBeamMesh.visible = shooting
	$Camera3D/PositronHitParticles.emitting = shooting
	if shooting:
		update_positron_beam()
	
	# positie camera veranderen
	if Input.is_action_just_pressed("switch_camera"):
		if camera_position == 0:
			camera_position = 1
			camera.position = Vector3(0.5, 1, 1.2)
		else:
			camera_position = 0
			camera.position = Vector3(0, 0.6, -0.4)

	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		desired_camera_rotation_x += event.relative.y / -2000*PI
		desired_camera_rotation_y += event.relative.x / -2000*PI

	if event.is_action("sprint"):
		if event.is_pressed():
			sprinting = true
			tween_camera_fov(SPRINTING_FOV)
		else:
			sprinting = false
			tween_camera_fov(DEFAULT_FOV)
	
	elif event.is_action("shoot"):
		shooting = event.is_pressed()

func update_positron_beam() -> void: ##Updates the scale.z and position.z based on the collision point of PositronHitRay and updates the position of Camera3D/PositronHit
	var _length : float
	if $Camera3D/PositronHitRay.is_colliding():
		_length = ($Camera3D/PositronHitRay.get_collision_point() - global_position).length()
	else:
		_length = 100.0
	
	$Camera3D/PositronBeamMesh.mesh.size.z = _length
	$Camera3D/PositronBeamMesh.position.z = _length / -2.0 #negatieve Z is naar voren
	$Camera3D/PositronHitParticles.position.z = -_length #particles zijn relatief aan camera dus we hoeven alleen z coordinaat aan te passen
	
	
	

func tween_camera_fov(new_fov : float, tween_time : float = 0.3) -> void:
	var _tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(camera, "fov", new_fov, tween_time)
