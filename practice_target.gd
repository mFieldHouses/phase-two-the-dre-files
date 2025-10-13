extends Node3D

@export var max_hp := 100
var hp : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
