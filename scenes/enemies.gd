extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_children_of_type(type : String) -> Array[Node]:
	var result : Array[Node]
	for child in get_children():
		if child.get_class() == type:
			result.append(child)
	return result
