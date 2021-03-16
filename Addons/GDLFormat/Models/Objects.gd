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
	
	var obj_data = []
	
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
		
		var last_position = f.get_position()
		for i in range(self.rom_obj_count):
			var rom_obj = self.rom_objs[i]
			
			# No data here!
			if rom_obj.data_pointer == 0:
				# Make sure indexes align with rom_obj!!
				self.obj_data.append(null)
				continue
			
			f.seek(rom_obj.data_pointer)
			
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
			
			# Read in sub obj data (Over 1, since the count includes the main obj!)
			if self.sub_obj_count > 1:
				var last_spot = f.get_position()
				f.seek(self.sub_obj_pointer)
				
				for _i in range(self.sub_obj_count - 1):
					self.sub_obj_data.append({
						'qwc': f.get_16(),
						'tex_index': f.get_16(),
						'lm_index': f.get_16(),
						'lodk': f.get_16(),
					})
				# End For
				
				f.seek(last_spot)
			# End If
			
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
	
	class ObjData:
		# PS2 related geometry flags
		const VIF_MSCAL = 0x14000000
		const VIF_MSCNT = 0x17000000
		
		# Constants for various things
		const OBJ_START_SIGNATURE = 0x6C018000
		
		const SIGNAL_MODE_UNK_5BYTE = 0x6F # V4-5 - 4 Items packed in 5 bytes
		const SIGNAL_MODE_UNK_8BYTE = 0x6D # V4-16 (4 items, 16 bytes) # Possibly level-based
		const SIGNAL_MODE_UNK_2BYTE = 0x66 # V2-8 (2 items, 8 bytes)
		# Confirmed
		const SIGNAL_MODE_HEADER = 0x6C # V4-32 (4 items, 32 bytes) (Doesn't quite line up..)
		# Vertex
		const SIGNAL_MODE_CHAR_3 = 0x6A
		const SIGNAL_MODE_SHORT_3 = 0x69
		# UV
		const SIGNAL_MODE_CHAR_2 = 0x66
		const SIGNAL_MODE_SHORT_2 = 0x65
		# Flip Vert related
		const SIGNAL_MODE_INT_4 = 0x6F
		
		# Helper classes
		class Vertex:
			var vector = Vector3()
			
			func read(mode, f : File):
				if mode == SIGNAL_MODE_CHAR_3:
					var x = Helpers.utsb(f.get_8())
					var y = Helpers.utsb(f.get_8())
					var z = Helpers.utsb(f.get_8())
					self.vector = Vector3( float(x), float(y), float(z) )
				elif mode == SIGNAL_MODE_SHORT_3:
					var x = Helpers.utsh(f.get_16())
					var y = Helpers.utsh(f.get_16())
					var z = Helpers.utsh(f.get_16())
					self.vector = Vector3( float(x), float(y), float(z) )
				else: # Unknown!
					var x = Helpers.utsb(f.get_8())
					var y = Helpers.utsb(f.get_8())
					var z = Helpers.utsb(f.get_8())
					self.vector = Vector3( float(x), float(y), float(z) )
				# End If
			# End Func
		# End Class
		
		class UV:
			var uv = Vector2()
			
			func read(mode, f : File):
				# Divided by max value of the type
				if mode == SIGNAL_MODE_CHAR_2:
					var u = float(Helpers.utsb(f.get_8())) / 128.0
					var v = float(Helpers.utsb(f.get_8())) / 128.0
					self.uv = Vector2( u, v )
				elif mode == SIGNAL_MODE_SHORT_2:
					var u = float(Helpers.utsh(f.get_16())) / 256.0#32768.0
					var v = float(Helpers.utsh(f.get_16())) / 256.0#32768.0
					self.uv = Vector2( u, v )
				else:
					var u = float(Helpers.utsb(f.get_8())) / 128.0
					var v = float(Helpers.utsb(f.get_8())) / 128.0
					self.uv = Vector2( u, v )
				# End If
				var hello = true
			# End Func
		# End Class
		
		class SkipVertex:
			var byte_1 = 0
			var byte_2 = 0
			var skip = false
			var normal = Vector3()
			
			func read(f : File):
				# Still unsure how this all works, but it does work!
				self.byte_1 = f.get_8()
				self.byte_2 = f.get_8()
				self.skip = bool( (self.byte_2 >> 7) )
				
				# Roll back and let's calculate normals!
				f.seek(f.get_position() - 2)
				var packed_normal = f.get_16()
				var x = ((packed_normal & 0x1f) - 0xf) * Constants.Normal_Scale
				var y = (((packed_normal >> 5) & 0xf) - 0xf) * Constants.Normal_Scale
				var z = (((packed_normal >> 10) & 0xf) - 0xf) * Constants.Normal_Scale
				self.normal = Vector3(x,y,z)
				
			# End Func
		# End Class
		
		class Signal:
			var index = 0
			var constant = 0
			var data_count = 0
			var mode = 0
			var signature = 0x0
			
			func read(f : File):
				self.signature = f.get_32()
				# Go back and let's actually read the signature!
				f.seek(f.get_position() - 4)
				
				self.index = f.get_8()
				self.constant = f.get_8()
				self.data_count = f.get_8()
				self.mode = f.get_8()
			# End Func
			
			func get_mode_string():
				if self.is_header():
					return "Header"
				elif self.is_vertex():
					return "Vertex"
				elif self.is_uv():
					return "UV"
				elif self.is_skip_vertex():
					return "Skip Vertex"
				return "Unknown"
			# End Func
			
			func is_header():
				return self.mode in [SIGNAL_MODE_HEADER]
			# End Func
			
			func is_vertex():
				return self.mode in [SIGNAL_MODE_CHAR_3, SIGNAL_MODE_SHORT_3]
			# End Func
			
			func is_uv():
				return self.mode in [SIGNAL_MODE_CHAR_2, SIGNAL_MODE_SHORT_2]
			# End Func
			
			func is_skip_vertex():
				return self.mode in [SIGNAL_MODE_INT_4]
			# End Func
		# End Class

		# Good reference: https://github.com/ps2dev/ps2sdk/blob/8b7579979db87ace4b0aa5693a8a560d15224a96/common/include/vif_codes.h
		class VUCommand:
			var command = 0
			
			func read(f : File):
				f.seek(f.get_position() + 3)
				self.command = f.get_8()
			# End Func
			
			func get_command_string():
				if self.command == 0x14:
					return "MSCAL (0x14)"
				elif self.command == 0x17:
					return "MSCNT (0x17)"
				return "Unknown %d" % self.command
			# End Func
		# End Class
		
		# End helper classes
		
		# Properties
		var vertices = []
		var skip_vertices = []
		var uvs = []
		var unk_vec2 = []
		
		func read(Obj : Objects, rom_obj: RomObj, f : File):
			# This includes the main mesh
			var obj_count = rom_obj.sub_obj_count
			
			var last_position = 0
			while obj_count > 0:
				obj_count -= 1
				
				var obj_vertices = []
				var obj_uvs = []
				var obj_skip_vertices = []
				var obj_unk_vec2 = []
					
				last_position = f.get_position()
				var unpack_command = f.get_32()
				
				# Skip past two unknown shorts
				f.seek(f.get_position() + 4)
				
				var current_position = f.get_position()
				# Data packet size, needs to be truncated to 32-bits
				var unpack_size = (unpack_command << 4) & 0xFFFFFFFF
				var total_size = 0
				
				if unpack_size > 10000:
					print("[ObjData::read] Unusually large unpack size at [%d]" % f.get_position())
				# End If
				
				# SubObj Count - 1 is how much extra data we have
				# ---
				# Once we hit unpack size, check if we'll bleed into another object,
				# if not, then check if there's a new "unpack_command". 
				# If there is, mark it as merge with previous then grab that mesh data.
				while total_size < unpack_size:
					
					while true:
						Helpers.align(4, f)
						
						var ps2_signal = Signal.new()
						ps2_signal.read(f)
						
						if ps2_signal.is_header():
							f.seek((4 * 2) + f.get_position())
							
							obj_unk_vec2.append(Vector2( f.get_float(), f.get_float() ))
						elif ps2_signal.is_vertex():
							for _i in range(ps2_signal.data_count - 1):
								var debug_pos = f.get_position()
								var vertex = Vertex.new()
								vertex.read(ps2_signal.mode, f)
								obj_vertices.append(vertex)
							# End For
							
							# Skip over data padding
							if ps2_signal.mode == SIGNAL_MODE_CHAR_3:
								f.seek(3 + f.get_position())
							elif ps2_signal.mode == SIGNAL_MODE_SHORT_3:
								f.seek(6 + f.get_position())
							# End if
							
						elif ps2_signal.is_uv():
							for _i in range(ps2_signal.data_count):
								var uv = UV.new()
								uv.read(ps2_signal.mode, f)
								obj_uvs.append(uv)
							# End For
						elif ps2_signal.is_skip_vertex():
							for _i in range(ps2_signal.data_count):
								var skip_vertex = SkipVertex.new()
								skip_vertex.read(f)
								obj_skip_vertices.append(skip_vertex)
							# End For
						else:
							print("[ObjData::read] Unknown signal %d at %d! Breaking from loop." % [ps2_signal.mode, f.get_position()])
							break
						# End If
						
						# We hit the uvs, now we can exit out
						if ps2_signal.index >= 4:
							break
						# End If
					# End While
					
					Helpers.align(4, f)
					
					# Check for VIF commands
					var vif_commands = f.get_32()
					
					current_position = f.get_position()
					total_size = current_position - last_position
					
				# End While
				Helpers.align(16, f)
				
				# Push the subobj into the main data array
				self.vertices.append(obj_vertices)
				self.uvs.append(obj_uvs)
				self.skip_vertices.append(obj_skip_vertices)
				self.unk_vec2.append(obj_unk_vec2)
				
			# End While
#			self.vertices = obj_vertices
#			self.uvs = obj_uvs
#			self.skip_vertices = obj_skip_vertices
#			self.unk_vec2 = obj_unk_vec2
		# End Func
		
	# End Class
# End Class



