extends Node

onready var file_loader = get_node("./Scripts/FileLoader")
var loaded_model = null
var loaded_anim = null
var loaded_path = ""
var loaded_filename = ""
var loaded_extension = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(file_loader)
	
	get_tree().connect("files_dropped", self, "on_file_dropped")
# End Func

func on_file_dropped(files: PoolStringArray, screen: int):
	print("Files!", files, screen)
	
	# Only allow one file to be dropped
	if len(files) > 1:
		return
	# End If
	
	# Grab the path of the loaded file
	self.loaded_path = files[0].get_base_dir()
	self.loaded_filename = files[0].get_file()
	self.loaded_extension = files[0].get_extension()
	
	var loaded_files = file_loader.on_file_load(files[0])
	self.loaded_model = loaded_files[0]
	self.loaded_anim = loaded_files[1]
# End Func
