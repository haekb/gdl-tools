extends Node

func build(name, rom_obj, obj_data, sub_obj_index, options):
	print("Building %s" % name)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var obj_vertices = obj_data.vertices[sub_obj_index]
	var obj_uvs = obj_data.uvs[sub_obj_index]
	var obj_skip_vertices = obj_data.skip_vertices[sub_obj_index]
	
	var vertices = []
	var uvs = []
	var indexes = []
	
	var flags = Helpers.get_model_flag_string(rom_obj.obj_flags)
	print("Object Flags: ", flags)
	
	# Points
	var p1 = 0
	var p2 = 1
	
	var flip = true
	
	for p3 in range(2, len(obj_vertices)):
		# https://gamedev.stackexchange.com/questions/159379/getting-the-winding-order-of-a-mesh
		var vertex = obj_vertices[p3].vector
		var a = obj_vertices[p1].vector
		var b = obj_vertices[p2].vector
		var c = obj_vertices[p3].vector
		
		var vec_1 = b - a
		var vec_2 = c - b
		
		
		var expected_normal = vec_1.cross(vec_2);
		
		var n1 = obj_skip_vertices[p1].normal
		var n2 = obj_skip_vertices[p2].normal
		var n3 = obj_skip_vertices[p3].normal
		var an = n1 + n2 + n3 / 3  
		
		var order = expected_normal.dot(an)
		
		if !obj_skip_vertices[p3].skip:
			if order > 0:
				indexes.append([p2, p1, p3])
			else: #elif order < 0:
				indexes.append([p3, p1, p2])
#			if flip:
#				indexes.append([p1, p3, p2])
#			else:
#				indexes.append([p1, p2, p3])
#			# End If
#
#			flip = not flip
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
	
	st.generate_normals(true)
	#st.generate_tangents()
	
	var mesh_array = st.commit()
	
	return mesh_array
# End Func
