extends Tree

onready var ui_controller = get_node("../../")
onready var anim_builder = load("res://Addons/GDLFormat/AnimBuilder.gd").new()
onready var texture_builder = load("res://Addons/GDLFormat/TextureBuilder.gd").new()
onready var model_builder = load('res://Addons/GDLFormat/ModelBuilder.gd').new()
onready var image_viewer = get_node("../../ImageViewer/Image") as TextureRect
onready var mesh_viewer = get_node("../../../MeshViewer") as Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(ui_controller)
	assert(anim_builder)
	assert(texture_builder)
	assert(model_builder)
	assert(image_viewer)
	assert(mesh_viewer)
	
	self.connect("item_activated", self, "on_item_activated")
	self.connect("mouse_entered", self, "on_mouse_entered")
	self.connect("mouse_exited", self, "on_mouse_leave")
	
	pass # Replace with function body.

func on_mouse_entered():
	GlobalSignals.emit_signal("OnMouseEnterFileList")
# End Func

func on_mouse_leave():
	GlobalSignals.emit_signal("OnMouseLeaveFileList")
	
	
# This is like load models + skeleton
func load_anim(anim_model, obj_model, index):
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	var skeleton = self.anim_builder.build_skeleton(anim_model, index)
	
	var anim_root = Spatial.new()
	anim_root.name = "AnimRoot"
	
	anim_root.add_child(skeleton)
	skeleton.owner = anim_root
	
	var model_indexes = {}
	var model_meshes = {}
	for bone in anim_model.skeletons[index].data.bones:
		for i in range(len(obj_model.rom_objs)):
			#var name = "%s%s" % [anim_model.skeletons[index].name, bone.name]
			var name = bone.name
			
			if name in obj_model.obj_defs[i].name:
			#if obj_model.obj_defs[i].name == name:
				# No data!
				if !obj_model.obj_data[i]:
					break
				# Save for future reference...
				model_indexes[bone.name] = i
				model_meshes[bone.name] = load_mesh(obj_model, i, bone)
				
				for mesh in model_meshes[bone.name]:
					# Temp: Until we can fix model vs skeleton scaling
					#mesh.scale = Vector3(2.0, 2.0, 2.0)
					skeleton.add_child(mesh)
					mesh.owner = anim_root
				break
			# End If
		# End For
	# End For
	
	var anim_player = AnimationPlayer.new()
	anim_player.name = "AnimPlayer"
	anim_player = self.anim_builder.process_animations(anim_model, index, skeleton, anim_player)
	

	

	anim_root.add_child(anim_player)
	anim_player.owner = anim_root
	
	anim_player.play("READY")
	
	return anim_root

func load_mesh(model, index, rom_skeleton = null):
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	var model_item = model.rom_objs[index]
	var obj_data = model.obj_data[index]
	var obj_def = model.obj_defs[index]
	
	if !obj_data:
		print("No data in this obj")
		return null
	
	var meshes = []
	
	print("Generating %d meshes..." % len(obj_data.vertices))
	for i in range(len(obj_data.vertices)):
		var mesh_array = self.model_builder.build(obj_def.name, model_item, obj_data, i, rom_skeleton, [])
		var mesh_instance = MeshInstance.new()
		
		mesh_instance.name = "%s - %d" % [obj_def.name, i]
		mesh_instance.mesh = mesh_array
		
		var tex_index = model_item.sub_obj_0_tex_index
		if i > 0:
			tex_index = model_item.sub_obj_data[i - 1]['tex_index']
		# End If
		
		print("Texture Index: %d" % tex_index)
		
		var imgTex = load_texture(model, tex_index, [])
		
		var mat = SpatialMaterial.new()
		mat.set_texture(SpatialMaterial.TEXTURE_ALBEDO, imgTex)
		mat.metallic_specular = 0.0
		
		# Required for now, some of our faces are flipped, and I'm not sure how to fix 'em
		# So let's just render both sides...
		mat.params_cull_mode = SpatialMaterial.CULL_DISABLED
		
		mesh_instance.set_surface_material(0, mat)
		meshes.append(mesh_instance)
	
	return meshes
# End Func

func load_texture(model, index, options = []):
	var file_path = ui_controller.loaded_path
	var extension = ui_controller.loaded_extension
	var model_item = model.rom_texs[index]
	return self.texture_builder.build("%s/TEXTURES.%s" % [file_path, extension], model_item, options)
# End Func

func load_object_texture(model, index, sub_obj_index = -1):
	# Small extra step!
	var obj = model.rom_objs[index]
	
	if sub_obj_index == -1:
		index = obj.sub_obj_0_tex_index
	else:
		index = obj.sub_obj_data[sub_obj_index]['tex_index']
	# End If

	return load_texture(model, index, ['no_filter'])
# End Func

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
	if text == "Objects" or text == "Textures" or text == "Anims":
		return
	
	var model = ui_controller.loaded_model
	var anim_model = ui_controller.loaded_anim
	
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
		var obj_data = model.obj_data[index]
		
		if obj_data != null:
			
			var mesh_instances = load_mesh(model, index)
			for mesh_instance in mesh_instances:

				mesh_viewer.add_child(mesh_instance)
				mesh_instance.owner = mesh_viewer
				
			self.image_viewer.get_parent().visible = false
		
	elif parent_text == "Textures":
		var index = metadata['id']
		
		var imgTex = load_texture(model, index, ['no_filter'])
		
		self.image_viewer.get_parent().visible = true
		self.image_viewer.texture = imgTex
	elif parent_text == "Object Textures":
		var index = metadata['id']
		var sub_obj = metadata['sub_id']
		
		var imgTex = load_object_texture(model, index, sub_obj)
		
		self.image_viewer.get_parent().visible = true
		self.image_viewer.texture = imgTex
	elif parent_text == "Anims":
		var index = metadata['id']
		
		var skel = load_anim(anim_model, model, index)
		skel.owner = mesh_viewer
		mesh_viewer.add_child(skel)
		
		var scene = PackedScene.new()
		scene.pack(skel)
		ResourceSaver.save("res://my_scene.tscn", scene)
		
		self.image_viewer.get_parent().visible = false
	
	pass
