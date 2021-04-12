extends Node

class Objects:
	
	var dir_name = ""
	var model_name = ""
	var version = 0
	
	var unknown_1 = 0
	var unknown_2 = 0
	var unknown_3 = 0
	
	var rom_obj_count = 0
	var rom_tex_count = 0
	var obj_def_count = 0
	var tex_def_count = 0
	
	
	var obj_def_pointer = 0
	var tex_def_pointer = 0
	
	# The rest aren't used
	var rom_obj_pointer = 0
	var rom_tex_pointer = 0
	
	var sub_obj_pointer = 0
	var geometry_pointer = 0
	var obj_end_pointer = 0
	var tex_start_pointer = 0
	var tex_end_pointer = 0
	var tex_bits = 0
	var lm_tex_first = 0
	var lm_tex_count = 0
	var tex_info = 0
	
	var obj_defs = []
	var tex_defs = []
	var rom_objs = []
	var rom_texs = []
	
	var obj_data = []
	
	func read(f : File):
		self.dir_name = f.get_buffer(32).get_string_from_ascii()
		self.model_name = f.get_buffer(32).get_string_from_ascii()
		self.version = f.get_32()
		
		if self.version != 0xF00B0001:
			print("[Warning] Objects file version does not match 0xF00B0001!")
		# End If
		
		self.unknown_1 = f.get_32()
		self.unknown_2 = f.get_32()
		self.unknown_3 = f.get_32()
		
		# Always empty?
		self.rom_obj_count = f.get_32()
		self.rom_tex_count = f.get_32()
		
		self.obj_def_pointer = f.get_32()
		self.tex_def_pointer = f.get_32()
		
		self.obj_def_count = f.get_32()
		self.tex_def_count = f.get_32()

		# Rom Obj
		for _i in range(self.obj_def_count):
			var rom_obj = RomObj.new()
			rom_obj.read(self, f)
			self.rom_objs.append(rom_obj)
		# End For
		
		# Rom Tex
		for _i in range(self.tex_def_count):
			var rom_tex = RomTex.new()
			rom_tex.read(self, f)
			self.rom_texs.append(rom_tex)
		# End For
		
		# Obj Def
		f.seek(self.obj_def_pointer)
		
		for _i in range(self.obj_def_count):
			var obj_def = ObjDef.new()
			obj_def.read(self, f)
			self.obj_defs.append(obj_def)
		# End For
		
		# Tex Def
		f.seek(self.tex_def_pointer)
		
		for _i in range(self.tex_def_count):
			var tex_def = TexDef.new()
			tex_def.read(self, f)
			tex_defs.append(tex_def)
		# End For
		
		#return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
		
		var last_position = f.get_position()
		for i in range(self.obj_def_count):
			var rom_obj = self.rom_objs[i]
			
			# No data here!
			if rom_obj.lods[0].vertex_data_pointer == 0:
				# Make sure indexes align with rom_obj!!
				self.obj_data.append(null)
				continue
			
			f.seek(rom_obj.lods[0].vertex_data_pointer)
			
			var obj = ObjData.new()
			obj.read(self, rom_obj, f)
			self.obj_data.append(obj)
		# End For
		
		return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
	# End Func
	
	class ObjDef:
		var name = ""
		var bnd_rad = 0.0
		var index = 0
		var frame_count = 0
		
		func read(Obj : Objects, f : File):
			self.name = f.get_buffer(16).get_string_from_ascii()
			self.bnd_rad = f.get_float()
			self.index = f.get_16()
			self.frame_count = f.get_16()
		# End Func
	# End Class
	
	class TexDef:
		var name = ""
		var index = 0
		var width = 0
		var height = 0
		
		func read(Obj : Objects, f : File):
			self.name = f.get_buffer(30).get_string_from_ascii()
			self.index = f.get_16()
			self.width = f.get_16()
			self.height = f.get_16()
		# End Func
	# End Class
	
	class RomObj:
		var inv_rad = 0.0
		var bnd_rad = 0.0
		
		var lod_levels = 0
		var lods = []
		
		class LOD:
			var unknown_1 = 0
			var unknown_2 = 0
			var vertex_count = 0
			var vertex_data_pointer = 0
			var triangle_count = 0
			var unk_data_pointer = 0
			var id_number = 0
			var uv_data_pointer = 0
			
			func read(Obj : Objects, f : File):
				self.unknown_1 = f.get_32()
				self.unknown_2 = f.get_32()
				self.vertex_count = f.get_32()
				self.vertex_data_pointer = f.get_32()
				self.triangle_count = f.get_32()
				self.unk_data_pointer = f.get_32()
				self.id_number = f.get_32()
				self.uv_data_pointer = f.get_32()
			# End Func
		# End Class
		
		# Not used
		var obj_flags = 0
		var sub_obj_count = 0
		var sub_obj_0_qwc = 0 # QWord Count
		var sub_obj_0_tex_index = 0
		var sub_obj_0_lm_index = 0
		var sub_obj_0_lodk = 0
		var sub_obj_pointer = 0
		var data_pointer = 0
		var vertex_count = 0
		var triangle_count = 0
		var id_number = 0
		var obj_def = 0
		
		var sub_obj_data = []
		
		func read(Obj : Objects, f : File):
			self.inv_rad = f.get_float()
			self.bnd_rad = f.get_float()
			
			self.lod_levels = f.get_32()
			
			# Always 4, seems to be duplicate of the same data...
			for _i in range(4):
				var lod = LOD.new()
				lod.read(Obj, f)
				self.lods.append(lod)
			# End For
		# End Func
	# End Class
	
	class RomTex:
		
		enum Formats {
			ABGR_1555 = 0,
			BGR_555 = 1,
			ABGR_8888 = 2,
			BGR_888 = 3,
			IDX_4_ABGR_1555 = 16,
			IDX_4_BGR_555 = 17,
			IDX_4_ABGR_8888 = 34,
			IDX_4_BGR_888 = 35,
			IDX_8_ABGR_1555 = 48,
			IDX_8_BGR_555 = 49,
			IDXA_88 = 56,
			IDX_8_ABGR_8888 = 66,
			IDX_8_BGR_888 = 67,
			IDX_8_A_8 = 130,
			IDX_8_I_8 = 131,
			IDX_4_A_4 = 146,
			IDX_4_I_4 = 147
			
			END = 255
		}
		
		var format = 0
		var lodk = 0
		var mipmaps = 0
		var width64 = 0
		var width_log2 = 0
		var height_log2 = 0
		var flags = 0
		var tex_palette_index = 0
		var tex_data_pointer = 0 # Was tex_base
		var tex_palette_count = 0
		var tex_shift_index = 0
		var frame_count = 0
		var width = 0
		var height = 0
		var size = 0
		var tex_def = 0
		var tex_0 = 0 # 64-bit?
		var mip_tbp_1 = 0 # 64-bit
		var mip_tbp_2 = 0 # 64-bit
		var vram_addr = 0
		var clut_addr = 0
		
		# New!
		var padding = 0xFF
		var data_type = 0
		var attributes = 0
		
		var unknown_1 = 0
		var unknown_2 = 0
		var unknown_data = []
		
		
		func read(Obj : Objects, f : File):
			self.padding = f.get_16()
			self.unknown_1 = f.get_8()
			self.unknown_2 = f.get_8()
			self.width = f.get_16()
			self.height = f.get_16()
			self.tex_data_pointer = f.get_32()
			self.format = f.get_32()
			self.attributes = f.get_32()
			self.size = f.get_32()
			
			# Override for now...
			self.format = Constants.Tex_Formats.UNK_DREAMCAST
			
			#self.flags = [
			#	(self.attributes >> 8) & 0xFF, # Texture Attributes
			#	self.unknown_2   # Is Half Res (??)
			#]
			
			for _i in range(14):
				unknown_data.append(f.get_32())
			# End For
		# End Func
	# End Class
	
	class ObjData:
		# Helper classes
		class Vertex:
			var vector = Vector3()
			var extra = Vector2()
			var flag = 0
			
			func read(f : File):
				var x = f.get_float()
				var y = f.get_float()
				var z = f.get_float()
				var e1 = f.get_float()
				var e2 = f.get_float()
				self.flag = f.get_32()
				
				self.vector = Vector3(x, y, z)
				self.extra = Vector2(e1, e2)
			# End Func
		# End Class
		
		class UV:
			var uv = Vector2()
			var lm_uv = Vector2()
			
			func read(f : File):
				var u = f.get_float()
				var v = f.get_float()
				self.uv = Vector2( u, v )
				
				# ?
				var extra = f.get_float()
				self.lm_uv = Vector2( extra, extra )
			# End Func
		# End Class
		
		class SkipVertex:
			var byte_1 = 0
			var byte_2 = 0
			var skip = false
			var normal = Vector3()
			
			func read(f : File):
				var x = float(Helpers.utsh(f.get_16()))# / 128.0
				var y = float(Helpers.utsh(f.get_16()))# / 128.0
				var z = float(Helpers.utsh(f.get_16()))# / 128.0
				self.normal = Vector3( x, y, z )
				
				self.byte_1 = f.get_16()
			# End Func
		# End Class

		# End helper classes
		
		# Properties
		var vertices = []
		var skip_vertices = []
		var uvs = []
		var unk_vec2 = []
		var vertex_colours = []
		
		func read(Obj : Objects, rom_obj: RomObj, f : File):
			# This includes the main mesh
			var obj_count = 1#rom_obj.sub_obj_count
			
			var obj_vertices = []
			var obj_uvs = []
			var obj_skip_vertices = []
			var obj_unk_vec2 = []
			var obj_vertex_colours = []
			
			var last_position = 0
			while obj_count > 0:
				obj_count -= 1
				
				var pack_count = rom_obj.lods[0].triangle_count * 3
				var tri_count = rom_obj.lods[0].triangle_count
				var vert_count = rom_obj.lods[0].vertex_count
				
				for i in vert_count:
					var vert = Vertex.new()
					vert.read(f)
					obj_vertices.append(vert)
					obj_unk_vec2.append(vert.extra)
				# End For
				for i in tri_count:
					var normals = SkipVertex.new()
					normals.read(f)
					#var vert = obj_vertices[i*2]
					#normals.skip = vert.flag & 0xFF
					obj_skip_vertices.append(normals)
					obj_skip_vertices.append(normals)
					obj_skip_vertices.append(normals)
				# End For
				for i in pack_count:
					var uv = UV.new()
					uv.read(f)
					obj_uvs.append(uv)
				# End For
				
			# Push the subobj into the main data array
			self.vertices.append(obj_vertices)
			self.uvs.append(obj_uvs)
			self.skip_vertices.append(obj_skip_vertices)
			self.unk_vec2.append(obj_unk_vec2)
			self.vertex_colours.append(obj_vertex_colours)
				
			# End While
#			self.vertices = obj_vertices
#			self.uvs = obj_uvs
#			self.skip_vertices = obj_skip_vertices
#			self.unk_vec2 = obj_unk_vec2
		# End Func
		
	# End Class
# End Class



