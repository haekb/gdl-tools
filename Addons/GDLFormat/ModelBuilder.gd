extends Node

func build(name, rom_obj, obj_data, sub_obj_index, bone = null, options = []):
	var no_log = "no_log" in options
	var show_time = "show_time" in options 
	var scale_mesh = "scale_mesh" in options
	
	var start = OS.get_ticks_msec()
	var end = OS.get_ticks_msec()
	
	if !no_log:
		print("Building %s" % name)
	var st = SurfaceTool.new()
	
	# GDL uses Triangle strips - check cxbx on how the data is formatted
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var obj_vertices = obj_data.vertices[sub_obj_index]
	var obj_uvs = obj_data.uvs[sub_obj_index]
	var obj_skip_vertices = obj_data.skip_vertices[sub_obj_index]
	var obj_unk_vec2 = obj_data.unk_vec2[sub_obj_index]
	var obj_vertex_colour = obj_data.vertex_colours[sub_obj_index]
	
	var mesh_scale = 1.0
	
	# GDL needs to be scaled waaaay down!
	if scale_mesh:
		mesh_scale = Constants.Mesh_Scale
	
	var vertices = []
	var uvs = []
	var indexes = []
	var normals = []
	
	if !no_log:
		var flags = Helpers.get_model_flag_string(rom_obj.obj_flags)
		print("Object Flags: ", flags)
	
	var has_lightmaps = rom_obj.obj_flags & Constants.Model_Flags.LMAP
	
	# Points
	#var p1 = 0
	#var p2 = 1
	
	var flip = true
	var flip_stick_counter = 0
	var first_run = false

	if !scale_mesh:
		flip = false
		# GL?
		var skipper = 0
		for i in range(len(obj_skip_vertices)):
			# We duplicate normals to match vert count for later...it sucks but ehh
			if skipper < 2:
				skipper += 1
				continue
			else:
				skipper = 0
				
			# Index list is packed into normal for now...
			var vi = obj_skip_vertices[i].indexes
			var skip = obj_skip_vertices[i].skip
			var byte1 = obj_skip_vertices[i].byte_1
			var byte2 = obj_skip_vertices[i].byte_2
			
			var x = obj_vertices[vi[0]]
			var y = obj_vertices[vi[1]]
			var z = obj_vertices[vi[2]]
			
			
#			if first_run:
#				if byte2 == 0xC0:
#					flip = true
#				else:
#					flip = false
#				first_run = false
			
#			if skip != 0:
#				flip = true
#			else:
#				flip = false
			

			if flip:
				indexes.append([vi[0], vi[1], vi[2]])
			else:
				indexes.append([vi[0], vi[2], vi[1]])
				
			flip = not flip
			
			var hello = true
			
			

			

	else:
		# GDL
		for i in range(len(obj_vertices)):
			if i < 2:
				continue

			var p1 = i - 2
			var p2 = i - 1
			var p3 = i
			var front_face = obj_unk_vec2[p3][0] == 1.0
			var cull_cw = !front_face

			# HACK!
			if !obj_skip_vertices[p3].skip:
				# Clockwise
				if !cull_cw:
					if flip:
						indexes.append([p1, p2, p3])
					else:
						indexes.append([p2, p1, p3])
					# End If
				# Counter-Clockwise
				else:
					if flip:
						indexes.append([p1, p3, p2])
					else:
						indexes.append([p1, p2, p3])
					# End If

				flip = not flip
			# End If

#	for p3 in range(2, len(obj_vertices)):
#		var front_face = obj_unk_vec2[p3][0] == 1.0
#		#var back_face = obj_unk_vec2[p3][1] == 1.0
#		if !obj_skip_vertices[p3].skip:
#
#			if !front_face:
#				if flip:
#					indexes.append([p1, p3, p2])
#				else:
#					indexes.append([p1, p2, p3])
#				# End If
#			else:
#				if flip:
#					indexes.append([p3, p2, p1])
#				else:
#					indexes.append([p3, p1, p2])
#				# End If
#
#
#			flip = not flip
#			#print("Flip %d" % int(flip))
#		#else:
#		#	pass
#			#print("^ SKIP VERT!")
#		# End If
#
#		# Carry over!
#		p1 = p2
#		p2 = p3
#	# End For
	
	

	
#	for vi in range(len(obj_vertices)):
#		var vertex = obj_vertices[vi].vector
#
#		# Scale it down a bit...
#		#vertex *= 0.0
#		#vertex *= 0.02
#		vertex *= Constants.Mesh_Scale
#		#vertex *= 0.016
#		#vertex *= 0.003
#
#		# Switch from model space to skeleton space (which sounds real cool.)
#		#if bone:
#		#	vertex = bone.bind_matrix * vertex
#
#		vertices.append(vertex)
#	# End For
	start = OS.get_ticks_msec()
	for i in range(len(indexes)):
		var index = indexes[i]
		for vi in index:
			st.add_index(vi)
		# End For
	# End For
	
	for i in range(len(obj_vertices)):
		if bone:
			st.add_weights([1.0, 0.0, 0.0, 0.0])
			st.add_bones([bone.id, 0, 0, 0])
			
		if len(obj_uvs) > 0:
			
			var uv = obj_uvs[i].uv
			#uv[0] *= -1
			#uv[1] *= -1
			st.add_uv(uv)
			
			if has_lightmaps:
				var lm_uv = obj_uvs[i].lm_uv
				st.add_uv2(lm_uv)
		
		if len(obj_vertex_colour) > 0:
			st.add_color(obj_vertex_colour[i].colour)
		
		#if mesh_scale:
		st.add_normal(obj_skip_vertices[i].normal)
		st.add_vertex(obj_vertices[i].vector * mesh_scale)
	# End For
	
	# Clean up normals
	# Note: Normals are inside out because MeshView Scale.X is -1 to match GDL
	st.generate_normals(true)
	
	var mesh_array = st.commit()
	
	end = OS.get_ticks_msec()
	if show_time:
		print("Mesh generation time (ms): %d" % (end - start))
	
	return mesh_array
# End Func
