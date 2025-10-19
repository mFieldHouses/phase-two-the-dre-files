extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(dir_contents("res://assets/textures/fish"))
	var texture = load(dir_contents("res://assets/textures/fish").pick_random())
	$Sprite3D.texture = texture
	$Sprite3D2.texture = texture
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func dir_contents(path):
	var dir = DirAccess.open(path)
	var all_files_in_folder : Array
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#print("Found directory: " + file_name)
			elif not file_name.ends_with(".import"):
				all_files_in_folder.append(str(path) + "/" + file_name)
			file_name = dir.get_next()
	else:
		pass
		#print("An error occurred when trying to access the path.")
	return all_files_in_folder
