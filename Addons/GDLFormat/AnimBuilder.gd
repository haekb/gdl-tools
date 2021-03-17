extends Node

func build(source_file, options):
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		print("Failed to open %s" % source_file)
		return null
		
	print("Opened %s" % source_file)
	
	var path = "%s/Models/Anim.gd" % self.get_script().get_path().get_base_dir()
	var anim_file = load(path)
	
	# Model as in MVC model, not mesh model!
	var model = anim_file.Anim.new()
	var response = model.read(file)
	
	file.close()
	
	if response.code == Helpers.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	return model

func build_skeleton(anim):
	
	# Need a bit of setup first
	
	for skeleton in anim.skeletons:
		for bone in skeleton.data.bones:
			# Skip root
			if bone.parent_id == -1:
				continue
			# End If
				
			bone.parent = skeleton.data.bones[bone.parent_id]
			skeleton.data.bones[bone.parent_id].children.append(bone)
			skeleton.data.bones[bone.parent_id].child_count += 1
		# End For
		
		# Make those bind poses relative!
		for bone in skeleton.data.bones:
			if bone.child_count == 0:
				continue
			# End If
	
			for child_bone in bone.children:
				child_bone.bind_matrix = bone.bind_matrix * child_bone.bind_matrix
			# End For
		# End For
	# End For
	
	# Okay build the skeleton!
	
# End Func
