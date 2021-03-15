extends Node

func build(name, rom_obj, obj_data, options):
	print("Building %s" % name)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vertices = []
	var uvs = []
	var indexes = []
	
	var flags = Helpers.get_model_flag_string(rom_obj.obj_flags)
	print("Object Flags: ", flags)
	
	# Points
	var p1 = 0
	var p2 = 1
	
	var flip = true
	
	for p3 in range(2, len(obj_data.vertices)):
		if !obj_data.skip_vertices[p3].skip:
			if flip:
				indexes.append([p1, p3, p2])
			else:
				indexes.append([p1, p2, p3])
			# End If
			
			#uvs.append(obj_data.uvs[p1].uv)
			
			flip = not flip
		# End If
		
		# Carry over!
		p1 = p2
		p2 = p3
	# End For
	
	for vi in range(len(obj_data.vertices)):
		var vertex = obj_data.vertices[vi].vector
		
		# Scale it down a bit...
		vertex *= 0.008
		
		vertices.append(vertex)
	# End For
	
#	for vi in range(len(vertices)):
#		var vertex = vertices[vi]
#		var index = indexes[vi]
#		var uv = uvs[vi]
#
#		st.add_index(index[0])
#		st.add_index(index[1])
#		st.add_index(index[2])
#
#		st.add_uv(uv)
#		st.add_vertex(vertex)
#	# End For

	for i in range(len(indexes)):
		#var vertex = vertices[vi]
		var index = indexes[i]
		var uv = obj_data.uvs[i].uv
		
		var verts = []
		
		st.add_uv(uv)
		for vi in index:
			st.add_vertex(vertices[vi])
		# End For
	# End For
	
	st.generate_normals()
	
	var mesh_array = st.commit()
	
	return mesh_array
# End Func
