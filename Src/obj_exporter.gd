extends Node

class OBJExporter:
	var obj_buffer = ""
	var last_vertex_index = 0
	
	func print_vertex_data(mdt : MeshDataTool):
		for i in range(mdt.get_vertex_count()):
			var vertex = mdt.get_vertex(i)
			self.obj_buffer += "v %f %f %f\n" % [ vertex.x, vertex.y, vertex.z ]
		# End For
	# End Func
	
	func print_uv_data(mdt : MeshDataTool, use_uv2 = false):
		for i in range(mdt.get_vertex_count()):
			var uv = mdt.get_vertex_uv(i)
			
			if use_uv2:
				uv = mdt.get_vertex_uv2(i)
			# End Func
			
			# Hack: Fix lightmaps
			uv = Vector2( uv.x, 1.0 - uv.y )
			
			self.obj_buffer += "vt %f %f\n" % [ uv.x, uv.y ]
		# End For
	# End Func
	
	func print_normal_data(mdt : MeshDataTool):
		for i in range(mdt.get_vertex_count()):
			var normal = mdt.get_vertex_normal(i)
			self.obj_buffer += "vn %f %f %f\n" % [ normal.x, normal.y, normal.z ]
		# End For
	# End Func
	
	func print_face_data(mdt : MeshDataTool):
		var obj_face_vertex = 0
		for i in range(mdt.get_face_count()):
			self.obj_buffer += "f"
			for j in range(3):
				var face_vertex = mdt.get_face_vertex(i, j)
				obj_face_vertex = (face_vertex + 1) + self.last_vertex_index
				self.obj_buffer += " %d/%d/%d" % [ obj_face_vertex, obj_face_vertex, obj_face_vertex ]
			self.obj_buffer += "\n"
		# End For
		
		self.last_vertex_index = obj_face_vertex
	# End Func
	
	#
	# Takes in a MeshArray (Array or single), a save path, and whether or not we should use uv2 instead of uv1
	#
	func export_mesh(mesh_data, path, use_uv2 = false):
		# Obj string buffer
		self.obj_buffer = ""
		self.last_vertex_index = 0
		var mdt_list = [  ]
		var index = 0
		
		if typeof(mesh_data) != TYPE_ARRAY:
			mesh_data = [mesh_data]
		# End If
		
		for data in mesh_data:
			var mdt = MeshDataTool.new()
			mdt.create_from_surface(data, 0)
			mdt_list.append(mdt)
		# End For
		
		self.obj_buffer += "# HeyThereCoffee Debug Export Tool\n"
		
		# Give our object a name!
		self.obj_buffer += "o godot_mesh\n"
		
		self.obj_buffer += "# Vertex Data\n"
		index = 0
		for mdt in mdt_list:
			self.obj_buffer += "# Mesh %d\n" % index
			self.print_vertex_data(mdt)
			index += 1
		# End For
		
		self.obj_buffer += "# UV Data\n"
		index = 0
		for mdt in mdt_list:
			self.obj_buffer += "# Mesh %d\n" % index
			self.print_uv_data(mdt, use_uv2)
			index += 1
		# End For
		
		
		self.obj_buffer += "# Vertex Normal Data\n"
		index = 0
		for mdt in mdt_list:
			self.obj_buffer += "# Mesh %d\n" % index
			self.print_normal_data(mdt)
			index += 1
		# End For

		self.obj_buffer += "# Misc\n"
		self.obj_buffer += "usemtl None\n"
		self.obj_buffer += "s off\n"
		
		self.obj_buffer += "# Face Data\n"
		index = 0
		for mdt in mdt_list:
			self.obj_buffer += "# Mesh %d\n" % index
			self.print_face_data(mdt)
			index += 1
		# End For
		
		self.obj_buffer += "# Fin\n"
		
		var file = File.new()
		file.open(path, File.WRITE)
		file.store_string(obj_buffer)
		file.close()
	# End Func
