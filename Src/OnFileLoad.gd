extends Node

onready var file_list = get_node("../../Container/FileList") as Tree

var loaded_model = null

func object_loader(path):
	var obj_builder = load('res://Addons/GDLFormat/ObjectBuilder.gd').new()
	var obj_model = obj_builder.build(path, [])
	self.loaded_model = obj_model
	
	var root = file_list.create_item()
	root.set_text(0, "%s" % path.get_file())
	
	var objs = file_list.create_item(root)
	objs.set_text(0, "Objects")
	
	for obj_def in obj_model.obj_defs:
		# Ignore empty entries
		if obj_def.name == "":
			continue
		var item = file_list.create_item(objs)
		item.set_text(0, obj_def.name)
	# End For
	
	var texs = file_list.create_item(root)
	texs.set_text(0, "Textures")
	
	for tex_def in obj_model.tex_defs:
		# Ignore empty entries
		if tex_def.name == "":
			continue
		var item = file_list.create_item(texs)
		item.set_text(0, tex_def.name)
	# End For
# End Func

# Bootstraps the application
func _ready():
	# For Debug
	#self.object_loader("D:\\GameDev\\opengdl\\GameData\\STATIC\\OBJECTS.PS2")
	pass
# End Func

func on_file_load(path : String):
	
	# Clean up
	file_list.clear()
	
	if "objects." in path.to_lower():
		self.object_loader(path.to_lower())
	# End If
	
	return self.loaded_model
# End Func
