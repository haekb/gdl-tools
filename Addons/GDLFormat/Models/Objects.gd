extends Node

class Objects:
	
	var dir_name = ""
	var model_name = ""
	var version = 0
	var rom_obj_count = 0
	var rom_tex_count = 0
	var obj_def_count = 0
	var tex_def_count = 0
	var rom_obj_pointer = 0
	var rom_tex_pointer = 0
	var obj_def_pointer = 0
	var tex_def_pointer = 0
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
	
	enum IMPORT_RETURN{SUCCESS, ERROR}
	
	func read(f : File):
		self.dir_name = f.get_buffer(32).get_string_from_ascii()
		self.model_name = f.get_buffer(32).get_string_from_ascii()
		self.version = f.get_32()
		
		if self.version != 0xF00B000D:
			print("[Warning] Objects file version does not match 0xF00B000D!")
		# End If
		
		self.rom_obj_count = f.get_32()
		self.rom_tex_count = f.get_32()
		self.obj_def_count = f.get_32()
		self.tex_def_count = f.get_32()
		
		self.rom_obj_pointer = f.get_32()
		self.rom_tex_pointer = f.get_32()
		self.obj_def_pointer = f.get_32()
		self.tex_def_pointer = f.get_32()
		self.sub_obj_pointer = f.get_32()
		self.geometry_pointer = f.get_32()
		self.obj_end_pointer = f.get_32()
		self.tex_start_pointer = f.get_32()
		self.tex_end_pointer = f.get_32()
		
		self.tex_bits = f.get_32()
		
		self.lm_tex_first = f.get_16()
		self.lm_tex_count = f.get_16()
		
		self.tex_info = f.get_32()
		
		# Dummy
		var _dummy = f.get_32()
		
		f.seek(self.obj_def_pointer)
		
		for _i in range(self.obj_def_count):
			var obj_def = ObjDef.new()
			obj_def.read(self, f)
			self.obj_defs.append(obj_def)
		# End For
		
		f.seek(self.tex_def_pointer)
		
		for _i in range(self.tex_def_count):
			var tex_def = TexDef.new()
			tex_def.read(self, f)
			tex_defs.append(tex_def)
		# End For
		
		f.seek(self.rom_obj_pointer)
		
		for _i in range(self.rom_obj_count):
			var rom_obj = RomObj.new()
			rom_obj.read(self, f)
			self.rom_objs.append(rom_obj)
		# End For
		
		f.seek(self.rom_tex_pointer)
		
		for _i in range(self.rom_tex_count):
			var rom_tex = RomTex.new()
			rom_tex.read(self, f)
			self.rom_texs.append(rom_tex)
		# End For
		
		return self._make_response(IMPORT_RETURN.SUCCESS)
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
		
		func read(Obj : Objects, f : File):
			self.inv_rad = f.get_float()
			self.bnd_rad = f.get_float()
			self.obj_flags = f.get_32()
			
			self.sub_obj_count = f.get_32()
			self.sub_obj_0_qwc = f.get_16()
			self.sub_obj_0_tex_index = f.get_16()
			self.sub_obj_0_lm_index = f.get_16()
			self.sub_obj_0_lodk = f.get_16()
			
			self.sub_obj_pointer = f.get_32()
			self.data_pointer = f.get_32()
			
			self.vertex_count = f.get_32()
			self.triangle_count = f.get_32()
			self.id_number = f.get_32()
			self.obj_def = f.get_32()
			
			# Skip past 4 ints
			var _dummy = Array(f.get_buffer(4 * 4))
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
		
		func read(Obj : Objects, f : File):
			self.format = f.get_8()
			self.lodk = f.get_8()
			self.mipmaps = f.get_8()
			self.width64 = f.get_8()
			self.width_log2 = f.get_16()
			self.height_log2 = f.get_16()
			self.flags = f.get_16()
			self.tex_palette_index = f.get_16()
			self.tex_data_pointer = f.get_32()
			self.tex_palette_count = f.get_16()
			self.tex_shift_index = f.get_16()
			self.frame_count = f.get_16()
			self.width = f.get_16()
			self.height = f.get_16()
			self.size = f.get_16()
			self.tex_def = f.get_32()
			self.tex_0 = f.get_64()
			self.mip_tbp_1 = f.get_64()
			self.mip_tbp_2 = f.get_64()
			self.vram_addr = f.get_32()
			self.clut_addr = f.get_32()
		# End Func
	# End Class
	
	#
	# Helpers
	# 
	func _make_response(code, message = ''):
		return { 'code': code, 'message': message }
	# End Func
# End Class



