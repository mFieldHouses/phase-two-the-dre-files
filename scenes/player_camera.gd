extends Camera3D

var camera_shake_enabled : bool = false
var _previous_camera_shake_intensity : float = 1.0
var camera_shake_intensity : float = 1.0
var camera_shake_speed : float = 1.0

var _camera_time : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_camera_time += delta
	h_offset = sin(_camera_time * 80 * camera_shake_speed) * ((float(camera_shake_enabled) * camera_shake_intensity) + PositionalCameraShakeManager.get_intensity_at_point(global_position)) * 0.02 * float(GlobalSettings.positron_ray_camera_shake)
	v_offset = cos(_camera_time * 70 * camera_shake_speed) * ((float(camera_shake_enabled) * camera_shake_intensity) + PositionalCameraShakeManager.get_intensity_at_point(global_position)) * 0.02 * float(GlobalSettings.positron_ray_camera_shake)
	

var _camera_fov_tween : Tween
var _goal_fov : float = 0.0
func tween_fov(new_fov : float, tween_time : float = 0.3) -> void:
	if _camera_fov_tween:
		fov = _goal_fov
		_camera_fov_tween.kill()
	
	_goal_fov = new_fov
	_camera_fov_tween = create_tween()
	_camera_fov_tween.set_parallel()
	_camera_fov_tween.set_trans(Tween.TRANS_CUBIC)
	_camera_fov_tween.set_ease(Tween.EASE_OUT)
	_camera_fov_tween.tween_property(self, "fov", new_fov, tween_time)
	_camera_fov_tween.finished.connect(func(): _camera_fov_tween = null)

func toggle_camera_shake(state : bool) -> void:
	camera_shake_enabled = state

func set_camera_shake_intensity(intensity : float = 1.0) -> void:
	camera_shake_intensity = intensity

var _current_shake_impact_tween : Tween
func shake_impact(start_intensity : float = 1.0, time : float = 1.0) -> void:
	toggle_camera_shake(true)
	
	if _current_shake_impact_tween:
		_current_shake_impact_tween.kill()
	_current_shake_impact_tween = create_tween()
	_current_shake_impact_tween.tween_method(set_camera_shake_intensity, start_intensity, 0.0, time)
	
	await _current_shake_impact_tween.finished
	
	toggle_camera_shake(false)
