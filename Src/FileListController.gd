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
	
	# Ignore categories
	if text == "Objects" or text == "Textures":
		return
	
	var model = ui_controller.loaded_model
	var model_item = null
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	
	if parent_text == "Objects":
		var index = 0
		for obj_def in model.obj_defs:
			if text == obj_def.name:
				index = obj_def.index
				break
		
		model_item = model.rom_objs[index]
	elif parent_text == "Textures":
		var index = 0
		for tex_def in model.tex_defs:
			if text == tex_def.name:
				index = tex_def.index
				break
		model_item = model.rom_texs[index]
		var imgTex = self.texture_builder.build("%s/textures.%s" % [file_path, extension], model_item, [])
		image_viewer.texture = imgTex
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
