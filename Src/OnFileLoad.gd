extends Node

onready var ui_controller = get_node("../../")
onready var file_list = get_node("../../SplitContainer/FileList") as Tree
onready var anim_builder = load('res://Addons/GDLFormat/AnimBuilder.gd').new()

var loaded_model = null
var loaded_anim_model = null
var loaded_world = null

func anim_loader(root : TreeItem):
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	
	#if "players" in file_path.to_lower():
	#	file_path += "\\..\\anim"
	
	var anim = self.anim_builder.build("%s/ANIM.%s" % [file_path, extension], [])
	self.loaded_anim_model = anim
	
	if anim == null:
		return
	
	for i in range(len(anim.skeletons)):
		var skeleton = anim.skeletons[i]
		var skel = file_list.create_item(root)
		skel.set_text(0, skeleton.name)
		skel.set_metadata(0, {'id': i})
	# End For
# End Func


func object_loader(path):
	var obj_builder = load('res://Addons/GDLFormat/ObjectBuilder.gd').new()
	var obj_model = obj_builder.build(path, [])
	
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	
	self.loaded_model = obj_model
	
	var root = file_list.create_item()
	root.set_text(0, "Objects.%s" % extension)
	
	var anims = file_list.create_item(root)
	anims.set_text(0, "Anims")
	
	if "ps2" in path.to_lower():
		anim_loader(anims)
	
	var objs = file_list.create_item(root)
	objs.set_text(0, "Objects")
	
	for obj_def in obj_model.obj_defs:
		# Ignore empty entries
		if obj_def.name == "":
			continue
		var item = file_list.create_item(objs)
		item.set_text(0, obj_def.name)
		item.set_metadata(0, {'id': obj_def.index})
	# End For
	
	var texs = file_list.create_item(root)
	texs.set_text(0, "Textures")
	
	for tex_def in obj_model.tex_defs:
		# Ignore empty entries
		if tex_def.name == "":
			continue
		var item = file_list.create_item(texs)
		item.set_text(0, tex_def.name)
		item.set_metadata(0, {'id': tex_def.index})
	# End For
	
	var model_texs = file_list.create_item(root)
	model_texs.set_text(0, "Object Textures")
	
	# Append the model textures
	for obj_def in obj_model.obj_defs:
		# Ignore empty entries
		if obj_def.name == "":
			continue
		var item = file_list.create_item(model_texs)
		item.set_text(0, "%s" % obj_def.name)
		item.set_metadata(0, {'id': obj_def.index, 'sub_id': -1})
		
		if len(obj_model.rom_objs) == 0:
			continue
		
		var rom_obj = obj_model.rom_objs[obj_def.index]
		
		if rom_obj.sub_obj_count > 1:
			for i in range(len(rom_obj.sub_obj_data)):
				item = file_list.create_item(model_texs)
				item.set_text(0, "%s (SubObj %d)" % [obj_def.name, i+1])
				item.set_metadata(0, {'id': obj_def.index, 'sub_id': i})
		
	# End For
	
# End Func

func world_loader(path):
	var obj_builder = load('res://Addons/GDLFormat/WorldBuilder.gd').new()
	var obj_model = obj_builder.build(path, [])
	self.loaded_world = obj_model
	
	var root = file_list.create_item()
	root.set_text(0, "%s" % path.get_file())
	
	var world_objs = file_list.create_item(root)
	world_objs.set_text(0, "World Objects")
	
	for i in range(len(obj_model.world_objs)):
	#for world_obj in obj_model.world_objs:
		var world_obj = obj_model.world_objs[i]
		# Ignore empty entries
		if world_obj.name == "":
			continue
		var item = file_list.create_item(world_objs)
		item.set_text(0, world_obj.name)
		item.set_metadata(0, {'id': i})
	# End For
	
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	
	self.object_loader("%s/OBJECTS.%s" % [file_path, extension])
	
	pass

# Bootstraps the application
func _ready():
	# For Debug
	#self.object_loader("D:\\GameDev\\opengdl\\GameData\\STATIC\\OBJECTS.PS2")
	pass
# End Func

func on_file_load(path : String):
	
	# Clean up
	file_list.clear()
	TextureCache.clear()
	
	if "objects." in path.to_lower():
		self.object_loader(path.to_lower())
	# End If
	
	if "worlds." in path.to_lower():
		self.world_loader(path.to_lower())
	# End If
	
	return [self.loaded_model, self.loaded_anim_model, self.loaded_world]
# End Func
