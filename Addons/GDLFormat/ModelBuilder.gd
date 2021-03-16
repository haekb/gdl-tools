extends Node

func build(name, rom_obj, obj_data, sub_obj_index, options):
	print("Building %s" % name)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var obj_vertices = obj_data.vertices[sub_obj_index]
	var obj_uvs = obj_data.uvs[sub_obj_index]
	var obj_skip_vertices = obj_data.skip_vertices[sub_obj_index]
	var obj_unk_vec2 = obj_data.unk_vec2[sub_obj_index]
	
	var vertices = []
	var uvs = []
	var indexes = []
	var normals = []
	
	var flags = Helpers.get_model_flag_string(rom_obj.obj_flags)
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
			print("Flip %d" % int(flip))
		else:
			print("^ SKIP VERT!")
		# End If
		
		# Carry over!
		p1 = p2
		p2 = p3
	# End For
	
	for vi in range(len(obj_vertices)):
		var vertex = obj_vertices[vi].vector
		
		# Scale it down a bit...
		vertex *= 0.008
		
		vertices.append(vertex)
	# End For
	
	for i in range(len(indexes)):
		var index = indexes[i]
		for vi in index:
			st.add_index(vi)
		# End For
	# End For
	
	for i in range(len(vertices)):
		st.add_uv(obj_uvs[i].uv)
		st.add_normal(obj_skip_vertices[i].normal)
		st.add_vertex(vertices[i])
	# End For
	
	# Clean up normals
	st.generate_normals()
	
	var mesh_array = st.commit()
	
	return mesh_array
# End Func
