class Texture_IDX_8_ABGR_1555:
	const palette_size = 512
	
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
			
			if pos % 2 == 0:
				palette.append(current_set)
				current_set = []
		# End While
		
		pos = palette_size
		while pos < data_len:
			var index = data[pos]
			var palette_set = palette[ index ]
				
			var packed_short = palette_set[1] * 256 + palette_set[0]

			var a = (packed_short & 0x8000) >> 15
			var b = (packed_short & 0x7C00) >> 10
			var g = (packed_short & 0x3E0) >> 5
			var r = (packed_short) & 0x1F
			
			image_data.append(r << 3)
			image_data.append(g << 3)
			image_data.append(b << 3)
			
			if !has_alpha:
				image_data.append(255)
			else:
				image_data.append(a << 3)
			
			pos += 1
		# End While

		return image_data
	# End Func
# End Class
