extends Control

var random_number = RandomNumberGenerator.new()

func _ready() -> void:
	$Sprite2D.self_modulate = Color(0, 0, 0, 1)
	flash()
#func _physics_process(_delta: float) -> void:
	

func flash():
	for number in range(round(random_number.randf_range(1, 5))):
		$Sprite2D.self_modulate = Color(0.7, 0.7, 0.7, 1)
		await get_tree().create_timer(random_number.randf_range(0.01, 0.3)).timeout
		$Sprite2D.self_modulate = Color(0.2, 0.2, 0.2, 1)
		await get_tree().create_timer(random_number.randf_range(0.01, 0.3)).timeout
	await get_tree().create_timer(random_number.randf_range(0.1, 4)).timeout
	flash()
