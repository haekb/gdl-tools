class Texture_Unk_Dreamcast:
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
	
	static func process2(data, width, height, flags):
		var data_len = len(data)
		var image_data = []
		
		var image = Image.new()
		image.create_from_data(width, height, false, Image.FORMAT_RGB8, data)
		image.save_png("./dreamcast.png")
		
		return image
		
		#while i < data_len - 2:
		#	image_data.append(data[i])
	
	static func get_mipmap_count(width):
		var current_width = width
		var mip_count = 0
		while ( current_width > 0 ):
			mip_count += 1
			current_width /= 2
		# End While
		return mip_count
	# End Func
	
	static func process(data, width, height, flags, options = []):
		var data_len = len(data)
		var image_data = []
		
		for _i in range(width * height * 4):
			image_data.append(0)
		# End For
		
		var has_mipmaps = Constants.DC_Tex_Attributes.Twiddled_MipMaps
		var mipmaps = 1
		
		var is_twiddled = Constants.DC_Tex_Attributes.Twiddled || Constants.DC_Tex_Attributes.Twiddled_MipMaps || Constants.DC_Tex_Attributes.Twiddled_Non_Square
		var is_compressed = false
		
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
		var processed = 0
		
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
