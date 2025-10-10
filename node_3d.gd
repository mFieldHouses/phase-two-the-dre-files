extends CharacterBody3D

# customizable dingen
@export var initial_velocity : float
@export var bullets_spawning_range : float
# alleen voor schonere code
var player = information.player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite3D.scale = Vector3(1, 1, 1) * randf_range(0.1, 0.5)
	global_position = player.get_node("Bullet_origin").global_position + Vector3(randf_range(-bullets_spawning_range, bullets_spawning_range), randf_range(-bullets_spawning_range, bullets_spawning_range), randf_range(-bullets_spawning_range, bullets_spawning_range)) 
	velocity = -player.camera.global_transform.basis.z * initial_velocity
	await get_tree().create_timer(3).timeout
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()

func _on_area_3d_body_entered(_body: Node3D) -> void:
	queue_free()
