extends CharacterBody3D

# customizable dingen
@export var initial_velocity : float
@export var bullets_spawning_range : float
@export var spread : float
# alleen voor schonere code
var player = GlobalData.player_instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$hit_detect.body_entered.connect(_bullet_hit)
	$Sprite3D.scale = Vector3(1, 1, 1) * randf_range(0.01, 0.3)
	velocity = -player.camera.global_transform.basis.z * initial_velocity + Vector3(randf_range(-spread, spread), randf_range(-spread, spread), randf_range(-spread, spread))
	global_position = player.get_node("BulletOrigin").global_position + Vector3(randf_range(-bullets_spawning_range, bullets_spawning_range), randf_range(-bullets_spawning_range, bullets_spawning_range), randf_range(-bullets_spawning_range, bullets_spawning_range)) 
	
	await get_tree().create_timer(3).timeout
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.y -= 9.81 * delta
	move_and_slide()

func _on_area_3d_body_entered(_body: Node3D) -> void:
	queue_free()

func _bullet_hit(_body):
	print(_body, _body.name, _body.get_parent().name)
	ParticleEffectManager.positron_hit(global_position, player.get_parent())
	queue_free()
	
