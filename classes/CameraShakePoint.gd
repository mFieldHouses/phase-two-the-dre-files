extends Node3D
class_name CameraShakePoint

@export var radius : float = 1.0
@export var inner_radius : float = 0.5
@export var intensity : float = 1.0

func _init(_init_radius : float = 1.0, _init_inner_radius : float = 0.5, _init_intensity : float = 1.0) -> void:
	radius = _init_radius
	inner_radius = _init_inner_radius
	intensity = _init_intensity

func _ready() -> void:
	PositionalCameraShakeManager._submit_shake_point(self)
