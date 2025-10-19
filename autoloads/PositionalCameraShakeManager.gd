extends Node

var _shake_points : Array[CameraShakePoint] = []

func _submit_shake_point(_shake_point : CameraShakePoint) -> void:
	if !_shake_points.has(_shake_point):
		_shake_points.append(_shake_point) 

func get_intensity_at_point(position : Vector3) -> float:
	var _intensity_sum : float = 0.0
	
	for _point in _shake_points:
		_intensity_sum += get_intensity_for_shake_point_at_point(_point, position)
	
	#print(_intensity_sum)
	return _intensity_sum

func get_intensity_for_shake_point_at_point(_shake_point : CameraShakePoint, position : Vector3) -> float:
	#print(clamp((-_shake_point.intensity / _shake_point.radius - _shake_point.inner_radius) * ((_shake_point.global_position - position).length() - _shake_point.radius), 0.0, _shake_point.intensity))
	return clamp((-_shake_point.intensity / _shake_point.radius - _shake_point.inner_radius) * ((_shake_point.global_position - position).length() - _shake_point.radius), 0.0, _shake_point.intensity)
