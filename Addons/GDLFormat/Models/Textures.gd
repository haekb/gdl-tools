extends Node

class TextureFormat:	
	# From: https://stackoverflow.com/a/3124978
	static func flip_byte(x):
		var nibble1 = (x & 0x0F)
		var nibble2 = ((x & 0xF0) >> 4)
		
		# Flip those numbers!
		return ((nibble1 << 4) | nibble2)
		
	static func get_nibbles(x):
		var nibble1 = (x & 0x0F)
		var nibble2 = ((x & 0xF0) >> 4)
		return [nibble1, nibble2]
	
	static func signed_to_unsigned(value):
		if value < 0:
			return value + (128*2)
			
		return value
	
	static func cast(data, width, height, flags, format):
		var return_data = []
		
		var processors = load('res://Src/Processors/processors.gd').Processors.new()
		
		return_data = processors.process(data, width, height, flags, format)
#
#		if format == Formats.IDX_4_A_4:
#
#			var previous_pixel = 0
#			var read_alpha = false
#			var adjust_half_res = false
#
#			var pos = 0
#			var full_size = len(data)
#			var size = full_size / 2
#
#			var data_b = data.slice(size, full_size)
#
#			var slice_w = width# / 2
#			var slice_h = height# / 2
#
#			if flags & TextureFormat.FLAG_HALF_RES:
#				slice_w = width / 4
#				slice_h = height / 2
#
#			var image1 = Image.new()
#			image1.create_from_data(slice_w, slice_h, false, Image.FORMAT_R8, data_b)
#			image1.save_png("./dump.png")
#
#			while pos < size:# - 1:
#				var pixel = data[pos]
#				#var pixel2 = data_b[pos]
#
#				return_data.append(pixel) # R
#				return_data.append(pixel) # G
#				return_data.append(pixel) # B
#				return_data.append(255) # A
#
#				if flags & TextureFormat.FLAG_HALF_RES:
#					return_data.append(pixel) # R
#					return_data.append(pixel) # G
#					return_data.append(pixel) # B
#					return_data.append(255) # A
#				# End If
#
#				return_data.append(pixel) # R
#				return_data.append(pixel) # G
#				return_data.append(pixel) # B
#				return_data.append(255) # A
##
#				if flags & TextureFormat.FLAG_HALF_RES:
#					return_data.append(pixel) # R
#					return_data.append(pixel) # G
#					return_data.append(pixel) # B
#					return_data.append(255) # A
#				# End If
#
#				return_data.append(pixel) # R
#				return_data.append(pixel) # G
#				return_data.append(pixel) # B
#				return_data.append(255) # A
##
#				if flags & TextureFormat.FLAG_HALF_RES:
#					return_data.append(pixel) # R
#					return_data.append(pixel) # G
#					return_data.append(pixel) # B
#					return_data.append(255) # A
#				# End If
#
#				return_data.append(pixel) # R
#				return_data.append(pixel) # G
#				return_data.append(pixel) # B
#				return_data.append(255) # A
##
#				if flags & TextureFormat.FLAG_HALF_RES:
#					return_data.append(pixel) # R
#					return_data.append(pixel) # G
#					return_data.append(pixel) # B
#					return_data.append(255) # A
#				# End If
#
#				pos += 1
#			# End While
#
#		# 1024 byte palette - 4 bytes each, 256 entries
#		elif format == Formats.IDX_8_ABGR_8888:
#			var palette_img = Image.new()
#			var palette = []
#			var palette_stream = StreamPeerBuffer.new()
#			var size = width * height
#			var data_len = len(data)
#			var pos = 0
#
#			while pos < 1024:
#				palette.append(data[pos])
#				pos += 1
#			# End While
#
#			pos = 0
#
#			palette_stream.set_data_array(palette)
#			palette = []
#
#			palette_stream.seek(0)
#
#			while pos < 256:
#
#				palette.append(palette_stream.get_8())
#				palette.append(palette_stream.get_8())
#				palette.append(palette_stream.get_8())
#				palette_stream.get_8()
#				palette.append(255) # Alpha
#				pos += 1
#			# End While
#
#			palette_img.create_from_data(64, 4, false, Image.FORMAT_RGBA8, palette)
#			palette_img.save_png("./palette.png")
#
#			pos = 1024
#			var current_pos = 0
#			while pos < data_len:
#				palette_stream.seek(0)
#
#				if current_pos == 128:
#					pass
#
#				var index = data[pos]
#				palette_stream.seek(index * 4)
#
#				var r = TextureFormat.signed_to_unsigned(palette_stream.get_8())
#				var g = TextureFormat.signed_to_unsigned(palette_stream.get_8())
#				var b = TextureFormat.signed_to_unsigned(palette_stream.get_8())
#				var a = TextureFormat.signed_to_unsigned(palette_stream.get_8())
#
#				a = 255
#
#				return_data.append( r )
#				return_data.append( g )
#				return_data.append( b )
#				return_data.append( a )
#
#				pos += 1
#				current_pos += 1
#			# End While
#		# End If
		
		var image = Image.new()
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, return_data)
		#image.resize(width, height, Image.INTERPOLATE_NEAREST)
		image.save_png("./dump.png")
		
		return return_data
	# End Func
# End Class

class Textures:
	var texture = null
	
	func read_texture(f : File, width, height, flags, format):
		var read_width = width
		var read_height = height
		var bytes = 1
		
		var tex_data = []
		if flags & Constants.Tex_Flags.HALF_RES:
			read_width /= 2
			read_height /= 2
		
		#if flags & TextureFormat.FLAG_HAS_ALPHA:
		#	bytes += 1
		# End If
		

		
		var read = read_width * read_height * bytes
		
		# Include the palette
		if format == Constants.Tex_Formats.IDX_8_ABGR_8888:
			read += 1024
		
		if !f.endian_swap:
			tex_data = Array(f.get_buffer(read))
		else:
			for _i in range(read):
				tex_data.append(TextureFormat.flip_byte(f.get_8()))
			# End For
		# End If

		var tex_data_rgb888a = TextureFormat.cast(tex_data, width, height, flags, format)
		
		var image = Image.new()
		#image.create_from_data(width, height, false, Image.FORMAT_R8, tex_data)
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, tex_data_rgb888a)
		image.save_png("./texture_test.png")
		
		return tex_data_rgb888a
	# End Func
		
	enum IMPORT_RETURN{SUCCESS, ERROR}

	func read(f : File, rom_tex):
		var size = rom_tex.size
		var width = rom_tex.width
		var height = rom_tex.height
		var format = rom_tex.format
		var flags = rom_tex.flags
		
		f.seek(rom_tex.tex_data_pointer)
		
		self.texture = read_texture(f, width, height, flags, format)
		
		return self._make_response(IMPORT_RETURN.SUCCESS)
	# End Func
	
	#
	# Helpers
	# 
	func _make_response(code, message = ''):
		return { 'code': code, 'message': message }
	# End Func
# End Class
