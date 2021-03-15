extends Tree

onready var ui_controller = get_node("../../")
onready var texture_builder = load("res://Addons/GDLFormat/TextureBuilder.gd").new()
onready var model_builder = load('res://Addons/GDLFormat/ModelBuilder.gd').new()
onready var image_viewer = get_node("../../ImageViewer/Image") as TextureRect
onready var mesh_viewer = get_node("../../../MeshViewer") as Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(ui_controller)
	assert(texture_builder)
	assert(model_builder)
	assert(image_viewer)
	assert(mesh_viewer)
	
	self.connect("item_activated", self, "on_item_activated")
	
	pass # Replace with function body.

func on_item_activated():
	var item = self.get_selected()
	var parent = item.get_parent()
	
	# Ignore the root
	if parent == null:
		return
	
	var parent_text = parent.get_text(0)
	var text = item.get_text(0)
	var metadata = item.get_metadata(0)
	
	# Ignore categories
	if text == "Objects" or text == "Textures":
		return
	
	var model = ui_controller.loaded_model
	var model_item = null
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	
	var mesh_children = mesh_viewer.get_children()
	if len(mesh_children):
		for child in mesh_children:
			mesh_viewer.remove_child(child)
			child.queue_free()
		# End For
	# End If
	
	# TODO: Clean up!!
	if parent_text == "Objects":
		var index = metadata['id']
		model_item = model.rom_objs[index]
		var obj_data = model.obj_data[index]
		var obj_def = model.obj_defs[index]
		
		var mesh_array = self.model_builder.build(obj_def.name, model_item, obj_data, [])
		var mesh_instance = MeshInstance.new()
		
		mesh_instance.name = obj_def.name
		mesh_instance.mesh = mesh_array
		
		mesh_viewer.add_child(mesh_instance)
		
		self.image_viewer.visible = false
		
	elif parent_text == "Textures":
		var index = metadata['id']
		
		model_item = model.rom_texs[index]
		var imgTex = self.texture_builder.build("%s/textures.%s" % [file_path, extension], model_item, [])
		
		self.image_viewer.visible = true
		self.image_viewer.texture = imgTex
	elif parent_text == "Object Textures":
		var index = metadata['id']
		var sub_obj = metadata['sub_id']
		
		# Small extra step!
		var obj = model.rom_objs[index]
		
		if sub_obj == -1:
			index = obj.sub_obj_0_tex_index
		else:
			index = obj.sub_obj_data[sub_obj]['tex_index']
		# End If
		# Okay back to normal stuff
		model_item = model.rom_texs[index]
		var imgTex = self.texture_builder.build("%s/textures.%s" % [file_path, extension], model_item, [])
		
		self.image_viewer.visible = true
		self.image_viewer.texture = imgTex
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
