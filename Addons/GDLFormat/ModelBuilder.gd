extends Node

func build(name, rom_obj, obj_data, sub_obj_index, bone = null, options = []):
	var no_log = "no_log" in options
	
	if !no_log:
		print("Building %s" % name)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var obj_vertices = obj_data.vertices[sub_obj_index]
	var obj_uvs = obj_data.uvs[sub_obj_index]
	var obj_skip_vertices = obj_data.skip_vertices[sub_obj_index]
	var obj_unk_vec2 = obj_data.unk_vec2[sub_obj_index]
	var obj_vertex_colour = obj_data.vertex_colours[sub_obj_index]
	
	
	var vertices = []
	var uvs = []
	var indexes = []
	var normals = []
	
	var flags = Helpers.get_model_flag_string(rom_obj.obj_flags)
	if !no_log:
		print("Object Flags: ", flags)
	
	# Points
	var p1 = 0
	var p2 = 1
	
	var flip = true

	for p3 in range(2, len(obj_vertices)):
		if !obj_skip_vertices[p3].skip:
			if flip:
				indexes.append([p1, p3, p2])
			else:
				indexes.append([p1, p2, p3])
			# End If

			
			flip = not flip
			#print("Flip %d" % int(flip))
		else:
			pass
			#print("^ SKIP VERT!")
		# End If
		
		# Carry over!
		p1 = p2
		p2 = p3
	# End For
	
	for vi in range(len(obj_vertices)):
		var vertex = obj_vertices[vi].vector
		
		# Scale it down a bit...
		#vertex *= 0.0
		#vertex *= 0.02
		if bone:
			vertex *= Constants.Mesh_Scale
		#vertex *= 0.016
		#vertex *= 0.003
		
		# Switch from model space to skeleton space (which sounds real cool.)
		#if bone:
		#	vertex = bone.bind_matrix * vertex
		
		vertices.append(vertex)
	# End For
	
	for i in range(len(indexes)):
		var index = indexes[i]
		for vi in index:
			st.add_index(vi)
		# End For
	# End For
	
	for i in range(len(vertices)):
		if bone:
			st.add_weights([1.0, 0.0, 0.0, 0.0])
			st.add_bones([bone.id, 0, 0, 0])
			
		if len(obj_uvs) > 0:
			st.add_uv(obj_uvs[i].uv)
		
		if len(obj_vertex_colour) > 0:
			st.add_color(obj_vertex_colour[i].colour)
		
		st.add_normal(obj_skip_vertices[i].normal)
		st.add_vertex(vertices[i])
	# End For
	
	# Clean up normals
	st.generate_normals()
	
	var mesh_array = st.commit()
	
	return mesh_array
# End Func
