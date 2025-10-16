extends CharacterBody3D

const SPEED = 6.0 #default walking speed
const SPRINT_SPEED_DELTA = 4.0 #value to be added to SPEED when the player is sprinting
const JUMP_VELOCITY = 4.5

const DEFAULT_FOV = 75
const SPRINTING_FOV = 100
const SHOOTING_RAY_FOV_DELTA = 15

var sprinting : bool = false

var camera_time : float = 0.0

var camera_offset_scale : float = 1.0

var desired_camera_rotation_x : float = 0
var desired_camera_rotation_y : float = 0

var previous_camera_rotation_x : float = 0
var previous_camera_rotation_y : float = 0

var shoot_timeout : float = 0
var shooting : bool = false
var count_jump_charge : bool = false
var jump_charge_timer : float = 0
var max_jump_charge_time : float = 3.0
var max_jump_charge_power : float = 10.0

var grip : float = 1.0

@onready var camera : Camera3D = $Camera3D

var camera_position := 0

var camera_shake_enabled : bool = false
var camera_shake_intensity : float = 1.0
var camera_shake_speed : float = 1.0

@onready var beam_mesh_material : ShaderMaterial = $Camera3D/PositronBeamMesh.get_active_material(0)

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	GlobalData.player_instance = self
	global_position = %Spawnpoint_player.global_position

func _physics_process(delta: float) -> void:
	camera_time += delta
	shoot_timeout -= delta
	if count_jump_charge:
		jump_charge_timer += delta
	
	grip = float(is_on_floor()) * 0.8 + 0.2
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = lerp(velocity.x, direction.x * SPEED + (direction.x * SPRINT_SPEED_DELTA * int(sprinting)), 0.3 * grip)
	velocity.z = lerp(velocity.z, direction.z * SPEED + (direction.z * SPRINT_SPEED_DELTA * int(sprinting)), 0.3 * grip) 
	
	camera.rotation.x = lerp(previous_camera_rotation_x, desired_camera_rotation_x, 0.3)
	rotation.y = lerp(previous_camera_rotation_y, desired_camera_rotation_y, 0.3)
	
	desired_camera_rotation_x = clamp(desired_camera_rotation_x, -0.5 * PI, 0.5 * PI)
	
	previous_camera_rotation_x = camera.rotation.x
	previous_camera_rotation_y = rotation.y
	
	
	#Shooting ==========================================================
	
	if shooting:
		velocity += camera.global_basis.z * Vector3(1.0, 0.7, 1.0)
		update_positron_beam()
	
	#Camera ================================================================
	
	camera.h_offset = sin(camera_time * 80 * camera_shake_speed) * float(camera_shake_enabled) * float(camera_shake_intensity) * 0.02 * float(GlobalSettings.positron_ray_camera_shake)
	camera.v_offset = cos(camera_time * 70 * camera_shake_speed) * float(camera_shake_enabled) * float(camera_shake_intensity) * 0.02 * float(GlobalSettings.positron_ray_camera_shake)
	
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
	
	if event.is_action("shoot_burst") and event.is_pressed() and shoot_timeout <= 0:
		update_positron_beam()
		shoot_positron_burst()
		shake_impact(2.0, 0.1, 1.0)
		#velocity += camera.global_basis.z * 7 * Vector3(1.0, 0.7, 1.0)
	
	elif event.is_action("shoot_ray"):
		toggle_camera_shake(event.is_pressed())
		set_camera_shake_intensity(2.0)
		set_camera_shake_speed()
		shooting = event.is_pressed()
		if event.is_pressed():
			$Camera3D/PositronBeamMesh.visible = true
			$Camera3D/PositronHitParticles.emitting = true
			tween_camera_fov(camera.fov + SHOOTING_RAY_FOV_DELTA)
		else:
			$Camera3D/PositronBeamMesh.visible = false
			$Camera3D/PositronHitParticles.emitting = false
			tween_camera_fov(camera.fov - SHOOTING_RAY_FOV_DELTA)

func update_positron_beam() -> void: ##Updates the scale.z and position.z based on the collision point of PositronHitRay and updates the position of Camera3D/PositronHit
	var _length : float
	if $Camera3D/PositronHitRay.is_colliding():
		_length = ($Camera3D/PositronHitRay.get_collision_point() - global_position).length() #gewoon afstand tussen collision point en player
		if $Camera3D/PositronHitRay.get_collider() is Enemy:
			$Camera3D/PositronHitRay.get_collider().death()
	else:
		_length = 100.0
	
	$Camera3D/PositronBeamMesh.mesh.height = _length #we gaan er hier van uit dat de mesh een CylinderMesh is
	$Camera3D/PositronBeamMesh.mesh.rings = ceil(_length) + 4
	beam_mesh_material.set_shader_parameter("cylinder_length", _length)
	$Camera3D/PositronBeamMesh.position.z = _length / -2.0 #negatieve Z is naar voren
	$Camera3D/PositronHitParticles.position.z = -_length #particles zijn relatief aan camera dus we hoeven alleen z coordinaat aan te passen
	

func shoot_positron_burst() -> void:
	var set_beam_opacity = func x(opacity : float):
		beam_mesh_material.set_shader_parameter("opacity", opacity)
	
	var _ray_opacity_tween = create_tween()
	$Camera3D/PositronHitParticles.emitting = true
	$Camera3D/PositronBeamMesh.visible = true
	beam_mesh_material.set_shader_parameter("opacity", 1.0)
	_ray_opacity_tween.tween_method(set_beam_opacity, 1.0, 0.0, 0.1)
	shoot_timeout = 0.1
	
	await _ray_opacity_tween.finished
	
	$Camera3D/PositronHitParticles.emitting = false
	$Camera3D/PositronBeamMesh.visible = false
	beam_mesh_material.set_shader_parameter("opacity", 1.0)


var _camera_fov_tween : Tween
func tween_camera_fov(new_fov : float, tween_time : float = 0.3) -> void:
	if _camera_fov_tween:
		_camera_fov_tween.kill()
	_camera_fov_tween = create_tween()
	_camera_fov_tween.set_parallel()
	_camera_fov_tween.set_trans(Tween.TRANS_CUBIC)
	_camera_fov_tween.set_ease(Tween.EASE_OUT)
	_camera_fov_tween.tween_property(camera, "fov", new_fov, tween_time)

func toggle_camera_shake(state : bool) -> void:
	camera_shake_enabled = state

func set_camera_shake_intensity(intensity : float = 1.0) -> void:
	camera_shake_intensity = intensity

func set_camera_shake_speed(speed : float = 1.0) -> void:
	camera_shake_speed = speed

func shake_impact(start_intensity : float = 1.0, time : float = 1.0, shake_speed : float = 1.0) -> void:
	toggle_camera_shake(true)
	set_camera_shake_speed(shake_speed)
	
	var _tween = create_tween()
	_tween.tween_method(set_camera_shake_intensity, start_intensity, 0.0, time)
	
	await _tween.finished
	
	toggle_camera_shake(false)
