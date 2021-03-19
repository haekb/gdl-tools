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
	
	setup_skeleton(model)
	
	if response.code == Helpers.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	return model

func setup_skeleton(anim):
	
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
	
			#for child_bone in bone.children:
			#	child_bone.bind_matrix = bone.bind_matrix.inverse() * child_bone.bind_matrix
			# End For
		# End For
	# End For
# End Func

func build_skeleton(anim, index):
	var skeleton = anim.skeletons[index]
	
	var godot_skeleton = Skeleton.new()
	godot_skeleton.name = "Skeleton"
	
	for bone in skeleton.data.bones:
		godot_skeleton.add_bone(bone.name)
		var bi = godot_skeleton.get_bone_count() - 1
		
		bone.id = bi
		
		if bone.parent != null:
			godot_skeleton.set_bone_parent(bi, bone.parent_id)
		# End If
		
		godot_skeleton.set_bone_rest(bi, bone.bind_matrix)
		godot_skeleton.set_bone_pose(bi, bone.bind_matrix)
	# End For
	
	return godot_skeleton

func process_animations(model, index, godot_skeleton : Skeleton, anim_player : AnimationPlayer):
	var anim = Animation.new()
	var skeleton = model.skeletons[index]
	
	# Pre-make our track ids
	for bi in range(len(skeleton.data.bones)):
		var bone = skeleton.data.bones[bi]
		
		var key = "Skeleton:%s" % bone.name
		var track_id = anim.add_track(Animation.TYPE_TRANSFORM)
		anim.track_set_path(track_id, key)
		
		var matrix = godot_skeleton.get_bone_rest(bi)
		var translation = matrix.origin 
		var rotation  = matrix.basis.get_rotation_quat()
		
		anim.transform_track_insert_key(bi, 0, translation, rotation, Vector3(1.0, 1.0, 1.0))
	# End For
	
	anim.loop = true
	anim_player.add_animation("Default", anim)
	
	# Okay go through the transforms and make some animations!
	
	if len(skeleton.data.animations) == 0:
		return anim_player
	
	# Loop through sequences...
	
	var header = skeleton.data.animation_headers[0]
	var fps = header.frame_rate
	var frames = header.frame_count
	
	anim = Animation.new()
	var length = 0
	for bi in range(len(skeleton.data.bones)):
		var sequence = skeleton.data.animations[bi][0]
		
		if sequence.size == 0:
			continue
		
		var bone = skeleton.data.bones[bi]
		var key = "Skeleton:%s" % bone.name
		var track_id = anim.add_track(Animation.TYPE_TRANSFORM)
		anim.track_set_path(track_id, key)
		
		for frame in range(frames):
			var time = (float(frame) / float(fps)) * 10
			
			var matrix = godot_skeleton.get_bone_rest(bi)
			var translation = matrix.origin 
			var rotation  = Quat(sequence.data[frame])
			
			anim.transform_track_insert_key(track_id, time, translation, rotation, Vector3(1.0, 1.0, 1.0))
			length = time + 1.0
		# End For
		
	# End For
	
	anim.length = length
	anim.loop = true #header.loop
	anim_player.add_animation(header.name, anim)
	
	return anim_player
