extends Node

#onready var file_list_container = get_node("./Container") as WindowDialog
onready var file_loader = get_node("./Scripts/FileLoader")
var loaded_model = null

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(file_loader)
	#assert(file_list_container)
	
	#file_list_container.popup()
	#file_list_container.get_close_button().hide()
	
	get_tree().connect("files_dropped", self, "on_file_dropped")
# End Func

func on_file_dropped(files: PoolStringArray, screen: int):
	print("Files!", files, screen)
	
	# Only allow one file to be dropped
	if len(files) > 1:
		return
	# End If
	
	self.loaded_model = file_loader.on_file_load(files[0])
# End Func
