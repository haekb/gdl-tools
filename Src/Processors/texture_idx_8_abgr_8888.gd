class Texture_IDX_8_ABGR_8888:
	const palette_size = 1024
	
	static func signed_to_unsigned(value):
		if value < 0:
			return value + (128*2)

		return value
		
	# Via https://github.com/TGEnigma/Amicitia/blob/35b1615c74ae3c3f9dd8dcf17f08ea0c0b7fdf3b/Source/AmicitiaLibrary/PS2/Graphics/PS2PixelFormatHelper.cs#L151
	# TODO: Figure out how this actually works...
	static func process_palette(palette):
		var new_palette = []
		for _i in range(len(palette)):
			new_palette.append([])
		var new_index = 0
		var old_index = 0
		for i in range(8):
			for x in range(8):
				new_palette[new_index] = palette[old_index]
				new_index += 1
				old_index += 1
			# End For
			old_index += 8
			for x in range(8):
				new_palette[new_index] = palette[old_index]
				new_index += 1
				old_index += 1
			# End For
			old_index -= 16
			for x in range(8):
				new_palette[new_index] = palette[old_index]
				new_index += 1
				old_index += 1
			# End For
			old_index += 8
			for x in range(8):
				new_palette[new_index] = palette[old_index]
				new_index += 1
				old_index += 1
			# End For
		# End For
		return new_palette
	
	static func process(data, width, height, flags, options = []):
		var data_len = len(data)
		var image_data = []
		var palette = []
		
		var start = OS.get_ticks_msec()
		var end = OS.get_ticks_msec()
		
		var has_alpha = flags & Constants.Tex_Flags.HAS_ALPHA
		var half_size = flags & Constants.Tex_Flags.HALF_RES
		
		var pos = 0
		var current_set = []
		# Read in the palette (put them into groups of 4)
		while pos < palette_size:
			current_set.append(data[pos])
			pos += 1
			
			if pos % 4 == 0:
				palette.append(current_set)
				current_set = []
		# End While
		
		end = OS.get_ticks_msec()
		
		print("Palette loading :", (end-start))
		start = OS.get_ticks_msec()
		
		palette = process_palette(palette)
		
		end = OS.get_ticks_msec()
		print("Palette processing :", (end-start))
		start = OS.get_ticks_msec()
		
		var big_a = 0
		var small_a = 255
		for item in palette:
			big_a = max(big_a, item[3])
			small_a = min(small_a, item[3])

		end = OS.get_ticks_msec()
		print("Palette min/max :", (end-start))
		start = OS.get_ticks_msec()
		
		pos = palette_size
		while pos < data_len:
			var index = data[pos]
			var palette_set = palette[ index ]
			
			var r = palette_set[0]
			var g = palette_set[1]
			var b = palette_set[2]
			var a = palette_set[3]
			
			if !has_alpha:
				a = 255
			else:
				# http://skygfx.rockstarvision.com/skygfx.html#PS2atest 
				# Alpha textures may need to be doubled
				r = min(r << 1, 255)
				g = min(g << 1, 255)
				b = min(b << 1, 255)
				a = min(a << 1, 255)
			
#			var r = signed_to_unsigned( palette_set[0] )
#			var g = signed_to_unsigned( palette_set[1] )
#			var b = signed_to_unsigned( palette_set[2] )
#			var a = signed_to_unsigned( palette_set[3] )
			#var r = ( palette_set[0] )
			#var g = ( palette_set[1] )
			#var b = ( palette_set[2] )
			#var a = ( palette_set[3] )

			image_data.append(r)
			image_data.append(g)
			image_data.append(b)
			image_data.append(a)
			
			pos += 1
		# End While
		
		end = OS.get_ticks_msec()
		print("Image assembly :", (end-start))

		return image_data
	# End Func
# End Class
