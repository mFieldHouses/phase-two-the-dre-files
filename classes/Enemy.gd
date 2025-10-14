extends CharacterBody3D
class_name Enemy

@export var max_hp := 100
@export var speed := 1
var hp : int
@export var all_points : Array
var goal_point : Vector3

enum MovementState {IDLE, WAITING_TO_MOVE, MOVE}
var movement_state : MovementState = MovementState.IDLE

var idle_timer_count : float = 0.0
var idle_wait_time : float = 0.1

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

func next_point(point):
	if point + 1 < all_points.size():
		goal_point = all_points[point + 1]
	else:
		goal_point = all_points[0]

func damage(amount, knockback):
	hp -= amount
	if hp >= 0:
		velocity = -%player.camera.global_transform.basis.z * knockback
	if hp <= 0:
		velocity.y = 10
	
	get_node("model").mesh.material.albedo_color += Color(0.1, 0, 0, 0)
