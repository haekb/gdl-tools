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
	
	static func process(data, width, height, flags):
		var data_len = len(data)
		var image_data = []
		var palette = []
		
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
		
		palette = process_palette(palette)
		
		pos = palette_size
		while pos < data_len:
			var index = data[pos]
			var palette_set = palette[ index ]
			
			if !has_alpha:
				palette_set[3] = 255
			
			var r = signed_to_unsigned(palette_set[0])
			var g = signed_to_unsigned(palette_set[1])
			var b = signed_to_unsigned(palette_set[2])
			var a = signed_to_unsigned(palette_set[3])

			image_data.append(r)
			image_data.append(g)
			image_data.append(b)
			image_data.append(a)
			
			pos += 1
		# End While

		return image_data
	# End Func
# End Class
