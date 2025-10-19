extends Node3D
var summon_timer = Timer.new()
@export var Spawning_Timer : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	summon_timer.timeout.connect(summon_fish)
	add_child(summon_timer)
	summon_timer.start(Spawning_Timer)
	GlobalData.throwables = self
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func summon_fish():
	var new_fish = preload("res://scenes/food on floor.tscn").instantiate()
	add_child(new_fish)
	new_fish.global_position = Vector3(randf_range(67, 30), 2.4, randf_range(-53, -35))
	summon_timer.start(3)

func get_children_of_type(type : String) -> Array[Node]:
	var result : Array[Node]
	for child in get_children():
		if child.get_class() == type:
			result.append(child)
	return result
