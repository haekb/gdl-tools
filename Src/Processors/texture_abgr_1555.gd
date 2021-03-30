class Texture_ABGR_1555:
	static func process(data, width, height, flags):
		var data_len = len(data)
		var image_data = []
		
		var working_width = width * 2
		var working_height = height
		
		# Original width/height
		var full_width = width
		var full_height = height
		
		var repeated_line = false
		var y = 0

		# Data is two bytes, so we need to collect two bytes
		# Data's stride is also width * 2
		var short = []
		while y < working_height:
			for x in range(working_width):
				var pixel = data[ y * working_width + x ]
				
				short.append(pixel)
				
				if len(short) == 2:
					var packed_short = short[1] * 256 + short[0]

					var a = (packed_short & 0x8000) >> 15
					var b = (packed_short & 0x7C00) >> 10
					var g = (packed_short & 0x3E0) >> 5
					var r = (packed_short) & 0x1F
					
					# We also need to expand it to 8-bit
					image_data.append(r << 3)
					image_data.append(g << 3)
					image_data.append(b << 3)
					
					if !(flags & Constants.Tex_Flags.HAS_ALPHA):
						image_data.append(255)
					else:
						if a > 0:
							image_data.append(255)
						else:
							image_data.append(0)

					
					short = []
			# End For
			y += 1
		# End While

		return image_data
	# End Func
# End Class
