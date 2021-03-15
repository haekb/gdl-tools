extends Tree

onready var ui_controller = get_node("../../")
onready var texture_builder = load("res://Addons/GDLFormat/TextureBuilder.gd").new()
onready var image_viewer = get_node("../../ImageViewer/Image") as TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(ui_controller)
	assert(texture_builder)
	assert(image_viewer)
	
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
	
	# TODO: Clean up!!
	if parent_text == "Objects":
		var index = metadata['id']
		model_item = model.rom_objs[index]
	elif parent_text == "Textures":
		var index = metadata['id']
		
		model_item = model.rom_texs[index]
		var imgTex = self.texture_builder.build("%s/textures.%s" % [file_path, extension], model_item, [])
		image_viewer.texture = imgTex
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
		image_viewer.texture = imgTex
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
