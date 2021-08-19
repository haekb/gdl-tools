class Texture_565:
	const TWIDDLE_TABLE_SIZE = 1024
	
	static func untwiddle_value(value):
		var untwiddled = 0
		for i in range(10):
			var shift = int(pow(2, i))
			if (value & shift):
				untwiddled |= (shift << i)
			# End If
		# End For
		
		return untwiddled
	# End Func
	
	static func get_untwiddled_texel_position(x, y):
		var pos = 0
		
		#if (x >= TWIDDLE_TABLE_SIZE || y >= TWIDDLE_TABLE_SIZE):
		pos = untwiddle_value(x) | untwiddle_value(y) << 1
		
		return pos
	
	static func get_mipmap_count(width):
		var current_width = width
		var mip_count = 0
		while ( current_width > 0 ):
			mip_count += 1
			current_width /= 2
		# End While
		return mip_count
	# End Func
	
	static func process(data, rom_tex, options = []):
		var width = rom_tex.width
		var height = rom_tex.height
		var flags = rom_tex.flags
		var attributes = rom_tex.attributes
		
		var data_len = len(data)
		var image_data = []
		
		for _i in range(width * height * 4):
			image_data.append(0)
		# End For

		var mipmaps = 1
		var has_mipmaps = false
		var is_twiddled = false
		var is_compressed = false
		var palette_size = 0

		if attributes & Constants.DC_Tex_Attributes.TWIDDLED:
			is_twiddled = true
		elif attributes & Constants.DC_Tex_Attributes.TWIDDLED_MM:
			is_twiddled = true
			has_mipmaps = true
		elif attributes & Constants.DC_Tex_Attributes.PALETTIZE4:
			palette_size = 8
		elif attributes & Constants.DC_Tex_Attributes.PALETTIZE4_MM:
			palette_size = 4
			has_mipmaps = true
		elif attributes & Constants.DC_Tex_Attributes.PALETTIZE8:
			palette_size = 8
		elif attributes & Constants.DC_Tex_Attributes.PALETTIZE8_MM:
			palette_size = 8
			has_mipmaps = true
		elif attributes & Constants.DC_Tex_Attributes.TWIDDLED_RECTANGLE:
			is_twiddled = true
		elif attributes & Constants.DC_Tex_Attributes.TWIDDLED_MM_ALIAS:
			is_twiddled = true
		
		if has_mipmaps:
			mipmaps = get_mipmap_count(width)
		# End If
		
		var current_pos = 0
		
		var mip_width = 0
		var mip_height = 0
		var mip_size = 0
		
		# Skip past mipmaps
		while mipmaps > 0:
			mipmaps -= 1
			
			if mipmaps == 0:
				mip_width = width
				mip_height = height
			else:
				mip_width = (width >> (mipmaps - 1))
				mip_height = (height >> (mipmaps - 1))
			mip_size = mip_width * mip_height
			
			if mipmaps > 0:
				current_pos += 2 * mip_size
			elif has_mipmaps:
				current_pos += 2 # Skip 1x1
			# End If
		# End While
			
		var x = 0
		var y = 0
		var processed = current_pos
		
#		# HACK
#		var packed_shorts = []
#		var short = []
#		for pixel in range(width*height):
#			short.append(pixel)
#
#			if len(short) == 2:
#				var packed_short = short[1] * 256 + short[0]
#				packed_shorts.append(packed_short)
#				short = []
#		# End For
#		# END HACK

		var palette = []
		if palette_size > 0:
			var buffer = StreamPeerBuffer.new()
			buffer.data_array = data
			
			if palette_size == 4:
				for p_x in range(16):
					for p_y in range(16):
						var pos = get_untwiddled_texel_position(p_x, p_y)
						
						buffer.seek(pos)
						var rgb = Helpers.stub(buffer.get_8())
						var nibbles = Helpers.split_byte(rgb)
						palette.append(nibbles[0])
						palette.append(nibbles[1])
					# End For
				# End For
				buffer.seek(256) # End of palette
			else:
				for p_x in range(16):
					for p_y in range(16):
						var pos = get_untwiddled_texel_position(p_x, p_y)
						var rgb = data[pos]
						palette.append(rgb)
				# End For
				buffer.seek(256) # End of palette
			# End If
			
			image_data = []
			while processed < mip_size:
				var index = Helpers.stub(buffer.get_8())
				var src_texel = palette[index]
				
				var a = 255
				var r = (src_texel & 0xF800) >> 8
				var g = (src_texel & 0x07E0) >> 3
				var b = (src_texel & 0x001F) << 3
				
				image_data.append(r)
				image_data.append(g)
				image_data.append(b)
				image_data.append(a)
				
				processed += 1
		else:
			var src_pos = 0
			while processed < mip_size:
				
				var dest_pos = 0
				var src_texel = 0
				
				if !is_compressed:
					x = processed % mip_width
					y = processed / mip_width
					
					if is_twiddled:
						src_pos = get_untwiddled_texel_position(x, y)
					# End If
					
					# HACK!
					if (len(data)-1 < src_pos):
						break
					
					if len(palette) > 0:
						var bytes = Helpers.split_short(palette[src_pos])
						
						src_texel = palette[src_pos]
					else:
						src_texel = data[src_pos]
					
					if !is_twiddled:
						src_pos += 1

					# ABGR_1555
	#				var r = src_texel & 0x7C00 >> 7
	#				var g = src_texel & 0x03E0 >> 2
	#				var b = src_texel & 0x001F << 3
	#
	#				var a = 0
	#				if (src_texel & 0x8000):
	#					a = 255
					# End If
					
					# RGB565
					var a = 255
					var r = (src_texel & 0xF800) >> 8
					var g = (src_texel & 0x07E0) >> 3
					var b = (src_texel & 0x001F) << 3
					
					dest_pos = processed * 4
					
					image_data[dest_pos] = r
					image_data[dest_pos + 1] = g
					image_data[dest_pos + 2] = b
					image_data[dest_pos + 3] = 255
				# End If
				
				processed += 1
				# End If
			# End While

		var image = Image.new()
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, image_data)
		image.save_png("./dreamcast.png")
	

		return image_data
	# End Func
# End Class
